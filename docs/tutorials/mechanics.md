# Analytical mechanics: from velocity to canonical momentum

[Learning path](index.md) · Previous: [vector calculus](vector-calculus.md) ·
Next: [normal modes](normal-modes.md)

Prerequisites: derivatives, energy and Newton's law. Difficulty: intermediate.
Dependencies: AnalyticMathLab and Symbolics in the checkout project.
Executable: [mechanics.jl](scripts/mechanics.jl). From the repository root:

```sh
julia +1.12.7 --project=. docs/tutorials/scripts/mechanics.jl
```

## Physical model and assumptions

Consider one conservative harmonic oscillator with a dimensionless mass parameter
$m=2$, stiffness $k=8$, coordinate $q$ and generalized velocity $v=\dot q$.
This is the one-coordinate oscillator model already used in the mechanics guide,
with explicit numerical constants chosen to make momentum different from velocity.
There are no dissipative forces, external drive or explicit time dependence.
All quantities are deliberately dimensionless, not SI measurements with inferred units.

$$T=\tfrac12mv^2=v^2,\quad V=\tfrac12kq^2=4q^2,\quad L=T-V.$$

The independent Symbolics names `q` and `v` represent a coordinate and its velocity
when constructing the mechanics object; they are not functions `q(t)`.
The Euler–Lagrange equation is

$$\frac{d}{dt}\frac{\partial L}{\partial v}-\frac{\partial L}{\partial q}=0,
\qquad 2\ddot q+8q=0.$$

Canonical momentum is $p=\partial L/\partial v=2v$, and the velocity Hessian is
$\partial^2 L/\partial v^2=2$. Its nonzero value establishes regularity and allows
inversion $v=p/2$. The Legendre transform gives

$$H(q,p)=pv-L(q,v(q,p))=p^2/4+4q^2.$$

Hamilton's equations, in phase order $(q,p)$, are
$\dot q=p/2$, $\dot p=-8q$. Substituting $p=2\dot q$ recovers the same EL equation.
Its oscillation frequency is $\sqrt{k/m}=2$ in the declared time scale.

## Implementation

AML's `euler_lagrange` returns residual expressions set equal to zero, not explicit
solutions $q(t)$. The report's generated acceleration symbol is used only to
verify that residual. `legendre_transform` returns a `PropertyResult`; on success,
its `value` is already a `HamiltonianAnalysis`, not a system needing another analyze.

```julia
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
```

## Verification and result interpretation

EXACT_IDENTITY / ANALYTICAL_REFERENCE: direct differentiation supplies momentum,
velocity Hessian, EL residual and Hamiltonian; symbolic zero differences check
all of them, including Hamilton's two first-order equations.
EXAMPLE_EXECUTED: momentum `2v`, mass matrix `[2;;]`, Hamiltonian
`p^2/4 + 4q^2`, flow `[p/2,-8q]`, and Legendre status `:established` were observed.
Local linearization at $q=0$ recovered mass 2 and stiffness 8 exactly.
The system is already linear, so this particular linearization is the full model.

Energy is $E=v\,\partial_v L-L=v^2+4q^2=T+V$ here. Time independence and absent
nonconservative forces establish the formal on-shell energy identity for this
model. They do not establish exact conservation along a floating-point trajectory.
For general Lagrangians, this energy need not equal an arbitrarily chosen $T+V$.

## Limitations and next steps

The supported Legendre route requires proven regularity, an affine momentum–velocity
map and no generalized/Rayleigh forces. It is not a universal inverse for singular
systems, nonlinear branches, constraints or dissipative dynamics. Unknown regularity
must not be treated as false, or silently replaced by unit mass.
For $n$ natural coordinates, $p=Mv$; converting between $(q,v)$ and $(q,p)$
requires that matrix, not relabeling the same numerical state.

Continue to [coupled normal modes](normal-modes.md) and
[numerical first-order systems](odes.md). The existing [mechanics guide](../mechanics.md)
covers parameter assumptions and forced systems. The
[capstone](one-system-many-methods.md) reuses its unchanged two-coordinate model;
this one-coordinate lesson does not change it.
[Execution record](../../reports/m10d6/tutorial_implementation_report.md).
