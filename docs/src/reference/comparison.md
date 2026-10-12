# Compatibility-gated scientific comparisons

Value equality does not establish compatible units, particle identity, time windows or source ancestry. Compatibility and statistical independence are separate. Comparison inspects declared stored evidence rather than reconstructing missing scientific results.

Read [API boundaries and evidence semantics](@ref api-boundaries) for the distinction between raw constructors, validated factories, exceptions, unknown claims and unrequested/partial diagnostics. Signatures are text, not runnable examples. Backend forwarding/context lines do not create public helper APIs.

```@raw html
<p>Repository resources: <a href="../repository/docs/trajectory_comparison.md">docs/trajectory_comparison.md</a>; <a href="../repository/docs/tutorials/scripts/trajectories.jl">docs/tutorials/scripts/trajectories.jl</a>; <a href="../repository/docs/tutorials/trajectories.md">docs/tutorials/trajectories.md</a>; <a href="../repository/reports/m10d6/tutorial_verification.json">reports/m10d6/tutorial_verification.json</a></p>
```

## [F25: Compatibility-gated comparisons](@id family-F25)

<!-- aml-api: {"symbol": "compare", "family": "F25", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [compare](@id api-compare)

**Identity:** generic function; F25; **PUBLIC_STABLE**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "6fad1411173439102ac7ddbf4b53778c82c277cc563ffa5a697f86caecadb754"} -->
**Purpose and output:** ObservableComparison or MDTrajectoryComparison

**Source declarations and forwarding context:**

```text
function compare(a::ComparisonInput,b::ComparisonInput;quantity=:auto,
independence=:unknown,unitless=false,unitless_time=false)

compare(a::Union{PropertyResult,AutocorrelationAnalysis,BlockAnalysis,MeanSquaredDisplacement,VelocityAutocorrelation},

compare(a::MDTrajectoryAnalysis,b::MDTrajectoryAnalysis;kwargs...)=compare_runs(a,b;kwargs...)
```

**Inputs:** ComparisonInput or supported stored summary/ACF/block/MSD/VACF results; MDTrajectoryAnalysis dispatches compare_runs

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError unsupported quantity/independence; missing metadata becomes compatibility unknown and no difference

**Numerical limitations:** quantity=:auto or pair; independence=:unknown|:independent, unitless=false,unitless_time=false. No alignment/truncation/recomputation. Shared plain unit scales must be asserted; physical_tau index time unavailable in comparison; estimator/grid/selection match required. Combined SE only distinct results with compatible actual SE/time/window and caller independent assertion.

**Units:** Compatible Unitful arithmetic preserved; units unknown for plain values; variance/covariance squared units. Time spacing does not infer simulation dt.

**Ownership:** Retains both inputs; fresh differences; source labels not identities.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: DETAILED but wrapper reference incomplete. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/trajectory/comparison.jl:264; src/trajectory/comparison.jl:315; src/trajectory/comparison.jl:368.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:88; test/m10a_atomistic_statistics.jl:236; examples/integration/one_system_many_methods.jl:177.

```@raw html
<p>Repository resources: <a href="../repository/examples/integration/one_system_many_methods.jl">examples/integration/one_system_many_methods.jl</a>; <a href="../repository/src/trajectory/comparison.jl">src/trajectory/comparison.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/m10a_atomistic_statistics.jl">test/m10a_atomistic_statistics.jl</a></p>
```

<!-- aml-api: {"symbol": "compare_runs", "family": "F25", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [compare_runs](@id api-compare-runs)

**Identity:** generic function; F25; **PUBLIC_STABLE**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "f74c15c1aab936b2069f3fff095e806e9701428ea034f670b3cc246bdc9274a9"} -->
**Purpose and output:** MDTrajectoryComparison

**Source declarations and forwarding context:**

```text
function compare_runs(a::MDTrajectoryAnalysis,b::MDTrajectoryAnalysis;
components=(:summaries,:correlations,:deviations,:transients,:msd,:vacf,:diffusion),
labels=(nothing,nothing),selections=(nothing,nothing),kwargs...)
```

**Inputs:** Two MDTrajectoryAnalysis; literal components/labels/selections/kwargs

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError invalid components or two-label/selection lengths

**Numerical limitations:** Union of stored map keys, observable identity from series not keys. Default quantity for each component only; no missing calculation.

**Units:** Compatible Unitful arithmetic preserved; units unknown for plain values; variance/covariance squared units. Time spacing does not infer simulation dt.

**Ownership:** Retains reports and new component maps.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: DETAILED. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/trajectory/comparison.jl:341.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:88; test/trajectory_comparison_runs.jl:5; notebooks/trajectory_comparison.jl:22.

```@raw html
<p>Repository resources: <a href="../repository/notebooks/trajectory_comparison.jl">notebooks/trajectory_comparison.jl</a>; <a href="../repository/src/trajectory/comparison.jl">src/trajectory/comparison.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/trajectory_comparison_runs.jl">test/trajectory_comparison_runs.jl</a></p>
```

<!-- aml-api: {"symbol": "ComparisonCompatibility", "family": "F25", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "type / constructors", "variant_count": 1} -->
## [ComparisonCompatibility](@id api-ComparisonCompatibility)

**Identity:** type / constructors; F25; **PUBLIC_STABLE**; explicitly exported.

**Stored fields:** `status`, `checks`, `reasons`. Immutable outer record; referenced payloads may still be mutable. Obtain validated outputs through the operations described below; a raw record constructor does not itself certify scientific consistency.

<!-- aml-contract: {"variant": 0, "digest": "a3d3086c83a849d9dee014ffbe0725cfaf07ba148758bcb1f75ec56222e0e262"} -->
**Purpose and output:** Status compatible/incompatible/unknown with named tri-state checks

**Source declarations and forwarding context:**

```text
struct ComparisonCompatibility <: AbstractAnalysis; raw generated field constructor: (status::Symbol, checks::Dict{Symbol,PropertyResult}, reasons::Vector{String})
```

**Inputs:** Raw status/checks/reasons; constructed by comparison

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** No additional refusal specified in this audited route; raw records do not establish validation.

**Numerical limitations:** Compatibility != physical certification or statistical independence.

**Units:** Compatible Unitful arithmetic preserved; units unknown for plain values; variance/covariance squared units. Time spacing does not infer simulation dt.

**Ownership:** Stored checks/reasons.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: DETAILED. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/trajectory/comparison.jl:23.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:87.

```@raw html
<p>Repository resources: <a href="../repository/src/trajectory/comparison.jl">src/trajectory/comparison.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a></p>
```

<!-- aml-api: {"symbol": "ComparisonInput", "family": "F25", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "type / constructors", "variant_count": 1} -->
## [ComparisonInput](@id api-ComparisonInput)

**Identity:** type / constructors; F25; **PUBLIC_STABLE**; explicitly exported.

**Stored fields:** `result`, `series`, `parent`, `label`, `selection`. Immutable outer record; referenced payloads may still be mutable. Obtain validated outputs through the operations described below; a raw record constructor does not itself certify scientific consistency.

<!-- aml-contract: {"variant": 0, "digest": "a3633ccb69dc892dc0663270061ae91c661080f129e300c66dd1e32db46e8d78"} -->
**Purpose and output:** Borrowed context wrapper

**Source declarations and forwarding context:**

```text
struct ComparisonInput{R,S,P,L,I} <: AbstractAnalysis; raw generated field constructor: (result::R, series::S, parent::P, label::L, selection::I)

ComparisonInput(result;series=nothing,parent=nothing,label=nothing,selection=nothing)=
```

**Inputs:** Stored result; series/parent/label/selection optional caller associations

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** No additional refusal specified in this audited route; raw records do not establish validation.

**Numerical limitations:** Associations assertions not reconstructed lineage; selection token required for transport population comparison.

**Units:** Compatible Unitful arithmetic preserved; units unknown for plain values; variance/covariance squared units. Time spacing does not infer simulation dt.

**Ownership:** Borrows result/series/parent.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: DETAILED. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/trajectory/comparison.jl:9; src/trajectory/comparison.jl:16.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:87; test/m10a_atomistic_statistics.jl:235; notebooks/trajectory_comparison.jl:33.

```@raw html
<p>Repository resources: <a href="../repository/notebooks/trajectory_comparison.jl">notebooks/trajectory_comparison.jl</a>; <a href="../repository/src/trajectory/comparison.jl">src/trajectory/comparison.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/m10a_atomistic_statistics.jl">test/m10a_atomistic_statistics.jl</a></p>
```

<!-- aml-api: {"symbol": "MDTrajectoryComparison", "family": "F25", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "type / constructors", "variant_count": 1} -->
## [MDTrajectoryComparison](@id api-MDTrajectoryComparison)

**Identity:** type / constructors; F25; **PUBLIC_STABLE**; explicitly exported.

**Stored fields:** `a`, `b`, `labels`, `components`, `assumptions`, `notes`. Immutable outer record; referenced payloads may still be mutable. Obtain validated outputs through the operations described below; a raw record constructor does not itself certify scientific consistency.

<!-- aml-contract: {"variant": 0, "digest": "754e602bc8b8fa484a87f666bf6248bb0e2de3a3c012350036f2e459962fc719"} -->
**Purpose and output:** Selective composition of stored component comparisons

**Source declarations and forwarding context:**

```text
struct MDTrajectoryComparison{A,B,L,C,S} <: AbstractAnalysis; raw generated field constructor: (a::A, b::B, labels::L, components::C, assumptions::S, notes::Vector{String})
```

**Inputs:** compare_runs or raw fields

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** No additional refusal specified in this audited route; raw records do not establish validation.

**Numerical limitations:** Not ensemble grade; missing components unknown.

**Units:** Compatible Unitful arithmetic preserved; units unknown for plain values; variance/covariance squared units. Time spacing does not infer simulation dt.

**Ownership:** Retains both full reports.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: BRIEF. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/trajectory/comparison.jl:320.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:87; test/trajectory_comparison_runs.jl:14.

```@raw html
<p>Repository resources: <a href="../repository/src/trajectory/comparison.jl">src/trajectory/comparison.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/trajectory_comparison_runs.jl">test/trajectory_comparison_runs.jl</a></p>
```

<!-- aml-api: {"symbol": "ObservableComparison", "family": "F25", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "type / constructors", "variant_count": 1} -->
## [ObservableComparison](@id api-ObservableComparison)

**Identity:** type / constructors; F25; **PUBLIC_STABLE**; explicitly exported.

**Stored fields:** `a`, `b`, `quantity`, `compatibility`, `metadata`, `difference`, `uncertainty`, `assumptions`, `notes`. Immutable outer record; referenced payloads may still be mutable. Obtain validated outputs through the operations described below; a raw record constructor does not itself certify scientific consistency.

<!-- aml-contract: {"variant": 0, "digest": "19542592a8df599e0bafdfa749933af495db54fe9e0c909e097d8aecb264753c"} -->
**Purpose and output:** Descriptive B−A with independent compatibility/difference/uncertainty

**Source declarations and forwarding context:**

```text
struct ObservableComparison{A,B,M,D,U,S} <: AbstractAnalysis; raw generated field constructor: (a::A, b::B, quantity::Symbol, compatibility::ComparisonCompatibility, metadata::M, difference::D, uncertainty::U, assumptions::S, notes::Vector{String})
```

**Inputs:** compare or raw stored fields

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** No additional refusal specified in this audited route; raw records do not establish validation.

**Numerical limitations:** No rankings or significance from difference alone.

**Units:** Compatible Unitful arithmetic preserved; units unknown for plain values; variance/covariance squared units. Time spacing does not infer simulation dt.

**Ownership:** Retains input contexts and metadata.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: BRIEF. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/trajectory/comparison.jl:30.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:87; test/trajectory_comparison.jl:12.

```@raw html
<p>Repository resources: <a href="../repository/src/trajectory/comparison.jl">src/trajectory/comparison.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/trajectory_comparison.jl">test/trajectory_comparison.jl</a></p>
```
