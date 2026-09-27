# NeuralPDE public ResidualBlock + SII adapter. No symbolic lowering or AD is duplicated.
# Compiled coordinate arrays have fixed column counts. Pad only the final batch by
# repeating its last point, then discard padding. M9A requires pointwise Lux models.
function _sample_residual(r,b,points)
    X=points.coordinates
    size(X,1)==length(b.ivs) || throw(DimensionMismatch("residual coordinate rows must follow block.ivs"))
    isempty(b.extra_params) || throw(ArgumentError("independent diagnostics for integral residual blocks are not supported"))
    opt=r.optimization_problem
    state=SII.ProblemState(;u=copy(r.parameters),p=deepcopy(SII.parameter_values(r.backend_solution)))
    getter=SII.getu(opt,b.residual)
    setter=b.xs===nothing ? nothing : SII.setp(opt,b.xs)
    n=size(X,2); batch=b.npoints
    batch>0 || throw(ArgumentError("empty backend collocation blocks are unsupported"))
    values=Float64[]
    for start in 1:batch:n
        ids=min.(start:start+batch-1,n)
        setter===nothing || setter(state,X[:,ids])
        raw=vec(collect(getter(state)))
        length(raw)==batch || throw(DimensionMismatch("backend residual must be scalar per collocation point"))
        append!(values,raw[1:min(batch,n-start+1)])
    end
    values
end

function _collocation(r,b)
    X=b.xs===nothing ? zeros(0,1) : Matrix{Float64}(SII.getp(r.optimization_problem,b.xs)(r.backend_solution))
    (coordinates=copy(X),variables=copy(b.ivs),global_indices=copy(b.ivpos),
        bounds=deepcopy(b.bounds),count=size(X,2),dimension=size(X,1),
        duplicate_count=size(X,2)-length(Set(Tuple(col) for col in eachcol(X))),
        kind=b.kind,equation=b.eq,quadrature_weights=b.w===nothing ? nothing :
            copy(SII.getp(r.optimization_problem,b.w)(r.backend_solution)),
        snapshot=:returned_solution_parameters,training_history=:unavailable)
end

function _strategy_metadata(p)
    s=p.strategy
    semantics=s isa NeuralPDE.GridTraining ? :deterministic_grid :
        s isa NeuralPDE.StochasticTraining ? :uniform_random :
        s isa NeuralPDE.QuasiRandomTraining ? :quasi_random_not_iid :
        s isa NeuralPDE.QuadratureTraining ? :quadrature_nodes : :backend_defined
    (strategy=s,type=string(typeof(s)),semantics=semantics,
        rng_type=p.provenance.rng_type,rng_control=s isa NeuralPDE.QuasiRandomTraining ?
            :not_forwarded_to_sampler : :backend_strategy_dependent,
        resampling=:caller_callback_only,domain=p.domains,coverage_claim=:none)
end

function loss_breakdown(r::AML.PINNTrainingResult)
    options=r.problem.provenance.optimization_options
    weights=get(options,:weights,nothing)
    (objective=r.losses.value.objective,evaluated_objective=r.losses.value.evaluated_objective,
        components=r.losses.value.components,definitions=r.problem.loss_components,
        configured_weights=weights===nothing ? ones(length(r.problem.loss_components)) : deepcopy(weights),
        weight_provenance=:construction_configuration,weight_evolution=:not_recorded,
        history=r.history,termination=r.termination,
        interpretation=:training_cost_not_physical_error)
end

function _reference_analysis(r,points,reference,provenance,guard)
    reference===nothing && return AML.PropertyResult(nothing,:unknown,:reference_unavailable,
        ["No reference supplied; residual evidence remains useful."])
    points isa AML.PINNPoints || throw(ArgumentError("reference_points must be explicit PINNPoints"))
    X=points.coordinates
    predictions=predict(r,X)
    cols=[collect(reference(copy(x))) for x in eachcol(X)]
    all(v->length(v)==size(predictions,1),cols) || throw(DimensionMismatch("reference must return one value per dependent variable"))
    ref=reduce(hcat,cols)
    all(x->x isa Real && isfinite(x),ref) || throw(ArgumentError("reference values must be finite real numbers"))
    errors=predictions.-ref
    relative=map(errors,ref) do e,y
        abs(y)>guard && isfinite(e) ? abs(e)/abs(y) : missing
    end
    summary=[AML.sampled_summary(row) for row in eachrow(errors)]
    AML.PropertyResult((points=points,variables=r.problem.independent_variables,
        dependent_variables=r.problem.dependent_variables,prediction=predictions,reference=ref,
        signed_error=errors,absolute_error=abs.(errors),relative_error=relative,
        relative_denominator_guard=guard,summary=summary,provenance=provenance),
        all(isfinite,errors) ? :heuristic : :unknown,:sampled_reference_comparison,
        ["Reference trust is caller-supplied, not certified by AML. No global error bound.",
         "Relative error is unavailable where |reference| is at or below the explicit guard."])
end

function analyze_pinn(r::AML.PINNTrainingResult;residual_points=Dict(),condition_roles=Dict(),
        reference=nothing,reference_points=nothing,
        reference_provenance=(kind=:user_supplied_unknown_trust,),relative_guard=1e-12,
        provenance=NamedTuple())
    isfinite(relative_guard) && relative_guard>=0 || throw(ArgumentError("relative_guard must be finite and nonnegative"))
    blocks=r.problem.backend_metadata.blocks
    all(i->i isa Integer && 1<=i<=length(blocks),keys(residual_points)) || throw(ArgumentError("invalid residual block index"))
    for (i,role) in condition_roles
        i isa Integer && 1<=i<=length(blocks) && blocks[i].kind==:bc && role in (:bc,:ic) ||
            throw(ArgumentError("explicit condition roles :bc/:ic apply only to backend BC blocks"))
    end
    snapshots=[_collocation(r,b) for b in blocks]
    reports=NamedTuple[]
    for (i,b) in enumerate(blocks)
        points=get(residual_points,i,nothing)
        points===nothing || points isa AML.PINNPoints || throw(ArgumentError("residual points must be PINNPoints in each block's free-variable order"))
        values=points===nothing ? nothing : _sample_residual(r,b,points)
        snapshot=snapshots[i]
        training=Set(Tuple(col) for col in eachcol(snapshot.coordinates))
        overlap=points===nothing ? nothing : count(col->Tuple(col) in training,eachcol(points.coordinates))
        outside=points===nothing ? nothing : count(eachcol(points.coordinates)) do col
            any(j->col[j]<b.bounds[1][j] || col[j]>b.bounds[2][j],eachindex(col))
        end
        evidence=AML.PropertyResult(values,values===nothing || !all(isfinite,values) ? :unknown : :heuristic,
            values===nothing ? :not_evaluated : :backend_signed_sampled_residual,
            ["Signed lhs-rhs residual, unweighted samples; not a global functional norm or proof."])
        push!(reports,(index=i,equation=b.eq,backend_kind=b.kind,role=get(condition_roles,i,b.kind),
            role_source=haskey(condition_roles,i) ? :caller_declared : :backend,
            variables=copy(b.ivs),points=points,values=values,
            summary=values===nothing ? nothing : AML.sampled_summary(values),
            sampling=(snapshot_overlap_count=overlap,all_training_overlap=:unknown,
                independence=:not_established,outside_domain_count=outside),evidence=evidence))
    end
    ref=_reference_analysis(r,reference_points,reference,reference_provenance,relative_guard)
    adaptive=AML.PropertyResult(nothing,:unknown,:unsupported_backend_api,
        ["NeuralPDE 7.3 has no built-in adaptive-loss strategy API; fixed/configured weights are retained separately.",
         "Caller-managed weight changes are not inferred; weight evolution is unavailable."])
    AML.PINNAnalysis(r,reports,ref,(strategy=_strategy_metadata(r.problem),blocks=snapshots),
        loss_breakdown(r),adaptive,
        AML.PropertyResult(nothing,:unknown,:global_correctness_not_established,
            ["Small sampled residuals do not prove global PDE correctness."]),
        (training=r.provenance,user=provenance,derivative=r.problem.provenance.derivative),
        ["Small training loss does not prove physical correctness.",
         "Only the returned collocation snapshot is known; all-training-set independence is not established.",
         "BC/IC roles require explicit caller classification; backend only distinguishes PDE/BC.",
         "Integral residuals are unsupported; finite-difference derivative error is not estimated.",
         "Uniqueness, global accuracy and extrapolation validity are not established."])
end
