# M10D.6A — Bounded core API audit

Baseline: `377a3c45905d0e16dba1fc2adc9d8eb3dcff14ca`.
Evidence level: **SOURCE_INSPECTED**. No Julia execution, canonical test run, dependency installation, source/test edit, commit, or subagent was performed.

## Completion and artifacts

- Fully read and semantically inspected all **24 required source files / 2,434 lines**: every `.jl` under `src/core`, `src/vector_fields`, and `src/dynamical_systems`, plus top-level `src/*.jl` excluding `scientific_metadata.jl`.
- `core_inspection.json` records exact read ranges, SHA-256, and concise semantic findings. Source progress was persisted after batches of six, five, five, five, and the final three source files. Related tests, documentation sections, and executable examples are separately recorded; section reads are not represented as whole-file reads.
- `core_api.json` contains **40 distinct primary-export records**, exactly matching F01–F09 in `exports.json`. Each has all requested contract fields. Shared `analyze`, `evaluate`, and `linearization` records include their core overloads; shared `jacobian` and `domain_contains` methods are also covered without inventing additional exports.
- Source hashes, full-source ranges, symbol-set equality, required API fields, and cited source/test/example line ranges were checked. No result is promoted to runtime-tested evidence.

## Principal findings

### 1. Dispatch and domain semantics need a single navigation table

The same generic does not imply the same contract. `analyze(f, x)` is univariate, while `analyze(f, (x,))` is the scalar-field API. Component containers select vector analysis; `AutonomousSystem` selects structural analysis. Primary ownership remains F03 for `analyze`/`evaluate` and F06 for `linearization`.

Univariate `evaluate` deliberately preserves generated-callable behavior, including cancellation and NaNMath results; it does not enforce `real_analysis.domain`. Scalar/vector evaluation rejects known exclusions and nonfinite coordinates/results but can evaluate when membership is unresolved. Numerical gradients, Hessians, Jacobians, and affine linearizations require a supported open smooth original-domain neighborhood. Trajectory RHS evaluation instead requires domain membership **exactly true**, including trial stages.

Evidence: `src/numerical.jl:1-16`, `src/multivariate_analysis.jl:88-116`, `src/vector_fields/analysis.jl:73-100`, `src/dynamical_systems/integration.jl:43-59`; tests in `test/runtests.jl:28-72`, `test/multivariate_regressions.jl:4-24`, `test/trajectories.jl:45-49`.

### 2. Good guide coverage is not complete symbol-level reference coverage

The README explains univariate/real/convergence/scalar workflows in detail; `docs/vector_fields.md` and `docs/dynamical_systems.md` give substantial scientific contracts. However, core scalar/vector/dynamical `analyze` overloads and several calculus methods have no attached method docstrings. `RealDomain` and `RealFunctionStudy` lack type docstrings; the latter's detailed internal factory documentation is not an attached public type reference. Macro guidance is shared with `RealExpression`, not separately attached to the macro definition.

Every API entry is conservatively **PARTIAL** for documentation coverage, with explicit existing sections and a recommended symbol reference target. This is not a claim that every symbol is undocumented, defective, or untested. No entry receives DOCUMENTED merely because a docstring exists. A consolidated reference should cover all overloads, controls, return shapes, errors, ownership, units, and evidence limits.

For example, `levelset` returns only `report.expression ~ c`; it does not attach `report.domain`. A reference should explicitly instruct consumers to retain the domain separately (`src/multivariate_analysis.jl:366-370`).

### 3. Evidence, ownership, and constructors must stay separate

`AbstractAnalysis` is a marker, not a universal execution protocol. `PropertyResult` remains the permissive four-field `(value,status,method,notes)` record. Raw positional containers do not certify their supplied content. Established, heuristic, unknown, unrequested, nonisolated, and solver execution diagnostics are not interchangeable statuses.

Immutable outer structs contain mutable vectors and syntax. Numerical/report factories generally own fresh result arrays, but raw constructors can retain caller references. Formal gradient/Hessian/Jacobian accessors copy arrays; vector calculus and autonomous evidence accessors deep-copy. Autonomous systems retain the identical field/domain. `TrajectoryResult` retains its native solution without copying solution arrays, and its `problem` field is the AML `FirstOrderODE` object rather than a separate native ODEProblem field.

Evidence: `src/core/contracts.jl:20-40`, `src/analysis.jl:19-76`, `src/dynamical_systems/analysis.jl:34-61`, `src/dynamical_systems/integration.jl:124-131`; `test/vector_regressions.jl:20-24`, `test/dynamical_systems.jl:60-66`. Current semantics authority: `docs/m10d_semantics.md:19-75`.

### 4. Exactness and resource limits are scoped, not universal guarantees

The bounded exact engine limits dense degree to 64, projected coefficient size to 4,096 bits, cumulative algebraic work to 200,000 units, source AST size to 512 nodes, and depth to 48. It does not bound caller expression construction, Symbolics compilation, or every elimination operation. Unresolved irrational roots and unsupported classes remain unknown. Budget exhaustion does not silently start numerical fallback.

Scalar/vector exact candidates use restricted rational affine/separable classes. Numerical searches are bounded multistart heuristics; residual acceptance is not a root-position bound. Potential reconstruction is restricted to rational polynomial fields of total degree at most eight and verified by differentiation. Zero curl on a punctured domain does not prove a global potential. Stability is equilibrium-local; Float64 diagnostic eigenvalues are not exact sign certificates.

Evidence: `src/core/exact_algebra.jl:1-162`, `src/multivariate_analysis.jl:213-339`, `src/vector_fields/calculus.jl:45-100`, `src/dynamical_systems/stability.jl:23-88`; corresponding real-analysis, vector-calculus, and dynamical-system tests are indexed in the API artifact.

### 5. Public ODE and private scaling boundaries must not be conflated

The public `FirstOrderODE`/`trajectory` contract remains out-of-place and limited to 1–32 states. The fully inspected private `_scale_ode_problem` is a separate native in-place Float64 ODEProblem factory without that cap; it is not a new public trajectory or symbolic/mechanics bridge.

Public trajectory conversion rejects nonfinite or nonzero-underflowed state/RHS values but is not precision-exact conversion of arbitrary real inputs. `saveat` supplies direction-aware `tstops` while retaining every adaptive step and native dense interpolation; it does **not** yield exclusively uniform output. The grid is bounded independently of `maxiters`. Solver termination can return a partial solution with explicit failure/completion diagnostics, whereas domain exceptions fail fast rather than returning a boundary-located path. Stage checks do not certify the continuous interpolant.

Evidence: `src/dynamical_systems/integration.jl:1-132`, `src/dynamical_systems/scaling.jl:1-43`, `test/dynamical_regressions.jl:23-60`.

### 6. Numerical comparison is not an error certificate or units engine

`compare_derivatives` uses ForwardDiff and FiniteDiff's default central step against an evaluated symbolic reference. `derivative_convergence` explicitly converts to Float64 and controls its stencil; relative discrepancies can be unavailable, and observed order is the first eligible stable decreasing window, not a theoretical guarantee or optimized step. There is no explicit convergence sample-count cap.

Core coordinate/state units are caller-managed. Labels do not declare physical units, unknown units are not dimensionless, and residual scales must be scientifically consistent. No general Unitful conversion should be promised for these paths. SciMLBase and OrdinaryDiffEqTsit5 are mandatory core numerical dependencies, not optional extension activation requirements.

Evidence: `src/numerical.jl:70-90`, `src/convergence.jl:36-130`, `src/AnalyticMathLab.jl:4-13`; `README.md:243-282`, `docs/m10d_architecture_inventory.md:25-39`.

## Historical documentation cautions

- `docs/vector_fields.md:193-196` still describes ODEs/stability as outside that milestone and a possible next milestone as unstarted. Read as historical milestone scope, not present library capability; current dynamics implementation and guide supersede it.
- `docs/m10d_semantics.md:87-100` contains historical family labels that do not consistently match frozen F01–F36 ownership. This audit uses `exports.json` and `docs/m10d_architecture_inventory.md:52-60`, not those legacy census labels, for ownership.
- The newer `docs/m10d_user_research_results.md` records the M10D.5 successful canonical at implementation checkpoint `c913f9e7dcb285ecb3780ce3964e6f4c1d17d720` and explicitly corrects incomplete recovery evidence. Its recorded 5,649 passing assertions and 198 reported testsets are historical, scoped evidence—not a new test run at this audit baseline and not a unique scientific-coverage count. Earlier unresolved assertions must not be repeated as current blockers.

## Remaining work outside this audit

Write/link the consolidated reference and dispatch table; fill missing public docstrings without changing algorithms; clarify raw constructors, units, domain gates, and native-backend ownership at navigation entry points. Reconcile historical milestone/family prose with current navigation. Runtime validation, canonical testing, scientific_metadata methods, visualization implementations, and noncore family methods were intentionally not performed or claimed here.
