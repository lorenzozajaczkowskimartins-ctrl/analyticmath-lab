
"""A verified stationary candidate and its local Hessian evidence."""
struct StationaryPoint{P,T,H,E,C}
    point::P
    value::T
    residual_norm::Float64
    residual_threshold::Float64
    hessian::H
    eigenvalues::E
    classification::Symbol
    classification_evidence::C
end

"""
    ScalarFieldAnalysis <: AbstractAnalysis

Reusable symbolic and numerical analysis of a scalar field `f: R^n -> R`.
Derivatives are constructed once. `stationary_points` is a `PropertyResult`, so
candidate discovery status and method remain separate from residual diagnostics.
"""
struct ScalarFieldAnalysis{E,O,V,G,H,N,D,S} <: AbstractAnalysis
    expression::E
    original_expression::O
    variables::V
    dimension::Int
    gradient_expression::G
    hessian_expression::H
    numerical::N
    domain::D
    stationary_points::S
end



function _mv_variables(variables)
    variables isa Union{Tuple,AbstractVector} || throw(ArgumentError("variables must be a tuple or vector"))
    1 <= length(variables) <= 32 || throw(ArgumentError("between 1 and 32 variables are supported"))
    vars = tuple(variables...)
    for v in vars
        v isa Symbolics.Num || throw(ArgumentError("variables must be Symbolics variables"))
        found = Symbolics.get_variables(v)
        length(found) == 1 && isequal(Symbolics.Num(only(found)), v) ||
            throw(ArgumentError("each independent variable must be a single Symbolics variable"))
    end
    length(unique(Symbolics.toexpr.(vars))) == length(vars) ||
        throw(ArgumentError("independent variables must be distinct"))
    return vars
end

# Checked product avoids machine-integer wrap before Cartesian allocations.
function _mv_product_size(sizes, limit)
    count = 1
    for size in sizes
        0 <= size <= limit || throw(ArgumentError("Cartesian search exceeds its resource budget"))
        size == 0 && return 0
        count <= limit ÷ size || throw(ArgumentError("Cartesian search exceeds its resource budget"))
        count *= size
    end
    count
end

# Sufficient, not necessary, C² test on an open original-domain neighborhood.
# In particular sqrt/abs at zero do not become smooth through cancellation.
function _mv_smooth(report, point)
    domain_contains(report.domain, point) === true || return false
    ast = _mv_ast(report.original_expression)
    names = Symbol[_mv_ast(v) for v in report.variables]
    function walk(e)
        e isa Real && return isfinite(e)
        e isa Symbol && return e in names
        e isa Expr && e.head == :call || return false
        op = _mv_op(e); args = e.args[2:end]
        all(walk, args) || return false
        if op in (:sqrt, :abs)
            val = _mv_eval_ast(only(args), names, point)
            return isfinite(val) && (op == :sqrt ? val > 0 : !iszero(val))
        end
        op in (:+, :-, :*, :/, ://, :^, :log, :sin, :cos, :exp)
    end
    try
        walk(ast)
    catch err
        err isa InterruptException && rethrow()
        false
    end
end

function _mv_point(report, point)
    point isa Union{Tuple,AbstractVector} || throw(ArgumentError("point must be a tuple or vector"))
    length(point) == report.dimension || throw(DimensionMismatch("point dimension does not match the analysis"))
    all(x -> x isa Real && isfinite(x), point) || throw(DomainError(point, "point coordinates must be finite real values"))
    domain_contains(report.domain, point) === false && throw(DomainError(point, "point is outside the known original domain"))
    return point
end

function _mv_call(f, point)
    value = f(point...)
    value isa Real && isfinite(value) || throw(DomainError(point, "scalar field evaluation is not finite and real"))
    return value
end

evaluate(report::ScalarFieldAnalysis, point::Union{Tuple,AbstractVector}) =
    _mv_call(report.numerical.function_value, _mv_point(report, point))
gradient(report::ScalarFieldAnalysis) = copy(report.gradient_expression)
hessian(report::ScalarFieldAnalysis) = copy(report.hessian_expression)

function gradient(report::ScalarFieldAnalysis, point::Union{Tuple,AbstractVector})
    p = _mv_point(report, point)
    _mv_smooth(report,p) || throw(DomainError(point, "gradient requires a supported open smooth neighborhood"))
    return [_mv_call(f, p) for f in report.numerical.gradient]
end
function hessian(report::ScalarFieldAnalysis, point::Union{Tuple,AbstractVector})
    p = _mv_point(report, point)
    _mv_smooth(report,p) || throw(DomainError(point, "Hessian requires a supported open smooth neighborhood"))
    return [_mv_call(report.numerical.hessian[i][j], p) for i in 1:report.dimension, j in 1:report.dimension]
end

_mv_threshold(tolerance, rtol, scale) = _residual_controls(tolerance, rtol, scale).threshold

function _mv_classify(H, atol, rtol; symbolic=false)
    matrix = Float64.(H)
    all(isfinite, matrix) || throw(DomainError(H, "Hessian is not representable in Float64"))
    LinearAlgebra.issymmetric(matrix) || throw(DomainError(H, "mixed partials disagree"))
    eigenvalues = LinearAlgebra.eigvals(LinearAlgebra.Symmetric(matrix))
    scale = max(LinearAlgebra.opnorm(matrix, Inf), 1.0)
    threshold = atol + rtol*scale
    classification = all(>(threshold), eigenvalues) ? :minimum_candidate :
        all(<(-threshold), eigenvalues) ? :maximum_candidate :
        minimum(eigenvalues) < -threshold && maximum(eigenvalues) > threshold ? :saddle_candidate : :inconclusive
    evidence = PropertyResult(classification, :heuristic, :numerical_eigenvalues,
        ["Eigenvalue threshold = $threshold (atol=$atol, rtol=$rtol, scale=$scale)."])
    return classification, eigenvalues, evidence
end

function _mv_candidate(report, point, threshold, catol, crtol; symbolic=false)
    point = [_mv_concrete(x) for x in point]
    domain_contains(report.domain, point) === true || return nothing
    _mv_smooth(report, point) || return nothing
    g = try gradient(report, point) catch; return nothing end
    residual = Float64(LinearAlgebra.norm(Float64.(g)))
    isfinite(residual) && residual <= threshold || return nothing
    value = try evaluate(report, point) catch; return nothing end
    H = try hessian(report, point) catch; return nothing end
    exact_class = symbolic ? _mv_symbolic_classification(H) : nothing
    cls, eigs, evidence = try
        _mv_classify(H, catol, crtol)
    catch err
        err isa DomainError || rethrow()
        (:inconclusive, Float64[], PropertyResult(:inconclusive, :unknown, :unrepresentable_hessian, [sprint(showerror, err)]))
    end
    if exact_class !== nothing
        cls = exact_class
        evidence = PropertyResult(cls, :established, :symbolic_definiteness, String[])
    end
    return StationaryPoint(collect(point), value, residual, threshold, H, eigs, cls, evidence)
end

_mv_concrete(x::Symbolics.Num) = Symbolics.value(x)
_mv_concrete(x) = x

function _mv_symbolic_classification(H)
    n = size(H,1)
    values = [_mv_concrete(Symbolics.simplify(H[i,j])) for i in 1:n, j in 1:n]
    all(x -> x isa Union{Integer,Rational}, values) || return nothing
    values = _RAQ.(values)
    LinearAlgebra.issymmetric(values) || return nothing
    if all(iszero(values[i,j]) for i in 1:n, j in 1:n if i != j)
        diagonal = LinearAlgebra.diag(values)
        return all(>(0),diagonal) ? :minimum_candidate : all(<(0),diagonal) ? :maximum_candidate :
            any(>(0),diagonal) && any(<(0),diagonal) ? :saddle_candidate : :inconclusive
    elseif n == 2
        determinant = values[1,1]*values[2,2] - values[1,2]*values[2,1]
        return determinant < 0 ? :saddle_candidate : determinant > 0 && values[1,1] > 0 ? :minimum_candidate :
            determinant > 0 && values[1,1] < 0 ? :maximum_candidate : :inconclusive
    end
    return nothing
end

function _mv_gaussian_solve(A, b)
    exact(x) = begin
        value = _mv_concrete(Symbolics.simplify(x))
        value isa Integer ? BigInt(value)//BigInt(1) :
            value isa Rational ? BigInt(numerator(value))//BigInt(denominator(value)) : nothing
    end
    converted_A = exact.(A); converted_b = exact.(b)
    if any(isnothing, converted_A) || any(isnothing, converted_b)
        return nothing
    end
    n = length(b); M = _RAQ.(converted_A); rhs = _RAQ.(converted_b)
    for k in 1:n
        pivot = findfirst(i -> !iszero(Symbolics.simplify(M[i,k])), k:n)
        pivot === nothing && return nothing
        p = k - 1 + pivot
        if p != k
            row = copy(M[k,:])
            M[k,:] = M[p,:]
            M[p,:] = row
            rhs[k], rhs[p] = rhs[p], rhs[k]
        end
        for i in k+1:n
            factor = Symbolics.simplify(M[i,k] / M[k,k])
            for j in k:n; M[i,j] = Symbolics.simplify(M[i,j] - factor*M[k,j]); end
            rhs[i] = Symbolics.simplify(rhs[i] - factor*rhs[k])
        end
    end
    x = Vector{_RAQ}(undef,n)
    for i in n:-1:1
        x[i] = Symbolics.simplify((rhs[i] - sum(M[i,j]*x[j] for j in i+1:n; init=0)) / M[i,i])
    end
    return x
end

function _mv_exact_candidates(report)
    vars = report.variables; n = report.dimension
    # Complete class 1: nonsingular affine gradient (quadratic scalar fields).
    if all(isempty(Symbolics.get_variables(report.hessian_expression[i,j])) for i in 1:n, j in 1:n)
        zero_point = ntuple(_ -> 0, n)
        b = [f(zero_point...) for f in report.numerical.gradient]
        point = _mv_gaussian_solve(report.hessian_expression, -b)
        point !== nothing && return [point], :exact_linear_system
    end
    # Complete class 2: separable rational polynomials with exactly enumerable derivative roots.
    roots = Vector{_RAQ}[]
    for i in 1:n
        used = Set(Symbolics.toexpr.(Symbolics.get_variables(report.gradient_expression[i])))
        used ⊆ Set([Symbolics.toexpr(vars[i])]) || return nothing, :unsupported
        ast = _ra_ast(report.gradient_expression[i]); _ra_preflight(ast)
        rat = _ra_parse(ast, _ra_ast(vars[i]))
        rat === nothing && return nothing, :unsupported
        length(rat.d) == 1 && !iszero(only(rat.d)) || return nothing, :unsupported
        rr, complete, nonisolated = _ra_roots(rat.n)
        complete && !nonisolated || return nothing, :unsupported
        push!(roots, rr)
    end
    try
        _mv_product_size(length.(roots), 4096)
    catch err
        err isa ArgumentError || rethrow()
        throw(_RABudgetExceeded())
    end
    points = vec([_RAQ[p...] for p in Iterators.product(roots...)])
    return points, :exact_separable_polynomial
end

function _mv_bounds(bounds, n)
    bounds === nothing && return nothing
    bounds isa Union{Tuple,AbstractVector} && length(bounds) == n ||
        throw(ArgumentError("bounds must provide one (low, high) pair per variable"))
    result = map(bounds) do bound
        bound isa Tuple && length(bound) == 2 || throw(ArgumentError("each bound must be a pair"))
        a,b = Float64.(bound)
        isfinite(a) && isfinite(b) && a < b || throw(ArgumentError("bounds must be finite and increasing"))
        (a,b)
    end
    return tuple(result...)
end

# Shared bounded system search. Callbacks provide the residual vector and its
# Jacobian; scalar stationary search uses gradient/Hessian, vector zeros F/J_F.
function _system_numerical_candidates(field, derivative, bounds, grid, iterations)
    seeds = Iterators.product((range(a,b; length=grid) for (a,b) in bounds)...)
    candidates = Vector{Vector{Float64}}()
    for seed in seeds
        x = Float64[seed...]
        for _ in 1:iterations
            g = try Float64.(field(x)) catch; break end
            H = try Float64.(derivative(x)) catch; break end
            step = try H \ g catch; break end
            all(isfinite, step) || break
            next = x - step
            x = [clamp(next[i], bounds[i][1], bounds[i][2]) for i in eachindex(x)]
            LinearAlgebra.norm(step) <= 1e-11 && break
        end
        all(i -> bounds[i][1] <= x[i] <= bounds[i][2], eachindex(x)) || continue
        any(p -> LinearAlgebra.norm(p-x) <= 1e-7, candidates) || push!(candidates,x)
    end
    return candidates
end

_mv_numerical_candidates(report, bounds, grid, iterations) =
    _system_numerical_candidates(x -> gradient(report,x), x -> hessian(report,x), bounds, grid, iterations)

function analyze(expression::Real, variables::Union{Tuple,AbstractVector};
        bounds=nothing, grid::Integer=7, iterations::Integer=40,
        residual_tolerance::Real=1e-8, residual_rtol::Real=0, residual_scale::Real=1,
        classification_atol::Real=1e-10, classification_rtol::Real=1e-8,
        original_expression=expression)
    vars = _mv_variables(variables); n = length(vars)
    allowed = Set(Symbolics.toexpr.(vars))
    Set(Symbolics.toexpr.(Symbolics.get_variables(expression))) ⊆ allowed ||
        throw(ArgumentError("expression contains unbound parameters or variables"))
    threshold = _mv_threshold(residual_tolerance, residual_rtol, residual_scale)
    catol, crtol = Float64(classification_atol), Float64(classification_rtol)
    isfinite(catol) && catol >= 0 || throw(ArgumentError("classification_atol must be finite and nonnegative"))
    isfinite(crtol) && crtol >= 0 || throw(ArgumentError("classification_rtol must be finite and nonnegative"))
    2 <= grid <= 25 || throw(ArgumentError("grid must be between 2 and 25"))
    1 <= iterations <= 200 || throw(ArgumentError("iterations must be between 1 and 200"))
    differentials = Symbolics.Differential.(vars)
    g = [Symbolics.expand_derivatives(d(expression)) for d in differentials]
    H = [Symbolics.expand_derivatives(differentials[j](g[i])) for i in 1:n, j in 1:n]
    numerical = (function_value=Symbolics.build_function(expression, vars...; expression=Val{false}),
        gradient=tuple((Symbolics.build_function(e, vars...; expression=Val{false}) for e in g)...),
        hessian=ntuple(i -> ntuple(j -> Symbolics.build_function(H[i,j], vars...; expression=Val{false}), n), n))
    domain = _mv_domain(original_expression, vars)
    placeholder = PropertyResult(StationaryPoint[], :unknown, :pending, String[])
    report = ScalarFieldAnalysis(expression, original_expression, vars, n, g, H, numerical, domain, placeholder)
    raw, method = if domain.status != :established
        (nothing, domain.method == :resource_budget ? :resource_budget : :unknown_domain)
    else
        task_local_storage(_RA_BUDGET_KEY, Ref(_RA_MAX_WORK)) do
            try
                _mv_exact_candidates(report)
            catch err
                err isa _RABudgetExceeded || rethrow()
                (nothing, :resource_budget)
            end
        end
    end
    symbolic = raw !== nothing
    search_bounds = _mv_bounds(bounds,n)
    search_bounds === nothing || _mv_product_size(fill(grid,n), 50_000)
    if raw === nothing && search_bounds !== nothing && method == :unsupported && domain.status == :established
        raw = _mv_numerical_candidates(report, search_bounds, grid, iterations)
        method = :bounded_multistart_newton
    end
    points = StationaryPoint[]
    unresolved = false
    raw === nothing || for point in raw
        domain_contains(domain, point) === false && continue
        candidate = _mv_candidate(report, point, threshold, catol, crtol; symbolic)
        candidate === nothing && (unresolved = true)
        candidate === nothing || push!(points, candidate)
    end
    result = raw === nothing ? PropertyResult(points, :unknown, method,
        ["No complete exact solver applies; provide explicit finite bounds for heuristic search."]) :
        PropertyResult(points, symbolic && !unresolved ? :established : symbolic ? :unknown : :heuristic, method,
        symbolic ? [unresolved ? "Some algebraic candidates could not be verified in an open smooth domain; completeness is unresolved." : "Complete within the documented exact solver class."] :
                   ["Bounded multistart Newton candidates; completeness is not established."])
    return ScalarFieldAnalysis(expression, original_expression, vars, n, g, H, numerical, domain, result)
end

analyze(captured::RealExpression, variables::Union{Tuple,AbstractVector}; kwargs...) =
    analyze(captured.expression, variables; original_expression=captured.original, kwargs...)

function directional_derivative(report::ScalarFieldAnalysis, point, direction)
    p = _mv_point(report, point)
    _mv_smooth(report,p) || throw(DomainError(point, "directional derivative requires a supported open smooth neighborhood"))
    direction isa Union{Tuple,AbstractVector} && length(direction) == report.dimension ||
        throw(DimensionMismatch("direction dimension does not match the analysis"))
    all(x -> x isa Real && isfinite(x), direction) || throw(DomainError(direction, "direction must be finite and real"))
    scale = maximum(abs, direction)
    scale > 0 || throw(DomainError(direction, "direction must be nonzero"))
    unit = collect(direction) ./ scale
    magnitude = LinearAlgebra.norm(unit)
    isfinite(magnitude) && magnitude > 0 || throw(DomainError(direction, "direction must be nonzero"))
    return LinearAlgebra.dot(gradient(report,p), unit ./ magnitude)
end

function linearization(report::ScalarFieldAnalysis, point)
    _mv_smooth(report, _mv_point(report,point)) || throw(DomainError(point, "linearization requires a supported open smooth neighborhood"))
    p = collect(_mv_point(report,point)); value = evaluate(report,p); coefficients = gradient(report,p)
    expression = value + sum(coefficients[i]*(report.variables[i]-p[i]) for i in 1:report.dimension)
    return (expression=Symbolics.simplify(expression), base_point=p, value=value, coefficients=coefficients)
end

function levelset(report::ScalarFieldAnalysis, c::Real)
    c isa Symbolics.Num && throw(ArgumentError("level must be a finite numerical real"))
    isfinite(c) || throw(DomainError(c, "level must be finite"))
    report.expression ~ c
end

function Base.show(io::IO, report::ScalarFieldAnalysis)
    print(io, "ScalarFieldAnalysis(", report.expression, "; dimension=", report.dimension,
        ", stationary_points=", report.stationary_points.status, ")")
end
function Base.show(io::IO, ::MIME"text/plain", report::ScalarFieldAnalysis)
    println(io, "AnalyticMathLab — Scalar Field Analysis")
    println(io, "  f(", join(string.(report.variables), ", "), ") = ", report.expression)
    println(io, "  Gradient: ", report.gradient_expression)
    println(io, "  Hessian:  ", report.hessian_expression)
    println(io, "  Domain: ", report.domain.status, " (", report.domain.method, ")")
    print(io, "  Stationary points: ", report.stationary_points.status,
        " (", report.stationary_points.method, "), candidates=", length(report.stationary_points.value))
end
