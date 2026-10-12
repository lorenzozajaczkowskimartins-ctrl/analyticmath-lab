# Sampling, stored statistics and diagnostics

Descriptive n-1 sample variance does not make correlated observations independent. Unknown uncertainty is not zero uncertainty. Saved sampling times are not solver internal timesteps; missing units are not dimensionlessness.

Read [API boundaries and evidence semantics](@ref api-boundaries) for the distinction between raw constructors, validated factories, exceptions, unknown claims and unrequested/partial diagnostics. Signatures are text, not runnable examples. Backend forwarding/context lines do not create public helper APIs.

```@raw html
<p>Repository resources: <a href="../repository/docs/trajectory_statistics.md">docs/trajectory_statistics.md</a>; <a href="../repository/docs/tutorials/scripts/trajectories.jl">docs/tutorials/scripts/trajectories.jl</a>; <a href="../repository/docs/tutorials/trajectories.md">docs/tutorials/trajectories.md</a>; <a href="../repository/reports/m10d6/tutorial_verification.json">reports/m10d6/tutorial_verification.json</a></p>
```

Overload map: [analyze](@ref dispatch-analyze).

Overload map: [observable_series](@ref dispatch-observable_series).

## [observable_series overloads](@id dispatch-observable_series)

<!-- aml-dispatch: {"symbol": "observable_series", "variants": 3} -->
### observable_series: dispatch-oriented map

| Input contract | Supported signature | Result | Dependencies | Scientific contract | Destination |
|---|---|---|---|---|---|
| Molly.GeneralObservableLogger | `function AML.observable_series(logger::Molly.GeneralObservableLogger;times=nothing, interval=nothing,index_time=false,provenance=NamedTuple())` | ObservableSeries | Molly | Stored selection and sampling/units provenance | [primary contract](@ref api-observable-series); [family](@ref family-F19) |
| TrajectoryResult | `function observable_series(path::TrajectoryResult;component=nothing,observable=nothing, name=:observable,context=NamedTuple())` | ObservableSeries | Core | Stored selection and sampling/units provenance | [primary contract](@ref api-observable-series); [family](@ref family-F19) |
| AtomisticTrajectoryView | `function observable_series(t::AtomisticTrajectoryView,name::Symbol;component=nothing, dof=nothing,boltzmann=nothing,time_options=NamedTuple())` | ObservableSeries | Core | Stored selection and sampling/units provenance | [primary contract](@ref api-observable-series); [family](@ref family-F19) |

## [F19: Sampling and observables](@id family-F19)

<!-- aml-api: {"symbol": "observable_series", "family": "F19", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 3} -->
## [observable_series](@id api-observable-series)

**Identity:** generic function; F19; **PUBLIC_STABLE**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "7a6f60e49a17ca74e84169229a723072a5a7f14661d018673d1d249823700f74"} -->
### Dispatch contract 1

**Purpose and output:** ObservableSeries

**Source declarations and forwarding context:**

```text
function AML.observable_series(logger::Molly.GeneralObservableLogger;times=nothing,
interval=nothing,index_time=false,provenance=NamedTuple())
```

**Inputs:** Supported Molly scalar energy/temperature GeneralObservableLogger; times/interval/index_time/provenance

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError unsupported logger; series sampling/value validation propagates

**Numerical limitations:** Captured-length values; temperature is logged backend DOF convention, not recomputed; scalar-coordinate synchronization caller responsibility.

**Units:** Supported Unitful arithmetic retained; unitless data are physically unknown unless caller declares provenance; labels never convert data.

**Ownership:** Borrows captured-length view; logger stride does not imply physical times.

**Dependencies:** Molly.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: DETAILED. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: ext/AnalyticMathLabMollyExt.jl:109.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:82; test/m10a_atomistic_statistics.jl:200; examples/integration/one_system_many_methods.jl:130.

```@raw html
<p>Repository resources: <a href="../repository/examples/integration/one_system_many_methods.jl">examples/integration/one_system_many_methods.jl</a>; <a href="../repository/ext/AnalyticMathLabMollyExt.jl">ext/AnalyticMathLabMollyExt.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/m10a_atomistic_statistics.jl">test/m10a_atomistic_statistics.jl</a></p>
```

<!-- aml-contract: {"variant": 1, "digest": "01440eabc49b6e9583c2a8ac53eef4a076eae854eb0e354b49c0665cc21fab68"} -->
### Dispatch contract 2

**Purpose and output:** ObservableSeries

**Source declarations and forwarding context:**

```text
function observable_series(path::TrajectoryResult;component=nothing,observable=nothing,
name=:observable,context=NamedTuple())
```

**Inputs:** TrajectoryResult with exactly one component index/unique source label or scalar observable(u,t); name/context

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError invalid selectors/names/empty samples/nonfinite values/unit mixture; DimensionMismatch states/times/labels; sampling refuses backward/duplicate times

**Numerical limitations:** Stored samples only; partial native solutions allowed and diagnostics retained; no interpolant/resampling/identity inference.

**Units:** Compatible Unitful arithmetic preserved; units unknown for plain values; variance/covariance squared units. Time spacing does not infer simulation dt.

**Ownership:** Fresh times/values; scalar callback receives copy of state; provenance strongly retains source/context/selector and labels/domain.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: DETAILED. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/trajectory/interoperability.jl:18.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:82; test/m10a_atomistic_statistics.jl:200; examples/integration/one_system_many_methods.jl:130.

```@raw html
<p>Repository resources: <a href="../repository/examples/integration/one_system_many_methods.jl">examples/integration/one_system_many_methods.jl</a>; <a href="../repository/src/trajectory/interoperability.jl">src/trajectory/interoperability.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/m10a_atomistic_statistics.jl">test/m10a_atomistic_statistics.jl</a></p>
```

<!-- aml-contract: {"variant": 2, "digest": "ef92aefc5919fd4b51497866c013b5fc80bbdc9dfde1353e958be1f2fac898ee"} -->
### Dispatch contract 3

**Purpose and output:** Lazy ObservableSeries

**Source declarations and forwarding context:**

```text
function observable_series(t::AtomisticTrajectoryView,name::Symbol;component=nothing,
dof=nothing,boltzmann=nothing,time_options=NamedTuple())
```

**Inputs:** AtomisticTrajectoryView,name::Symbol; component,dof,boltzmann,time_options

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError unsupported name/invalid component, dof, Boltzmann constant; missing observations retained

**Numerical limitations:** Energy/momentum/CM/temperature only; vector observable requires component for scalar statistics; temperature requires both explicit DOF and k; no force evaluation.

**Units:** Compatible Unitful arithmetic preserved; units unknown for plain values; variance/covariance squared units. Time spacing does not infer simulation dt.

**Ownership:** Lazy closure retains frame view; no frame history; mdcheck pairs disabled (selected index allocation still occurs).

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: DETAILED. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/trajectory/analyst.jl:16.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:82; test/m10a_atomistic_statistics.jl:200; examples/integration/one_system_many_methods.jl:130.

```@raw html
<p>Repository resources: <a href="../repository/examples/integration/one_system_many_methods.jl">examples/integration/one_system_many_methods.jl</a>; <a href="../repository/src/trajectory/analyst.jl">src/trajectory/analyst.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/m10a_atomistic_statistics.jl">test/m10a_atomistic_statistics.jl</a></p>
```

<!-- aml-api: {"symbol": "ObservableSeries", "family": "F19", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "type / constructors", "variant_count": 1} -->
## [ObservableSeries](@id api-ObservableSeries)

**Identity:** type / constructors; F19; **PUBLIC_STABLE**; explicitly exported.

**Stored fields:** `values`, `sampling`, `name`, `units`, `provenance`, `missing_policy`. Immutable outer record; referenced payloads may still be mutable. Obtain validated outputs through the operations described below; a raw record constructor does not itself certify scientific consistency.

<!-- aml-contract: {"variant": 0, "digest": "6ed72dab6674934acb06c8a2a5a5ab9d1c7d6dd2f943b768f68ac19d0cbc8c6f"} -->
**Purpose and output:** Borrowed scalar series

**Source declarations and forwarding context:**

```text
struct ObservableSeries{V,S,U,P} <: AbstractAnalysis; raw generated field constructor: (values::V, sampling::S, name::Symbol, units::U, provenance::P, missing_policy::Symbol)

function ObservableSeries(values::AbstractVector;times=nothing,interval=nothing,index_time=false,
name=:observable,provenance=NamedTuple(),missing_policy=:reject)
```

**Inputs:** AbstractVector values; required missing_policy=:reject; explicit timing/name/provenance

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError invalid name/policy or invalid sampling

**Numerical limitations:** Constructor inspects only first value for units; downstream analyses return unknown for missing/nonreal/nonfinite data, do not drop; dimensional mismatch throws.

**Units:** Compatible Unitful arithmetic preserved; units unknown for plain values; variance/covariance squared units. Time spacing does not infer simulation dt.

**Ownership:** Borrows even lazy vector; read-only convention.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: DETAILED. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/trajectory/statistics.jl:83; src/trajectory/statistics.jl:91.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:82; test/m10a_atomistic_statistics.jl:106; examples/integration/one_system_plots.jl:33.

```@raw html
<p>Repository resources: <a href="../repository/examples/integration/one_system_plots.jl">examples/integration/one_system_plots.jl</a>; <a href="../repository/src/trajectory/statistics.jl">src/trajectory/statistics.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/m10a_atomistic_statistics.jl">test/m10a_atomistic_statistics.jl</a></p>
```

<!-- aml-api: {"symbol": "sampling_info", "family": "F19", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [sampling_info](@id api-sampling-info)

**Identity:** generic function; F19; **PUBLIC_STABLE**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "6f55ecd96b050087196fce025d17f65ea2e322c1647f5a8dc05747863a6054f3"} -->
**Purpose and output:** SamplingInfo

**Source declarations and forwarding context:**

```text
function sampling_info(n::Integer;times=nothing,interval=nothing,index_time=false,provenance=NamedTuple())

sampling_info(t::AtomisticTrajectoryView;times=t.times,provenance=t.provenance,kwargs...)=
```

**Inputs:** n>=0 or AtomisticTrajectoryView; times, interval, index_time=false, provenance

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError nonfinite/nonincreasing times, incompatible/mixed units, conflicting interval/index_time; DimensionMismatch time count

**Numerical limitations:** Spacing relative tolerance1e-8 absolute0; interval produces lazy0-based range; index_time explicitly labeled sample index.

**Units:** Compatible Unitful arithmetic preserved; units unknown for plain values; variance/covariance squared units. Time spacing does not infer simulation dt.

**Ownership:** Borrows times/provenance; no collection unless caller.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: DETAILED. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/trajectory/statistics.jl:38; src/trajectory/statistics.jl:74.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:82; test/m10a_atomistic_statistics.jl:157; notebooks/molly_trajectory_analysis.jl:20.

```@raw html
<p>Repository resources: <a href="../repository/notebooks/molly_trajectory_analysis.jl">notebooks/molly_trajectory_analysis.jl</a>; <a href="../repository/src/trajectory/statistics.jl">src/trajectory/statistics.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/m10a_atomistic_statistics.jl">test/m10a_atomistic_statistics.jl</a></p>
```

<!-- aml-api: {"symbol": "SamplingInfo", "family": "F19", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "type / constructors", "variant_count": 1} -->
## [SamplingInfo](@id api-SamplingInfo)

**Identity:** type / constructors; F19; **PUBLIC_STABLE**; explicitly exported.

**Stored fields:** `count`, `times`, `interval`, `regularity`, `units`, `provenance`, `evidence`. Immutable outer record; referenced payloads may still be mutable. Obtain validated outputs through the operations described below; a raw record constructor does not itself certify scientific consistency.

<!-- aml-contract: {"variant": 0, "digest": "8c89096571b5b2221f842b12c95914e26320198a6944a43da5aa34c7c955f6f9"} -->
**Purpose and output:** Saved time metadata/evidence

**Source declarations and forwarding context:**

```text
struct SamplingInfo{T,I,U,P,E} <: AbstractAnalysis; raw generated field constructor: (count::Int, times::T, interval::I, regularity::Symbol, units::U, provenance::P, evidence::E)
```

**Inputs:** sampling_info factory or raw stored fields

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** No additional refusal specified in this audited route; raw records do not establish validation.

**Numerical limitations:** Count0/1 insufficient; spacing metadata not physical timestamp certification.

**Units:** Compatible Unitful arithmetic preserved; units unknown for plain values; variance/covariance squared units. Time spacing does not infer simulation dt.

**Ownership:** Borrowed time/provenance arrays.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: DETAILED. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/trajectory/statistics.jl:6.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:82.

```@raw html
<p>Repository resources: <a href="../repository/src/trajectory/statistics.jl">src/trajectory/statistics.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a></p>
```

## [F20: Descriptive moments](@id family-F20)

<!-- aml-api: {"symbol": "running_statistics", "family": "F20", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [running_statistics](@id api-running-statistics)

**Identity:** generic function; F20; **PUBLIC_STABLE**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "54fc16ed32aae03040e9872804c89a63e16d50b68b927086d8afab5f1b8921bd"} -->
**Purpose and output:** PropertyResult prefix counts/means/variances

**Source declarations and forwarding context:**

```text
function running_statistics(s::ObservableSeries)
```

**Inputs:** ObservableSeries

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** Same invalid data behavior as statistical_summary

**Numerical limitations:** O(N) output; first variance nothing; descriptive not uncertainty.

**Units:** Compatible Unitful arithmetic preserved; units unknown for plain values; variance/covariance squared units. Time spacing does not infer simulation dt.

**Ownership:** New prefix arrays, no copied whole series.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: BRIEF. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/trajectory/statistics.jl:143.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:82; test/m10a_atomistic_statistics.jl:112; examples/integration/one_system_many_methods.jl:136.

```@raw html
<p>Repository resources: <a href="../repository/examples/integration/one_system_many_methods.jl">examples/integration/one_system_many_methods.jl</a>; <a href="../repository/src/trajectory/statistics.jl">src/trajectory/statistics.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/m10a_atomistic_statistics.jl">test/m10a_atomistic_statistics.jl</a></p>
```

<!-- aml-api: {"symbol": "statistical_summary", "family": "F20", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [statistical_summary](@id api-statistical-summary)

**Identity:** generic function; F20; **PUBLIC_STABLE**; explicitly exported.

**Interpretation:** This is descriptive stored-sample evidence. standard_error=nothing is unavailable uncertainty, not zero. A saved-sample mean is not generally a continuous-time average.

<!-- aml-contract: {"variant": 0, "digest": "f5092c0b0988ed1807f4d225d7be6a2c471d88a7c477be810c3b70ad528ff7e5"} -->
**Purpose and output:** PropertyResult heuristic count/mean/sample variance/std/extrema; standard_error=nothing

**Source declarations and forwarding context:**

```text
function statistical_summary(s::ObservableSeries)
```

**Inputs:** ObservableSeries

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** Unknown empty/nonfinite/missing/nonreal/arithmetic overflow; ArgumentError mixed/incompatible units

**Numerical limitations:** Welford O(1) auxiliary, variance denominator n−1; singleton variance/std nothing; never IID SE.

**Units:** Compatible Unitful arithmetic preserved; units unknown for plain values; variance/covariance squared units. Time spacing does not infer simulation dt.

**Ownership:** Context-free leaf has no invented ancestry; no values retained in leaf.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: DETAILED. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/trajectory/statistics.jl:134.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:82; test/m10a_atomistic_statistics.jl:107; examples/integration/one_system_many_methods.jl:135.

```@raw html
<p>Repository resources: <a href="../repository/examples/integration/one_system_many_methods.jl">examples/integration/one_system_many_methods.jl</a>; <a href="../repository/src/trajectory/statistics.jl">src/trajectory/statistics.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/m10a_atomistic_statistics.jl">test/m10a_atomistic_statistics.jl</a></p>
```

## [F21: Correlation-aware analysis](@id family-F21)

<!-- aml-api: {"symbol": "autocorrelation", "family": "F21", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [autocorrelation](@id api-autocorrelation)

**Identity:** generic function; F21; **PUBLIC_STABLE**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "312542453365988a5a2c666dc73812de292cc630cd265d9f66b65d8f6a65294d"} -->
**Purpose and output:** AutocorrelationAnalysis

**Source declarations and forwarding context:**

```text
function autocorrelation(s::ObservableSeries;maxlag=min(length(s.values)-1,128),normalization=:biased)
```

**Inputs:** Series with regular saved sampling; maxlag=min(N−1,128), normalization=:biased

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError invalid lag/normalization; unknown inadequate regular samples or invalid arithmetic/data

**Numerical limitations:** Direct O(N*K) work O(N+K) storage; index time allowed; biased N or unbiased N−k denominators not exact unbiased claim; mean estimated from whole finite window.

**Units:** Compatible Unitful arithmetic preserved; units unknown for plain values; variance/covariance squared units. Time spacing does not infer simulation dt.

**Ownership:** Materializes scalar vector; no stored frame history.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: DETAILED. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/trajectory/statistics.jl:174.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:83; test/m10a_atomistic_statistics.jl:116; examples/scaling/million_sample_statistics.jl:34.

```@raw html
<p>Repository resources: <a href="../repository/examples/scaling/million_sample_statistics.jl">examples/scaling/million_sample_statistics.jl</a>; <a href="../repository/src/trajectory/statistics.jl">src/trajectory/statistics.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/m10a_atomistic_statistics.jl">test/m10a_atomistic_statistics.jl</a></p>
```

<!-- aml-api: {"symbol": "AutocorrelationAnalysis", "family": "F21", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "type / constructors", "variant_count": 1} -->
## [AutocorrelationAnalysis](@id api-AutocorrelationAnalysis)

**Identity:** type / constructors; F21; **PUBLIC_STABLE**; explicitly exported.

**Stored fields:** `sampling`, `lags`, `lag_times`, `autocovariance`, `autocorrelation`, `counts`, `normalization`, `method`, `evidence`. Immutable outer record; referenced payloads may still be mutable. Obtain validated outputs through the operations described below; a raw record constructor does not itself certify scientific consistency.

<!-- aml-contract: {"variant": 0, "digest": "23d7b2c827f1cae0196eeaea223beed32cdca6e335e9550462ea3072de5a6979"} -->
**Purpose and output:** Lag covariance/correlation/counts/sampling/evidence

**Source declarations and forwarding context:**

```text
struct AutocorrelationAnalysis{S,L,T,C,R,N,E} <: AbstractAnalysis; raw generated field constructor: (sampling::S, lags::L, lag_times::T, autocovariance::C, autocorrelation::R, counts::N, normalization::Symbol, method::Symbol, evidence::E)
```

**Inputs:** autocorrelation or raw fields

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** No additional refusal specified in this audited route; raw records do not establish validation.

**Numerical limitations:** Missing normalized correlation nothing, not NaN; constant series covariance0 correlation unknown.

**Units:** Compatible Unitful arithmetic preserved; units unknown for plain values; variance/covariance squared units. Time spacing does not infer simulation dt.

**Ownership:** Retains sampling; new arrays.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: DETAILED. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/trajectory/statistics.jl:154.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:83; test/trajectory_comparison_edges.jl:12.

```@raw html
<p>Repository resources: <a href="../repository/src/trajectory/statistics.jl">src/trajectory/statistics.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/trajectory_comparison_edges.jl">test/trajectory_comparison_edges.jl</a></p>
```

<!-- aml-api: {"symbol": "correlated_mean", "family": "F21", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [correlated_mean](@id api-correlated-mean)

**Identity:** generic function; F21; **PUBLIC_STABLE**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "64c3fb5056fa61665fd8a1485904b99ca1f59c2871975ebf6783fad504cb3042"} -->
**Purpose and output:** PropertyResult mean/std/SE/tau/N_eff/count plus ACF/integration

**Source declarations and forwarding context:**

```text
function correlated_mean(s::ObservableSeries;window=nothing,maxlag=min(length(s.values)-1,128),normalization=:biased)
```

**Inputs:** ObservableSeries; window/maxlag/normalization

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** Invalid lag/window/etc errors propagate; unknown N_eff<1 or invalid data/tail

**Numerical limitations:** No IID fallback; regular sampling/stationarity assumed; effective count not independent experiments.

**Units:** Compatible Unitful arithmetic preserved; units unknown for plain values; variance/covariance squared units. Time spacing does not infer simulation dt.

**Ownership:** Materializes scalar values; stores ACF/integration, not input values.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: DETAILED. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/trajectory/uncertainty.jl:34.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:83; test/m10a_atomistic_statistics.jl:128; notebooks/molly_trajectory_analysis.jl:30.

```@raw html
<p>Repository resources: <a href="../repository/notebooks/molly_trajectory_analysis.jl">notebooks/molly_trajectory_analysis.jl</a>; <a href="../repository/src/trajectory/uncertainty.jl">src/trajectory/uncertainty.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/m10a_atomistic_statistics.jl">test/m10a_atomistic_statistics.jl</a></p>
```

<!-- aml-api: {"symbol": "integrated_autocorrelation_time", "family": "F21", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [integrated_autocorrelation_time](@id api-integrated-autocorrelation-time)

**Identity:** generic function; F21; **PUBLIC_STABLE**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "eefe0ab474f35fdcd04ef19a88cea121946bd56b7757b5a8bcc25cea1ad2cbe6"} -->
**Purpose and output:** PropertyResult tau/raw_tau/physical_tau/window/assumptions

**Source declarations and forwarding context:**

```text
function integrated_autocorrelation_time(a::AutocorrelationAnalysis;window=nothing)
```

**Inputs:** AutocorrelationAnalysis; window=nothing or explicit integer

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError window outside computed range; unknown unavailable normalized ACF, count<4 or no nonpositive tail

**Numerical limitations:** Convention 1/2+sum rho; automatic before first nonpositive lag. max(0.5,raw) caps N_eff≤N; no stationarity/run length proof.

**Units:** Compatible Unitful arithmetic preserved; units unknown for plain values; variance/covariance squared units. Time spacing does not infer simulation dt.

**Ownership:** Small leaf retains numbers/assumptions not full series.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: DETAILED. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/trajectory/uncertainty.jl:9.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:83; test/m10a_atomistic_statistics.jl:124.

```@raw html
<p>Repository resources: <a href="../repository/src/trajectory/uncertainty.jl">src/trajectory/uncertainty.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/m10a_atomistic_statistics.jl">test/m10a_atomistic_statistics.jl</a></p>
```

## [F22: Blocking and transient evidence](@id family-F22)

<!-- aml-api: {"symbol": "block_average", "family": "F22", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [block_average](@id api-block-average)

**Identity:** generic function; F22; **PUBLIC_STABLE**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "26454e1fefe156f6ded05b851c6b8b5893e5b90f4dd82b9722433c96f00b75aa"} -->
**Purpose and output:** BlockAnalysis

**Source declarations and forwarding context:**

```text
function block_average(s::ObservableSeries;block_sizes=[2^k for k in 0:floor(Int,log2(max(1,length(s.values)÷2)))])
```

**Inputs:** ObservableSeries; block_sizes default powers2 up to floor(log2(max(1,N÷2)))

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError nonpositive/noninteger sizes; unknown invalid/empty values

**Numerical limitations:** Complete nonoverlap blocks only; each size omits own tail; SE sqrt(sample variance blockmeans/count), no independent-block proof or hard output budget.

**Units:** Compatible Unitful arithmetic preserved; units unknown for plain values; variance/covariance squared units. Time spacing does not infer simulation dt.

**Ownership:** Materializes scalar values and per-size blockmeans.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: METHOD lacks separate docstring; type brief. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/trajectory/uncertainty.jl:62.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:84; test/m10a_atomistic_statistics.jl:141; examples/scaling/million_sample_statistics.jl:33.

```@raw html
<p>Repository resources: <a href="../repository/examples/scaling/million_sample_statistics.jl">examples/scaling/million_sample_statistics.jl</a>; <a href="../repository/src/trajectory/uncertainty.jl">src/trajectory/uncertainty.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/m10a_atomistic_statistics.jl">test/m10a_atomistic_statistics.jl</a></p>
```

<!-- aml-api: {"symbol": "BlockAnalysis", "family": "F22", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "type / constructors", "variant_count": 1} -->
## [BlockAnalysis](@id api-BlockAnalysis)

**Identity:** type / constructors; F22; **PUBLIC_STABLE**; explicitly exported.

**Stored fields:** `block_sizes`, `block_counts`, `discarded`, `block_means`, `variances`, `standard_errors`, `sampling`, `units`, `evidence`. Immutable outer record; referenced payloads may still be mutable. Obtain validated outputs through the operations described below; a raw record constructor does not itself certify scientific consistency.

<!-- aml-contract: {"variant": 0, "digest": "3abd036f6b929f78003e5f560a580a33757cec450dc5151306c5f5cf4c36a77c"} -->
**Purpose and output:** Block-size/count/tail/block mean/variance/SE evidence

**Source declarations and forwarding context:**

```text
struct BlockAnalysis <: AbstractAnalysis; raw generated field constructor: (block_sizes, block_counts, discarded, block_means, variances, standard_errors, sampling, units, evidence::PropertyResult)
```

**Inputs:** block_average or raw fields

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** No additional refusal specified in this audited route; raw records do not establish validation.

**Numerical limitations:** No automatic independence/plateau inference.

**Units:** Compatible Unitful arithmetic preserved; units unknown for plain values; variance/covariance squared units. Time spacing does not infer simulation dt.

**Ownership:** Stores block output arrays and sampling.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: BRIEF. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/trajectory/uncertainty.jl:51.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:84; test/trajectory_uncertainty.jl:42.

```@raw html
<p>Repository resources: <a href="../repository/src/trajectory/uncertainty.jl">src/trajectory/uncertainty.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/trajectory_uncertainty.jl">test/trajectory_uncertainty.jl</a></p>
```

<!-- aml-api: {"symbol": "transient_analysis", "family": "F22", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [transient_analysis](@id api-transient-analysis)

**Identity:** generic function; F22; **PUBLIC_STABLE**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "4ebb319918aaf1b2f467acd63d17afcb168301058f14af4a5fddeadc5dcb59a5"} -->
**Purpose and output:** Heuristic PropertyResult early/late midpoint shift and suggested_start/time

**Source declarations and forwarding context:**

```text
function transient_analysis(s::ObservableSeries;threshold=1.0)
```

**Inputs:** ObservableSeries; threshold=1.0 finite positive

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError invalid threshold; unknown <8/invalid values

**Numerical limitations:** Uses pooled fluctuations not IID significance. Cutoff never applied; absence shift not equilibrium.

**Units:** Compatible Unitful arithmetic preserved; units unknown for plain values; variance/covariance squared units. Time spacing does not infer simulation dt.

**Ownership:** Materializes scalar values; leaf summaries only.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: DETAILED. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/trajectory/uncertainty.jl:86.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:84; test/trajectory_comparison_edges.jl:55.

```@raw html
<p>Repository resources: <a href="../repository/src/trajectory/uncertainty.jl">src/trajectory/uncertainty.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/trajectory_comparison_edges.jl">test/trajectory_comparison_edges.jl</a></p>
```

## [F24: Stored trajectory diagnostics](@id family-F24)

<!-- aml-api: {"symbol": "diagnose", "family": "F24", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 2} -->
## [diagnose](@id api-diagnose)

**Identity:** generic function; F24; **PUBLIC_STABLE**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "415af20df3c3333198f62d9a66fbebc26869ff54b5426fc3991d520e7873388d"} -->
### Dispatch contract 1

**Purpose and output:** Heuristic PropertyResult composed stored evidence

**Source declarations and forwarding context:**

```text
function diagnose(r::MDTrajectoryAnalysis)

diagnose(t::AtomisticTrajectoryView;kwargs...)=diagnose(analyze(t;kwargs...))
```

**Inputs:** MDTrajectoryAnalysis or view plus analyze kwargs

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** Requested analysis failures propagate on view route

**Numerical limitations:** Stored report route no recomputation; view convenience performs analyze. No simulation validity score.

**Units:** Compatible Unitful arithmetic preserved; units unknown for plain values; variance/covariance squared units. Time spacing does not infer simulation dt.

**Ownership:** Retains stored fields in composed claim.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: DETAILED. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/trajectory/analyst.jl:139; src/trajectory/analyst.jl:145.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:86; test/trajectory_analyst.jl:75; notebooks/molly_trajectory_analysis.jl:39.

```@raw html
<p>Repository resources: <a href="../repository/notebooks/molly_trajectory_analysis.jl">notebooks/molly_trajectory_analysis.jl</a>; <a href="../repository/src/trajectory/analyst.jl">src/trajectory/analyst.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/trajectory_analyst.jl">test/trajectory_analyst.jl</a></p>
```

<!-- aml-contract: {"variant": 1, "digest": "f348976fd444ac97a197a9a2dcc8db1bbed60c93057d3cde6b9cd4d1d547ec60"} -->
### Dispatch contract 2

**Purpose and output:** Heuristic stored component PropertyResult

**Source declarations and forwarding context:**

```text
diagnose(c::MDTrajectoryComparison)=PropertyResult(c.components,:heuristic,:stored_comparison_composition,c.notes)
```

**Inputs:** MDTrajectoryComparison

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** No additional refusal specified in this audited route; raw records do not establish validation.

**Numerical limitations:** Composition only not recomputation/score.

**Units:** Compatible Unitful arithmetic preserved; units unknown for plain values; variance/covariance squared units. Time spacing does not infer simulation dt.

**Ownership:** Borrows component map and notes.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: ABSENT method. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/trajectory/comparison.jl:369.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:86; test/trajectory_analyst.jl:75; notebooks/molly_trajectory_analysis.jl:39.

```@raw html
<p>Repository resources: <a href="../repository/notebooks/molly_trajectory_analysis.jl">notebooks/molly_trajectory_analysis.jl</a>; <a href="../repository/src/trajectory/comparison.jl">src/trajectory/comparison.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/trajectory_analyst.jl">test/trajectory_analyst.jl</a></p>
```

<!-- aml-api: {"symbol": "energy_diagnostics", "family": "F24", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [energy_diagnostics](@id api-energy-diagnostics)

**Identity:** generic function; F24; **PUBLIC_STABLE**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "e8949de6d6e23640931bf06b57ada3a66d7f58077a8b8f27211d731aaedb3854"} -->
**Purpose and output:** PropertyResult deviations from initial value/max/RMS/relative/trend/ensemble

**Source declarations and forwarding context:**

```text
energy_diagnostics(s::ObservableSeries;kwargs...)=_trajectory_deviations(s;kwargs...).values
```

**Inputs:** ObservableSeries; kwargs to deviation helper

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** Unknown invalid/empty/misaligned values; underlying unit/arithmetic errors may propagate

**Numerical limitations:** NVE metadata only describes expected conservation; no conservation grade; zero reference -> relative nothing; trend descriptive.

**Units:** Compatible Unitful arithmetic preserved; units unknown for plain values; variance/covariance squared units. Time spacing does not infer simulation dt.

**Ownership:** Materializes scalar history; leaf values omit source context.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: ABSENT method. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/trajectory/analyst.jl:81.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:85; test/m10a_atomistic_statistics.jl:209.

```@raw html
<p>Repository resources: <a href="../repository/src/trajectory/analyst.jl">src/trajectory/analyst.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/m10a_atomistic_statistics.jl">test/m10a_atomistic_statistics.jl</a></p>
```

<!-- aml-api: {"symbol": "MDTrajectoryAnalysis", "family": "F24", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "type / constructors", "variant_count": 1} -->
## [MDTrajectoryAnalysis](@id api-MDTrajectoryAnalysis)

**Identity:** type / constructors; F24; **PUBLIC_STABLE**; explicitly exported.

**Stored fields:** `sampling`, `observables`, `summaries`, `correlations`, `deviations`, `transients`, `msd`, `vacf`, `diffusion`, `notes`. Immutable outer record; referenced payloads may still be mutable. Obtain validated outputs through the operations described below; a raw record constructor does not itself certify scientific consistency.

<!-- aml-contract: {"variant": 0, "digest": "620b92629a5d49f2446dd8779dec8e7eb11295be8b211df9ad64037790f04a87"} -->
**Purpose and output:** Stored opt-in statistics/correlation/deviations/transients/MSD/VACF/diffusion

**Source declarations and forwarding context:**

```text
struct MDTrajectoryAnalysis <: AbstractAnalysis; raw generated field constructor: (sampling, observables, summaries, correlations, deviations, transients, msd, vacf, diffusion::PropertyResult, notes::Vector{String})
```

**Inputs:** analyze(view) or raw fields

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** No additional refusal specified in this audited route; raw records do not establish validation.

**Numerical limitations:** Default time metadata only, unrequested != failed.

**Units:** Compatible Unitful arithmetic preserved; units unknown for plain values; variance/covariance squared units. Time spacing does not infer simulation dt.

**Ownership:** Retains observable sources and requested outputs.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: DETAILED. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/trajectory/analyst.jl:89.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:86; test/trajectory_analyst.jl:44.

```@raw html
<p>Repository resources: <a href="../repository/src/trajectory/analyst.jl">src/trajectory/analyst.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/trajectory_analyst.jl">test/trajectory_analyst.jl</a></p>
```

<!-- aml-api: {"symbol": "momentum_diagnostics", "family": "F24", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [momentum_diagnostics](@id api-momentum-diagnostics)

**Identity:** generic function; F24; **PUBLIC_STABLE**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "0cc891fd489d479fd60f0a6a87abb7117530a24b76dd2e26ef65f17f2a9a9a6d"} -->
**Purpose and output:** PropertyResult vector deviations/magnitudes

**Source declarations and forwarding context:**

```text
momentum_diagnostics(s::ObservableSeries;kwargs...)=_trajectory_deviations(s;vector=true,kwargs...).values
```

**Inputs:** Vector-valued ObservableSeries; kwargs

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** Unknown invalid vectors/data; errors propagate

**Numerical limitations:** No inferred external forces or conservation certification; vector trend unknown.

**Units:** Compatible Unitful arithmetic preserved; units unknown for plain values; variance/covariance squared units. Time spacing does not infer simulation dt.

**Ownership:** Materializes vector history; leaf lacks retained source context.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: ABSENT method. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/trajectory/analyst.jl:82.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:85; test/m10a_atomistic_statistics.jl:225.

```@raw html
<p>Repository resources: <a href="../repository/src/trajectory/analyst.jl">src/trajectory/analyst.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/m10a_atomistic_statistics.jl">test/m10a_atomistic_statistics.jl</a></p>
```
