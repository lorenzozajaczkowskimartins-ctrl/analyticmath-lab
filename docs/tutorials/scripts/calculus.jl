using AnalyticMathLab, Symbolics

@variables x
f = x^3 - 6x^2 + 9x + 1
report = analyze(f, x; interval=(0, 4))
zero_identity(e) = iszero(Symbolics.simplify(Symbolics.expand(e)))
@assert zero_identity(report.first_derivative - 3*(x-1)*(x-3))
@assert zero_identity(report.second_derivative - (6x-12))
@assert evaluate(report, 2.0) == 3.0
@assert evaluate(report, 2.0; order=1) == -3.0
points = sort(report.critical_points.points; by=p -> p.x)
@assert length(points) == 2
@assert maximum(abs.([p.x for p in points] - [1.0, 3.0])) <= 1e-10
@assert [p.classification for p in points] == [:maximum_candidate, :minimum_candidate]
@assert maximum(abs.([p.value for p in points] - [5.0, 1.0])) <= 1e-10

comparison = compare_derivatives(report, 2.0)
@assert abs(comparison.values.symbolic + 3) <= 1e-12
@assert abs(comparison.values.automatic + 3) <= 1e-12
@assert abs(comparison.values.central + 3) <= 1e-7
# A caller-chosen stencil, distinct from FiniteDiff's default step.
h = 1/8
central = (evaluate(report, 2+h) - evaluate(report, 2-h))/(2h)
@assert abs(central - (-3 + h^2)) <= 1e-12
println((value=evaluate(report, 2.0), stationary=[p.x for p in points],
    classifications=[p.classification for p in points], derivative_values=comparison.values,
    discrepancies=comparison.absolute_errors, explicit_h=h, stencil=central))
println("CALCULUS_OK")
