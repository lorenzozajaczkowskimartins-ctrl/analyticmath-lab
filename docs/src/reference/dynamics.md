# Autonomous analysis and numerical trajectories

Equilibrium stability is local. FirstOrderODE and trajectory use their explicit checked numerical boundary, not arbitrary SciML options. saveat observations, native adaptive history and dense interpolation are different objects; solver success is not a rigorous error bound.

Read [API boundaries and evidence semantics](@ref api-boundaries) for the distinction between raw constructors, validated factories, exceptions, unknown claims and unrequested/partial diagnostics. Signatures are text, not runnable examples. Backend forwarding/context lines do not create public helper APIs.

```@raw html
<p>Repository resources: <a href="../repository/docs/dynamical_systems.md">docs/dynamical_systems.md</a>; <a href="../repository/docs/tutorials/odes.md">docs/tutorials/odes.md</a>; <a href="../repository/docs/tutorials/scripts/odes.jl">docs/tutorials/scripts/odes.jl</a>; <a href="../repository/reports/m10d6/tutorial_verification.json">reports/m10d6/tutorial_verification.json</a></p>
```

Overload map: [analyze](@ref dispatch-analyze).

Overload map: [evaluate](@ref dispatch-evaluate).

Overload map: [observable_series](@ref dispatch-observable_series).

Overload map: [predict](@ref dispatch-predict).

## [F08: Autonomous systems](@id family-F08)

<!-- aml-api: {"symbol": "AutonomousSystem", "family": "F08", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "type / constructors", "variant_count": 1} -->
## [AutonomousSystem](@id api-AutonomousSystem)

**Identity:** type / constructors; F08; **PUBLIC_STABLE**; explicitly exported.

**Stored fields:** `field`. Immutable outer record; referenced payloads may still be mutable. Obtain validated outputs through the operations described below; a raw record constructor does not itself certify scientific consistency.

<!-- aml-contract: {"variant": 0, "digest": "f5ad17086deb8cda1ee8e7588b108c113530ad3cedc18575e6a8debc6550eab6"} -->
**Purpose and output:** AutonomousSystem retaining field for x′=F(x).

**Source declarations and forwarding context:**

```text
AutonomousSystem(field::VectorFieldAnalysis)

AutonomousSystem(F, variables; kwargs...)
```

**Inputs:** Square stored VectorFieldAnalysis or component map plus ordered variables.

**Keywords:**

| Scope | Keyword | Default / constraint |
|---|---|---|
| route | `kwargs` | Forwarded to vector-field analyze, including original_expression, bounds, grid, iterations, residual_tolerance, residual_rtol, residual_scale; classification tolerances belong to analyze(system), not this constructor. |

**Failure and refusal:** DimensionMismatch if field input/output dimensions differ; vector analyze errors propagate for convenience constructor.

**Numerical limitations:** Square autonomous fields; inherited zero evidence. Local stability only; exact rational diagonal/planar tests, diagnostic Float64 eigenspectrum; nonhyperbolic nonlinear center not inferred.

**Units:** Inherits ordered field coordinates, no general physical units inference or conversion; eigenvalue thresholds caller scale.

**Ownership:** Retains identical field; does not deep-copy or recompute an existing report.

**Dependencies:** Symbolics.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: PRESENT_BRIEF. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/dynamical_systems/analysis.jl:1-10.

Inventory-listed candidate references (not a verified call graph or new execution): test/dynamical_systems.jl:6-20; test/dynamical_systems.jl:67-70; notebooks/dynamical_systems.jl:6-22.

```@raw html
<p>Repository resources: <a href="../repository/notebooks/dynamical_systems.jl">notebooks/dynamical_systems.jl</a>; <a href="../repository/src/dynamical_systems/analysis.jl">src/dynamical_systems/analysis.jl</a>; <a href="../repository/test/dynamical_systems.jl">test/dynamical_systems.jl</a></p>
```

<!-- aml-api: {"symbol": "DynamicalSystemAnalysis", "family": "F08", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "type / constructors", "variant_count": 1} -->
## [DynamicalSystemAnalysis](@id api-DynamicalSystemAnalysis)

**Identity:** type / constructors; F08; **PUBLIC_STABLE**; explicitly exported.

**Stored fields:** `system`, `field`, `variables`, `dimension`, `domain`, `equilibria`, `nullclines`. Immutable outer record; referenced payloads may still be mutable. Obtain validated outputs through the operations described below; a raw record constructor does not itself certify scientific consistency.

<!-- aml-contract: {"variant": 0, "digest": "8d70dcf24a6676da58261d5af55e664a8c0fd047ab01a17a205f0df940512538"} -->
**Purpose and output:** Stored source system and identical field/domain, equilibrium evidence and implicit nullclines.

**Source declarations and forwarding context:**

```text
DynamicalSystemAnalysis(system, field, variables, dimension, domain, equilibria, nullclines)
```

**Inputs:** Normally analyze(AutonomousSystem(field)); raw full positional record does not recompute/validate supplied evidence.

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** Generated constructors enforce declared Julia field/type constraints, not mathematical validity; no general invariant-validation promise.

**Numerical limitations:** Square autonomous fields; inherited zero evidence. Local stability only; exact rational diagonal/planar tests, diagnostic Float64 eigenspectrum; nonhyperbolic nonlinear center not inferred.

**Units:** Inherits ordered field coordinates, no general physical units inference or conversion; eigenvalue thresholds caller scale.

**Ownership:** Retains system/field/domain/variables; newly constructed equilibrium records copy candidate points/values; query accessors deep-copy evidence.

**Dependencies:** Symbolics.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: PRESENT_BRIEF. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/dynamical_systems/analysis.jl:13.

Inventory-listed candidate references (not a verified call graph or new execution): test/dynamical_systems.jl:6-104; test/dynamical_regressions.jl:61-68; notebooks/dynamical_systems.jl:6-22.

```@raw html
<p>Repository resources: <a href="../repository/notebooks/dynamical_systems.jl">notebooks/dynamical_systems.jl</a>; <a href="../repository/src/dynamical_systems/analysis.jl">src/dynamical_systems/analysis.jl</a>; <a href="../repository/test/dynamical_regressions.jl">test/dynamical_regressions.jl</a>; <a href="../repository/test/dynamical_systems.jl">test/dynamical_systems.jl</a></p>
```

<!-- aml-api: {"symbol": "equilibria", "family": "F08", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [equilibria](@id api-equilibria)

**Identity:** generic function; F08; **PUBLIC_STABLE**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "0830ac0fb12eb8cfd2d8894a200f03cf9f2ca94ee166d25079b3bcbd2b780c05"} -->
**Purpose and output:** PropertyResult containing equilibrium records with point/value/residual+threshold, status/method, domain_valid and LocalStabilityAnalysis.

**Source declarations and forwarding context:**

```text
equilibria(r::DynamicalSystemAnalysis)
```

**Inputs:** Stored autonomous structural analysis; no new root search/differentiation.

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** No explicit accessor validation/errors for a valid stored report; unsupported cases are stored unknown evidence.

**Numerical limitations:** Discovery inherits exact square affine/separable class or bounded heuristic zeros; small residual does not prove root position or global stability; unknown/nonisolated families not invented.

**Units:** Inherits ordered field coordinates, no general physical units inference or conversion; eigenvalue thresholds caller scale.

**Ownership:** deepcopy of stored evidence/records; mutations to returned contents do not change source.

**Dependencies:** Symbolics.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: PRESENT_BRIEF. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/dynamical_systems/analysis.jl:52-53.

Inventory-listed candidate references (not a verified call graph or new execution): test/dynamical_systems.jl:13-16; test/dynamical_systems.jl:39-64; notebooks/dynamical_systems.jl:6-22.

```@raw html
<p>Repository resources: <a href="../repository/notebooks/dynamical_systems.jl">notebooks/dynamical_systems.jl</a>; <a href="../repository/src/dynamical_systems/analysis.jl">src/dynamical_systems/analysis.jl</a>; <a href="../repository/test/dynamical_systems.jl">test/dynamical_systems.jl</a></p>
```

<!-- aml-api: {"symbol": "nullclines", "family": "F08", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [nullclines](@id api-nullclines)

**Identity:** generic function; F08; **PUBLIC_STABLE**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "72982d72b09991ae2f9bbc576e4e2e2544900585effd63ad34427c886ae5ec3c"} -->
**Purpose and output:** PropertyResult containing two (component,equation,domain) records for planar systems, or unknown evidence in other dimensions.

**Source declarations and forwarding context:**

```text
nullclines(r::DynamicalSystemAnalysis)
```

**Inputs:** Stored autonomous structural analysis; no new root search/differentiation.

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** No explicit accessor validation/errors for a valid stored report; unsupported cases are stored unknown evidence.

**Numerical limitations:** Only planar implicit component equations restricted to original domain; no solved curve, topology or regularity certificate.

**Units:** Inherits ordered field coordinates, no general physical units inference or conversion; eigenvalue thresholds caller scale.

**Ownership:** deepcopy of stored evidence/records; mutations to returned contents do not change source.

**Dependencies:** Symbolics.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: PRESENT_BRIEF. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/dynamical_systems/analysis.jl:54-55.

Inventory-listed candidate references (not a verified call graph or new execution): test/dynamical_systems.jl:29-35; test/dynamical_systems.jl:40-43; notebooks/dynamical_systems.jl:6-22.

```@raw html
<p>Repository resources: <a href="../repository/notebooks/dynamical_systems.jl">notebooks/dynamical_systems.jl</a>; <a href="../repository/src/dynamical_systems/analysis.jl">src/dynamical_systems/analysis.jl</a>; <a href="../repository/test/dynamical_systems.jl">test/dynamical_systems.jl</a></p>
```

<!-- aml-api: {"symbol": "stability", "family": "F08", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [stability](@id api-stability)

**Identity:** generic function; F08; **PUBLIC_STABLE**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "506509a7bb3705f204fe80bcde31849ce412ac1d08c19221c047ea0c9732168a"} -->
**Purpose and output:** Vector of LocalStabilityAnalysis records in equilibrium order, each matrix/eigenvalues/scoped stability PropertyResult.

**Source declarations and forwarding context:**

```text
stability(r::DynamicalSystemAnalysis)
```

**Inputs:** Stored autonomous structural analysis; no new root search/differentiation.

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** No explicit accessor validation/errors for a valid stored report; unsupported cases are stored unknown evidence.

**Numerical limitations:** Local equilibrium claim only. Exact rational diagonal/2D trace-det tests; affine unrestricted planar center special case. Numerical eigenvalues diagnostic with atol+rtol*max(maxabs(eigs),1); generic signs heuristic. Open smooth original neighborhood required. Nonhyperbolic nonlinear systems generally inconclusive; positive direction may still prove instability. No basin/global attraction/periodic orbit inference.

**Units:** Inherits ordered field coordinates, no general physical units inference or conversion; eigenvalue thresholds caller scale.

**Ownership:** deepcopy of stored evidence/records; mutations to returned contents do not change source.

**Dependencies:** Symbolics; LinearAlgebra.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: PRESENT_BRIEF. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/dynamical_systems/analysis.jl:56-57.

Inventory-listed candidate references (not a verified call graph or new execution): test/dynamical_systems.jl:39-104; test/dynamical_regressions.jl:61-68; notebooks/dynamical_systems.jl:6-22.

```@raw html
<p>Repository resources: <a href="../repository/notebooks/dynamical_systems.jl">notebooks/dynamical_systems.jl</a>; <a href="../repository/src/dynamical_systems/analysis.jl">src/dynamical_systems/analysis.jl</a>; <a href="../repository/test/dynamical_regressions.jl">test/dynamical_regressions.jl</a>; <a href="../repository/test/dynamical_systems.jl">test/dynamical_systems.jl</a></p>
```

## [F09: Numerical ODE trajectories](@id family-F09)

<!-- aml-api: {"symbol": "FirstOrderODE", "family": "F09", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "type / constructors", "variant_count": 1} -->
## [FirstOrderODE](@id api-FirstOrderODE)

**Identity:** type / constructors; F09; **PUBLIC_STABLE**; explicitly exported.

**Stored fields:** `function_value`, `dimension`, `domain`, `labels`. Immutable outer record; referenced payloads may still be mutable. Obtain validated outputs through the operations described below; a raw record constructor does not itself certify scientific consistency.

<!-- aml-contract: {"variant": 0, "digest": "bbf0d7cbc7c8b894021dd84f1eab9687432513a58693512908e1d7323dcb6b60"} -->
**Purpose and output:** Callable/domain/labels/dimension container; no solve or structural equilibrium analysis.

**Source declarations and forwarding context:**

```text
FirstOrderODE(f, dimension::Integer; domain=(u,t)->true, labels=ntuple(i -> "u$i", max(0,min(dimension,32))))
```

**Inputs:** Out-of-place f(u,t) returning finite real vector/tuple of declared dimension1–32; parameters may be captured in closure. Scalar state still vector internally.

**Keywords:**

| Scope | Keyword | Default / constraint |
|---|---|---|
| route | `domain` | (u,t)->true; must return exactly true at every evaluated RHS stage |
| route | `labels` | u1,...,uN default (bounded construction); length dimension; converted to string tuple |

**Failure and refusal:** ArgumentError dimension outside1:32; DimensionMismatch labels length; label string conversion can propagate errors. RHS/domain validity checked by trajectory, not eagerly by constructor.

**Numerical limitations:** Public small-state out-of-place interface; 32-state cap unchanged by private _scale_ode_problem. Does not infer smoothness, autonomy or equilibria.

**Units:** Caller-consistent numeric state/time scales; no automatic Unitful normalization, no units schema; labels are names not unit declarations.

**Ownership:** Retains f and domain closures; converts labels to immutable tuple of strings; does not own captured mutable closure state.

**Dependencies:** SciMLBase; OrdinaryDiffEqTsit5.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: PRESENT_DETAILED. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/dynamical_systems/integration.jl:1-21.

Inventory-listed candidate references (not a verified call graph or new execution): test/trajectories.jl:3-53; test/dynamical_regressions.jl:23-60; notebooks/dynamical_systems.jl:24-35.

```@raw html
<p>Repository resources: <a href="../repository/notebooks/dynamical_systems.jl">notebooks/dynamical_systems.jl</a>; <a href="../repository/src/dynamical_systems/integration.jl">src/dynamical_systems/integration.jl</a>; <a href="../repository/test/dynamical_regressions.jl">test/dynamical_regressions.jl</a>; <a href="../repository/test/trajectories.jl">test/trajectories.jl</a></p>
```

<!-- aml-api: {"symbol": "trajectory", "family": "F09", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 2} -->
## [trajectory](@id api-trajectory)

**Identity:** generic function; F09; **PUBLIC_STABLE**; explicitly exported.

**Interpretation:** Saved points can include native adaptive steps as well as requested observations. saveat is not a global retention budget. Inspect diagnostics.success, completed and retcode; partial numerical output is different from an exception.

<!-- aml-contract: {"variant": 0, "digest": "294ce2f5c86ebfac93535029cddab29740a11514fdf4fec1cd7c6d6870ce771d"} -->
### Dispatch contract 1

**Purpose and output:** TrajectoryResult with native dense solution and AML problem; inspect diagnostics.success AND completed/retcode, including partial solver failure result.

**Source declarations and forwarding context:**

```text
trajectory(problem::FirstOrderODE, u0, tspan; algorithm=OrdinaryDiffEqTsit5.Tsit5(), abstol::Real=1e-9, reltol::Real=1e-7, saveat=nothing, dt=nothing, maxiters::Integer=100_000)

trajectory(report::DynamicalSystemAnalysis, u0, tspan; kwargs...)
```

**Inputs:** FirstOrderODE or autonomous analysis, scalar u0 for one state or collection matching dimension, two distinct finite Float64-converted time endpoints; reverse integration supported.

**Keywords:**

| Scope | Keyword | Default / constraint |
|---|---|---|
| route | `algorithm` | OrdinaryDiffEqTsit5.Tsit5(); explicit compatible installed SciML algorithm accepted |
| route | `abstol` | 1e-9; finite positive Real converted to Float64 |
| route | `reltol` | 1e-7; finite positive Real converted to Float64 |
| route | `saveat` | nothing; positive finite interval mapped to direction-aware tstops, <=1000000 intervals; all adaptive steps still saved |
| route | `dt` | nothing; positive finite initial step magnitude; direction signed internally |
| route | `maxiters` | 100000; positive Integer |
| route | `kwargs` | Dynamical method forwards same controls |

**Failure and refusal:** DimensionMismatch initial/RHS dimension. ArgumentError tspan/positive controls/save grid/dt/maxiters; backend/algorithm errors may propagate. DomainError nonfinite/unrepresentable initial state or RHS, invalid or unresolved domain at initial/trial stage; domain exceptions do not return a partial path.

**Numerical limitations:** Float64 conversion can round inputs; initial/RHS checks reject overflow and nonzero underflow, not all precision loss. saveat forces solver steps and changes cost/step sequence, not an exclusively uniform output; dense=true and save_everystep=true. Unknown or invalid domain fails fast at stages; no event-boundary localization or interpolant containment proof; tolerances not rigorous errors. MaxIters may return partial native result. Public1–32 states. Private scalable in-place bridge is not an exported larger trajectory contract.

**Units:** Caller supplies coherent plain numeric state/time scales; no unit stripping/conversion or inferred physical labels. Tolerances are solver controls in supplied scales.

**Ownership:** Float64 initial-state copy; native solution retained without copying arrays. Autonomous wrapper retains field identity; f/domain closures retained; no mutation of source field.

**Dependencies:** SciMLBase; OrdinaryDiffEqTsit5.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: PRESENT_DETAILED_FIRSTORDER_OVERLOAD_AUTONOMOUS_UNDOCUMENTED. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/dynamical_systems/integration.jl:36-41; src/dynamical_systems/integration.jl:43-132.

Inventory-listed candidate references (not a verified call graph or new execution): test/trajectories.jl:3-53; test/dynamical_regressions.jl:23-60; notebooks/dynamical_systems.jl:24-35.

```@raw html
<p>Repository resources: <a href="../repository/notebooks/dynamical_systems.jl">notebooks/dynamical_systems.jl</a>; <a href="../repository/src/dynamical_systems/integration.jl">src/dynamical_systems/integration.jl</a>; <a href="../repository/test/dynamical_regressions.jl">test/dynamical_regressions.jl</a>; <a href="../repository/test/trajectories.jl">test/trajectories.jl</a></p>
```

<!-- aml-contract: {"variant": 1, "digest": "68993f6f5c764adb0cbc97cc14dd96945155d865141b463b4086f997093c7c00"} -->
### Dispatch contract 2

**Purpose and output:** TrajectoryResult with native solution and recorded conversion origin

**Source declarations and forwarding context:**

```text
function trajectory(conversion::MechanicsDynamics,u0,tspan;kwargs...)
```

**Inputs:** MechanicsDynamics, initial state, time span; trajectory kwargs forwarded

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** Underlying public trajectory refusals/errors propagate

**Numerical limitations:** Actual stored/native solution; source origin not a scientific certification.

**Units:** Caller-managed physical units/coordinate ordering; symbolic identities do not infer positivity or dimensions.

**Ownership:** Native solution and problem retained; no copy of solution arrays.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: PRESENT_OR_PARTIAL; see literal source declaration. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/mechanics/bridge.jl:84.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:71; test/dynamical_regressions.jl:12; examples/inference/deterministic_gate.jl:7.

```@raw html
<p>Repository resources: <a href="../repository/examples/inference/deterministic_gate.jl">examples/inference/deterministic_gate.jl</a>; <a href="../repository/src/mechanics/bridge.jl">src/mechanics/bridge.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/dynamical_regressions.jl">test/dynamical_regressions.jl</a></p>
```

<!-- aml-api: {"symbol": "TrajectoryResult", "family": "F09", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "type / constructors", "variant_count": 1} -->
## [TrajectoryResult](@id api-TrajectoryResult)

**Identity:** type / constructors; F09; **PUBLIC_STABLE**; explicitly exported.

**Stored fields:** `solution`, `problem`, `labels`, `diagnostics`. Immutable outer record; referenced payloads may still be mutable. Obtain validated outputs through the operations described below; a raw record constructor does not itself certify scientific consistency.

<!-- aml-contract: {"variant": 0, "digest": "7f1e1891bba14f0731db5f326bcbe290c3804a1c0637d2e4ecd51712028af06f"} -->
**Purpose and output:** Native SciML solution, AML FirstOrderODE problem (not native ODEProblem field), labels, success/completed/retcode/algorithm/tolerances/final_time/accepted/rejected diagnostics.

**Source declarations and forwarding context:**

```text
TrajectoryResult(solution, problem, labels, diagnostics)
```

**Inputs:** Usually produced by trajectory; raw solution/problem/labels/diagnostics holder.

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** Generated constructors enforce declared Julia field/type constraints, not mathematical validity; no general invariant-validation promise.

**Numerical limitations:** Public out-of-place interface1–32 states; Float64 states/times, explicit representability/nonzero-to-zero checks for states/RHS but not precision-exact conversion. Stage domain checks do not certify interpolant. Solver success/completion not rigorous accuracy.

**Units:** Caller-consistent numeric state/time scales; no automatic Unitful normalization, no units schema; labels are names not unit declarations.

**Ownership:** Native solution retained without copying solution arrays; AML problem callable and domain retained. Treat backend state as read-only; backend API not AML-stable.

**Dependencies:** SciMLBase; OrdinaryDiffEqTsit5.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: PRESENT_BRIEF. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/dynamical_systems/integration.jl:24.

Inventory-listed candidate references (not a verified call graph or new execution): test/trajectories.jl:3-53; test/dynamical_regressions.jl:23-60; notebooks/dynamical_systems.jl:24-35.

```@raw html
<p>Repository resources: <a href="../repository/notebooks/dynamical_systems.jl">notebooks/dynamical_systems.jl</a>; <a href="../repository/src/dynamical_systems/integration.jl">src/dynamical_systems/integration.jl</a>; <a href="../repository/test/dynamical_regressions.jl">test/dynamical_regressions.jl</a>; <a href="../repository/test/trajectories.jl">test/trajectories.jl</a></p>
```
