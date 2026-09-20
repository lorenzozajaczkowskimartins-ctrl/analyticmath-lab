# Mechanics (Milestone 7)

Mechanics adds separate systems and `AbstractAnalysis` reports without changing
M1–M6 result layouts. There is no new numerical integrator or equilibrium solver.

## Lagrangian and Hamiltonian inputs

```julia
using AnalyticMathLab, Symbolics
@variables q v p m k t
L = LagrangianSystem(m*v^2/2-k*q^2/2;
    coordinates=(q,), velocities=(v,), nonzero=(m,))
lag = analyze(L)
ham = legendre_transform(lag; momenta=(p,))
@assert ham.status == :established
conversion = dynamics(ham.value; parameters=Dict(m=>1,k=>1))
path = trajectory(conversion,[1,0],(0,2pi); abstol=1e-10,reltol=1e-10)
energy_drift(conversion,path) # heuristic saved-time discrepancies
```

`LagrangianSystem(L; coordinates, velocities, time=nothing, rayleigh=0,
forces=nothing, parameters=Dict(), nonzero=())` accepts ordered, distinct scalar
Symbolics names, with one velocity and generalized force per coordinate.
`HamiltonianSystem(H; coordinates, momenta, time=nothing, parameters=Dict(),
nonzero=())` uses canonical ordering `(q...,p...)`. Both require positive equal
coordinate/conjugate dimensions. Mechanics itself adds no dimension cap; M5/M6
conversion limits still apply. Use independent scalar variables, not functions
`q(t)`; explicit time is a separate independent name.

Parameters remain symbolic until explicitly bound to finite real constants.
No implicit unit mass or positive-mass assumption is introduced. `nonzero=(m,)`
asserts only m != 0. Compound assumptions are allowed. Contradictory zero bindings
are rejected. Numerical conversion requires all parameters to be bound, including
names surviving only in captured source syntax. Already-bound report parameters
cannot be overridden; build a new system instead.

## Stored mathematical results

`LagrangianAnalysis` retains its system, source expression/domain, coordinates,
velocities, parameters, assumptions, momenta, Hessian, acceleration symbols,
Euler–Lagrange residuals, regularity and acceleration evidence, energy function,
energy rate, cyclic-coordinate records, and conservation evidence.

The residual convention is

    d/dt(∂L/∂v_i) - ∂L/∂q_i + ∂R/∂v_i - Q_i = 0.

The total derivative includes explicit time, every coordinate/velocity cross
term, and the velocity Hessian times accelerations. Energy is E = v·∂L/∂v - L,
with on-shell rate Σ v_i(Q_i-∂R/∂v_i)-∂L/∂t. A cyclic coordinate has conserved
momentum only when its total nonconservative force vanishes identically.

Accessors: `euler_lagrange`, `generalized_momenta`, `velocity_hessian`,
`energy_function`, `cyclic_coordinates`; each accepts a system or report.
Report-owned arrays are read-only by convention.

`HamiltonianAnalysis` retains canonical phase variables, equations/phase field,
symplectic matrix, Hamiltonian energy, and energy-conservation evidence:

    q′ = ∂H/∂p,  p′ = -∂H/∂q,
    {A,B} = Σ(∂q A ∂p B - ∂p A ∂q B),
    dA/dt = ∂t A + {A,H}.

Use `hamilton_equations`, `poisson_bracket(report,A,B)`, and
`observable_derivative(report,A)`. Brackets return formal symbolic expressions,
not domain/smoothness certificates for the observables. `force_from_potential`
returns the negative stored gradient of an existing `ScalarFieldAnalysis`;
its original domain and smooth-locus conditions remain the caller's responsibility.

## Evidence and supported inversion

`:established` formal identities apply only on the smooth original locus under
explicit assumptions. They do not establish global smoothness, existence,
uniqueness, or conservation along an arbitrary numerical curve. Conservation
requires a symbolic zero identity; a nonzero/unresolved rate yields `:unknown`,
not a guessed classification. No numerical sampling is used for these proofs.

Velocity-Hessian regularity uses exact determinant identities, numerical constants,
and explicit nonzero certificates propagated through products, quotients and
integer powers. Unknown determinants stay unknown. A zero determinant is
established singular; accelerations and Legendre inversion then remain unknown.
The verified adjugate linear solve avoids artificial pivot exclusions and checks
all residuals. Symbolic simplification and elimination are not a bounded sandbox;
large expressions/high-dimensional cofactors can be expensive. Prefer exact
integer/rational coefficients when exact arithmetic is required; floating input
retains the underlying library's floating arithmetic limitations.

`legendre_transform` returns a `PropertyResult` containing a Hamiltonian report
only for a proven-regular, affine momentum–velocity map with zero generalized and
Rayleigh forces. It solves the inverse, substitutes into every momentum and
energy identity, and pulls original source domains through the velocity map.
It does not implement constrained mechanics, nonlinear branch selection, or a
Hamiltonian representation of dissipative/forced dynamics.

## Original domains

Use `@real_function` to retain cancelled restrictions, e.g. `q/q`. Ordinary
Symbolics input cannot reveal source restrictions already erased by construction.
L/H, Rayleigh, generalized-force and nonzero-assumption domains all participate.
Report domains use `(states..., time?, remaining source names...)`; consult
`report.domain.variables` for the exact order, which includes explicit parameter
names. Numerical conversion substitutes parameter bindings into source syntax
without cancelling restrictions, then uses state/time-only domains.
Unknown membership blocks trajectory integration. Domain checks happen at solver
stages and saved energy samples; they do not certify every point of the native
dense interpolant or locate domain boundaries. Formal differentiation does not
prove differentiability at square-root/absolute-value boundaries.

## Reused dynamics and views

`dynamics(report; parameters=Dict(), kwargs...)` returns `MechanicsDynamics`,
retaining the source report, state order, M6 system, cached autonomous analysis,
compiled energy and domain. An explicit `time` chooses `FirstOrderODE`; otherwise
it reuses `AutonomousSystem` and `DynamicalSystemAnalysis`. Autonomous analysis
keywords such as `bounds` forward to the existing vector-field analyzer. M6
trajectory options and Float64 integration semantics remain unchanged.

`trajectory(conversion, u0, tspan; kwargs...)` delegates to M6/SciML.
`energy_drift(conversion,path)` requires a path from that exact conversion and
returns copied times, sampled energies, signed drift from the initial sample,
and maximum absolute drift, all with `:heuristic` evidence. Energy for an
explicit-time Hamiltonian need not be conserved.

`phaseplot(conversion; trajectories=[path], energy_levels=[...])` reuses the
cached autonomous planar portrait. Optional contours are sampled energy levels,
not invariant-curve proofs. `energyplot(conversion,path)` labels its values as
numerical energy. Report overloads can reuse an explicit `conversion` (required
for report energy plots); neither view integrates a trajectory. Callers load a
Makie backend, never mechanics analysis itself.

Run `julia --project=. notebooks/mechanics.jl` for executed symbolic assertions,
oscillator/pendulum/damped/coupled/driven trajectories, and representative figures
in ignored `notebooks/output/`. Canonical mechanics and rendering tests are wired
into `test/runtests.jl`, with backend checks before rendering imports. No M8 work
or publishing is part of this milestone.

## Addendum: force models and energy semantics

The existing `forces` interface accepts arbitrary symbolic `Q(q,v,t)`, with the
Euler–Lagrange convention `d/dt(L_v) - L_q + R_v - Q = 0`.
For symmetric C, `R = v'C*v/2` gives `R_v = C*v`; equivalently use `Q = -C*v`
without Rayleigh dissipation. Do not apply both for the same physical force.
Positive semidefiniteness of C is a separate physical assumption, not implied by
the existence of a Rayleigh function. Scalar damping is the one-coordinate case.

Stokes sphere drag `Q = -6*pi*eta*radius*v` is an effective creeping-flow,
low-Reynolds-number model with the appropriate sphere/boundary assumptions,
not a universal drag law or a fluid solver. Quadratic drag `Q = -c*abs(v)*v`
and vector drag `Q = -c*sqrt(sum(v_i^2))*v` use generalized forces, not the
standard quadratic Rayleigh function. Unsupported nonsmooth local derivative
operations must not be inferred just because a force can be evaluated.

Rayleigh damping and driving coexist: `L=(m*v^2-k*q^2)/2`, `R=c*v^2/2`,
`Q=F0*cos(Omega*t)` produce `m*qdd+c*qd+k*q=F0*cos(Omega*t)`.
An explicit `time` variable selects the existing nonautonomous M6 path through
`dynamics`; `trajectory` uses its existing SciML integrator.

The stored Lagrangian energy is `E=sum(v_i*L_v_i)-L`. Its formal balance is
`dE/dt=sum(v_i*(Q_i-R_v_i))-L_t`. It agrees with ordinary kinetic plus potential
energy only for the appropriate natural mechanical model. A Hamiltonian is a
separate canonical object; dissipative systems do not gain a Hamiltonian just
by having an energy expression. Nonzero/undecided balance does not certify
conservation or monotonic loss. Numerical energy samples remain heuristic;
even a decreasing plot is not proof that `dE/dt <= 0` globally.

The generic potential/force/Hessian, Cartesian layout, particle Hamiltonian and
future numerical-force boundaries are specified in [MD readiness](md-readiness.md).
These contracts do not implement M8.

## Local oscillations and normal modes

`linearize_mechanics(report, equilibrium; parameters=Dict())` accepts an ordered
coordinate tuple/vector, with zero generalized velocity and acceleration. It
returns `MechanicalLinearization`, storing M/C/K, equilibrium residual, original
domain, domain/equilibrium evidence, bound source and coordinate ordering.
For the stored EL residual E, the matrices are locally `E_acceleration`,
`E_velocity`, `E_coordinate`; this avoids inventing a T/V decomposition. For a
natural conservative system they coincide with the local velocity Hessian and
potential Hessian; for standard Rayleigh damping C is the velocity Hessian of R.
General forces contribute their correctly signed local derivatives. C can also
contain gyroscopic terms; the field name does not certify physical dissipation.

The residual must simplify exactly to zero and the existing original-domain
smooth-neighborhood gate must pass. Explicit-time systems and unresolved domain
parameters return unknown. Symbolic formal coefficients remain available even
when applicability is unknown. For the nonlinear pendulum they give
`M=m*l^2`, `K=m*g*l`, hence `K/M=g/l`; binding positive m/l/g establishes the
supported numerical mode without altering the original sine/cosine dynamics.
M6 state ordering remains `(q...,v...)`; its Jacobian agrees with
`[0 I; -M\K -M\C]` in the tested regular cases. No second stability classifier
or equilibrium search is maintained here.

`normal_modes(report, equilibrium; parameters=Dict(), kwargs...)`,
`normal_modes(linearization; kwargs...)`, and
`normal_modes(K, M; equilibrium=nothing, metadata=NamedTuple(), atol=1e-10,
rtol=1e-8)` share `NormalModeAnalysis`. Mechanical entry requires established
linearization and exactly zero C. The direct path trusts supplied matrix and
equilibrium provenance; it does not establish a stationary configuration.
The optional no-equilibrium convenience overload is deliberately not provided.

Finite real symmetric K and positive-definite M are converted to Float64 for
the dense symmetric eigensolver. The principal symmetric roots give
`D=M^(-1/2)*K*M^(-1/2)`, `D*e=lambda*e`, and `a=M^(-1/2)*e`.
Full SPD matrices are supported; M need not be diagonal. Stored fields include
raw eigenvalues, physical frequencies, generalized and weighted mode vectors,
M/K, roots, D, degeneracy index groups, zero-mode indices, equilibrium, evidence,
normalization and extensible metadata. `reconstruction` stores reconstructed K,
not a particle geometry. `metadata.reconstruction_convention` explicitly states
the vector conversion. Columns satisfy `a'M*a=I` and `e'e=I`; arbitrary overall
signs and bases within degenerate spaces have no unique physical significance.

All eigensolver results are `:heuristic`, including those with exact input
coefficients. `metadata.matrix_evidence` distinguishes exact, symbolic and
numerical inputs without upgrading the spectrum to a symbolic proof. Failed
applicability gives `:unknown` and unavailable spectral fields. Original input
matrices are retained; accepted near-symmetric numerical matrices are
symmetrized for computation. Symmetry discrepancy threshold is
`atol+rtol*opnorm(A,Inf)`; mass Cholesky must succeed and eigenvalues must exceed
`n*eps(Float64)*maximum(abs,mass_eigenvalues)`. Unresolved numerical rank,
including very ill-conditioned positive-definite masses, returns unknown rather
than trusting a rounded zero eigenvalue's sign. Nonzero coefficients that would
underflow to zero on Float64 conversion also return unknown. Diagonal and equal
entries are preserved during symmetrization, including subnormals. The
spectral threshold is `atol+rtol*maximum(abs,eigenvalues)`. Values within it are
numerical zero modes; negative values below it are unstable with `missing`
frequency; positive values above it have `sqrt(lambda)` frequencies. Raw signed
eigenvalues are retained, not replaced by `abs`. Degeneracy uses the same
threshold relative to the first member of each group. Thresholds and residuals
are stored, not advertised as certified error bounds or exact multiplicities.

`cartesian_mass_matrix(masses,d)` returns a type-preserving Diagonal with each
strictly positive finite real mass repeated d times. Unresolved symbolic masses
are rejected rather than assumed positive. Supply explicit optional metadata
such as `coordinate_layout=(particle_count=2,spatial_dimension=1,
ordering=:particle_major)` on the mode call. The helper itself returns only a
matrix, not a particle type. `metadata.zero_mode_categories` is an initially
empty index-to-Symbol adapter slot; generic analysis does not infer translation
or rotation. Additional adapter metadata remains optional.

`modeplot(result; modes=nothing, representation=:generalized)` plots components
against generalized-coordinate index. `representation=:mass_weighted` shows e.
It consumes stored modes without mutation or backend activation. No physical
geometry or animation is inferred. Run `notebooks/mechanics_addendum.jl` for
asserted harmonic/coupled/pendulum, drag/drive, unequal-mass, pair-potential and
Hamiltonian examples plus useful mode-shape and driven-response plots.
