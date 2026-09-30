"""Full model parameter order with an explicit ordered inferred subset.
Bounds, if supplied, are in inferred order. No positivity or transforms are invented.
"""
struct InferenceParameters
    names::Tuple
    initial::Vector{Float64}
    inferred::Tuple
    indices::Vector{Int}
    bounds
    units
    provenance
    function InferenceParameters(names,initial;inferred,bounds=nothing,units=nothing,
            provenance=NamedTuple())
        ns=Tuple(string.(names)); ins=Tuple(string.(inferred))
        length(ns)==length(initial) || throw(DimensionMismatch("one initial value per full model parameter"))
        !isempty(ins) && length(unique(ins))==length(ins) && length(unique(ns))==length(ns) ||
            throw(ArgumentError("unique parameter identities and nonempty inferred subset required"))
        all(n->n in ns,ins) || throw(ArgumentError("unknown inferred parameter name"))
        all(x->x isa Real && isfinite(x),initial) || throw(ArgumentError("finite numeric initial parameters required"))
        init=Float64.(initial); all(isfinite,init) || throw(ArgumentError("parameters not representable in Float64"))
        ids=Int[findfirst(==(n),ns) for n in ins]
        b=if bounds===nothing
            nothing
        else
            length(bounds)==2 && all(x->length(x)==length(ins),bounds) || throw(DimensionMismatch("bounds must be (lower,upper) in inferred order"))
            lo,hi=Float64.(bounds[1]),Float64.(bounds[2])
            all(i->!isnan(lo[i]) && !isnan(hi[i]) && lo[i]<hi[i] && lo[i]<=init[ids[i]]<=hi[i],eachindex(ids)) ||
                throw(ArgumentError("ordered bounds containing initial estimate required"))
            (lo,hi)
        end
        new(ns,init,ins,ids,b,units,provenance)
    end
end

function _inference_parameters(spec,theta)
    length(theta)==length(spec.indices) || throw(DimensionMismatch("inferred parameter dimension mismatch"))
    [begin j=findfirst(==(i),spec.indices); j===nothing ? oftype(first(theta),spec.initial[i]) : theta[j] end
        for i in eachindex(spec.initial)]
end

"""M6 model factory + observations, retaining the initial M6 object and native ODEProblem.
`factory(full_parameters)` must return the same ordered FirstOrderODE for every call.
This explicit parameter binding does not alter M6's Float64 trajectory contract.
"""
struct ParameterInferenceProblem <: AbstractAnalysis
    factory
    model::FirstOrderODE
    native_problem
    parameters::InferenceParameters
    observations::ObservationSet
    heldout
    indices::Vector{Int}
    solver
    reference
    provenance
end

function ParameterInferenceProblem(factory,spec::InferenceParameters,obs::ObservationSet;
        u0,tspan,heldout=nothing,algorithm=OrdinaryDiffEqTsit5.Tsit5(),
        abstol=1e-10,reltol=1e-9,maxiters=100_000,reference=nothing,provenance=NamedTuple())
    model=factory(copy(spec.initial))
    model isa FirstOrderODE || throw(ArgumentError("factory must return the existing M6 FirstOrderODE"))
    length(unique(model.labels))==model.dimension || throw(ArgumentError("unique state labels required"))
    all(x->x in model.labels,obs.variables) || throw(ArgumentError("observation variable not in model labels"))
    obs.role==:fit || throw(ArgumentError("objective observations must have role=:fit"))
    length(tspan)==2 && all(isfinite,tspan) && tspan[1]<tspan[2] || throw(ArgumentError("increasing finite tspan required"))
    all(x->isfinite(x) && x>0,(abstol,reltol)) && maxiters>0 || throw(ArgumentError("positive solver controls required"))
    initial=Float64.(u0)
    length(initial)==model.dimension || throw(DimensionMismatch("initial state dimension mismatch"))
    all(isfinite,initial) || throw(ArgumentError("finite initial state required"))
    ids=Int[findfirst(==(v),model.labels) for v in obs.variables]
    all(t->tspan[1]<=t<=tspan[2],obs.times) || throw(ArgumentError("fit times outside tspan"))
    if heldout!==nothing
        heldout isa ObservationSet && heldout.role==:heldout || throw(ArgumentError("heldout must explicitly have role=:heldout"))
        heldout.variables==obs.variables && isequal(heldout.units,obs.units) || throw(ArgumentError("heldout variable order and units must match fit data"))
        isempty(intersect(obs.times,heldout.times)) || throw(ArgumentError("heldout times must be excluded from objective"))
        all(t->tspan[1]<=t<=tspan[2],heldout.times) || throw(ArgumentError("heldout times outside tspan"))
    end
    if reference!==nothing
        reference.kind in (:synthetic_truth,:user_reference) || throw(ArgumentError("explicit reference kind required"))
        length(reference.values)==length(spec.indices) && all(isfinite,reference.values) || throw(ArgumentError("reference values must follow inferred parameter order"))
        reference.kind==:synthetic_truth && obs.kind!=:synthetic && throw(ArgumentError("synthetic truth requires synthetic observations"))
    end
    function rhs(u,p,t)
        m=factory(p)
        m isa FirstOrderODE && m.dimension==model.dimension && m.labels==model.labels || throw(ArgumentError("factory changed model state ordering"))
        m.domain(u,t)===true || throw(DomainError((u,t),"M6 domain check failed"))
        y=m.function_value(u,t)
        y isa Union{Tuple,AbstractVector} && length(y)==model.dimension || throw(DimensionMismatch("M6 RHS dimension changed"))
        all(isfinite,y) || throw(DomainError(y,"nonfinite M6 RHS"))
        collect(y)
    end
    native=SciMLBase.ODEProblem{false}(rhs,initial,Tuple(Float64.(tspan)),copy(spec.initial))
    rhs(initial,native.p,first(tspan))
    solver=(algorithm=algorithm,abstol=Float64(abstol),reltol=Float64(reltol),maxiters=Int(maxiters),
        sensitivity=:direct_forwarddiff_through_solve,ad_backend=:ForwardDiff)
    ParameterInferenceProblem(factory,model,native,spec,obs,heldout,ids,solver,reference,provenance)
end

function _inference_solve(p,theta,times)
    all(isfinite,theta) || throw(ArgumentError("finite parameters required"))
    full=_inference_parameters(p.parameters,theta)
    native=SciMLBase.remake(p.native_problem;p=full,u0=oftype.(Ref(first(full)),p.native_problem.u0))
    c=p.solver
    sol=SciMLBase.solve(native,c.algorithm;abstol=c.abstol,reltol=c.reltol,maxiters=c.maxiters,
        saveat=times,dense=false,save_everystep=false,
        save_start=first(times)==first(native.tspan),save_end=last(times)==last(native.tspan))
    SciMLBase.successful_retcode(sol) && length(sol.t)==length(times) && sol.t==times ||
        throw(ErrorException("forward solve failed or incomplete: $(sol.retcode)"))
    sol
end

"""Solve explicitly at supplied observations; variable order must match the fit set."""
function inference_predict(p::ParameterInferenceProblem,theta,obs::ObservationSet=p.observations)
    obs.variables==p.observations.variables && isequal(obs.units,p.observations.units) || throw(ArgumentError("prediction variable order/units mismatch"))
    all(t->p.native_problem.tspan[1]<=t<=p.native_problem.tspan[2],obs.times) || throw(ArgumentError("prediction times outside tspan"))
    Array(_inference_solve(p,theta,obs.times))[p.indices,:]
end

"""Weighted or unweighted sum of squared residuals; not a likelihood."""
function inference_objective(p::ParameterInferenceProblem,theta)
    residual=inference_predict(p,theta).-p.observations.values
    w=p.observations.weights
    w===nothing ? sum(abs2,residual) : sum(w.*abs2.(residual))
end

"""Local observation Jacobian/SVD in physical inferred-parameter order.
Conditioning depends on parameter units/scales; no global identifiability claim.
Rank threshold is `rank_atol + rank_rtol * maximum(singular_values)`.
"""
function local_sensitivity(p::ParameterInferenceProblem,theta;rank_rtol=1e-8,rank_atol=0.)
    all(x->isfinite(x) && x>=0,(rank_rtol,rank_atol)) || throw(ArgumentError("nonnegative finite rank tolerances required"))
    J=ForwardDiff.jacobian(x->vec(inference_predict(p,x)),collect(theta))
    weighted=p.observations.weights===nothing ? J : sqrt.(vec(p.observations.weights)).*J
    decomposition=LinearAlgebra.svd(weighted;full=false)
    s=decomposition.S; threshold=rank_atol+rank_rtol*maximum(s)
    rank=count(>(threshold),s); n=length(theta)
    norms=sqrt.(vec(sum(abs2,weighted;dims=1)))
    cosines=[norms[i]>0 && norms[j]>0 ? LinearAlgebra.dot(weighted[:,i],weighted[:,j])/(norms[i]*norms[j]) : NaN for i in 1:n,j in 1:n]
    PropertyResult((jacobian=J,weighted_jacobian=weighted,singular_values=s,rank=rank,
        threshold=threshold,rank_rtol=rank_rtol,rank_atol=rank_atol,
        condition=rank==n ? maximum(s)/minimum(s) : Inf,right_vectors=decomposition.V,
        column_cosines=cosines,parameter_order=p.parameters.inferred,
        observation_order=:column_major_variables_within_time),:heuristic,:local_forwarddiff_svd,
        ["Local, unit/scale-dependent sensitivity only; not global or structural identifiability.",
         "Column cosines measure sensitivity collinearity, not posterior parameter correlations."])
end

"""Stored deterministic inference evidence and native backend objects.
Read-only by convention. Objective history never retains intermediate trajectories.
"""
struct ParameterInferenceResult <: AbstractAnalysis
    problem::ParameterInferenceProblem
    optimization_problem
    solution
    parameters
    full_parameters
    trajectory
    prediction
    fit
    heldout
    sensitivity::PropertyResult
    reference_comparison
    history
    termination
    optimizer
    objective
    evidence::PropertyResult
    provenance
    limitations::Vector{String}
end

"""Fit explicit physical parameters with Optimization.jl (optional; no NeuralPDE required)."""
function infer_parameters(p::ParameterInferenceProblem,optimizer;kwargs...)
    ext=Base.get_extension(@__MODULE__,:AnalyticMathLabInferenceExt)
    ext===nothing && throw(ArgumentError("load Optimization to activate deterministic parameter inference"))
    ext.infer_parameters(p,optimizer;kwargs...)
end
