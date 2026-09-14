"""A field-zero candidate with residual diagnostics; no dynamical classification."""
struct FieldZero{P,V}
    point::P
    value::V
    residual_norm::Float64
    residual_threshold::Float64
end

function _vf_exact_candidates(report)
    report.input_dimension == report.output_dimension || return nothing,:unsupported
    # The existing solver needs a vector expression and its derivative matrix,
    # not a potential or a symmetric matrix. Adapt that internal system protocol.
    system = (variables=report.variables, dimension=report.input_dimension,
        gradient_expression=report.components, hessian_expression=report.jacobian_expression,
        numerical=(gradient=report.numerical.field,))
    return _mv_exact_candidates(system)
end

function _vf_zero_candidate(report, point, threshold; exact=false)
    domain_contains(report.domain,point) === true || return nothing
    value = try
        evaluate(report,point)
    catch err
        err isa InterruptException && rethrow()
        return nothing
    end
    residual = LinearAlgebra.norm(Float64.(value))
    isfinite(residual) && residual <= threshold || return nothing
    if exact
        substitutions = Dict(zip(report.variables,point))
        all(e -> iszero(_vf_simplify(Symbolics.substitute(e,substitutions))), report.components) || return nothing
    end
    return FieldZero(collect(point),value,residual,threshold)
end

function _vf_zeros(report, bounds, grid, iterations, threshold)
    raw,method = if report.domain.status != :established
        (nothing,:unknown_domain)
    else
        task_local_storage(_RA_BUDGET_KEY,Ref(_RA_MAX_WORK)) do
            try
                _vf_exact_candidates(report)
            catch err
                err isa _RABudgetExceeded || rethrow()
                (nothing,:resource_budget)
            end
        end
    end
    exact = raw !== nothing
    if raw === nothing && bounds !== nothing && method == :unsupported
        raw = _system_numerical_candidates(p -> evaluate(report,p), p -> jacobian(report,p), bounds,grid,iterations)
        method = :bounded_multistart_newton
    end
    candidates = FieldZero[]
    unresolved = false
    raw === nothing || for point in raw
        domain_contains(report.domain,point) === false && continue
        candidate = _vf_zero_candidate(report,point,threshold; exact)
        candidate === nothing ? (unresolved = true) : push!(candidates,candidate)
    end
    status = raw === nothing ? :unknown : exact ? (unresolved ? :unknown : :established) : :heuristic
    note = status == :established ? "Complete within the exact affine/separable polynomial solver class; candidates verified componentwise on the original domain." :
        status == :heuristic ? "Bounded multistart search; no completeness or root-position bound. Residual acceptance is not an exact-zero proof." :
        "No complete field-zero conclusion; exact families, unresolved domains, or unsupported systems remain unknown."
    return PropertyResult(candidates,status,method,[note])
end
