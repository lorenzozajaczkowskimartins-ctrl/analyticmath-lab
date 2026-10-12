using AnalyticMathLab, Symbolics

@variables x y
rotation = analyze([-y, x], (x, y))
@assert rotation.variables == (x, y)
@assert evaluate(rotation, (1, 2)) == [-2, 1]
@assert jacobian(rotation) == [0 -1; 1 0]
@assert jacobian(rotation, (1, 2)) == [0 -1; 1 0]
@assert divergence(rotation).status == :established
@assert divergence(rotation).value == 0
@assert curl(rotation).status == :established
@assert curl(rotation).value == 2
@assert rotation.conservative.value === false
@assert potential(rotation).status == :unknown

radial = analyze([2x, 2y], (x, y))
@assert curl(radial).value == 0
@assert radial.conservative.value === true
phi = potential(radial)
@assert phi.status == :established
@assert iszero(Symbolics.simplify(Symbolics.expand(phi.value - x^2 - y^2)))
println((rotation_value=evaluate(rotation, (1, 2)), jacobian=jacobian(rotation),
    divergence=divergence(rotation).value, planar_curl=curl(rotation).value,
    rotation_potential_status=potential(rotation).status, radial_potential=phi.value))
println("VECTOR_CALCULUS_OK")
