# Particle transport and physical-time interpretation

MSD and VACF require their explicit identity/coordinate assumptions. diffusion_estimate numerically accepts eligible index-time MSD: there is no invented physical-clock refusal. A physical diffusion interpretation nevertheless needs an appropriate clock and justified fit window.

Read [API boundaries and evidence semantics](@ref api-boundaries) for the distinction between raw constructors, validated factories, exceptions, unknown claims and unrequested/partial diagnostics. Signatures are text, not runnable examples. Backend forwarding/context lines do not create public helper APIs.

```@raw html
<p>Repository resources: <a href="../repository/docs/trajectory_statistics.md">docs/trajectory_statistics.md</a>; <a href="../repository/docs/tutorials/scripts/trajectories.jl">docs/tutorials/scripts/trajectories.jl</a>; <a href="../repository/docs/tutorials/trajectories.md">docs/tutorials/trajectories.md</a>; <a href="../repository/reports/m10d6/tutorial_verification.json">reports/m10d6/tutorial_verification.json</a></p>
```

## [F23: Particle transport](@id family-F23)

<!-- aml-api: {"symbol": "diffusion_estimate", "family": "F23", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [diffusion_estimate](@id api-diffusion-estimate)

**Identity:** generic function; F23; **PUBLIC_STABLE**; explicitly exported.

**Interpretation:** Eligible index-time MSD is numerically accepted. A fitted coefficient in sample-index units is not automatically a physical diffusion coefficient. Fit-window choice, physical clock, coordinate convention and uncertainty assumptions remain the caller’s responsibility.

<!-- aml-contract: {"variant": 0, "digest": "cc4567b49f579ae474cae407e298685ec5b1ea8cd3e8da616e02fd32749fd5c2"} -->
**Purpose and output:** Heuristic PropertyResult diffusion/slope/intercept/indices/residuals/RMS; unknown SE

**Source declarations and forwarding context:**

```text
function diffusion_estimate(m::MeanSquaredDisplacement;fit_window=nothing)
```

**Inputs:** MeanSquaredDisplacement and explicit fit_window=(start,stop)

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError window not pair; unknown missing MSD, <3 points, invalid span/nonfinite/negative slope

**Numerical limitations:** No implementation physical-time/index-time gate: may fit sample-index time. Physical interpretation requires caller justification/units. Zero slope accepted. OLS no independent-residual SE.

**Units:** Compatible Unitful arithmetic preserved; units unknown for plain values; variance/covariance squared units. Time spacing does not infer simulation dt.

**Ownership:** Materializes selected samples/residuals, no full frame history.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: DETAILED. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/trajectory/transport.jl:77.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:85; test/m10a_atomistic_statistics.jl:178; notebooks/molly_trajectory_analysis.jl:37.

```@raw html
<p>Repository resources: <a href="../repository/notebooks/molly_trajectory_analysis.jl">notebooks/molly_trajectory_analysis.jl</a>; <a href="../repository/src/trajectory/transport.jl">src/trajectory/transport.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/m10a_atomistic_statistics.jl">test/m10a_atomistic_statistics.jl</a></p>
```

<!-- aml-api: {"symbol": "mean_squared_displacement", "family": "F23", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [mean_squared_displacement](@id api-mean-squared-displacement)

**Identity:** generic function; F23; **PUBLIC_STABLE**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "0a0abc5d934b81b55735bc0b8583b43f3550ffec4aad49324c10d7dc98e8f81f"} -->
**Purpose and output:** MeanSquaredDisplacement

**Source declarations and forwarding context:**

```text
function mean_squared_displacement(t::AtomisticTrajectoryView;coordinates=:auto,
fixed_particles=false,species=nothing,time_options=NamedTuple())
```

**Inputs:** AtomisticTrajectoryView with fixed particle order asserted; coordinates=:auto, fixed_particles=false, species=nothing, time_options

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError invalid coordinates; unknown wrapped/auto periodic/unasserted order/missing times/invalid coordinates/changed layout

**Numerical limitations:** Open auto or caller-declared trustworthy unwrapped; no unwrapping. Index time is explicitly allowed. O(frames*particles*dimension) work and origin+output storage.

**Units:** Compatible Unitful arithmetic preserved; units unknown for plain values; variance/covariance squared units. Time spacing does not infer simulation dt.

**Ownership:** Copies selected origin coordinates only; new output; borrowed sampling times.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: DETAILED. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/trajectory/transport.jl:39.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:84; test/m10a_atomistic_statistics.jl:169; notebooks/molly_trajectory_analysis.jl:49.

```@raw html
<p>Repository resources: <a href="../repository/notebooks/molly_trajectory_analysis.jl">notebooks/molly_trajectory_analysis.jl</a>; <a href="../repository/src/trajectory/transport.jl">src/trajectory/transport.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/m10a_atomistic_statistics.jl">test/m10a_atomistic_statistics.jl</a></p>
```

<!-- aml-api: {"symbol": "MeanSquaredDisplacement", "family": "F23", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "type / constructors", "variant_count": 1} -->
## [MeanSquaredDisplacement](@id api-MeanSquaredDisplacement)

**Identity:** type / constructors; F23; **PUBLIC_STABLE**; explicitly exported.

**Stored fields:** `sampling`, `times`, `values`, `dimensions`, `particle_count`, `origin_count`, `species`, `coordinate_semantics`, `method`, `notes`. Immutable outer record; referenced payloads may still be mutable. Obtain validated outputs through the operations described below; a raw record constructor does not itself certify scientific consistency.

<!-- aml-contract: {"variant": 0, "digest": "a698cd317778581c03530d1442ae77eea06922061933ea2bd16f175567a51623"} -->
**Purpose and output:** Single-origin particle displacement analysis

**Source declarations and forwarding context:**

```text
struct MeanSquaredDisplacement <: AbstractAnalysis; raw generated field constructor: (sampling, times, values::PropertyResult, dimensions::Int, particle_count::Int, origin_count::Int, species, coordinate_semantics::Symbol, method::Symbol, notes::Vector{String})
```

**Inputs:** mean_squared_displacement or raw fields

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** No additional refusal specified in this audited route; raw records do not establish validation.

**Numerical limitations:** Only one origin; no transport/independence certificate.

**Units:** Compatible Unitful arithmetic preserved; units unknown for plain values; variance/covariance squared units. Time spacing does not infer simulation dt.

**Ownership:** Stores output values/times/sampling not snapshot history.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: BRIEF. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/trajectory/transport.jl:2.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:84.

```@raw html
<p>Repository resources: <a href="../repository/src/trajectory/transport.jl">src/trajectory/transport.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a></p>
```

<!-- aml-api: {"symbol": "velocity_autocorrelation", "family": "F23", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [velocity_autocorrelation](@id api-velocity-autocorrelation)

**Identity:** generic function; F23; **PUBLIC_STABLE**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "5cac7e5d8ccd1a86bf0f0718bd9fe289c96725f9650970ac7b829830cf87652a"} -->
**Purpose and output:** VelocityAutocorrelation

**Source declarations and forwarding context:**

```text
function velocity_autocorrelation(t::AtomisticTrajectoryView;maxlag=min(max(length(t)-1,0),128),
normalize=false,species=nothing,fixed_particles=false,time_options=NamedTuple())
```

**Inputs:** View; regular known saved sampling and fixed order assertion; maxlag default <=128, normalize=false, species/fixed_particles/time_options

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError invalid lag; unknown missing/irregular times/order/velocity/species; normalization unknown C0=0

**Numerical limitations:** Index time allowed. Velocity-only history O(frames*particles*dimension), no coordinates copied; no fixed RSS budget.

**Units:** Compatible Unitful arithmetic preserved; units unknown for plain values; variance/covariance squared units. Time spacing does not infer simulation dt.

**Ownership:** Copies selected velocities of every frame.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: DETAILED. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/trajectory/transport.jl:128.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:85; test/m10a_atomistic_statistics.jl:179.

```@raw html
<p>Repository resources: <a href="../repository/src/trajectory/transport.jl">src/trajectory/transport.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/m10a_atomistic_statistics.jl">test/m10a_atomistic_statistics.jl</a></p>
```

<!-- aml-api: {"symbol": "VelocityAutocorrelation", "family": "F23", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "type / constructors", "variant_count": 1} -->
## [VelocityAutocorrelation](@id api-VelocityAutocorrelation)

**Identity:** type / constructors; F23; **PUBLIC_STABLE**; explicitly exported.

**Stored fields:** `sampling`, `lags`, `lag_times`, `raw`, `normalized`, `origin_counts`, `particle_count`, `dimensions`, `species`, `method`, `notes`. Immutable outer record; referenced payloads may still be mutable. Obtain validated outputs through the operations described below; a raw record constructor does not itself certify scientific consistency.

<!-- aml-contract: {"variant": 0, "digest": "73dac261d5baddda3fbd67a52ae909fb7b7579e059ecfb1621d0ee5246f02bfe"} -->
**Purpose and output:** Raw/normalized dot-product VACF with overlapping origin counts

**Source declarations and forwarding context:**

```text
struct VelocityAutocorrelation <: AbstractAnalysis; raw generated field constructor: (sampling, lags, lag_times, raw::PropertyResult, normalized::PropertyResult, origin_counts, particle_count::Int, dimensions::Int, species, method::Symbol, notes::Vector{String})
```

**Inputs:** velocity_autocorrelation or raw fields

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** No additional refusal specified in this audited route; raw records do not establish validation.

**Numerical limitations:** Not mean-centered fluctuation correlation; normalized unrequested is :not_requested.

**Units:** Compatible Unitful arithmetic preserved; units unknown for plain values; variance/covariance squared units. Time spacing does not infer simulation dt.

**Ownership:** Stores velocity-derived result/sampling.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: BRIEF. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/trajectory/transport.jl:106.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:85.

```@raw html
<p>Repository resources: <a href="../repository/src/trajectory/transport.jl">src/trajectory/transport.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a></p>
```
