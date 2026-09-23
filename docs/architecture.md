# Architecture and API contracts (Milestones 4.5–7)

Milestone 4.5 reorganizes the Milestones 1–4 implementation, without adding a
mathematical domain or changing public exports, result layouts, or constructors.
There is one public module, `AnalyticMathLab`. Internal source paths and `_ra_*` /
`_mv_*` helpers are not public APIs. Milestone 5 adds a separate vector-field
subsystem on these boundaries; it does not change existing scalar result layouts.

## Dependency direction and source ownership

All package includes are explicit in `src/AnalyticMathLab.jl`, in this order:

1. `src/core/contracts.jl`: `AbstractAnalysis`, `PropertyResult`, finite-real
   validation, and shared absolute/relative residual controls.
2. `src/core/expressions.jl`: `RealExpression`, `@real_function`, and AST/operator
   normalization. Historical `_ra_ast`/`_mv_ast` and `_ra_op`/`_mv_op` names alias
   the same normalization functions; they do not merge the domain vocabularies.
3. `src/core/exact_algebra.jl`: bounded rational-polynomial arithmetic, parsing,
   factorization, syntax preflight, and resource accounting. Historical `_ra_*`
   names remain internal for minimal refactoring churn.
4. `src/analysis.jl`: univariate result containers and display;
   `src/real_analysis.jl`, `src/real_analysis_domain.jl`,
   `src/real_analysis_transforms.jl`, `src/real_analysis_periodic.jl`, and
   `src/real_analysis_display.jl`: specialized real-domain inference and evidence.
5. `src/multivariate_domain.jl`: original-syntax restrictions and membership;
   `src/multivariate_analysis.jl`: scalar-field reports, derivatives, smoothness
   gates, stationary solving, classification, and display.
6. `src/vector_fields/analysis.jl`, `src/vector_fields/calculus.jl`,
   `src/vector_fields/zeros.jl`, and `src/vector_fields/display.jl`: vector-map
   reports, calculus/potential evidence, field zeros, and text display.
7. `src/dynamical_systems/analysis.jl`, `src/dynamical_systems/stability.jl`,
   `src/dynamical_systems/display.jl`, and `src/dynamical_systems/integration.jl`:
   autonomous reports reusing vector fields, local classification, text display,
   and numerical first-order ODE integration through SciML.
8. `src/mechanics/core.jl`, `src/mechanics/hamiltonian.jl`,
   `src/mechanics/legendre.jl`, `src/mechanics/bridge.jl`, and
   `src/mechanics/normal_modes.jl`: formal mechanics, verified affine Legendre
   inversion, conversion to M6, local EL coefficients and generic normal modes.
9. `src/atomistic/core.jl`, `src/atomistic/inspection.jl`,
   `src/atomistic/potentials.jl`, `src/atomistic/distributions.jl`, and
   `src/atomistic/modes.jl`: borrowed particle data, inspection, scalar potential
   composition, streaming pair distributions, and the existing M7 mode bridge.
10. `src/trajectory/statistics.jl`, `src/trajectory/uncertainty.jl`,
   `src/trajectory/transport.jl`, and `src/trajectory/analyst.jl`: M8B time semantics,
   borrowed observables, correlated-sampling statistics, transport and opt-in diagnostics.
11. `src/numerical.jl`: legacy evaluation, stationary search, derivative comparison;
   `src/symbolic.jl`: univariate Symbolics orchestration;
   `src/convergence.jl`: controlled finite-difference experiments and display.
12. `src/visualization/real.jl`, `src/visualization/plots.jl`,
   `src/visualization/scalar_fields.jl`, `src/visualization/vector_fields.jl`,
   `src/visualization/dynamical_systems.jl`, `src/visualization/mechanics.jl`,
   `src/visualization/potentials.jl`, `src/visualization/atomistic.jl`, and
   `src/visualization/trajectory.jl`:
   Makie consumers of stored reports.

The optional `ext/AnalyticMathLabMollyExt.jl` loads only with Molly;
its contracts and public M8A API are documented in [atomistic analysis](atomistic.md).
M8A is the configuration layer; [M8B](trajectory_statistics.md) composes the
trajectory/statistical layer without changing snapshot or lazy-frame contracts.
The shared core depends on neither study type nor numerical experiment nor
presentation. Multivariate restrictions can load with the core and Symbolics,
without loading `RealFunctionStudy`, scalar solvers, or Makie. Scalar stationary
solving reuses the core rational engine, not the univariate study pipeline.
Convergence consumes `FunctionAnalysis` and finite-value validation, not real
function certificates. Domain walkers remain specialized: interval unions in
one variable and syntax constraints in multiple variables have different
semantics and should not be forced under a generic abstract domain.

Includes are centralized, but runtime function calls may refer to functions
introduced by later includes. Importing the public module loads all prerequisites;
individual subsystem files are not standalone public entry points. The isolated
core fixture in `test/architecture.jl` explicitly lists its prerequisites.

## Public dispatch and compatibility

- `analyze(expression::Real, variable::Symbolics.Num)` returns `FunctionAnalysis`.
  Symbolics scalar numbers are included in `Real`. A `RealExpression` wrapper
  forwards the preserved syntax through the corresponding scalar method.
- `analyze(expression::Real, variables::Union{Tuple,AbstractVector})` selects
  `ScalarFieldAnalysis`, including a one-element variable collection. Variables
  are validated and retained in order. A collection of variables does not make
  the expression vector-valued. A separate tuple/AbstractVector component method
  returns `VectorFieldAnalysis` for rectangular as well as square maps.
- `evaluate`, `gradient`, `hessian`, `directional_derivative`, and `linearization`
  dispatch on the stored report type. Symbolic gradient/Hessian access returns
  copies; numerical access reuses compiled callables.
- `plot`, `surface`, and `contour` extend the imported Makie functions, rather
  than creating competing generics. `gradient` and `hessian` are package-owned;
  qualify them as `AnalyticMathLab.gradient` / `AnalyticMathLab.hessian` when
  another imported package exports the same names. No broad fallback methods
  are added to third-party types.
- Existing result field layouts and permissive constructors remain intact,
  including six-argument `FunctionAnalysis` and `CriticalPointAnalysis`
  compatibility constructors. No status enum or new mandatory fields are added.

`test/architecture.jl` checks the complete export set, Makie binding identity,
scalar dispatch, inference on representative numerical paths, and ambiguities
across AnalyticMathLab, Symbolics, Makie, and LinearAlgebra. Only ambiguity pairs
with a method owned by AnalyticMathLab are failures; this is not a claim that all
third-party methods or every possible future package combination are unambiguous.

## Evidence, validation, and original domains

`PropertyResult(value, status, method, notes)` separates evidence from algorithm.
`:established` means established within the supported class and assumptions;
`:heuristic` does not certify completeness; `:unknown` gives no complete
conclusion, even when verified partial candidates are retained. An empty value
is not proof of absence unless the status and claim warrant it. Domain `:partial`
and legacy search `:not_requested` / `:nonisolated` retain specialized meanings.
Constructor acceptance of Symbol-valued statuses is unchanged.

Both stationary pipelines share the control validation for
`residual_tolerance + residual_rtol * residual_scale`: positive finite absolute
tolerance and scale, nonnegative finite relative tolerance, and finite effective
threshold. This is a residual acceptance test, not a root-position bound. Solver
algorithms, classification thresholds, and completeness claims stay specialized.

Capture original syntax before Symbolics cancels restrictions, using
`@real_function`. A plain Symbolics expression cannot reveal restrictions already
erased by construction. Caller-supplied `original_expression` must describe the
same mathematical expression and variable names; equivalence is trusted, not
proved. AST normalization never executes captured code. Restriction evaluation
uses a limited operation vocabulary, not Julia `eval`.

Original exclusions survive simplification. Partial multivariate domains reject
independently known exclusions even if another restriction cannot be resolved;
otherwise membership returns `nothing`, not `true`. Numerical scalar-field
derivatives, directional derivatives, and linearization require the existing
sufficient open-smooth-neighborhood gate. Formal symbolic derivatives do not
establish smoothness. Scalar-field evaluation rejects known exclusions and
nonfinite values, but unresolved membership is not proof of validity.

For compatibility, univariate `evaluate` still exposes the generated callable's
behavior (including cancellations and NaNMath results), and legacy stationary
search assumes smoothness across the supplied interval. Neither silently becomes
a checked-domain API. Check the stored real domain separately when needed.

## Resource and inference boundaries

The shared dense rational engine limits degree to 64, projected coefficient size
to 4096 bits, and scoped cumulative work to 200,000 units. Syntax preflight caps
512 nodes and depth 48; supported integer powers have magnitude at most 32.
Bounds precede expensive dense arithmetic; a dedicated budget exception becomes
explicit unknown/resource-budget evidence where handled by the study pipeline.
Exact integer/rational restriction arithmetic uses BigInt to prevent machine
wraparound. These are conservative implementation limits, not mathematical limits.

This is not a global computation sandbox. Symbolics expression construction,
derivative generation/compilation, exact affine-system elimination, and general
library routines are not all governed by the polynomial work counter. Scalar
search separately caps variables, seed counts, and Newton iterations as documented
in the README. Keep these limits scoped honestly rather than promising bounded
execution for arbitrary symbolic input.

Concrete compiled callables and parametric report fields preserve inference on
hot numerical paths. Symbolic orchestration, heterogeneous evidence, captured
syntax, and domain reasoning remain dynamic. `RealInterval` retains abstract
real endpoints for compatibility; real membership can show a wider inferred
union than the actual supported membership contract. Do not change public field
layouts or mathematical semantics just to eliminate inference coloring.

## Presentation and backend isolation

Analysis neither renders, prints, saves, nor activates a backend. The package
imports Makie, but does not import CairoMakie or GLMakie; callers choose a backend.
CairoMakie remains a project dependency for existing headless examples/tests.
Result objects contain no backend state. Plots reuse stored inference and
callables: curve/grid sampling is presentation, not new mathematical evidence.
Convergence plots use stored discrepancies without reevaluating the function.
Original-domain gaps and conservative scalar-field cell masks remain intact.

Structs are immutable but stored vectors and captured `Expr` objects are mutable.
Treat report-owned data as read-only or deep-copy it before editing. Display and
plotting must not mutate analyses. No generic immutability wrapper is introduced.

## Vector-field extension (Milestone 5)

`VectorFieldAnalysis` composes shared contracts and preserves input/output
dimensions separately. Existing `RealExpression` / `@real_function` capture is
reused for literal component vectors/tuples: no duplicate wrapper or macro.
Each original component has a `MultivariateDomain`; the intersection retains all
known restrictions and propagates unresolved evidence. Scalar smoothness checks
are applied componentwise before numerical Jacobians or linearizations.

The exact affine/separable system solver is reused via a small internal adapter
that supplies the field vector and Jacobian in the existing solver protocol.
The bounded Newton loop now accepts residual/Jacobian callbacks; scalar stationary
search wraps it with gradient/Hessian callbacks, retaining its existing behavior.
No second nonlinear solver is copied. Rectangular explicit searches use the same
matrix backslash step and independently verify the full field residual.

Polynomial potentials use bounded-degree radial integration followed by exact
componentwise differentiation checks. Zero curl never substitutes for a potential
proof on an unresolved topology. Formal divergence/curl apply only on the smooth
locus; numerical Jacobians retain the stricter original-domain smoothness gate.
See [vector-field contracts](vector_fields.md) for supported classes and limits.

New exports are `VectorFieldAnalysis`, `jacobian`, `divergence`, `curl`,
`potential`, and `vectorplot`; `evaluate`, `linearization`, and Makie's `plot`
gain report-specific methods. Qualify names such as `AnalyticMathLab.jacobian`
when other packages provide a same-named function. Milestone 5 itself adds no ODE
or stability inference to vector-field reports.

## Dynamical-system extension (Milestone 6)

`AutonomousSystem` wraps a square `VectorFieldAnalysis` by identity.
`DynamicalSystemAnalysis` reuses its domain, field zeros, Jacobian, and compiled
callables, adding equilibrium-local evidence and implicit planar nullclines.
No second field analyzer or equilibrium solver is introduced. Existing report
layouts remain unchanged. Accessors return copies of new evidence collections.

`FirstOrderODE` is a separate numerical out-of-place `f(u,t)` contract, including
nonautonomous systems; it makes no equilibrium claims. `trajectory` uses SciMLBase
and OrdinaryDiffEqTsit5 and retains the native solution in `TrajectoryResult`.
These numerical dependencies do not activate a rendering backend. `phaseplot`
consumes the stored field and same-field trajectories; `timeplot` consumes saved
states without evaluating the RHS. Neither view performs integration.
See [dynamical-system contracts](dynamical_systems.md) for exact versus numerical
stability methodology, domain semantics, and limitations.

## Verification and historical preservation

Milestone 7 adds separate Lagrangian/Hamiltonian systems and reports; no existing
result layouts change. Mechanics uses formal symbolic identities only on the
smooth original locus. Regularity and affine inversion require exact residual
verification and explicit nonzero assumptions where needed. Original source
restrictions (including Rayleigh/force inputs) survive numerical conversion and
the Legendre pullback. See [mechanics contracts](mechanics.md).

`MechanicsDynamics` retains the original report, canonical state order, cached M6
analysis and compiled energy. There is no new ODE, Jacobian, or equilibrium solver.
The shared M6 numerical RHS boundary normalizes mixed real components to Float64,
matching its existing state/time contract, and rejects conversion overflow.
Energy samples and contour levels are illustrations, never conservation proofs.

The M7 addendum extends mechanics with local second-order linearization and a
single generic normal-mode result for Lagrangian or directly supplied M/K
matrices. Scalar-field gradients/Hessians and the M6 solver remain their sole
existing implementations. M7 is the mathematical mechanics foundation; M8 is
the future particle-state/force-provider/geometry layer. The optional future
Molly adapter is outside the core and no dependency is added here. See
[MD-readiness boundary](md-readiness.md) for numerical versus symbolic providers,
coordinate reconstruction and the future scientific vibration pipeline.

From the repository root:

```sh
julia --project=. -e "using Pkg; Pkg.test()"
julia --project=. -e "using AnalyticMathLab"
julia --project=. notebooks/function_analysis.jl
julia --project=. notebooks/derivative_convergence.jl
julia --project=. notebooks/real_function_analysis.jl
julia --project=. notebooks/multivariable_analysis.jl
julia --project=. notebooks/vector_field_analysis.jl
julia --project=. notebooks/dynamical_systems.jl
julia --project=. notebooks/mechanics.jl
julia --project=. notebooks/mechanics_addendum.jl
```

The canonical runner includes architecture, source capture, real-core/integration,
scalar-field, domain-regression, convergence, and rendering tests. Backend-absence
checks execute before rendering imports. Architecture documentation paths and
centralized include ownership are also regression-tested. Generated outputs go
under ignored `notebooks/output/`, not into the source tree or public API.

The Python implementation remains at tag `python-v0.1` and branch `legacy-python`,
both rooted at `6820e97`. This milestone does not modify those refs or introduce
Python source copies. Publishing and Milestone 8 are outside this milestone.
