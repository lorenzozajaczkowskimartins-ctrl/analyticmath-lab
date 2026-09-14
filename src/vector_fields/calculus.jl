# Symbolic operators describe the smooth locus of the original domain, not a
# differentiability certificate at corners or boundaries.
_vf_simplify(e) = Symbolics.simplify(e; expand=true)

"""Structured divergence for square maps; unknown/unsupported for rectangular maps."""
divergence(report::VectorFieldAnalysis) = deepcopy(report.divergence)
"""Structured planar scalar curl (2D) or vector curl (3D); unknown otherwise."""
curl(report::VectorFieldAnalysis) = deepcopy(report.curl)
"""Verified scalar potential evidence; the additive constant is omitted."""
potential(report::VectorFieldAnalysis) = deepcopy(report.potential)

# Conservative polynomial degree preflight. Restrict exact construction to
# rational coefficients and total degree <= 8; no general integration engine.
function _vf_degree(e, names)
    e isa Union{Integer,Rational} && return 0
    e isa Symbol && return e in names ? 1 : nothing
    e isa Expr && e.head == :call || return nothing
    op = _expression_op(e); args = e.args[2:end]
    isempty(args) && return nothing
    if op == :^ && length(args) == 2
        args[2] isa Integer && 0 <= args[2] <= 8 || return nothing
        degree = _vf_degree(args[1],names)
        degree === nothing && return nothing
        result = degree*args[2]
    elseif op in (:/, ://) && length(args) == 2
        args[2] isa Union{Integer,Rational} && !iszero(args[2]) || return nothing
        return _vf_degree(args[1],names)
    elseif op in (:+,:-,:*)
        degrees = map(a -> _vf_degree(a,names),args)
        any(isnothing,degrees) && return nothing
        result = op == :* ? sum(degrees) : maximum(degrees)
    else
        return nothing
    end
    return result <= 8 ? Int(result) : nothing
end

function _vf_open_syntax(e)
    e isa Union{Real,Symbol} && return true
    e isa Expr && e.head == :call || return false
    _expression_op(e) in (:+,:-,:*,:/,://,:^,:log,:sin,:cos,:exp) || return false
    all(_vf_open_syntax,e.args[2:end])
end

function _vf_potential(expressions, originals, vars, domain, J)
    unknown = _vf_unknown("Zero curl alone is not a global potential proof; construction/topology unresolved.")
    length(expressions) == length(vars) || return unknown, _vf_unknown("Potential requires a square field.")
    domain.status == :established && all(e -> _vf_open_syntax(_expression_ast(e)), originals) || return unknown, unknown
    names = Set(Symbolics.toexpr.(vars))
    degrees = map(expressions) do e
        ast = _expression_ast(e)
        try
            _ra_preflight(ast)
            _vf_degree(ast,names)
        catch err
            err isa _RABudgetExceeded || rethrow()
            nothing
        end
    end
    any(isnothing,degrees) && return unknown, unknown
    symmetric = all(iszero(_vf_simplify(J[i,j]-J[j,i])) for i in eachindex(vars), j in eachindex(vars))
    if !symmetric
        # A nonzero polynomial curl obstructs a potential on R^n. Restricted or
        # possibly empty domains need a witness, not an algebraic nonidentity.
        isempty(domain.restrictions) && return _vf_established(false,:polynomial_mixed_partials), unknown
        return unknown, unknown
    end
    # Radial homotopy: integrate sum x_i F_i(t*x) from t=0 to 1 by finite
    # polynomial Taylor coefficients. No numerical integration or branch choice.
    t = Symbolics.variable(gensym(:potential_parameter))
    substitutions = Dict(v => t*v for v in vars)
    integrand = sum(vars[i]*Symbolics.substitute(expressions[i],substitutions) for i in eachindex(vars))
    phi = 0
    derivative = integrand
    factorial = BigInt(1)
    for k in 0:maximum(degrees)
        k > 0 && (factorial *= k)
        coefficient = Symbolics.substitute(derivative,Dict(t=>0))
        phi += coefficient / (factorial*(k+1))
        derivative = Symbolics.expand_derivatives(Symbolics.Differential(t)(derivative))
    end
    phi = _vf_simplify(phi)
    verified = all(iszero(_vf_simplify(Symbolics.expand_derivatives(Symbolics.Differential(vars[i])(phi))-expressions[i])) for i in eachindex(vars))
    verified || return unknown, unknown
    return _vf_established(true,:verified_polynomial_potential),
        PropertyResult(phi,:established,:verified_polynomial_potential,
            ["Differentiated componentwise and verified exactly; additive constant omitted; restricted to the original domain."])
end

function _vf_calculus(expressions, originals, vars, domain, J)
    n = length(vars); m = length(expressions)
    unsupported = _vf_unknown("Operator is not defined for these input/output dimensions.")
    div = m == n ? _vf_established(_vf_simplify(sum(J[i,i] for i in 1:n))) : unsupported
    rot = m == n == 2 ? _vf_established(_vf_simplify(J[2,1]-J[1,2])) :
        m == n == 3 ? _vf_established(_vf_simplify.([J[3,2]-J[2,3],J[1,3]-J[3,1],J[2,1]-J[1,2]])) : unsupported
    for result in (div,rot)
        result.status == :established && push!(result.notes,"Formal symbolic identity on the smooth locus of the original domain; not a boundary differentiability certificate.")
    end
    conservative, phi = _vf_potential(expressions,originals,vars,domain,J)
    return div,rot,conservative,phi
end

function linearization(report::VectorFieldAnalysis, point::Union{Tuple,AbstractVector})
    p = collect(_vf_point(report,point))
    coefficients = jacobian(report,p); value = evaluate(report,p)
    expressions = [_vf_simplify(value[i] + sum(coefficients[i,j]*(report.variables[j]-p[j]) for j in 1:report.input_dimension)) for i in 1:report.output_dimension]
    return (expression=expressions,base_point=p,value=value,coefficients=coefficients)
end
