using AnalyticMathLab, Symbolics

@variables x y
field = analyze(x^2 + x*y + 2y^2, (x, y))
zero_identity(e) = iszero(Symbolics.simplify(Symbolics.expand(e)))
@assert field.variables == (x, y)
@assert all(zero_identity, gradient(field) - [2x+y, x+4y])
@assert all(zero_identity, hessian(field) - [2 1; 1 4])
@assert gradient(field, (1, 2)) == [4, 9]
@assert hessian(field, (1, 2)) == [2 1; 1 4]
@assert evaluate(field, (1, 2)) == 11
@assert domain_contains(field.domain, (0, 0)) === true
@assert field.stationary_points.status == :established
point = only(field.stationary_points.value)
@assert collect(point.point) == [0, 0]
@assert point.classification == :minimum_candidate
@assert point.classification_evidence.status == :established
# At this quadratic's origin the second-order expansion is the whole function.
@assert zero_identity(field.expression - ((x+y/2)^2 + 7y^2/4))
println((gradient_at_1_2=gradient(field, (1, 2)), hessian=hessian(field, (1, 2)),
    stationary=point.point, classification=point.classification,
    search_status=field.stationary_points.status, method=field.stationary_points.method))
println("MULTIVARIATE_OK")
