module AnalyticMathLabSurrogateExt
using AnalyticMathLab, Lux, Optimization, NeuralOperators
const A=AnalyticMathLab

function learning_model(d,network;rng,normalization::Symbol,rng_provenance)
    normalization in (:none,:train_minmax) || throw(ArgumentError("choose explicit normalization=:none or :train_minmax"))
    d.kind==:operator && !(network isa NeuralOperators.DeepONet) && throw(ArgumentError("operator route currently requires public NeuralOperators.DeepONet"))
    d.kind==:surrogate && network isa NeuralOperators.DeepONet && throw(ArgumentError("DeepONet requires a function dataset"))
    norms=map((:inputs,:coordinates,:outputs)) do field
        n=A.fit_scaling(d,field)
        normalization==:none ? A.AffineScaling(zeros(length(n.offset)),ones(length(n.scale)),n.fitted_ids,field) : n
    end
    z=(inputs=norms[1],coordinates=norms[2],outputs=norms[3],method=normalization)
    ps,st=Lux.setup(rng,network)
    ps=Lux.f64(ps); st=Lux.testmode(st)
    schema=deepcopy((kind=d.kind,family=d.family,input_names=d.input_names,coordinate_names=d.coordinate_names,
        domain=d.domain,sensors=d.sensors,units=d.units,grid=d.grid))
    provenance=(rng=rng_provenance,packages=(Lux=pkgversion(Lux),NeuralOperators=pkgversion(NeuralOperators),Optimization=pkgversion(Optimization)),
        output_order=:query_columns,precision=:Float64,device=:CPU,resampling=:none,discretization_invariance=:not_established)
    m=A.ScientificModel(d.kind==:surrogate ? :coordinate_network : :deeponet,network,ps,st,schema,z,provenance)
    s=first(filter(s->s.split==:training,d.samples))
    predict(m,s.input,s.coordinates)
    m
end
function _network_input(m,input,q)
    b=A.transform(m.normalization.inputs,reshape(input,:,1))
    t=A.transform(m.normalization.coordinates,q)
    m.architecture==:deeponet ? (b,t) : vcat(repeat(b,1,size(q,2)),t)
end
function predict(m,input,q;sensors=m.schema.sensors)
    A.classify_query(m,input,q;sensors)
    y,st=Lux.apply(m.network,_network_input(m,input,q),m.parameters,m.state)
    isequal(st,m.state) || throw(ArgumentError("state-changing networks unsupported; use deterministic stateless layers"))
    expected=m.architecture==:deeponet ? (size(q,2),1) : (1,size(q,2))
    size(y)==expected || throw(DimensionMismatch("backend output must be $expected"))
    all(isfinite,y) || throw(DomainError(y,"nonfinite prediction"))
    vec(y).*only(m.normalization.outputs.scale).+only(m.normalization.outputs.offset)
end
function training_data(m,d)
    isequal(m.schema,(kind=d.kind,family=d.family,input_names=d.input_names,coordinate_names=d.coordinate_names,
        domain=d.domain,sensors=d.sensors,units=d.units,grid=d.grid)) || throw(ArgumentError("dataset scientific schema differs from model"))
    ss=filter(s->s.split==:training,d.samples)
    [s.id for s in ss]==m.normalization.inputs.fitted_ids || throw(ArgumentError("training IDs changed after preprocessing"))
    if m.architecture==:deeponet
        q=first(ss).coordinates
        all(s->s.coordinates==q,ss) || throw(ArgumentError("batched operator training requires identical query grids; no resampling"))
        x=(A.transform(m.normalization.inputs,hcat((s.input for s in ss)...)),A.transform(m.normalization.coordinates,q))
        y=hcat((s.values for s in ss)...)
        y=(y.-only(m.normalization.outputs.offset))./only(m.normalization.outputs.scale)
    else
        x=hcat((_network_input(m,s.input,s.coordinates) for s in ss)...)
        y=A.transform(m.normalization.outputs,reshape(vcat((s.values for s in ss)...),1,:))
    end
    A.LearningBatch(x,y,[s.id for s in ss])
end
function learning_objective(m,p,b)
    y,_=Lux.apply(m.network,b.inputs,p,m.state)
    sum(abs2,y.-b.targets)/length(b.targets)
end
function train(m,d;initial_parameters::AbstractVector,optimizer,adtype,maxiters::Integer,
        reconstruct=identity,history_limit::Integer=100)
    1<=maxiters<=100000 && 1<=history_limit<=10000 || throw(ArgumentError("bounded positive training/history limits required"))
    all(isfinite,initial_parameters) && !isempty(initial_parameters) || throw(ArgumentError("finite parameters required"))
    b=training_data(m,d) # snapshot containing training inputs and targets ONLY
    loss=(v,_)->learning_objective(m,reconstruct(v),b)
    initial=loss(initial_parameters,nothing)
    isfinite(initial) || throw(ArgumentError("nonfinite initial loss"))
    history=Float64[]
    callback=(state,l)->begin
        isfinite(l) || throw(ErrorException("nonfinite training objective"))
        length(history)==history_limit && popfirst!(history)
        push!(history,Float64(l)); false
    end
    problem=Optimization.OptimizationProblem(Optimization.OptimizationFunction(loss,adtype),copy(initial_parameters))
    started=time_ns()
    sol=Optimization.solve(problem,optimizer;maxiters,callback)
    elapsed=(time_ns()-started)/1e9
    fitted=A.ScientificModel(m.architecture,m.network,reconstruct(sol.u),m.state,m.schema,m.normalization,m.provenance)
    final=loss(sol.u,nothing)
    isfinite(final) || throw(ErrorException("nonfinite final objective"))
    timing=(optimization_seconds=elapsed,compilation=:included_if_not_precompiled,preprocessing_included=false)
    A.ScientificLearningResult(fitted,d,problem,sol,optimizer,history,
        (initial=Float64(initial),final=Float64(final),normalization=:scaled_mean_squared_error),m.normalization,timing,
        A.PropertyResult(nothing,:unknown,:global_generalization_not_established,["Optimizer termination is not generalization evidence."]),
        (training_ids=b.ids,reference_used_in_objective=false,heldout_used_in_objective=false,
         batching=:deterministic_full_batch,adtype=adtype,maxiters=maxiters,termination=sol.retcode,
         rng=m.provenance.rng,history_limit=history_limit))
end
end
