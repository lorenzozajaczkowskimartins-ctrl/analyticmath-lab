module AnalyticMathLabPINNExt
import AnalyticMathLab as AML
import Lux, NeuralPDE, ModelingToolkit, Optimization, SymbolicIndexingInterface
import Random
import AnalyticMathLab: Symbolics, SciMLBase
const MTK=ModelingToolkit
const SII=SymbolicIndexingInterface

function pinn_network(input_dim::Integer,output_dim::Integer;hidden=[32,32],activation=tanh)
    input_dim>0 && output_dim>0 || throw(ArgumentError("network dimensions must be positive"))
    all(n->n isa Integer && n>0,hidden) || throw(ArgumentError("hidden widths must be positive integers"))
    dims=[input_dim;collect(hidden);output_dim]
    Lux.Chain((Lux.Dense(dims[i]=>dims[i+1],i==length(dims)-1 ? identity : activation)
        for i in 1:length(dims)-1)...)
end

_same_symbol(a,b)=isequal(Symbolics.unwrap(a),Symbolics.unwrap(b))
function pinn_problem(system::MTK.PDESystem;network,strategy,rng::Random.AbstractRNG,adtype,
        network_layout=:auto,derivative=NeuralPDE.FiniteDifferenceDerivative(),
        additional_loss=nothing,param_estim::Bool=false,eval_points::Integer=32,optimization_options=NamedTuple(),
        provenance=NamedTuple())
    ivs=collect(MTK.get_ivs(system)); dvs=collect(MTK.get_dvs(system))
    isempty(ivs) && throw(ArgumentError("at least one independent variable is required"))
    isempty(dvs) && throw(ArgumentError("at least one dependent variable is required"))
    strategy isa NeuralPDE.AbstractTrainingStrategy || throw(ArgumentError("pass a NeuralPDE training strategy"))
    eval_points>=2 || throw(ArgumentError("eval_points must be at least two"))
    network_layout in (:auto,:shared,:separate) || throw(ArgumentError("network_layout must be :auto, :shared or :separate"))
    length(dvs)>1 && network_layout==:auto && throw(ArgumentError("multiple dependent variables require explicit network_layout=:shared or :separate"))
    separate=network_layout==:separate || (network_layout==:auto && network isa AbstractVector)
    nets=separate ? (network isa AbstractVector ? collect(network) : throw(ArgumentError("separate layout requires a vector of Lux models"))) : [network]
    length(nets)==(separate ? length(dvs) : 1) || throw(DimensionMismatch("one network per dependent variable required"))
    all(n->n isa Lux.AbstractLuxLayer,nets) || throw(ArgumentError("networks must be genuine Lux layers"))
    args=[collect(Symbolics.arguments(Symbolics.unwrap(dv))) for dv in dvs]
    indices=map(args) do aa
        ids=[findfirst(v->_same_symbol(v,a),ivs) for a in aa]
        isempty(ids) && throw(ArgumentError("dependent variables must have scalar independent-variable arguments"))
        any(isnothing,ids) && throw(ArgumentError("each dependent-variable argument must be a declared scalar independent variable; array/compound arguments are not supported in M9A"))
        length(unique(ids))==length(ids) || throw(ArgumentError("repeated dependent-variable arguments are unsupported"))
        Int[ids...]
    end
    !separate && !all(==(first(indices)),indices) && throw(ArgumentError("a shared network requires identical ordered dependent-variable arguments"))
    params=Any[]; states=Any[]
    for (i,net) in enumerate(nets)
        ps,st=Lux.setup(rng,net)
        Lux.statelength(st)==0 || throw(ArgumentError("NeuralPDE 7.3 uses stateless_apply: stateful Lux layers are unsupported, not silently frozen or discarded"))
        ps=Lux.f64(ps)
        n_in=length(indices[separate ? i : 1]); n_out=separate ? 1 : length(dvs)
        y,newstate=Lux.apply(net,zeros(Float64,n_in,2),ps,deepcopy(st))
        y isa Matrix && size(y)==(n_out,2) || throw(DimensionMismatch("network must return $(n_out) × batch outputs for $(n_in) coordinates"))
        all(isfinite,y) || throw(ArgumentError("network must produce finite outputs at the dimension-check probe"))
        isequal(st,newstate) || throw(ArgumentError("network changes state; current NeuralPDE PINN path requires stateless models"))
        push!(params,ps); push!(states,st)
    end
    disc=NeuralPDE.PhysicsInformedNN(separate ? nets : only(nets),strategy;
        init_params=separate ? params : only(params),rng,derivative,additional_loss,param_estim,eval_points=Int(eval_points))
    # Discretize ONCE: it calls symbolic_discretize and retains that exact System.
    # A second symbolic_discretize call could draw different parameters/collocation points.
    opt=NeuralPDE.discretize(system,disc;adtype,optimization_options...)
    md=NeuralPDE.pinn_metadata(opt)
    symbolic=opt.f.sys
    costs=MTK.get_costs(symbolic)
    length(costs)==length(md.blocks)+(additional_loss===nothing ? 0 : 1) ||
        throw(ArgumentError("backend cost layout is unsupported; cannot label components safely"))
    components=NamedTuple[(kind=b.kind,equation=b.eq,expression=costs[i],residual=b.residual)
        for (i,b) in enumerate(md.blocks)]
    additional_loss===nothing || push!(components,(kind=:additional,equation=nothing,expression=last(costs),residual=nothing))
    mapping=[(dependent_variable=dvs[i],input_variables=args[i],input_indices=indices[i],
        network_index=separate ? i : 1,output=separate ? 1 : i) for i in eachindex(dvs)]
    versions=(julia=VERSION,AnalyticMathLab=pkgversion(AML),Lux=pkgversion(Lux),
        NeuralPDE=pkgversion(NeuralPDE),ModelingToolkit=pkgversion(MTK),
        Optimization=pkgversion(Optimization),SciMLBase=pkgversion(SciMLBase),
        Symbolics=pkgversion(Symbolics),SymbolicIndexingInterface=pkgversion(SII))
    physical=MTK.get_ps(system)
    declared=physical isa SciMLBase.NullParameters ? [] : collect(physical)
    meta=(packages=versions,rng_type=string(typeof(rng)),initialization=:explicit_rng_consumed,
        precision=:Float64,device=:CPU,network_layout=separate ? :separate : :shared,
        physical_parameters=(param_estim=param_estim,declared=declared,
            inferred=param_estim ? copy(declared) : [],
            selection=:all_declared_or_none,initialization=:pdesystem_initial_conditions),
        adtype=adtype,derivative=derivative,optimization_options=optimization_options,user=provenance)
    AML.PINNProblem(system,ivs,dvs,MTK.get_domain(system),MTK.get_eqs(system),MTK.get_bcs(system),
        nets,mapping,params,states,strategy,disc,symbolic,opt,md,components,meta,
        AML.PropertyResult(true,:established,:backend_construction,
            ["Backend construction and sampled shape checks only; not physical validation.",
             "BC and IC costs share the backend :bc label; no semantic classification is inferred."]))
end
pinn_problem(system;kwargs...)=throw(ArgumentError("pinn_problem requires a ModelingToolkit PDESystem"))

function _record!(h,iteration,objective,components)
    entry=(iteration=Int(iteration),objective=Float64(objective),components=components)
    if !isempty(h.entries) && last(h.entries).iteration==iteration
        h.entries[end]=entry # Some optimizers report their final iteration twice.
    elseif length(h.entries)<h.capacity
        push!(h.entries,entry)
    else
        h.truncated=true
    end
end

function train(p::AML.PINNProblem,optimizer;kwargs...)
    _train(p,p.optimization_problem,optimizer;kwargs...)
end
function train(r::AML.PINNTrainingResult,optimizer;kwargs...)
    continued=SciMLBase.remake(r.optimization_problem;u0=copy(r.parameters))
    _train(r.problem,continued,optimizer;kwargs...)
end
function _train(p,source,optimizer;maxiters::Integer,history::Bool=false,
        log_every::Integer=10,history_capacity::Integer=1000,record_components::Bool=false,
        callback=nothing,kwargs...)
    maxiters>0 || throw(ArgumentError("maxiters must be positive"))
    log_every>0 && history_capacity>0 || throw(ArgumentError("history stride and capacity must be positive"))
    # Solver/callback mutation of its parameters must not modify the construction or
    # an earlier continuation stage. The symbolic system/model is still retained.
    opt=SciMLBase.remake(source;u0=copy(source.u0),p=deepcopy(source.p))
    h=history ? AML.PINNHistory(;stride=log_every,capacity=history_capacity) : nothing
    costs=[c.expression for c in p.loss_components]
    getter=history && record_components ? SII.getu(opt,costs) : nothing
    function observe(state,loss)
        if h!==nothing && (state.iter==1 || state.iter%h.stride==0)
            components=getter===nothing ? nothing : collect(getter(SII.ProblemState(;u=state.u,p=state.p)))
            _record!(h,state.iter,loss,components)
        end
        callback===nothing ? false : callback(state,loss)
    end
    solved=Optimization.solve(opt,optimizer;maxiters,callback=observe,kwargs...)
    # NeuralPDE 7.3 wraps the native OptimizationSolution in a PDE solution.
    native=solved.original_sol
    netparams=map(eachindex(p.networks)) do i
        net=p.backend_metadata.networks[p.provenance.network_layout==:separate ? i : 1]
        NeuralPDE.vector_to_parameters(copy(native[net.θ]),p.initial_parameters[i])
    end
    component_values=collect(native[costs])
    evaluated=opt.f(native.u,opt.p)
    finite=isfinite(native.objective) && isfinite(evaluated) && all(isfinite,component_values)
    losses=AML.PropertyResult((objective=native.objective,evaluated_objective=evaluated,
        components=component_values,definitions=p.loss_components),finite ? :heuristic : :unknown,
        :backend_training_costs,["Components are unweighted backend costs, not independent solution errors.",
            "The optimizer-reported objective and a fresh evaluation at returned parameters are retained separately."])
    termination=(retcode=native.retcode,backend_success=SciMLBase.successful_retcode(native),
        iterations=native.stats.iterations,requested_maxiters=Int(maxiters))
    provenance=(construction=p.provenance,optimizer_type=string(typeof(optimizer)),
        optimizer_module=string(parentmodule(typeof(optimizer))),
        optimizer_package_version=pkgversion(parentmodule(typeof(optimizer))),
        options=(maxiters=maxiters,history=history,log_every=log_every,
            history_capacity=history_capacity,record_components=record_components,solver=(;kwargs...)))
    AML.PINNTrainingResult(p,opt,solved,native,native.u,netparams,deepcopy(p.initial_states),
        h,losses,termination,optimizer,provenance,
        AML.PropertyResult(nothing,:unknown,:physical_validation_not_performed,
            ["Low training loss is not proof of a correct physical solution."]),
        ["Optimizer termination is not physical convergence.",
         "Stateless backend: final Lux states equal the verified empty initial states.",
         "No parameter snapshots or automatic optimizer scheduling."])
end

function predict(r::AML.PINNTrainingResult,x)
    point=x isa Real || x isa Union{AbstractVector,Tuple}
    X=if x isa Real
        reshape([x],1,1)
    elseif x isa Union{Vector,Tuple}
        reshape(collect(x),:,1)
    elseif x isa Matrix
        x
    else
        throw(ArgumentError("prediction requires CPU Vector/Tuple coordinates or a CPU Matrix with one point per column"))
    end
    p=r.problem
    size(X,1)==length(p.independent_variables) || throw(DimensionMismatch("coordinate rows must match stored independent-variable order"))
    all(v->v isa Real && isfinite(v),X) || throw(ArgumentError("coordinates must be finite and real"))
    coords=Float64.(X)
    all(isfinite,coords) || throw(ArgumentError("coordinates must be finite in Float64"))
    values=Matrix{Float64}(undef,length(p.dependent_variables),size(X,2))
    for i in eachindex(p.networks)
        rows=findall(m->m.network_index==i,p.network_mapping)
        m=p.network_mapping[first(rows)]
        output,state=Lux.apply(p.networks[i],coords[m.input_indices,:],r.network_parameters[i],deepcopy(r.states[i]))
        isequal(state,r.states[i]) || throw(ArgumentError("prediction changed Lux state; incompatible stateless backend"))
        size(output)==(length(rows),size(X,2)) || throw(DimensionMismatch("network output shape changed"))
        for row in rows
            values[row,:]=output[p.network_mapping[row].output,:]
        end
    end
    point ? vec(values) : values
end

include("pinn_diagnostics.jl")
end
