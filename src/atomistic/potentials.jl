"""
    PotentialAnalysis <: AbstractAnalysis

A bound scalar pair energy U(r), with radial force F(r) = -dU/dr. Wraps the
existing `FunctionAnalysis`; its `real_analysis` remains the original algebraic
study, not a claim on negative physical radii. `radial_domain` intersects that
original domain with r > 0. `equilibria` records known stationary points, not
necessarily a complete zero set. Numerical candidates remain heuristic.

`units` and `provenance` are caller metadata, not dimensional conversions.
`cutoff` is metadata only: no truncation, energy shift, or force shift is applied.
Numerical search uses the existing Float64 machinery. No dynamics are performed.
"""
struct PotentialAnalysis{A,F,N,P,U,C,E,V} <: AbstractAnalysis
    function_analysis::A
    force_expression::F
    numerical::N
    radial_domain::RealDomain
    provenance::P
    units::U
    cutoff::C
    equilibria::E
    evidence::V
    limitations::Vector{String}
end

function _potential_radial_domain(domain::RealDomain)
    components = RealInterval[]
    for i in domain.components
        i.right > 0 || continue
        left = max(0, i.left)
        push!(components, RealInterval(left, i.right, left > 0 && i.left_closed, i.right_closed))
    end
    RealDomain(components, domain.status, :positive_radius_intersection,
        [domain.notes; "Physical radius is strictly positive; original exclusions are retained."])
end

# A qualitative budget failure must not erase a tractable original domain.
# Reuse the bounded domain walker; do not introduce a symbolic solver.
function _potential_original_domain(analysis)
    domain = analysis.real_analysis.domain
    domain.method == :resource_budget || return domain
    task_local_storage(_RA_BUDGET_KEY, Ref(_RA_MAX_WORK)) do
        try
            ast = _ra_ast(analysis.real_analysis.original_expression)
            _ra_preflight(ast)
            _ra_domain(ast, _ra_ast(analysis.variable))
        catch err
            err isa _RABudgetExceeded || rethrow()
            domain
        end
    end
end

function _potential_radius(domain, r)
    r isa Real && isfinite(r) && r > 0 || throw(DomainError(r, "radius must be finite and positive"))
    domain_contains(domain, r) === false && throw(DomainError(r, "radius excluded by original expression"))
    r
end

function _potential_cutoff(cutoff)
    cutoff === nothing && return nothing
    cutoff isa Real && isfinite(cutoff) && cutoff > 0 ||
        throw(ArgumentError("cutoff must be a finite positive numeric radius"))
    (radius=cutoff, modification=:none, notes="Metadata only; the stored energy and force are unmodified.")
end

function _potential_equilibria(analysis, domain)
    extrema = analysis.real_analysis.extrema
    if extrema.status == :established
        points = [p for p in extrema.value if domain_contains(domain, p.x) === true]
        return PropertyResult(points, :established, extrema.method,
            ["Established strict extrema from the real study; stationary non-extrema may be absent."])
    end
    candidates = [p for p in analysis.critical_points.points if domain_contains(domain, p.x) === true]
    status = analysis.critical_points.status == :heuristic ? :heuristic : :unknown
    PropertyResult(candidates, status, analysis.critical_points.method,
        ["Bounded numerical stationary candidates only; no completeness or absence certificate."])
end

"""
    analyze_potential(expression, variable; interval=nothing, provenance=(source=:user,),
                      units=(length=:unspecified, energy=:unspecified), cutoff=nothing, kwargs...)

Analyze a supported bound scalar symbolic radial energy (or `@real_function`
capture). Unbound parameters are rejected by `analyze`. Preserve original syntax
with `@real_function` when cancellation would erase exclusions. An optional finite
positive search interval must lie in one established original-domain component;
unsupported domains can still be studied without a numerical search. Keyword
residual controls are forwarded to the existing scalar analyzer. Units are labels;
pass consistently scaled numbers, not quantities requiring implicit conversion.
"""
function analyze_potential(expression, variable::Symbolics.Num; interval=nothing,
        provenance=(source=:user,), units=(length=:unspecified, energy=:unspecified),
        cutoff=nothing, kwargs...)
    cutoff_data = _potential_cutoff(cutoff)
    analysis = analyze(expression, variable; kwargs...)
    domain = _potential_radial_domain(_potential_original_domain(analysis))
    if interval !== nothing
        a, b = _interval_bounds(interval)
        a > 0 || throw(ArgumentError("potential search interval must have positive endpoints"))
        domain.status == :established && any(i -> _ra_contains(i, a) && _ra_contains(i, b), domain.components) ||
            throw(ArgumentError("search interval must lie in one established original-domain component"))
        c = analysis.critical_points
        critical = _critical_points(analysis.numerical, analysis.first_derivative, (a,b),
            c.residual_tolerance, c.residual_relative_tolerance, c.residual_scale)
        analysis = FunctionAnalysis(analysis.expression, analysis.variable, analysis.first_derivative,
            analysis.second_derivative, analysis.numerical, critical, analysis.real_analysis)
    end
    energy(r) = analysis.numerical.function_value(_potential_radius(domain, r))
    force(r) = -analysis.numerical.first_derivative(_potential_radius(domain, r))
    evidence = (force=PropertyResult(-analysis.first_derivative, :established,
        :symbolic_differentiation, ["Radial convention F = -dU/dr wherever differentiable."]),)
    PotentialAnalysis(analysis, -analysis.first_derivative, (; energy, force), domain,
        provenance, units, cutoff_data, _potential_equilibria(analysis, domain), evidence,
        ["Real-analysis limits and asymptotes refer to the stored original expression; restrict interpretation to r > 0.",
         "Unknown domain membership is not certified; numerical evaluation may fail.",
         "No interaction mixing, cutoff modification, force vector, or simulation is inferred."])
end

"""Evaluate stored radial energy or its first/second derivative; r must be positive."""
function evaluate(report::PotentialAnalysis, r::Real; order::Integer=0)
    _potential_radius(report.radial_domain, r)
    evaluate(report.function_analysis, r; order)
end

"""
    lennard_jones_analysis(; epsilon=1, sigma=1, interval=nothing, kwargs...)

Textbook U(r) = 4epsilon*((sigma/r)^12-(sigma/r)^6), epsilon,sigma > 0.
Parameters must be finite positive real numeric scales. Binary floating scales
are embedded as exact rationals representing those supplied numbers; no physical
measurement exactness is claimed. Other keywords go to `analyze_potential`.

Differentiation is delegated to Symbolics. The positive stationary candidate
r = 2^(1/6)*sigma is verified through x=r/sigma and x^6=2: clearing the
positive denominators verifies U=-epsilon and U''=72epsilon/r^2 > 0.
This identity certificate does not upgrade the global real study's unknown
properties. Stored point coordinates and curvature are numerical approximations;
the exact defining expressions and assumptions are in `evidence.minimum`.
"""
function lennard_jones_analysis(; epsilon=1, sigma=1, interval=nothing,
        provenance=(source=:textbook, model=:lennard_jones_12_6), kwargs...)
    for (name, value) in ((:epsilon, epsilon), (:sigma, sigma))
        value isa Real && !(value isa Symbolics.Num) && isfinite(value) && value > 0 ||
            throw(ArgumentError("$name must be a finite positive real numeric scale"))
        isfinite(Float64(value)) && Float64(value) > 0 ||
            throw(ArgumentError("$name must be representable as a positive finite Float64 scale"))
    end
    e, s = Rational{BigInt}(epsilon), Rational{BigInt}(sigma)
    Symbolics.@variables r x epsilon_symbol sigma_symbol
    formula = 4epsilon_symbol*((sigma_symbol/r)^12-(sigma_symbol/r)^6)
    expression = Symbolics.substitute(formula, Dict(epsilon_symbol=>e, sigma_symbol=>s))
    base = analyze_potential(expression, r; interval, provenance, kwargs...)
    simp(z) = Symbolics.simplify(Symbolics.simplify_fractions(z); expand=true)
    scaled = simp(Symbolics.substitute(formula, Dict(r=>sigma_symbol*x))/epsilon_symbol)
    d = Symbolics.expand_derivatives(Symbolics.Differential(x)(scaled))
    d2 = Symbolics.expand_derivatives(Symbolics.Differential(x)(d))
    at_sixth(z) = simp(Symbolics.substitute(simp(z), Dict(x^6=>2)))
    identities = (scaling=iszero(simp(scaled-4*(x^(-12)-x^(-6)))),
        stationary=iszero(at_sixth(d*x^13)),
        energy=iszero(at_sixth(scaled*x^12)+4),
        curvature=iszero(at_sixth(d2*x^14)-288))
    verified = all(values(identities))
    rmin = exp2(1/6)*Float64(sigma)
    curvature = 72*(Float64(epsilon)/rmin)/rmin
    isfinite(rmin) && rmin > 0 && isfinite(curvature) && curvature > 0 ||
        throw(ArgumentError("minimum coordinates/curvature are not representable in Float64"))
    certificate = PropertyResult((identities=identities,
        radius_expression=:(2^(1//6) * $s), energy_expression=-e,
        curvature_expression=:(72 * $e / (2^(1//6) * $s)^2),
        scaled_expression=scaled, sixth_power=2, epsilon=epsilon, sigma=sigma),
        verified ? :established : :unknown, :scaled_sixth_power_identity,
        ["Assumptions: epsilon > 0, sigma > 0, x=r/sigma > 0.",
         "x^6=2 verifies the stationary candidate, energy and positive curvature exactly in scaled variables.",
         "The displayed radius and curvature are Float64 approximations, not exact algebraic numbers."])
    points = [(x=rmin, value=-epsilon, curvature=curvature, classification=:minimum)]
    equilibria = verified ? PropertyResult(points, :established, certificate.method, copy(certificate.notes)) : base.equilibria
    PotentialAnalysis(base.function_analysis, base.force_expression, base.numerical,
        base.radial_domain, base.provenance, base.units, base.cutoff, equilibria,
        merge(base.evidence, (minimum=certificate,)),
        [base.limitations; "The generic real study can remain unknown (including its algebraic budget); the scaled candidate certificate is independent."])
end
