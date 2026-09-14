"""Reusable analysis of a real map R^n → R^m. Stored arrays are read-only by convention."""
struct VectorFieldAnalysis{E,O,V,J,N,D,C,Z,B,K,P,Q} <: AbstractAnalysis
    components::E
    original_components::O
    variables::V
    input_dimension::Int
    output_dimension::Int
    jacobian_expression::J
    numerical::N
    domain::D
    component_domains::C
    field_zeros::Z
    divergence::B
    curl::K
    conservative::P
    potential::Q
end

_vf_unknown(note) = PropertyResult(nothing, :unknown, :unsupported, [note])
_vf_established(value, method=:symbolic_differentiation) = PropertyResult(value, :established, method, String[])

# Reuse RealExpression/@real_function: only literal component containers can be
# separated safely. Never reconstruct erased restrictions from simplified values.
function _vf_originals(original, m)
    original isa Union{Tuple,AbstractVector} && return original
    if original isa Expr && original.head in (:vect,:tuple,:vcat) && length(original.args) == m
        return tuple(original.args...)
    end
    return ntuple(_ -> original,m) # unsupported captured container => unknown
end

function _vf_domain(originals, vars)
    domains = map(e -> _mv_domain(e,vars), originals)
    restrictions = tuple((r for d in domains for r in d.restrictions)...)
    established = all(d -> d.status == :established, domains)
    status = established ? :established : isempty(restrictions) ? :unknown : :partial
    domain = MultivariateDomain(restrictions, vars, status, :component_intersection,
        established ? String[] : ["Component intersection unresolved; retained exclusions still apply."])
    return domain, domains
end

function analyze(components::Union{AbstractVector,Tuple}, variables::Union{Tuple,AbstractVector};
        original_expression=components, bounds=nothing, grid::Integer=7, iterations::Integer=40,
        residual_tolerance::Real=1e-8, residual_rtol::Real=0, residual_scale::Real=1)
    vars = _mv_variables(variables); n = length(vars); m = length(components)
    1 <= m <= 32 || throw(ArgumentError("between 1 and 32 components are supported"))
    threshold = _residual_controls(residual_tolerance,residual_rtol,residual_scale).threshold
    2 <= grid <= 25 || throw(ArgumentError("grid must be between 2 and 25"))
    1 <= iterations <= 200 || throw(ArgumentError("iterations must be between 1 and 200"))
    search_bounds = _mv_bounds(bounds,n)
    search_bounds === nothing || _mv_product_size(fill(grid,n),50_000)
    all(e -> e isa Real, components) || throw(ArgumentError("components must be scalar real expressions"))
    allowed = Set(Symbolics.toexpr.(vars))
    all(e -> Set(Symbolics.toexpr.(Symbolics.get_variables(e))) ⊆ allowed, components) ||
        throw(ArgumentError("components contain unbound variables or parameters"))
    original_expression = _vf_originals(original_expression,m)
    original_expression isa Union{Tuple,AbstractVector} && length(original_expression) == m ||
        throw(ArgumentError("original_expression must provide one original expression per component"))
    expressions = tuple(components...); originals = deepcopy(tuple(original_expression...))
    J = [Symbolics.expand_derivatives(Symbolics.Differential(vars[j])(expressions[i])) for i in 1:m, j in 1:n]
    numerical = (field=map(e -> Symbolics.build_function(e, vars...; expression=Val{false}), expressions),
        jacobian=ntuple(i -> ntuple(j -> Symbolics.build_function(J[i,j],vars...; expression=Val{false}), n), m))
    domain, domains = _vf_domain(originals,vars)
    unknown = _vf_unknown("No supported conclusion requested.")
    div,rot,conservative,phi = _vf_calculus(expressions,originals,vars,domain,J)
    report = VectorFieldAnalysis(expressions, originals, vars, n, m, J, numerical,
        domain, domains, unknown, div, rot, conservative, phi)
    zeros = _vf_zeros(report,search_bounds,grid,iterations,threshold)
    return VectorFieldAnalysis(expressions, originals, vars, n, m, J, numerical,
        domain, domains, zeros, div, rot, conservative, phi)
end

function _vf_point(report, point)
    length(point) == report.input_dimension || throw(DimensionMismatch("point dimension does not match the map"))
    all(x -> x isa Real && isfinite(x), point) || throw(DomainError(point,"coordinates must be finite and real"))
    domain_contains(report.domain,point) === false && throw(DomainError(point,"outside the original domain"))
    return point
end

function _vf_smooth(report, point)
    domain_contains(report.domain,point) === true || return false
    return all(eachindex(report.components)) do i
        _mv_smooth((domain=report.component_domains[i], original_expression=report.original_components[i],
            variables=report.variables), point)
    end
end

"""Evaluate stored field callables; unknown membership does not certify validity."""
function evaluate(report::VectorFieldAnalysis, point::Union{Tuple,AbstractVector})
    p = _vf_point(report,point)
    return [_mv_call(f,p) for f in report.numerical.field]
end

"""Return a copy of the formal m×n Jacobian, with components indexing rows."""
jacobian(report::VectorFieldAnalysis) = copy(report.jacobian_expression)
function jacobian(report::VectorFieldAnalysis, point::Union{Tuple,AbstractVector})
    p = _vf_point(report,point)
    _vf_smooth(report,p) || throw(DomainError(point,"Jacobian requires a supported open smooth neighborhood"))
    return [_mv_call(report.numerical.jacobian[i][j],p) for i in 1:report.output_dimension, j in 1:report.input_dimension]
end
