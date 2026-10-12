using AnalyticMathLab, Symbolics

@variables q v p
# Dimensionless mass m=2 and stiffness k=8: T=m*v^2/2, V=k*q^2/2.
lag = analyze(LagrangianSystem(v^2 - 4q^2; coordinates=(q,), velocities=(v,)))
zero_identity(e) = iszero(Symbolics.simplify(Symbolics.expand(e)))
@assert zero_identity(only(generalized_momenta(lag)) - 2v)
@assert velocity_hessian(lag) == reshape([2], 1, 1)
@assert lag.regularity.status == :established && lag.regularity.value === true
acceleration = only(lag.acceleration_symbols)
@assert zero_identity(only(euler_lagrange(lag)) - (2acceleration + 8q))
@assert zero_identity(energy_function(lag) - (v^2 + 4q^2))
transform = legendre_transform(lag; momenta=(p,))
@assert transform.status == :established
ham = transform.value
@assert zero_identity(energy_function(ham) - (p^2/4 + 4q^2))
@assert all(zero_identity, hamilton_equations(ham) - [p/2, -8q])
@assert ham.phase_variables == (q, p)
local_model = linearize_mechanics(lag, (0,))
@assert local_model.mass_matrix == reshape([2], 1, 1)
@assert local_model.stiffness_matrix == reshape([8], 1, 1)
println((momentum=only(generalized_momenta(lag)), mass=velocity_hessian(lag),
    lagrangian_energy=energy_function(lag), hamiltonian=energy_function(ham),
    hamilton_flow=hamilton_equations(ham), legendre_status=transform.status))
println("MECHANICS_OK")
