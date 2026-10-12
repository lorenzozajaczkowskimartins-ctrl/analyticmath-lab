# Scientific views and rendering

The 26 view names are stable exports, but experimental payload semantics remain experimental. Views consume stored evidence and may sample stored callables; they do not solve a new scientific problem. Makie is a root dependency; choose and explicitly load a rendering backend separately.

Read [API boundaries and evidence semantics](@ref api-boundaries) for the distinction between raw constructors, validated factories, exceptions, unknown claims and unrequested/partial diagnostics. Signatures are text, not runnable examples. Backend forwarding/context lines do not create public helper APIs.

```@raw html
<p>Repository resources: <a href="../repository/docs/m10d_semantics.md">docs/m10d_semantics.md</a>; <a href="../repository/docs/tutorials/normal-modes.md">docs/tutorials/normal-modes.md</a>; <a href="../repository/docs/tutorials/scripts/normal_modes.jl">docs/tutorials/scripts/normal_modes.jl</a>; <a href="../repository/reports/m10d6/tutorial_verification.json">reports/m10d6/tutorial_verification.json</a></p>
```

Overload map: [plot](@ref dispatch-plot).

## [plot overloads](@id dispatch-plot)

<!-- aml-dispatch: {"symbol": "plot", "variants": 3} -->
### plot: dispatch-oriented map

| Input contract | Supported signature | Result | Dependencies | Scientific contract | Destination |
|---|---|---|---|---|---|
| FunctionAnalysis | `function plot(report::FunctionAnalysis; xmin::Real=-5, xmax::Real=5, samples::Integer=501)` | Makie Figure | Rendering backend explicitly chosen by caller, e.g. CairoMakie | Stored evidence; explicit rendering backend | [primary contract](@ref api-plot); [family](@ref family-F35) |
| DerivativeConvergenceAnalysis | `function plot(result::DerivativeConvergenceAnalysis)` | Makie Figure | Rendering backend explicitly chosen by caller, e.g. CairoMakie | Stored evidence; explicit rendering backend | [primary contract](@ref api-plot); [family](@ref family-F35) |
| ScalarFieldAnalysis | `plot(report::ScalarFieldAnalysis; kwargs...) = surface(report; kwargs...)` | Makie Figure | Caller rendering backend | Stored evidence; explicit rendering backend | [primary contract](@ref api-plot); [family](@ref family-F35) |
| VectorFieldAnalysis | `plot(report::VectorFieldAnalysis;kwargs...) = vectorplot(report;kwargs...)` | Makie Figure | Caller rendering backend | Stored evidence; explicit rendering backend | [primary contract](@ref api-plot); [family](@ref family-F35) |
| PotentialAnalysis | `plot(p::PotentialAnalysis;kwargs...)=potentialplot(p;kwargs...)` | Makie Figure | Caller rendering backend | Stored evidence; explicit rendering backend | [primary contract](@ref api-plot); [family](@ref family-F35) |
| RadialDistributionAnalysis | `function plot(r::RadialDistributionAnalysis)` | Makie Figure | Caller rendering backend | Stored evidence; explicit rendering backend | [primary contract](@ref api-plot); [family](@ref family-F35) |

## [F35: Scientific views](@id family-F35)

<!-- aml-api: {"symbol": "autocorrelationplot", "family": "F35", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [autocorrelationplot](@id api-autocorrelationplot)

**Identity:** generic function; F35; **PUBLIC_STABLE**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "8b939b80a56693e56ce814c72fea910e6388aa073c1a18d1a206e35dc66b98b2"} -->
**Purpose and output:** Makie.Figure

**Source declarations and forwarding context:**

```text
autocorrelationplot(a::AutocorrelationAnalysis)=first(_ts_curve(a.lag_times,a.autocorrelation;title="Finite-sample autocorrelation",ylabel="ρ(k) [dimensionless]"))
```

**Inputs:** AutocorrelationAnalysis

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError correlation/time unavailable

**Numerical limitations:** Stored normalized ACF only no new lag/uncertainty estimation. Caller renderer only no backend activation/save.

**Units:** Trajectory/comparison Unitful display scales retained; inference supplied numeric coordinates, no conversion inference.

**Ownership:** Fresh buffers/Figure; source read-only, lazy values may be evaluated.

**Dependencies:** Caller rendering backend.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: BRIEF/detailed. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/visualization/trajectory.jl:17.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:86; test/trajectory_visualization.jl:11; notebooks/molly_trajectory_analysis.jl:55.

```@raw html
<p>Repository resources: <a href="../repository/notebooks/molly_trajectory_analysis.jl">notebooks/molly_trajectory_analysis.jl</a>; <a href="../repository/src/visualization/trajectory.jl">src/visualization/trajectory.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/trajectory_visualization.jl">test/trajectory_visualization.jl</a></p>
```

<!-- aml-api: {"symbol": "blockplot", "family": "F35", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [blockplot](@id api-blockplot)

**Identity:** generic function; F35; **PUBLIC_STABLE**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "354dab2538cb9b500d378d397ca38b60c7c9cd17f5ad6ac2f3e8b847ea3c996d"} -->
**Purpose and output:** Makie.Figure

**Source declarations and forwarding context:**

```text
function blockplot(b::BlockAnalysis)
```

**Inputs:** BlockAnalysis

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError unknown analysis/no >=2complete blocks

**Numerical limitations:** Available per-size SE only no plateau/independence. Caller renderer only no backend activation/save.

**Units:** Trajectory/comparison Unitful display scales retained; inference supplied numeric coordinates, no conversion inference.

**Ownership:** Fresh buffers/Figure; source read-only, lazy values may be evaluated.

**Dependencies:** Caller rendering backend.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: BRIEF/detailed. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/visualization/trajectory.jl:19.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:86; test/trajectory_visualization.jl:12; notebooks/molly_trajectory_analysis.jl:55.

```@raw html
<p>Repository resources: <a href="../repository/notebooks/molly_trajectory_analysis.jl">notebooks/molly_trajectory_analysis.jl</a>; <a href="../repository/src/visualization/trajectory.jl">src/visualization/trajectory.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/trajectory_visualization.jl">test/trajectory_visualization.jl</a></p>
```

<!-- aml-api: {"symbol": "collocationplot", "family": "F35", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [collocationplot](@id api-collocationplot)

**Identity:** generic function; F35; **PUBLIC_STABLE**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "8388d7661267bfd25e2cc8b45a1a4b71f3364bf7f2af66f992cda91c4107f0c9"} -->
**Purpose and output:** Makie.Figure

**Source declarations and forwarding context:**

```text
function collocationplot(a::PINNAnalysis;equation::Integer=1)
```

**Inputs:** PINNAnalysis; equation::Integer=1

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** BoundsError equation; ArgumentError >2dims

**Numerical limitations:** Returned collocation snapshot not all training/coverage/resampling history. Backend caller-activated only.

**Units:** Stored Float64 coordinates/errors, no units conversion.

**Ownership:** Fresh Figure and presentation buffers; stored data read-only.

**Dependencies:** Caller rendering backend.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: ABSENT. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/visualization/pinn_diagnostics.jl:45.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:92; test/pinn_diagnostics.jl:47; notebooks/pinn_diagnostics.jl:27.

```@raw html
<p>Repository resources: <a href="../repository/notebooks/pinn_diagnostics.jl">notebooks/pinn_diagnostics.jl</a>; <a href="../repository/src/visualization/pinn_diagnostics.jl">src/visualization/pinn_diagnostics.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/pinn_diagnostics.jl">test/pinn_diagnostics.jl</a></p>
```

<!-- aml-api: {"symbol": "comparisonplot", "family": "F35", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [comparisonplot](@id api-comparisonplot)

**Identity:** generic function; F35; **PUBLIC_STABLE**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "603d59ccc3b5e5d3d56d4e6fb980978456c828392ad69c3c138175af13483cc9"} -->
**Purpose and output:** Makie.Figure

**Source declarations and forwarding context:**

```text
function comparisonplot(c::ObservableComparison)
```

**Inputs:** ObservableComparison

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** Malformed raw records/backend failures

**Numerical limitations:** Stored compatible overlay, unknown/incompatible labeled refusal Figure not fake0. No curve alignment. Caller renderer only no backend activation/save.

**Units:** Trajectory/comparison Unitful display scales retained; inference supplied numeric coordinates, no conversion inference.

**Ownership:** Fresh buffers/Figure; source read-only, lazy values may be evaluated.

**Dependencies:** Caller rendering backend.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: BRIEF/detailed. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/visualization/comparison.jl:21.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:88; test/trajectory_comparison_visualization.jl:5; notebooks/trajectory_comparison.jl:50.

```@raw html
<p>Repository resources: <a href="../repository/notebooks/trajectory_comparison.jl">notebooks/trajectory_comparison.jl</a>; <a href="../repository/src/visualization/comparison.jl">src/visualization/comparison.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/trajectory_comparison_visualization.jl">test/trajectory_comparison_visualization.jl</a></p>
```

<!-- aml-api: {"symbol": "contour", "family": "F35", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [contour](@id api-contour)

**Identity:** generic function; F35; **PUBLIC_STABLE**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "3427c0b33e0b9a53018b76fcf2770d2b2f0b95e08204b1edf87c8bed9752268e"} -->
**Purpose and output:** Makie.Figure

**Source declarations and forwarding context:**

```text
function contour(report::ScalarFieldAnalysis; xrange=(-5,5),yrange=(-5,5),samples::Integer=101,
levels=15,critical_markers::Bool=true)
```

**Inputs:** 2D ScalarFieldAnalysis; ranges (-5,5),samples=101,levels=15,critical_markers=true

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError invalid dimension/bounds/count; Makie levels errors propagate

**Numerical limitations:** Samples2:501; filled contour from masked scalar grid. Conservative interval rendering masks are presentation not scientific certificates; no backend activation/save.

**Units:** View Float64 grids/Float32 arrow glyphs; coordinate labels not inferred physical units.

**Ownership:** Fresh sampled arrays/Figure, stored report retained read-only.

**Dependencies:** Caller rendering backend.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: BRIEF/detailed vector/phase. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/visualization/scalar_fields.jl:120.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:65; test/architecture.jl:106; notebooks/multivariable_analysis.jl:36.

```@raw html
<p>Repository resources: <a href="../repository/notebooks/multivariable_analysis.jl">notebooks/multivariable_analysis.jl</a>; <a href="../repository/src/visualization/scalar_fields.jl">src/visualization/scalar_fields.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a></p>
```

<!-- aml-api: {"symbol": "differenceplot", "family": "F35", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [differenceplot](@id api-differenceplot)

**Identity:** generic function; F35; **PUBLIC_STABLE**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "49bbf9a843549ec67781ae97a89bf13ba49cf1f2bbfa191028a946038386ea41"} -->
**Purpose and output:** Makie.Figure

**Source declarations and forwarding context:**

```text
function differenceplot(c::ObservableComparison)
```

**Inputs:** ObservableComparison

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** Malformed raw/backend failures

**Numerical limitations:** Stored B−A; optional scalar ±1heuristic SE only actual propagated uncertainty; no confidence/significance claim. Caller renderer only no backend activation/save.

**Units:** Trajectory/comparison Unitful display scales retained; inference supplied numeric coordinates, no conversion inference.

**Ownership:** Fresh buffers/Figure; source read-only, lazy values may be evaluated.

**Dependencies:** Caller rendering backend.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: BRIEF/detailed. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/visualization/comparison.jl:46.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:88; test/trajectory_comparison_visualization.jl:14; notebooks/trajectory_comparison.jl:51.

```@raw html
<p>Repository resources: <a href="../repository/notebooks/trajectory_comparison.jl">notebooks/trajectory_comparison.jl</a>; <a href="../repository/src/visualization/comparison.jl">src/visualization/comparison.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/trajectory_comparison_visualization.jl">test/trajectory_comparison_visualization.jl</a></p>
```

<!-- aml-api: {"symbol": "energyplot", "family": "F35", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 2} -->
## [energyplot](@id api-energyplot)

**Identity:** generic function; F35; **PUBLIC_STABLE**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "c8ef1bc7e1604042ca6c38e245969635056b9081dd94ccdcc5395bbe34407668"} -->
### Dispatch contract 1

**Purpose and output:** Makie.Figure

**Source declarations and forwarding context:**

```text
function energyplot(conversion::MechanicsDynamics,path::TrajectoryResult)

function energyplot(report::Union{LagrangianAnalysis,HamiltonianAnalysis},path::TrajectoryResult;
conversion)
```

**Inputs:** MechanicsDynamics,path or mechanics report,path with required conversion

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError wrongsource; energy domain/errors propagate

**Numerical limitations:** Samples energy_drift only matching source; not conservation/interpolant proof. Caller activates rendering backend; no file save/new simulation.

**Units:** Atomistic views explicitly scale Unitful to selected coordinate units; other labels do not convert metadata.

**Ownership:** New energy arrays/Figure.

**Dependencies:** Caller rendering backend.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: BRIEF/detailed. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/visualization/mechanics.jl:51; src/visualization/mechanics.jl:60.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:76; test/mechanics_visualization.jl:6; examples/integration/one_system_plots.jl:20.

```@raw html
<p>Repository resources: <a href="../repository/examples/integration/one_system_plots.jl">examples/integration/one_system_plots.jl</a>; <a href="../repository/src/visualization/mechanics.jl">src/visualization/mechanics.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/mechanics_visualization.jl">test/mechanics_visualization.jl</a></p>
```

<!-- aml-contract: {"variant": 1, "digest": "371a56147f248ccc72c40a1806f1d60ecf38764dfdf680849e3a802570ca70b3"} -->
### Dispatch contract 2

**Purpose and output:** Makie.Figure

**Source declarations and forwarding context:**

```text
function energyplot(r::MDTrajectoryAnalysis;observable=:total_energy)
```

**Inputs:** MDTrajectoryAnalysis; observable=:total_energy

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError diagnostics absent/unavailable

**Numerical limitations:** Stored deviations only, no conservation grade or recompute. Caller renderer only no backend activation/save.

**Units:** Trajectory/comparison Unitful display scales retained; inference supplied numeric coordinates, no conversion inference.

**Ownership:** Fresh buffers/Figure; source read-only, lazy values may be evaluated.

**Dependencies:** Caller rendering backend.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: BRIEF/detailed. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/visualization/trajectory.jl:49.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:76; test/mechanics_visualization.jl:6; examples/integration/one_system_plots.jl:20.

```@raw html
<p>Repository resources: <a href="../repository/examples/integration/one_system_plots.jl">examples/integration/one_system_plots.jl</a>; <a href="../repository/src/visualization/trajectory.jl">src/visualization/trajectory.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/mechanics_visualization.jl">test/mechanics_visualization.jl</a></p>
```

<!-- aml-api: {"symbol": "errorplot", "family": "F35", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [errorplot](@id api-errorplot)

**Identity:** generic function; F35; **PUBLIC_STABLE**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "1f467d359e3887b5f97b158b6a7ddf9350b312948bdf50ef2506bfd4c4c50ff3"} -->
**Purpose and output:** Makie.Figure

**Source declarations and forwarding context:**

```text
function errorplot(a::PINNAnalysis;variable::Integer=1)
```

**Inputs:** PINNAnalysis; variable::Integer=1

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** BoundsError bad variable; ArgumentError unavailable reference/>2dims

**Numerical limitations:** Stored absolute error, caller reference trust no global bound. Backend caller-activated only.

**Units:** Stored Float64 coordinates/errors, no units conversion.

**Ownership:** Fresh Figure and presentation buffers; stored data read-only.

**Dependencies:** Caller rendering backend.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: ABSENT. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/visualization/pinn_diagnostics.jl:36.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:92; test/pinn_diagnostics.jl:46; notebooks/pinn_diagnostics.jl:26.

```@raw html
<p>Repository resources: <a href="../repository/notebooks/pinn_diagnostics.jl">notebooks/pinn_diagnostics.jl</a>; <a href="../repository/src/visualization/pinn_diagnostics.jl">src/visualization/pinn_diagnostics.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/pinn_diagnostics.jl">test/pinn_diagnostics.jl</a></p>
```

<!-- aml-api: {"symbol": "forceplot", "family": "F35", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [forceplot](@id api-forceplot)

**Identity:** generic function; F35; **PUBLIC_STABLE**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "2220b452a9aabcb4f315e409b70bca7f6c5a42bc404ee3539ea3e7448a5762d2"} -->
**Purpose and output:** Makie.Figure

**Source declarations and forwarding context:**

```text
function forceplot(p::PotentialAnalysis;rmin::Real,rmax::Real,samples::Integer=501)
```

**Inputs:** PotentialAnalysis; same required bounds

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** Same potential view guard

**Numerical limitations:** Stored radial force with original gaps; not vector force engine. Caller activates rendering backend; no file save/new simulation.

**Units:** Atomistic views explicitly scale Unitful to selected coordinate units; other labels do not convert metadata.

**Ownership:** New buffers/Figure.

**Dependencies:** Caller rendering backend.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: BRIEF/detailed. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/visualization/potentials.jl:47.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:80; test/potential_visualization.jl:17; notebooks/molly_companion.jl:79.

```@raw html
<p>Repository resources: <a href="../repository/notebooks/molly_companion.jl">notebooks/molly_companion.jl</a>; <a href="../repository/src/visualization/potentials.jl">src/visualization/potentials.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/potential_visualization.jl">test/potential_visualization.jl</a></p>
```

<!-- aml-api: {"symbol": "gradientplot", "family": "F35", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [gradientplot](@id api-gradientplot)

**Identity:** generic function; F35; **PUBLIC_STABLE**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "383c912a855b79eabf35b38376e840b1b150518bdae2b453787a2bfd34a27a07"} -->
**Purpose and output:** Makie.Figure

**Source declarations and forwarding context:**

```text
function gradientplot(report::ScalarFieldAnalysis; xrange=(-5,5),yrange=(-5,5),samples::Integer=15,
arrowscale::Real=1)
```

**Inputs:** 2D ScalarFieldAnalysis; ranges (-5,5),samples=15,arrowscale=1

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError invalid dimension/bounds/count/positive Float64 scale

**Numerical limitations:** Samples2:50, unnormalized stored-gradient arrows. Unknown/non-smooth points skipped. Conservative interval rendering masks are presentation not scientific certificates; no backend activation/save.

**Units:** View Float64 grids/Float32 arrow glyphs; coordinate labels not inferred physical units.

**Ownership:** Fresh sampled arrays/Figure, stored report retained read-only.

**Dependencies:** Caller rendering backend.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: BRIEF/detailed vector/phase. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/visualization/scalar_fields.jl:134.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:67; test/multivariate_visualization.jl:10; notebooks/multivariable_analysis.jl:37.

```@raw html
<p>Repository resources: <a href="../repository/notebooks/multivariable_analysis.jl">notebooks/multivariable_analysis.jl</a>; <a href="../repository/src/visualization/scalar_fields.jl">src/visualization/scalar_fields.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/multivariate_visualization.jl">test/multivariate_visualization.jl</a></p>
```

<!-- aml-api: {"symbol": "losscomponentsplot", "family": "F35", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [losscomponentsplot](@id api-losscomponentsplot)

**Identity:** generic function; F35; **PUBLIC_STABLE**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "59e8b7dbe68a0f3f49782590a08248944e1716a9269e304cf50f08e7e45c90a6"} -->
**Purpose and output:** Makie.Figure

**Source declarations and forwarding context:**

```text
function losscomponentsplot(a::PINNAnalysis)
```

**Inputs:** PINNAnalysis

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** Raw malformed/backend errors

**Numerical limitations:** Unweighted training costs not physical error; BC/IC cost distinction not invented; weight evolution unavailable. Backend caller-activated only.

**Units:** Stored Float64 coordinates/errors, no units conversion.

**Ownership:** Fresh Figure and presentation buffers; stored data read-only.

**Dependencies:** Caller rendering backend.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: ABSENT. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/visualization/pinn_diagnostics.jl:56.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:92; test/pinn_diagnostics.jl:48; examples/pinn/benchmark_gate.jl:82.

```@raw html
<p>Repository resources: <a href="../repository/examples/pinn/benchmark_gate.jl">examples/pinn/benchmark_gate.jl</a>; <a href="../repository/src/visualization/pinn_diagnostics.jl">src/visualization/pinn_diagnostics.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/pinn_diagnostics.jl">test/pinn_diagnostics.jl</a></p>
```

<!-- aml-api: {"symbol": "lossplot", "family": "F35", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [lossplot](@id api-lossplot)

**Identity:** generic function; F35; **PUBLIC_STABLE**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "282453614e6b1aa3a3513778d5b1aae2e3c4af01520c8ef8b6c34e501c38f585"} -->
**Purpose and output:** Makie.Figure

**Source declarations and forwarding context:**

```text
function lossplot(h::PINNHistory)

function lossplot(r::PINNTrainingResult)
```

**Inputs:** PINNHistory or PINNTrainingResult

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError history unrequested/empty

**Numerical limitations:** Stored total objective only; labels truncation, no new loss evaluation. Backend caller-activated only.

**Units:** Stored Float64 coordinates/errors, no units conversion.

**Ownership:** Fresh Figure and presentation buffers; stored data read-only.

**Dependencies:** Caller rendering backend.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: BRIEF. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/visualization/pinn.jl:2; src/visualization/pinn.jl:13.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:90; test/pinn_base.jl:5; notebooks/pinn_diagnostics.jl:29.

```@raw html
<p>Repository resources: <a href="../repository/notebooks/pinn_diagnostics.jl">notebooks/pinn_diagnostics.jl</a>; <a href="../repository/src/visualization/pinn.jl">src/visualization/pinn.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/pinn_base.jl">test/pinn_base.jl</a></p>
```

<!-- aml-api: {"symbol": "mdplot", "family": "F35", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [mdplot](@id api-mdplot)

**Identity:** generic function; F35; **PUBLIC_STABLE**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "5119d37a3835280f84c7ef9f65968c93c712797727438d5423b82d3fe693ba55"} -->
**Purpose and output:** Makie.Figure

**Source declarations and forwarding context:**

```text
function mdplot(s::AtomisticSnapshot;color=:species,selected_particle=nothing,markersize=14)

mdplot(r::AtomisticSystemAnalysis;kwargs...)=mdplot(r.source;kwargs...)

mdplot(t::AtomisticTrajectoryView;frame::Integer=1,kwargs...)=mdplot(t[frame];kwargs...)

mdplot(x;kwargs...)=mdplot(atomistic_snapshot(x);kwargs...)
```

**Inputs:** Snapshot,AtomisticSystemAnalysis,TrajectoryView frame=1,or backend; color=:species,selected_particle=nothing,markersize=14

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError invalid coords/color/velocity/markersize; BoundsError selection/frame

**Numerical limitations:** Only finite nonempty2D/3D; provided images not unwrapped; marker pixels not radius, no bonds. Caller activates rendering backend; no file save/new simulation.

**Units:** Atomistic views explicitly scale Unitful to selected coordinate units; other labels do not convert metadata.

**Ownership:** Only requested frame accessed; fresh rendering buffers.

**Dependencies:** Caller rendering backend.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: BRIEF/detailed. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/visualization/atomistic.jl:14; src/visualization/atomistic.jl:65; src/visualization/atomistic.jl:66; src/visualization/atomistic.jl:67.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:81; test/atomistic_visualization.jl:6; notebooks/molly_companion.jl:77.

```@raw html
<p>Repository resources: <a href="../repository/notebooks/molly_companion.jl">notebooks/molly_companion.jl</a>; <a href="../repository/src/visualization/atomistic.jl">src/visualization/atomistic.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/atomistic_visualization.jl">test/atomistic_visualization.jl</a></p>
```

<!-- aml-api: {"symbol": "modeplot", "family": "F35", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [modeplot](@id api-modeplot)

**Identity:** generic function; F35; **PUBLIC_STABLE**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "33c2631bd7d8e1eeffc58b44d6c7bc28605b048046f54e51d724020b41db4eb3"} -->
**Purpose and output:** Makie.Figure

**Source declarations and forwarding context:**

```text
function modeplot(r::NormalModeAnalysis;modes=nothing,representation=:generalized)
```

**Inputs:** NormalModeAnalysis; modes=nothing, representation=:generalized or :mass_weighted

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError missing modes,invalid representation/index

**Numerical limitations:** Stored components vs index no assumed geometry; degenerate bases nonunique. Caller activates rendering backend; no file save/new simulation.

**Units:** Atomistic views explicitly scale Unitful to selected coordinate units; other labels do not convert metadata.

**Ownership:** Fresh plotted vectors/Figure.

**Dependencies:** Caller rendering backend.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: BRIEF/detailed. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/visualization/mechanics.jl:74.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:77; test/normal_modes_visualization.jl:5; notebooks/mechanics_addendum.jl:70.

```@raw html
<p>Repository resources: <a href="../repository/notebooks/mechanics_addendum.jl">notebooks/mechanics_addendum.jl</a>; <a href="../repository/src/visualization/mechanics.jl">src/visualization/mechanics.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/normal_modes_visualization.jl">test/normal_modes_visualization.jl</a></p>
```

<!-- aml-api: {"symbol": "msdplot", "family": "F35", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [msdplot](@id api-msdplot)

**Identity:** generic function; F35; **PUBLIC_STABLE**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "c00510620704a15019dcf83aee02f6b1c1a0dc370def2f6a4260f03dce1dd4bc"} -->
**Purpose and output:** Makie.Figure

**Source declarations and forwarding context:**

```text
function msdplot(m::MeanSquaredDisplacement;fit=nothing)
```

**Inputs:** MeanSquaredDisplacement; fit optional stored PropertyResult

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError unavailable MSD/invalid stored fit

**Numerical limitations:** Optional fit overlay caller association not independently verified against MSD; no new fitting. Caller renderer only no backend activation/save.

**Units:** Trajectory/comparison Unitful display scales retained; inference supplied numeric coordinates, no conversion inference.

**Ownership:** Fresh buffers/Figure; source read-only, lazy values may be evaluated.

**Dependencies:** Caller rendering backend.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: BRIEF/detailed. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/visualization/trajectory.jl:31.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:86; test/trajectory_visualization.jl:16; notebooks/molly_trajectory_analysis.jl:56.

```@raw html
<p>Repository resources: <a href="../repository/notebooks/molly_trajectory_analysis.jl">notebooks/molly_trajectory_analysis.jl</a>; <a href="../repository/src/visualization/trajectory.jl">src/visualization/trajectory.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/trajectory_visualization.jl">test/trajectory_visualization.jl</a></p>
```

<!-- aml-api: {"symbol": "parameterfitplot", "family": "F35", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [parameterfitplot](@id api-parameterfitplot)

**Identity:** generic function; F35; **PUBLIC_STABLE**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "da6505d65f65a8c7f7d5f2b15d9be827b138a108088266a0f66b036c081cdf8f"} -->
**Purpose and output:** Makie.Figure

**Source declarations and forwarding context:**

```text
function parameterfitplot(r::ParameterInferenceResult;variable::Integer=1)
```

**Inputs:** ParameterInferenceResult; variable::Integer=1

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError invalid observed variable index

**Numerical limitations:** Stored prediction/history/local sensitivity/reference only; no solve/AD/resample. Caller renderer only no backend activation/save.

**Units:** Trajectory/comparison Unitful display scales retained; inference supplied numeric coordinates, no conversion inference.

**Ownership:** Fresh buffers/Figure; source read-only, lazy values may be evaluated.

**Dependencies:** Caller rendering backend.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: BRIEF/detailed. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/visualization/inference.jl:4.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:94; examples/inference/integration_gate.jl:41.

```@raw html
<p>Repository resources: <a href="../repository/examples/inference/integration_gate.jl">examples/inference/integration_gate.jl</a>; <a href="../repository/src/visualization/inference.jl">src/visualization/inference.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a></p>
```

<!-- aml-api: {"symbol": "phaseplot", "family": "F35", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 2} -->
## [phaseplot](@id api-phaseplot)

**Identity:** generic function; F35; **PUBLIC_STABLE**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "2d536cf8470e7e31a41aa1100cfda1768a7942a37231fe251282f944c58e2b31"} -->
### Dispatch contract 1

**Purpose and output:** Makie.Figure

**Source declarations and forwarding context:**

```text
function phaseplot(report::DynamicalSystemAnalysis; trajectories=(),show_nullclines::Bool=false,
xrange=(-2,2),yrange=(-2,2),samples::Integer=15,arrowscale::Real=0.1)
```

**Inputs:** 2D DynamicalSystemAnalysis; precomputed trajectories=(),show_nullclines=false, ranges(-2,2),samples=15,arrowscale=0.1

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError wrong dimension/trajectory source; vector view failures propagate

**Numerical limitations:** Trajectory field identity required; stored equilibrium markers; optional 101-grid nullclines no solving. Segments crossing unresolved cells omitted. Conservative interval rendering masks are presentation not scientific certificates; no backend activation/save.

**Units:** View Float64 grids/Float32 arrow glyphs; coordinate labels not inferred physical units.

**Ownership:** Fresh sampled arrays/Figure, stored report retained read-only.

**Dependencies:** Caller rendering backend.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: BRIEF/detailed vector/phase. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/visualization/dynamical_systems.jl:32.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:71; test/dynamical_visualization.jl:6; notebooks/dynamical_systems.jl:55.

```@raw html
<p>Repository resources: <a href="../repository/notebooks/dynamical_systems.jl">notebooks/dynamical_systems.jl</a>; <a href="../repository/src/visualization/dynamical_systems.jl">src/visualization/dynamical_systems.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/dynamical_visualization.jl">test/dynamical_visualization.jl</a></p>
```

<!-- aml-contract: {"variant": 1, "digest": "6291800b394ac525965e139252c948a68493202d07db6646afcb17b401229c50"} -->
### Dispatch contract 2

**Purpose and output:** Makie.Figure

**Source declarations and forwarding context:**

```text
function phaseplot(conversion::MechanicsDynamics;energy_levels=nothing,
xrange=(-2,2),yrange=(-2,2),kwargs...)

function phaseplot(report::Union{LagrangianAnalysis,HamiltonianAnalysis};
conversion=dynamics(report),kwargs...)
```

**Inputs:** MechanicsDynamics or mechanics report; energy_levels optional; report conversion defaults dynamics(report)

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError nonautonomous/wrongsource/invalid sorted levels; delegated phase guards

**Numerical limitations:** Conversion route reuses cached planar analysis; report convenience default performs dynamics conversion/reanalysis (not universally stored-only). Optional energy contours illustrative not invariant proof. Caller activates rendering backend; no file save/new simulation.

**Units:** Atomistic views explicitly scale Unitful to selected coordinate units; other labels do not convert metadata.

**Ownership:** Fresh Figure; report default conversion may allocate symbolic/numerical analysis.

**Dependencies:** Caller rendering backend.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: BRIEF/detailed. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/visualization/mechanics.jl:17; src/visualization/mechanics.jl:38.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:71; test/dynamical_visualization.jl:6; notebooks/dynamical_systems.jl:55.

```@raw html
<p>Repository resources: <a href="../repository/notebooks/dynamical_systems.jl">notebooks/dynamical_systems.jl</a>; <a href="../repository/src/visualization/mechanics.jl">src/visualization/mechanics.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/dynamical_visualization.jl">test/dynamical_visualization.jl</a></p>
```

<!-- aml-api: {"symbol": "pinnplot", "family": "F35", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [pinnplot](@id api-pinnplot)

**Identity:** generic function; F35; **PUBLIC_STABLE**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "12eb5e76ee72c8c7434582d2621cac32e8b48dfff53388ef0dc28e4252ba852a"} -->
**Purpose and output:** Makie.Figure

**Source declarations and forwarding context:**

```text
function pinnplot(a::PINNAnalysis;variable::Integer=1,equation::Integer=1)
```

**Inputs:** PINNAnalysis; variable/equation default1

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** BoundsError selection; ArgumentError unavailable reference/residual/>2dims

**Numerical limitations:** Stored reference/prediction/abs error/signed residual, no new evaluation. Backend caller-activated only.

**Units:** Stored Float64 coordinates/errors, no units conversion.

**Ownership:** Fresh Figure and presentation buffers; stored data read-only.

**Dependencies:** Caller rendering backend.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: BRIEF. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/visualization/pinn_diagnostics.jl:67.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:92; test/pinn_diagnostics.jl:49; examples/pinn/benchmark_gate.jl:28.

```@raw html
<p>Repository resources: <a href="../repository/examples/pinn/benchmark_gate.jl">examples/pinn/benchmark_gate.jl</a>; <a href="../repository/src/visualization/pinn_diagnostics.jl">src/visualization/pinn_diagnostics.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/pinn_diagnostics.jl">test/pinn_diagnostics.jl</a></p>
```

<!-- aml-api: {"symbol": "plot", "family": "F35", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 3} -->
## [plot](@id api-plot)

**Identity:** generic function; F35; **PUBLIC_STABLE**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "8c86ab2163a6718a3d7918795e3040511cd4596cc3e3b2a1cd21576cc0925b67"} -->
### Dispatch contract 1

**Purpose and output:** Makie.Figure

**Source declarations and forwarding context:**

```text
function plot(report::FunctionAnalysis; xmin::Real=-5, xmax::Real=5,
samples::Integer=501)

function plot(result::DerivativeConvergenceAnalysis)
```

**Inputs:** FunctionAnalysis with xmin=-5,xmax=5,samples=501 or DerivativeConvergenceAnalysis

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError invalid bounds/samples; DomainError values masked, other exceptions propagate

**Numerical limitations:** Stored domain split curves with NaN rendering separators; unknown domain sampling not proof. Convergence zero errors omitted, never epsilon. No backend activation/save/solve.

**Units:** Learning numeric outputs Float64 normalized/scaled; plotting Float64 view conversion, not units engine.

**Ownership:** Fresh Figure sampled arrays; no report mutation.

**Dependencies:** Rendering backend explicitly chosen by caller, e.g. CairoMakie.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: DETAILED. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/visualization/plots.jl:12; src/visualization/plots.jl:53.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:68; test/architecture.jl:106; notebooks/derivative_convergence.jl:25.

```@raw html
<p>Repository resources: <a href="../repository/notebooks/derivative_convergence.jl">notebooks/derivative_convergence.jl</a>; <a href="../repository/src/visualization/plots.jl">src/visualization/plots.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a></p>
```

<!-- aml-contract: {"variant": 1, "digest": "07dd25403531a491e0e9ba6502d079acde98eb765e7e9fe11226826681facac4"} -->
### Dispatch contract 2

**Purpose and output:** Makie.Figure

**Source declarations and forwarding context:**

```text
plot(report::ScalarFieldAnalysis; kwargs...) = surface(report; kwargs...)

plot(report::VectorFieldAnalysis;kwargs...) = vectorplot(report;kwargs...)
```

**Inputs:** ScalarFieldAnalysis or VectorFieldAnalysis; kwargs

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** Inherited view guards

**Numerical limitations:** Dispatch scalar→surface, vector→vectorplot; inherited limitations. Conservative interval rendering masks are presentation not scientific certificates; no backend activation/save.

**Units:** View Float64 grids/Float32 arrow glyphs; coordinate labels not inferred physical units.

**Ownership:** Fresh sampled arrays/Figure, stored report retained read-only.

**Dependencies:** Caller rendering backend.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: BRIEF/detailed vector/phase. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/visualization/scalar_fields.jl:158; src/visualization/vector_fields.jl:47.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:68; test/architecture.jl:106; notebooks/derivative_convergence.jl:25.

```@raw html
<p>Repository resources: <a href="../repository/notebooks/derivative_convergence.jl">notebooks/derivative_convergence.jl</a>; <a href="../repository/src/visualization/scalar_fields.jl">src/visualization/scalar_fields.jl</a>; <a href="../repository/src/visualization/vector_fields.jl">src/visualization/vector_fields.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a></p>
```

<!-- aml-contract: {"variant": 2, "digest": "f9b97b65502432b7e59cc330ff299c73f5abb75ca12767987cb9b33bd39f7cea"} -->
### Dispatch contract 3

**Purpose and output:** Makie.Figure

**Source declarations and forwarding context:**

```text
plot(p::PotentialAnalysis;kwargs...)=potentialplot(p;kwargs...)

function plot(r::RadialDistributionAnalysis)
```

**Inputs:** PotentialAnalysis→potentialplot or RadialDistributionAnalysis

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError RDF normalization unavailable or delegated view guards

**Numerical limitations:** RDF unavailable not plotted0; unknown units not dimensionless. Caller activates rendering backend; no file save/new simulation.

**Units:** Atomistic views explicitly scale Unitful to selected coordinate units; other labels do not convert metadata.

**Ownership:** Fresh view buffers.

**Dependencies:** Caller rendering backend.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: BRIEF/detailed. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/visualization/potentials.jl:44; src/visualization/atomistic.jl:70.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:68; test/architecture.jl:106; notebooks/derivative_convergence.jl:25.

```@raw html
<p>Repository resources: <a href="../repository/notebooks/derivative_convergence.jl">notebooks/derivative_convergence.jl</a>; <a href="../repository/src/visualization/atomistic.jl">src/visualization/atomistic.jl</a>; <a href="../repository/src/visualization/potentials.jl">src/visualization/potentials.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a></p>
```

<!-- aml-api: {"symbol": "potentialplot", "family": "F35", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [potentialplot](@id api-potentialplot)

**Identity:** generic function; F35; **PUBLIC_STABLE**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "2f0ef36e5bf2e2637db2569cd8fe2f0aaa311f4c110c4f2649bfa7bc3ca10cf6"} -->
**Purpose and output:** Makie.Figure

**Source declarations and forwarding context:**

```text
function potentialplot(p::PotentialAnalysis;rmin::Real,rmax::Real,samples::Integer=501)
```

**Inputs:** PotentialAnalysis; required rmin/rmax, samples=501

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError bounds/count; known domain errors masked, other errors propagate

**Numerical limitations:** Positive finite interval samples>=2; cutoff metadata does not modify curves; no reanalysis. Caller activates rendering backend; no file save/new simulation.

**Units:** Atomistic views explicitly scale Unitful to selected coordinate units; other labels do not convert metadata.

**Ownership:** New Float64 radius/energy/force buffers.

**Dependencies:** Caller rendering backend.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: BRIEF/detailed. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/visualization/potentials.jl:25.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:80; test/potential_visualization.jl:7; notebooks/molly_companion.jl:78.

```@raw html
<p>Repository resources: <a href="../repository/notebooks/molly_companion.jl">notebooks/molly_companion.jl</a>; <a href="../repository/src/visualization/potentials.jl">src/visualization/potentials.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/potential_visualization.jl">test/potential_visualization.jl</a></p>
```

<!-- aml-api: {"symbol": "residualplot", "family": "F35", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [residualplot](@id api-residualplot)

**Identity:** generic function; F35; **PUBLIC_STABLE**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "8d21b90c50b446d06c9598bef6cb13756c5a73bd084705ec6e968afb1762c255"} -->
**Purpose and output:** Makie.Figure

**Source declarations and forwarding context:**

```text
function residualplot(a::PINNAnalysis;equation::Integer=1)
```

**Inputs:** PINNAnalysis; equation::Integer=1

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** BoundsError invalid equation; ArgumentError unevaluated or >2 coordinate dims

**Numerical limitations:** Signed stored residual; 0/1D scatter, 2D complete unique Cartesian grid heatmap else scatter, no interpolation. Backend caller-activated only.

**Units:** Stored Float64 coordinates/errors, no units conversion.

**Ownership:** Fresh Figure and presentation buffers; stored data read-only.

**Dependencies:** Caller rendering backend.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: ABSENT method. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/visualization/pinn_diagnostics.jl:27.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:92; test/pinn_diagnostics.jl:45; notebooks/pinn_diagnostics.jl:25.

```@raw html
<p>Repository resources: <a href="../repository/notebooks/pinn_diagnostics.jl">notebooks/pinn_diagnostics.jl</a>; <a href="../repository/src/visualization/pinn_diagnostics.jl">src/visualization/pinn_diagnostics.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/pinn_diagnostics.jl">test/pinn_diagnostics.jl</a></p>
```

<!-- aml-api: {"symbol": "surface", "family": "F35", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [surface](@id api-surface)

**Identity:** generic function; F35; **PUBLIC_STABLE**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "9bb2f280975f66a76980cbf223cd18189582fb23d157bb192b1af2ea69925a08"} -->
**Purpose and output:** Makie.Figure

**Source declarations and forwarding context:**

```text
function surface(report::ScalarFieldAnalysis; xrange=(-5,5), yrange=(-5,5), samples::Integer=101,
tangent_at=nothing, critical_markers::Bool=true)
```

**Inputs:** 2D ScalarFieldAnalysis; xrange/yrange (-5,5),samples=101,tangent_at=nothing,critical_markers=true

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError invalid dimension/bounds/count; tangent smoothness errors propagate

**Numerical limitations:** Samples2:501 each axis; tangent_at calls checked stored gradient/linearization (no new symbolic analysis). Conservative interval rendering masks are presentation not scientific certificates; no backend activation/save.

**Units:** View Float64 grids/Float32 arrow glyphs; coordinate labels not inferred physical units.

**Ownership:** Fresh sampled arrays/Figure, stored report retained read-only.

**Dependencies:** Caller rendering backend.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: BRIEF/detailed vector/phase. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/visualization/scalar_fields.jl:100.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:68; test/architecture.jl:106; examples/operators/focused_gate.jl:12.

```@raw html
<p>Repository resources: <a href="../repository/examples/operators/focused_gate.jl">examples/operators/focused_gate.jl</a>; <a href="../repository/src/visualization/scalar_fields.jl">src/visualization/scalar_fields.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a></p>
```

<!-- aml-api: {"symbol": "timeplot", "family": "F35", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [timeplot](@id api-timeplot)

**Identity:** generic function; F35; **PUBLIC_STABLE**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "a2636b564f01e1a1c0465189ea9d4583ac9bd7f3379338429a462c652c9c7d33"} -->
**Purpose and output:** Makie.Figure

**Source declarations and forwarding context:**

```text
function timeplot(path::TrajectoryResult)
```

**Inputs:** TrajectoryResult

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** Malformed raw trajectory/backend plotting errors propagate

**Numerical limitations:** Only saved states/time no RHS/interpolation/solve. Conservative interval rendering masks are presentation not scientific certificates; no backend activation/save.

**Units:** View Float64 grids/Float32 arrow glyphs; coordinate labels not inferred physical units.

**Ownership:** Fresh sampled arrays/Figure, stored report retained read-only.

**Dependencies:** Caller rendering backend.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: BRIEF/detailed vector/phase. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/visualization/dynamical_systems.jl:76.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:71; test/dynamical_visualization.jl:7; examples/integration/one_system_plots.jl:12.

```@raw html
<p>Repository resources: <a href="../repository/examples/integration/one_system_plots.jl">examples/integration/one_system_plots.jl</a>; <a href="../repository/src/visualization/dynamical_systems.jl">src/visualization/dynamical_systems.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/dynamical_visualization.jl">test/dynamical_visualization.jl</a></p>
```

<!-- aml-api: {"symbol": "timeseriesplot", "family": "F35", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [timeseriesplot](@id api-timeseriesplot)

**Identity:** generic function; F35; **PUBLIC_STABLE**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "6c691b7d4f2ac5b086930758f940fb1afa78a31e1b9d7a1ef4db947a541cd493"} -->
**Purpose and output:** Makie.Figure

**Source declarations and forwarding context:**

```text
timeseriesplot(s::ObservableSeries)=first(_ts_curve(s.sampling.times,collect(s.values);title=string(s.name)))
```

**Inputs:** ObservableSeries

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError absent times/unavailable/misaligned/nonfinite values

**Numerical limitations:** Explicit times or declared index time upstream; finite aligned scalar values; may materialize lazy series. Caller renderer only no backend activation/save.

**Units:** Trajectory/comparison Unitful display scales retained; inference supplied numeric coordinates, no conversion inference.

**Ownership:** Fresh buffers/Figure; source read-only, lazy values may be evaluated.

**Dependencies:** Caller rendering backend.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: BRIEF/detailed. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/visualization/trajectory.jl:15.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:86; test/trajectory_visualization.jl:6; examples/integration/one_system_plots.jl:35.

```@raw html
<p>Repository resources: <a href="../repository/examples/integration/one_system_plots.jl">examples/integration/one_system_plots.jl</a>; <a href="../repository/src/visualization/trajectory.jl">src/visualization/trajectory.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/trajectory_visualization.jl">test/trajectory_visualization.jl</a></p>
```

<!-- aml-api: {"symbol": "vacfplot", "family": "F35", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [vacfplot](@id api-vacfplot)

**Identity:** generic function; F35; **PUBLIC_STABLE**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "2fd405d771ed8def86d2a78295bdc8995916c060c17a3cd4a41917b599351003"} -->
**Purpose and output:** Makie.Figure

**Source declarations and forwarding context:**

```text
function vacfplot(v::VelocityAutocorrelation;normalized=false)
```

**Inputs:** VelocityAutocorrelation; normalized=false

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError unavailable normalized/time/raw values

**Numerical limitations:** Normalized must have been requested and available; raw no mean subtraction. Caller renderer only no backend activation/save.

**Units:** Trajectory/comparison Unitful display scales retained; inference supplied numeric coordinates, no conversion inference.

**Ownership:** Fresh buffers/Figure; source read-only, lazy values may be evaluated.

**Dependencies:** Caller rendering backend.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: BRIEF/detailed. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/visualization/trajectory.jl:44.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:86; test/trajectory_visualization.jl:18; notebooks/molly_trajectory_analysis.jl:56.

```@raw html
<p>Repository resources: <a href="../repository/notebooks/molly_trajectory_analysis.jl">notebooks/molly_trajectory_analysis.jl</a>; <a href="../repository/src/visualization/trajectory.jl">src/visualization/trajectory.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/trajectory_visualization.jl">test/trajectory_visualization.jl</a></p>
```

<!-- aml-api: {"symbol": "vectorplot", "family": "F35", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [vectorplot](@id api-vectorplot)

**Identity:** generic function; F35; **PUBLIC_STABLE**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "6dbeaf1eeec707d557c00fec299d362274f98a6d30925011a0a035efaf2cc026"} -->
**Purpose and output:** Makie.Figure

**Source declarations and forwarding context:**

```text
function vectorplot(report::VectorFieldAnalysis; xrange=(-2,2),yrange=(-2,2),
samples::Integer=15,arrowscale::Real=1)
```

**Inputs:** R²→R² VectorFieldAnalysis; ranges (-2,2),samples=15,arrowscale=1

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError invalid dimension/bounds/count/scale

**Numerical limitations:** Samples2:50; rendered Float32 anchor checked for known membership; glyph shafts not certified paths. Conservative interval rendering masks are presentation not scientific certificates; no backend activation/save.

**Units:** View Float64 grids/Float32 arrow glyphs; coordinate labels not inferred physical units.

**Ownership:** Fresh sampled arrays/Figure, stored report retained read-only.

**Dependencies:** Caller rendering backend.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: BRIEF/detailed vector/phase. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/visualization/vector_fields.jl:37.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:69; test/vector_visualization.jl:8; notebooks/vector_field_analysis.jl:44.

```@raw html
<p>Repository resources: <a href="../repository/notebooks/vector_field_analysis.jl">notebooks/vector_field_analysis.jl</a>; <a href="../repository/src/visualization/vector_fields.jl">src/visualization/vector_fields.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/vector_visualization.jl">test/vector_visualization.jl</a></p>
```
