# M10D.1 architecture and public API freeze

Baseline: `ff28e89bb08f95015d241091de7406d8f02d5861`. One public module:
`AnalyticMathLab` (AML). This document is the authoritative pre-1.0 boundary
inventory; [architecture.md](architecture.md) retains implementation history.
No version bump, exported symbol removal, rename or scientific algorithm change.

## Classification policy and scope

Each numbered family has exactly one classification. PUBLIC_STABLE means retain
its documented scientific contract for 1.0, not universal support for arbitrary
inputs or a guarantee of exact answers. PUBLIC_EXPERIMENTAL means intentionally
user-facing but its backend/schema/semantic boundary is not yet frozen for 1.0;
use qualified APIs and the documented environment. INTERNAL means no external
constructor, file-path, helper or type-identity compatibility promise. REDUNDANT,
RENAME_BEFORE_1_0 and REMOVE_BEFORE_1_0 are available decisions, but no evidenced
safe candidate currently warrants them. Similar names alone are not duplicates.

Every explicit export is owned by exactly one row below. Shared generic names
are assigned to their primary family; their other methods are cross-referenced,
not counted as extra exports. Unexported returned records and Base/Makie methods
are inventoried too. All paths below are relative to the repository and all core
families belong to AML. `ext/` modules are private implementation boundaries.

Conventions applying to every row:

- Inputs/outputs below describe supported factories/accessors, not a promise that
  raw positional struct constructors validate scientific invariants. Existing
  compatibility constructors remain, but report factories are the normal entry.
- A result being an `AbstractAnalysis` is not proof it has an `analyze` method,
  common fields, common units, or established evidence. The marker is not an
  execution protocol; `TrajectoryResult` and `DynamicsTrainingResult` need not
  subtype it. No forced hierarchy is introduced.
- Owned/borrowed arrays are read-only by convention, not deeply immutable.
  Direct mutation can invalidate evidence. Backend objects retained for inspection
  are intentional escape hatches, not AML-owned stable backend APIs.
- Unit metadata alone does not convert values; where dimensioned arithmetic is
  not supported, callers must explicitly nondimensionalize. Unknown units never
  become dimensionless by default. Column/coordinate order is never guessed.
- `PropertyResult` separates value/status/method/notes; `:unknown` can retain
  partial evidence. Optimizer success, small residual and physical correctness
  are different claims. See semantic targets below for current inconsistencies.

## Public family ownership and scientific contracts

Each row gives purpose and input → output; evidence; units/domain/order; backend,
consumers, overlap and integration risk. Supporting contract tests are evidence
of intended behavior, not a claim all were rerun in M10D.1.

| ID / classification | Names (primary ownership) | Location / purpose and input → output | Evidence; units, domain and ordering | Backend / consumers / overlap / risks |
|---|---|---|---|---|
| F01 PUBLIC_STABLE | AbstractAnalysis, PropertyResult | src/core/contracts.jl; marker and `(value,status,method,notes)` claim container | Open Symbol status; no universal unit/domain/order fields; payload-specific | Base; every subsystem. Not an analyzability protocol; status taxonomy deferred. test/architecture.jl |
| F02 PUBLIC_STABLE | RealExpression, @real_function | src/core/expressions.jl; captured original syntax + expression → reusable source wrapper | Original restrictions before symbolic cancellation; caller-supplied syntax equivalence trusted; explicit variable order downstream | Symbolics; M1/M3–M7. Not a second expression evaluator. Capture required before simplification. test/source_capture.jl |
| F03 PUBLIC_STABLE | FunctionAnalysis, CriticalPoint, CriticalPointAnalysis, analyze, evaluate | src/analysis.jl, symbolic.jl, numerical.jl; scalar expression + Num → report; report + number → value/derivative | Legacy search heuristic/not_requested/nonisolated; tolerance/rejections stored; evaluation preserves generic numeric types but is not domain-checked; one scalar variable | Base Symbolics/Roots/AD; convergence, potentials, plots. CriticalPoint differs from multivariate stationary record for scientific dimensional reasons. Six-argument compatibility constructors retained. test/runtests.jl |
| F04 PUBLIC_STABLE | RealInterval, RealDomain, RealFunctionStudy, domain_contains, PeriodicPointSet, PeriodicIntervalSet | src/real_analysis*.jl; report-owned interval unions, periodic descriptors, membership | Established/partial/unknown domains; true/false/nothing membership; exact original-domain reasoning bounded by supported classes; units not generally modeled; one variable | Base; numerical safety/plots. RealDomain is not interchangeable with multivariate constraints. Direct containers do not certify content. test/real_analysis_core.jl |
| F05 PUBLIC_STABLE | DerivativeComparison, compare_derivatives, DerivativeConvergenceAnalysis, derivative_convergence | src/numerical.jl, convergence.jl; FunctionAnalysis + point → symbolic/AD/FD comparison or controlled step experiment | Absolute/relative errors and reference method; observed order optional; convergence explicitly Float64; same scalar variable, no new domain certificate | ForwardDiff/FiniteDiff; plots/research. Comparison is not statistical run comparison. test/convergence.jl |
| F06 PUBLIC_STABLE | ScalarFieldAnalysis, MultivariateDomain, StationaryPoint, gradient, hessian, directional_derivative, linearization, levelset | src/multivariate*.jl; scalar + ordered variables → report; formal/numeric derivatives, affine local map, implicit level | Original restrictions and stationary classification evidence; numerical derivatives require open smooth neighborhood; no generic physical-unit inference; tuple/vector order retained | Symbolics/base; force, Hessian/modes, plots. One-element variable collection still scalar-field API. `linearization` is not mechanical second-order linearization. test/multivariate_regressions.jl |
| F07 PUBLIC_STABLE | VectorFieldAnalysis, jacobian, divergence, curl, potential | src/vector_fields/*.jl; components + variables → rectangular map report and calculus evidence | Component domains intersect; residual-checked zeros; potential requires direct verification, not zero-curl shortcut; inputs/outputs ordered independently; plain numeric coordinates | Base; autonomous systems, plots. Scalar gradient/Hessian and vector Jacobian are different shapes by design. Name collisions with other packages require qualification. test/vector_regressions.jl |
| F08 PUBLIC_STABLE | AutonomousSystem, DynamicalSystemAnalysis, equilibria, stability, nullclines | src/dynamical_systems/{analysis,stability}.jl; square field → system → analysis | Same field/domain retained; equilibrium-local stability only; copies of evidence returned; coordinate order from field; no general unit conversion | Base LinearAlgebra; trajectory/phase views. A field zero is not global stability; nullclines only supported dimensions. test/dynamical_systems.jl |
| F09 PUBLIC_STABLE | FirstOrderODE, TrajectoryResult, trajectory | src/dynamical_systems/integration.jl; `f(u,t)`, dimension/domain/labels; problem or analysis + u0/tspan → native-solution holder | Explicit checked Float64 state/time boundary, small-state limit; diagnostic success/completed/retcode and tolerances, not proof of accuracy; labels retain state order; domain callback requires true | SciMLBase/Tsit5 mandatory numerical deps; mechanics/learned dynamics/plots. Not an atomistic trajectory and not automatically a statistical series. test/trajectories.jl |
| F10 PUBLIC_STABLE | LagrangianSystem, LagrangianAnalysis, euler_lagrange, generalized_momenta, velocity_hessian, energy_function, cyclic_coordinates | src/mechanics/core.jl; L + named coordinates/velocities/forces/Rayleigh → formal EL report | Regularity/acceleration/conservation claims separately proven or unknown; original domains/nonzero assumptions preserved; `(q...,v...)`; formal scalars, explicit parameters | Symbolics; Legendre, dynamics, linearization. Some accessors borrow arrays unlike copy-returning Hamiltonian accessors; mutation policy deferred. test/mechanics.jl |
| F11 PUBLIC_STABLE | HamiltonianSystem, HamiltonianAnalysis, hamilton_equations, poisson_bracket, observable_derivative, force_from_potential | src/mechanics/hamiltonian.jl; H + coordinates/momenta → canonical report; scalar field → -gradient | Canonical `(q...,p...)`, formal smooth-locus identities; original domain/parameters/nonzero assumptions; no automatic SI conversion | Base; dynamics/HNN. `energy_function` shared with F10. Hamilton equations accessor returns phase-field vector, not equation objects. test/mechanics_dynamics.jl |
| F12 PUBLIC_STABLE | legendre_transform | src/mechanics/legendre.jl; regular Lagrangian → PropertyResult containing Hamiltonian construction | Verified affine momentum inversion; unsupported/nonconservative cases unknown; restrictions pulled back; canonical order and assumptions required | Base; Hamiltonian analysis. Not arbitrary nonlinear inverse or dissipative-to-conservative conversion. test/mechanics_readiness.jl |
| F13 PUBLIC_STABLE | MechanicsDynamics, dynamics, energy_drift | src/mechanics/bridge.jl; bound mechanics report → M6 conversion; matching path → sampled drift | Source identity, original domain, state order retained; autonomous/nonautonomous distinction; Float64 numerical conversion; path identity checked | Base M6; trajectories/energy views. Sample energy drift is not conservation proof; not an independent integrator. test/mechanics_dynamics.jl |
| F14 PUBLIC_STABLE | MechanicalLinearization, linearize_mechanics, NormalModeAnalysis, normal_modes, cartesian_mass_matrix | src/mechanics/normal_modes.jl, atomistic/modes.jl; equilibrium + L → M/C/K; `(K,M)` or linearization/snapshot → modal result | Equilibrium/domain/SPD/symmetry evidence; damped unsupported route unknown; dense Float64 with preflight; supplied coordinate order; snapshot route stores explicit unit scales and particle-major reconstruction | LinearAlgebra; modes/plots/atomistic. `(K,M)` ordering must be explained, not changed aesthetically. Snapshot Hessian does not certify equilibrium. test/normal_modes.jl, atomistic_modes.jl |
| F15 PUBLIC_STABLE | AtomisticSnapshot, AtomisticTrajectoryView, atomistic_snapshot, atomistic_trajectory | src/atomistic/core.jl; positions + optional physical metadata → borrowed/owned snapshot; count/getframe/times → lazy frames; Molly conversion via extension | Unknown missing quantities preserved; Unitful supported; boundary and distance-provider semantics explicit; particle-major coordinates, fixed identity not inferred | Optional Molly; geometry/statistics/modes. `atomistic_trajectory` is Molly adapter; generic users construct AtomisticTrajectoryView, not a generic simulation converter. test/atomistic_core.jl |
| F16 PUBLIC_STABLE | AtomisticSystemAnalysis, mdcheck, inspect_particle, pair_distances | src/atomistic/{inspection,core}.jl; snapshot/backend → checks/observations or pair PropertyResult | Observations are finite-sample evidence; no force/integrator reconstruction; compatible units retained; boundary-aware pair distance, explicit species/index order; output preflight | Base or Molly source; RDF/inspection. `mdcheck` distinct from trajectory `diagnose`, not duplicate generic analyze. test/atomistic_core.jl |
| F17 PUBLIC_STABLE | PotentialAnalysis, analyze_potential, lennard_jones_analysis | src/atomistic/potentials.jl; radial scalar expression/parameters → wrapped scalar analysis, force, equilibria | Radius-domain checked evaluate; explicit length/energy metadata and LJ scale certificate; cutoff is descriptive, not an implemented MD potential; radial coordinate | Base symbolic; equilibrium/plots. `potential(field)` proves a conservative potential, whereas this analyzes supplied radial U. test/atomistic_potentials.jl |
| F18 PUBLIC_STABLE | RadialDistributionAnalysis, radial_distribution, coordination | src/atomistic/distributions.jl; snapshot/frames + edges/cutoff → counts, finite-N normalized RDF or coordination | Unsupported geometry unknown; distance units/edges retained; populations and normalization explicit; selected particles/frames, no hidden neighbor engine | Base/Molly distance; static plots. Quadratic traversal unchanged. test/atomistic_distributions.jl |
| F19 PUBLIC_STABLE | SamplingInfo, sampling_info, ObservableSeries, observable_series | src/trajectory/{statistics,analyst}.jl; scalar vector/frame observable/logger + explicit time → borrowed series | Saved-sample spacing, not integrator dt; reject missing policy; unknown vs sample-index units explicit; monotone time and scalar selection | Optional Molly logger methods; all statistics. Physical metadata is not a generic table schema. test/trajectory_statistics.jl |
| F20 PUBLIC_STABLE | statistical_summary, running_statistics | src/trajectory/statistics.jl; ObservableSeries → PropertyResult moments / prefix moments | Welford n-1 variance, heuristic descriptive evidence; standard_error=nothing without correlation model; unit-aware values, missing/nonfinite → unknown; temporal order retained for prefixes | Base; comparison/MD report. `sampled_summary` F27 is residual/RMS metric, not statistical uncertainty. test/trajectory_statistics.jl |
| F21 PUBLIC_STABLE | AutocorrelationAnalysis, autocorrelation, integrated_autocorrelation_time, correlated_mean | src/trajectory/{statistics,uncertainty}.jl; scalar series → lag record / uncertainty claims | Explicit normalization/window and regular time; squared units for covariance, time units for IAT; stationarity assumptions not proven | Base; statistical comparison/plots. No IID inference from raw moments. test/trajectory_uncertainty.jl |
| F22 PUBLIC_STABLE | BlockAnalysis, block_average, transient_analysis | src/trajectory/uncertainty.jl; series + block sizes/threshold → block record or heuristic early/late claim | Discarded counts stored; block SE not automatic convergence certificate; original units and sample order; finite data requirements | Base; stored comparisons. No silent burn-in selection. test/trajectory_uncertainty.jl |
| F23 PUBLIC_STABLE | MeanSquaredDisplacement, mean_squared_displacement, diffusion_estimate, VelocityAutocorrelation, velocity_autocorrelation | src/trajectory/transport.jl; particle frames + identity/coordinate assertion → transport results | Wrapped/unwrapped/fixed-particle assumptions explicit; diffusion requires physical time and justified fit window; Unitful transport; particle identity/order must persist | Base; comparisons/views. MSD not interchangeable with scalar ACF, periodic unwrap not invented. test/trajectory_transport.jl |
| F24 PUBLIC_STABLE | MDTrajectoryAnalysis, diagnose, energy_diagnostics, momentum_diagnostics | src/trajectory/analyst.jl; frame view + opt-in requests → stored aggregate; stored report → diagnosis | Separate sampling/summary/correlation/transient/transport evidence; no automatic recompute in stored diagnosis; units/selection inherited, incomplete report allowed | Base; compare_runs/plots. `diagnose(view)` explicitly does analysis; `diagnose(report)` only summarizes. test/trajectory_analyst.jl |
| F25 PUBLIC_STABLE | ComparisonInput, ComparisonCompatibility, ObservableComparison, compare, MDTrajectoryComparison, compare_runs | src/trajectory/comparison.jl; stored results + explicit series/parent/selection context → compatibility-gated differences | Unknown units/identity/windows can withhold comparison; independence separate from compatibility; no missing result reconstruction; matching temporal/particle semantics required | Base; comparison views. Context wrapper compensates for older metadata omissions, not redundant. Not universal scientific equivalence or model ranking. test/trajectory_comparison_edges.jl |
| F26 PUBLIC_EXPERIMENTAL | PINNProblem, PINNTrainingResult, PINNHistory, pinn_network, pinn_problem, train, predict, pinn_inspect | src/scientific_ml/pinn.jl, ext/AnalyticMathLabPINNExt.jl; PDESystem + native model/strategy/RNG/AD → problem → trained holder | Construction vs fit vs physics separate; bounded history; symbolic variable order controls coordinate rows/output rows; backend domains retained, units not inferred | PINN five-trigger extension; diagnostics/views. train/predict also used by F30/F33 with deliberately different signatures/output shapes. Native backend state intentionally visible. test/pinn_base.jl, pinn_construction.jl |
| F27 PUBLIC_EXPERIMENTAL | PINNPoints, PINNAnalysis, sampled_summary, loss_breakdown | src/scientific_ml/diagnostics.jl, ext/pinn_diagnostics.jl; trained PINN + explicit points/reference → sampled residual analysis | Points own checked Float64 coordinate columns and generation/provenance; unweighted RMS/max/mean absolute not continuum norm; reference trust explicit; equation/block order matters | PINN extension for trained diagnostics; generic sampled_summary works in base; residual plots/heat metrics. Units of distinct residual blocks cannot silently be combined. test/pinn_diagnostics_base.jl |
| F28 PUBLIC_EXPERIMENTAL | ObservationSet, InferenceParameters, ParameterInferenceProblem, inference_predict, inference_objective, local_sensitivity, ParameterInferenceResult, infer_parameters | src/scientific_ml/{inference,parameter_inference}.jl; explicit observation times + parameter factory → forward problem → fit | Checked Float64 observations/parameters; variables and units must match; fit/heldout, solver/reference/provenance retained; local SVD not global identifiability; explicit inferred-name order | Base forward/ForwardDiff, Optimization for fit; parameterfitplot. Parameter units are metadata; factory owns physical interpretation. test/inference_base.jl |
| F29 PUBLIC_EXPERIMENTAL | distance_observations | src/scientific_ml/trajectory_inference.jl; explicit particle pair/frames → ObservableSeries → ObservationSet overload | Actual physical times, minimum-image provenance, positive scales for Unitful conversion; pair/time order preserved; unknown/index time refused | Base atomistic/inference; fitting. Existing narrow bridge, not arbitrary trajectory serialization. test/trajectory_inference.jl |
| F30 PUBLIC_EXPERIMENTAL | DerivativeData, TrajectoryData, HamiltonianNN, UDEProblem, DynamicsTrainingResult, learned_energy, learned_vector_field, learned_correction, dynamics_objective, aligned_energy | src/scientific_ml/learned_dynamics.jl, ext/AnalyticMathLabDynamicsExt.jl; canonical derivative/trajectory data + Lux model → learned field / fitted model; predict → TrajectoryResult | Data matrices borrow inputs; increasing times; `(q...,p...)` for HNN, correction indices for UDE; loss does not prove physics; solver/training provenance retained; no unit schema on data types | Lux+Optimization; M6 predict/plots. No new model families. Empty generics give MethodError when absent, unlike guarded PINN/inference errors. test/learned_dynamics_base.jl |
| F31 PUBLIC_EXPERIMENTAL | ScientificSample, ScientificDataset, classify_query | src/scientific_ml/surrogates.jl; copied input/query/target arrays + explicit family/splits/schema → scalar-field dataset | Checked Float64, units/reference/grid/RNG/provenance metadata; domain membership descriptive; coordinate columns/input names/sensor grid explicit; no target leakage | Base; learning/generalization. Not ObservationSet: family versus time observations. Simulation data require documented reference/error; no automatic converter. test/surrogate_data.jl, surrogate_contracts.jl |
| F32 PUBLIC_EXPERIMENTAL | AffineScaling, fit_scaling, transform, inverse_transform | src/scientific_ml/surrogates.jl; training dataset → row-wise affine map → normalized/restored arrays | Training IDs/field stored; constant rows use scale1; explicit Float64 fit; no automatic normalization; order/schema must match | Base; F33. Physical units held by dataset, not scale object; transform not general unit conversion. test/surrogate_contracts.jl |
| F33 PUBLIC_EXPERIMENTAL | ScientificModel, ScientificLearningResult, learning_model, training_data, learning_objective | src/scientific_ml/surrogates.jl, ext/AnalyticMathLabSurrogateExt.jl; dataset + Lux/DeepONet → native model/batch → train/predict | Schema equality, fixed sensors, explicit RNG/normalization/AD/optimizer; optimizer success separate from generalization; physical output scale restored | Lux+Optimization+NeuralOperators even for plain surrogate; F34. LearningBatch returned opaquely; no public constructor guarantee. test/surrogate_contracts.jl; examples/operators/analysis_gate.jl |
| F34 PUBLIC_EXPERIMENTAL | GeneralizationAnalysis, field_errors, heat_residual, benchmark_queries | src/scientific_ml/generalization.jl and surrogates.jl; trained result → per-split empirical evidence; arrays → errors; `(x,t)` predictor → sampled heat residual | Reference/dataset retained; no ranking/continuum/extrapolation guarantee; relative floor explicit; heat coordinate order fixed; query timings descriptive and caller scope-dependent | Base metrics/ForwardDiff; prediction requires F33 extension; research reports. Timings do not certify speedup. Not run during M10D.1. test/surrogate_diagnostics.jl |
| F35 PUBLIC_STABLE | plot, surface, contour, gradientplot, vectorplot, phaseplot, timeplot, energyplot, modeplot, potentialplot, forceplot, mdplot, timeseriesplot, autocorrelationplot, blockplot, msdplot, vacfplot, comparisonplot, differenceplot, lossplot, residualplot, errorplot, collocationplot, losscomponentsplot, pinnplot, parameterfitplot | src/visualization/*.jl and Base.show methods in source families; stored report → Makie Figure/text | Displays consume stored evidence; curve/field sampling may evaluate stored callables but does not create new scientific proof; units/domain masks/order from source | Makie imported, rendering backend chosen by user; CairoMakie remains installed dependency but not auto-loaded. Stable view names, experimental ML payloads follow owning family. test/*visualization.jl |
| F36 INTERNAL | FieldZero, Equilibrium, LocalStabilityAnalysis, MultivariateRestriction, LearningBatch, TrajectoryObservations, DeviationAnalysis; underscore helpers; extension modules/AtomTypes; imported dependency bindings | src/vector_fields/zeros.jl, dynamical_systems/{analysis,stability}.jl, multivariate_domain.jl, scientific_ml/surrogates.jl, trajectory/analyst.jl, core/exact_algebra.jl, dynamical_systems/scaling.jl, ext/*.jl | Reachable record fields support documented inspection, not stable type names or direct constructors; backend bindings are not re-exports; helper assumptions inherited from caller | Package internals/test fixtures and labeled maintainer experiments only. No test helpers exported. No internal type promoted just for an example. |

## Public language decisions

A new user learns: (1) scientific input object plus ordered variables/data,
(2) report factory (`analyze` or domain-specific operation), (3) claims and
limitations, (4) evaluation/conversion/diagnostics appropriate to that object,
(5) optional fit/predict lifecycle, (6) stored presentation. There is one evidence
language in intent, but several historical vocabularies and metadata layouts.

Preserve differentiated terms with scientific justification: `RealDomain` versus
`MultivariateDomain`, `TrajectoryResult` versus `AtomisticTrajectoryView`,
`ObservationSet` versus `ScientificDataset`, `sampled_summary` versus
`statistical_summary`, `potential` versus `analyze_potential`, `linearization`
versus `linearize_mechanics`, and derivative comparison versus stored MD comparison.
Do not add an `analyze(::Any)` or a universal result wrapper. Existing broad
backend adapters (`mdcheck(x)`, pair inspection) delegate to `atomistic_snapshot`
and fail for unsupported sources rather than inventing conversions.

API names are retained. Existing native backend payloads are intentionally
inspectable, while extension modules, implementation types and dependency
bindings remain internal. Direct public constructor forms and exposed mutable
fields still need hardening in M10D.5; a status label on a manually fabricated
record cannot manufacture scientific evidence.

## Analyze dispatch inventory

| Family | Dispatch signatures | Output / justified difference |
|---|---|---|
| scalar | `(Real, Symbolics.Num)`; `(RealExpression, Symbolics.Num)` | FunctionAnalysis; capture forwards original syntax |
| multivariate scalar | `(Real, Union{Tuple,AbstractVector})`; `(RealExpression, Union{Tuple,AbstractVector})` | ScalarFieldAnalysis for scalar expressions; captured component collections forward into vector path |
| vector | `(Union{AbstractVector,Tuple}, Union{Tuple,AbstractVector})` | VectorFieldAnalysis; rectangular field allowed |
| autonomous | `(AutonomousSystem)` | DynamicalSystemAnalysis, square field/local stability |
| Lagrangian | `(LagrangianSystem)` | LagrangianAnalysis, formal EL/regularity |
| Hamiltonian | `(HamiltonianSystem)` | HamiltonianAnalysis, canonical identities |
| atomistic trajectory | `(AtomisticTrajectoryView)` | MDTrajectoryAnalysis, only requested diagnostics |
| PINN diagnostics | `(PINNTrainingResult)` | PINNAnalysis; base method delegates to optional extension |
| generalization | `(ScientificLearningResult)` | GeneralizationAnalysis; base orchestration calls optional predict |

These are nine conceptual families / eleven source methods. No analyze(::FirstOrderODE),
analyze(::AtomisticSnapshot), analyze(::ObservableSeries) or universal analysis
identity method exists. Use trajectory, mdcheck and named statistics respectively.
This is a discoverability issue, not evidence of dispatch ambiguity. `train` and
`predict` distinguish first-argument problem/model types; learned dynamics predict
returns a trajectory, PINN predict returns values, surrogate predict returns
scalar query values. These shapes are scientifically intentional and documented,
not homogenized. Runtime method/ambiguity checks are recorded in the plan.

## Optional-extension map

| Trigger dependencies (all required) | Extension module | Public methods / absence | Present behavior / supported example environment |
|---|---|---|---|
| Molly | AnalyticMathLabMollyExt | atomistic_snapshot, atomistic_trajectory, observable_series on Molly types; generic snapshots/series work without Molly | CPU Array adapter, explicit historical times/fixed-box identity; examples/molly; no MD engine |
| Optimization | AnalyticMathLabInferenceExt | infer_parameters base wrapper gives actionable ArgumentError | Native Optimization fit, base forward problem works without it; examples/inference |
| Lux, Optimization | AnalyticMathLabDynamicsExt | learned_energy/vector_field/correction, dynamics_objective, aligned_energy, train/predict methods absent without triggers (MethodError) | Native Lux state + ForwardDiff/Optimization; examples/inference; no NeuralPDE dependency |
| Lux, NeuralPDE, ModelingToolkit, Optimization, SymbolicIndexingInterface | AnalyticMathLabPINNExt | guarded pinn_network/problem/train/predict/analyze/loss_breakdown; ArgumentError without extension | Native PINN construction/optimization and residual callbacks; examples/pinn explicitly declares all triggers |
| Lux, Optimization, NeuralOperators | AnalyticMathLabSurrogateExt | guarded learning_model/training_data/learning_objective/train/predict; ArgumentError | Lux/DeepONet query/fit routes; examples/operators; plain surrogate also requires NeuralOperators under current registration |

All triggers are weakdeps; none was made mandatory. Extension sources use base
AML dependencies legitimately inside package-owned implementation. Examples must
not copy that convention as a promise of dependency re-exports. Runtime imports
use Julia's extension loader, not manual ext includes. PINN activation commonly
also activates inference/dynamics because triggers overlap; the pinned NeuralPDE
environment also imports NeuralOperators and activates the surrogate extension.
These transitive activations are expected. A stale path-dependency manifest can
silently omit newer extensions even while loading current AML source. Before the
manual loader audit, refresh an existing optional environment with
`julia +release --project=examples/<environment> -e 'using Pkg; Pkg.resolve()'`,
then start a fresh Julia process. The audit checks manifest extension/weakdep
metadata against the package Project.toml before checking runtime activation.
No extension adds a new public `analyze` signature; wrappers already exist in core.
Native backend objects in PINN/learning/inference results are deliberate, but
version-sensitive payloads support PUBLIC_EXPERIMENTAL rather than pretending
backend-independent universal schemas.

## Layout, examples and fixtures

All production includes are centrally registered in src/AnalyticMathLab.jl.
Normal examples/notebooks contain no production-file injection after removing
obsolete ODE scale fallbacks. Neighboring example includes and optional test
runners including test files are orchestration, not a production API.
The architecture CoreFixture intentionally loads a minimal isolated core to test
dependency direction; that is not a user workflow. The M10C scaling directory is
explicitly maintainer-only internal instrumentation, not a new public scale API.

The ordinary mechanics addendum notebook's `_mc_zero` validation dependency was
replaced by the same operations through public Symbolics functions; no production
mechanics path or mathematical assertion changed.
Optional example helpers importing `AnalyticMathLab: ForwardDiff, Symbolics` expose
an internal dependency-binding assumption. These are recorded for explicit
example environment cleanup; no dependency is promoted to AML's public API.
No output from a benchmark is refreshed by this phase.

## M10D.3 semantic and provenance targets

| Concept | Classification | Existing evidence / target |
|---|---|---|
| Claim status | INCONSISTENT | PropertyResult established/heuristic/unknown; domain partial; search not_requested/nonisolated; compatibility distinct vocabulary. Scope each status rather than force one enum. |
| Evidence vs termination | CONSISTENT | PINN/inference/generalization explicitly separate fit/retcode from physical correctness; mechanical proofs separate sampled energy drift. Preserve this invariant. |
| Evidence location | INCONSISTENT | top-level evidence, per-property claims, diagnostics NamedTuple, provenance.evidence (DynamicsTrainingResult), some bare metric tuples. Add lightweight access conventions later, not rewrites now. |
| Method and notes | INCONSISTENT | PropertyResult.method/notes, top-level method/notes, limitations strings, algorithm in trajectory diagnostics. Clarify algorithm versus epistemic claim. |
| Domain | INCONSISTENT | Original symbolic constraints, callable ODE domain, radial domain, descriptive dataset bounds, backend PINN domains. They are different scientific objects; adapters must preserve rather than conflate them. |
| Units | INCONSISTENT | Unitful arithmetic in atomistics/statistics; string unknown/sample index; NamedTuple metadata in datasets/potential; no physical-unit schema in derivative data. Unknown is not dimensionless. |
| Coordinates | CONSISTENT | Ordered symbolic variables, canonical phase order, particle-major snapshot modes, columns-as-points. Different layouts are explicit locally but lack common bridge accessors. |
| Coordinate metadata transfer | MISSING | No general TrajectoryResult → ObservableSeries/dataset adapter retaining named selection and assumptions. |
| Backend metadata | BACKEND_SPECIFIC | PINN backend_metadata/native objects; native ODE solution; Optimization solutions; Molly version/provenance. Retain origin without exposing extension implementation types. |
| Approximation metadata | INCONSISTENT | Numerical diagnostics/tolerances; local mode metadata; sampled-error normalization and floors; empirical generalization limitations. No uniform accessor. |
| Numerical tolerance metadata | MISSING | Stationary/trajectory controls stored; not every returned scalar/derivative tuple retains all caller controls. Audit per computation before adding fields. |
| Source/origin | INFORMATION_LOSS | statistical_summary carries values/method but not parent series/time/units provenance itself; ComparisonInput supplies context. Retaining a source reference or explicit context is preferable to guessing. |
| Source retained already | CONSISTENT | MechanicsDynamics.source, MechanicalLinearization.source, NormalModeAnalysis.source, AtomisticSnapshot.provenance, SamplingInfo/ObservableSeries.provenance, PINN training/problem/provenance, inference problem/provenance, ScientificDataset reference/grid/RNG/provenance, GeneralizationAnalysis.training. |
| Ownership | INCONSISTENT | Borrowed atomistic/observable/derivative arrays; copied ScientificSample/PINNPoints arrays; shallow immutable containers with mutable fields; mixed accessor copies. Define documented lifetime/read-only policy. |

These findings are targets, not an implementation of universal provenance. An
important result should know its origin, but caller data/reference claims must
remain visibly caller-supplied and unknown quantities must stay unknown.
