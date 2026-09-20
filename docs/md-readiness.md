# M7 boundary: vibrations now, particle dynamics later

M7 is a mathematical mechanics foundation, not a molecular-dynamics simulator.
The generic calculus, mechanics, M6 trajectory and normal-mode APIs are usable
without chemical types or a symbolic expression for every future force model.

## Dependency boundary

```text
AnalyticMathLab core
  multivariate calculus: gradient / Hessian
  dynamical systems: Jacobian / first-order trajectories
  analytical mechanics: Lagrangian / Hamiltonian / generalized forces
  small oscillations: M / C / K / normal modes / mass weighting
       |
       v
future M8 particle-system adapter
  particle state / potentials / force providers / trajectories / observables
  coordinate geometry and animation
  optional Molly.jl adapter
```

There are no Molly imports or dependencies in M7. An eventual adapter must stay
optional. No particle, molecule, thermostat, neighbor-list, boundary-condition,
Verlet or stochastic-integration subsystem is introduced here.

## Potential, force and Hessian

For a symbolic scalar potential use `analyze(U, coordinates)` once, then
`force_from_potential(report)` (negative stored gradient), `gradient(report)`,
`hessian(report)` and `hessian(report, equilibrium)`. These are the existing
scalar-field derivatives, not a second mechanics differentiation engine.
Formal symbolic expressions hold on the report's smooth original locus;
evaluated derivatives require its supported open-neighborhood domain gate.
Keep the scalar report with these arrays to retain source/domain provenance.
A matrix supplied directly to a mode solver carries no proof that an imported
configuration is an equilibrium: that is the provider's responsibility.

The future force-provider boundary is conceptually:

```text
energy(R)         optional when only a force is known
force(R)          numerical or symbolic
hessian(R)        optional; with method/evidence provenance
```

Sources may include native symbolic potentials, user-defined numerical potentials,
Molly interactions, bonded interactions, imported force fields, automatic
differentiation or direct numerical force implementations. A numerical force
alone does not establish a potential, conservativity, an exact Hessian or Newton
pair antisymmetry. Do not integrate arbitrary forces numerically and relabel the
result an established potential. Missing capabilities stay unknown/unavailable.

## State and coordinate layout

Generic `q`, `v`, `p` map to particle positions `R`, velocities `V`, momenta `P`
only through an explicit adapter. A particle-major Cartesian ordering is
`[x1,y1,z1,x2,y2,z2,...]` in three dimensions, or the analogous `d` components
per particle for any supported positive dimension. A repeated diagonal mass
matrix repeats each particle's mass `d` times. Full generalized mass matrices
remain valid: generalized coordinates need not be Cartesian positions.

A future adapter can associate particle indices, component indices, masses,
equilibrium positions, species and element labels through optional metadata.
Chemistry metadata is not mandatory in generic mechanics. It should attach
`:translation`, `:rotation`, `:constraint`, `:symmetry` or `:other_neutral`
only when independently justified. A zero eigenvalue alone identifies none of
these physical origins; it is a neutral direction of the quadratic model.

For positive-definite M, the convention is `e = M^(1/2)*a`,
`a = M^(-1/2)*e`, with `e'e = 1` and `a'M*a = 1` for each mode.
For Cartesian layout `a` is the physical displacement, not `e`.
The full matrix convention uses the symmetric positive-definite square root,
not an undocumented Cholesky-coordinate convention.
A geometry-aware future consumer may reconstruct
`R(t) = R* + A*a*cos(omega*t + phi)` for an oscillatory mode.
Zero/unstable modes must not be animated as fictitious oscillations; individual
bases inside degenerate eigenspaces are not physically unique. M7 plots mode
components against coordinate index, never invented particle geometry.

## Hamiltonian and dissipative mappings

The existing HamiltonianSystem represents
`H(R,P) = sum(P_component^2/(2*m_particle)) + U(R)`.
Hamilton equations give `Rdot = M^-1*P` and `Pdot = -gradient(U)`.
The two-coordinate unequal-mass harmonic-pair regression verifies this mapping
without claiming that the toy spring model is a realistic molecule.

Future particle dynamics need not be Hamiltonian. Existing generalized forces
and Rayleigh dissipation represent `M*Rddot = F(R) - Gamma*V + external terms`.
Langevin dynamics, thermostats, random forces and stochastic integrators require
future work; none is implemented by this deterministic mechanics addendum.

## Scientific pipeline and scope

```text
U(R) -> F(R) = -grad(U)
     -> equilibrium search or imported R*
     -> H_U(R*) -> M -> D = M^(-1/2)*H_U*M^(-1/2)
     -> NormalModeAnalysis -> harmonic frequencies and displacement modes
     -> future comparison with nonlinear MD trajectories
```

This contract prepares molecular vibrations, local atomistic stability, harmonic
approximations around minima, comparison with trajectories, vibrational density
of states, lattice/material vibration and future phonon-oriented work. It does
not implement IR/Raman intensities, spectroscopy, phonon bands, Brillouin-zone
sampling, periodic-crystal dynamical matrices or force-field parameterization.
Dense small/moderate mode problems are the present scope. Large-N simulation,
sparse/iterative eigensolvers and high-performance force kernels are future
specialized work; no quadratic symbolic pair expansion is baked into this API.
