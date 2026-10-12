# Stored atomistic geometry and supplied potentials

Positions, masses, particle selection, boundary geometry and units must be declared. A configuration or caller-supplied Hessian does not establish equilibrium. The core snapshot and frame view do not require Molly; atomistic_trajectory is the optional Molly adapter.

Read [API boundaries and evidence semantics](@ref api-boundaries) for the distinction between raw constructors, validated factories, exceptions, unknown claims and unrequested/partial diagnostics. Signatures are text, not runnable examples. Backend forwarding/context lines do not create public helper APIs.

```@raw html
<p>Repository resources: <a href="../repository/docs/atomistic.md">docs/atomistic.md</a>; <a href="../repository/docs/tutorials/atomistics.md">docs/tutorials/atomistics.md</a>; <a href="../repository/docs/tutorials/scripts/atomistics.jl">docs/tutorials/scripts/atomistics.jl</a>; <a href="../repository/reports/m10d6/tutorial_verification.json">reports/m10d6/tutorial_verification.json</a></p>
```

Overload map: [evaluate](@ref dispatch-evaluate).

Overload map: [normal_modes](@ref dispatch-normal_modes).

Overload map: [observable_series](@ref dispatch-observable_series).

Overload map: [plot](@ref dispatch-plot).

Overload map: [analyze](@ref dispatch-analyze).

## [F15: Stored atomistic inputs and adapters](@id family-F15)

<!-- aml-api: {"symbol": "atomistic_snapshot", "family": "F15", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 2} -->
## [atomistic_snapshot](@id api-atomistic-snapshot)

**Identity:** generic function; F15; **PUBLIC_STABLE**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "b4b2079b46023796109354e885768da83781f426d6b6dcd4f2b9c254ff0094db"} -->
### Dispatch contract 1

**Purpose and output:** AtomisticSnapshot

**Source declarations and forwarding context:**

```text
atomistic_snapshot(s::AtomisticSnapshot;kwargs...) = isempty(kwargs) ? s :
```

**Inputs:** Snapshot identity or backend adapter

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError any kwargs on existing snapshot; missing backend dispatch error

**Numerical limitations:** No generic positions-only conversion function; use AtomisticSnapshot factory; backend requirements reviewed in separate Molly batch.

**Units:** Supported Unitful arithmetic retained; unitless data are physically unknown unless caller declares provenance; labels never convert data.

**Ownership:** Existing snapshot returned identically.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: NO independent generic docstring. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/atomistic/core.jl:32.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:78; test/atomistic_core.jl:11; notebooks/molly_companion.jl:36.

```@raw html
<p>Repository resources: <a href="../repository/notebooks/molly_companion.jl">notebooks/molly_companion.jl</a>; <a href="../repository/src/atomistic/core.jl">src/atomistic/core.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/atomistic_core.jl">test/atomistic_core.jl</a></p>
```

<!-- aml-contract: {"variant": 1, "digest": "732fb39226af6c9404f254df4251dbacf52143b0cde85852d4ce35207b5c6e4a"} -->
### Dispatch contract 2

**Purpose and output:** AtomisticSnapshot

**Source declarations and forwarding context:**

```text
function AML.atomistic_snapshot(sys::Molly.System;observables=false,time=nothing,copy_data=false,n_threads=1)
```

**Inputs:** Molly.System; observables=false,time=nothing,copy_data=false,n_threads=1

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError GPU/non-Array CPU storage; backend observable failures propagate

**Numerical limitations:** Configured backend observables at step0 only on explicit request; unsupported mixed/triclinic boundary not invented; replacing backend fields does not retarget snapshot.

**Units:** Supported Unitful arithmetic retained; unitless data are physically unknown unless caller declares provenance; labels never convert data.

**Ownership:** Borrows CPU arrays and lazy atom type view; distance closure retains boundary. copy_data selectively owns particle data.

**Dependencies:** Molly.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: DETAILED. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: ext/AnalyticMathLabMollyExt.jl:40.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:78; test/atomistic_core.jl:11; notebooks/molly_companion.jl:36.

```@raw html
<p>Repository resources: <a href="../repository/ext/AnalyticMathLabMollyExt.jl">ext/AnalyticMathLabMollyExt.jl</a>; <a href="../repository/notebooks/molly_companion.jl">notebooks/molly_companion.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/atomistic_core.jl">test/atomistic_core.jl</a></p>
```

<!-- aml-api: {"symbol": "atomistic_trajectory", "family": "F15", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 2} -->
## [atomistic_trajectory](@id api-atomistic-trajectory)

**Identity:** generic function; F15; **PUBLIC_STABLE**; explicitly exported.

**Interpretation:** The core declares this generic; the callable scientific adapter shown here requires Molly. Generic stored-data users construct AtomisticTrajectoryView directly.

<!-- aml-contract: {"variant": 0, "digest": "b4217009d7cc2a91261d5015970ea1d98acfa1bbb4f06704f329af4c03ffee90"} -->
### Dispatch contract 1

**Purpose and output:** AtomisticTrajectoryView

**Source declarations and forwarding context:**

```text
Core generic declaration; the callable adapter is documented in the next route.
```

**Inputs:** Extension-specific backend arguments

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** Absent dispatch if adapter unavailable

**Numerical limitations:** Empty core generic; no invented identity/general vector overload.

**Units:** Supported Unitful arithmetic retained; unitless data are physically unknown unless caller declares provenance; labels never convert data.

**Ownership:** Extension-specific lazy retention.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: ABSENT core. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: .

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:78; test/m10d_extensions.jl:54; notebooks/molly_companion.jl:28.

```@raw html
<p>Repository resources: <a href="../repository/notebooks/molly_companion.jl">notebooks/molly_companion.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/m10d_extensions.jl">test/m10d_extensions.jl</a></p>
```

<!-- aml-contract: {"variant": 1, "digest": "05f1bfdcd658c43e5f1843d4509fd803b812682d31e97c73c27677ee39856e9e"} -->
### Dispatch contract 2

**Purpose and output:** Captured-length AtomisticTrajectoryView

**Source declarations and forwarding context:**

```text
function AML.atomistic_trajectory(sys::Molly.System;fixed_box=false,times=nothing,
coordinate_logger=stored_logger(sys.loggers,:coords),velocity_logger=stored_logger(sys.loggers,:velocities))
```

**Inputs:** Molly.System with fixed_box=true assertion; optional explicit times/loggers

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError fixed_box missing, nonstandard loggers, differing stride, invalid times; DimensionMismatch frame/time counts

**Numerical limitations:** Caller asserts historic fixed box/masses/species/order and synchronization; matching stride not proof. Times nondecreasing here, downstream statistics may require strictly increasing.

**Units:** Explicit time units retained; no inferred dt/seconds.

**Ownership:** Borrows logger frames and current fixed metadata, no history recollection.

**Dependencies:** Molly.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: DETAILED. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: ext/AnalyticMathLabMollyExt.jl:74.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:78; test/m10d_extensions.jl:54; notebooks/molly_companion.jl:28.

```@raw html
<p>Repository resources: <a href="../repository/ext/AnalyticMathLabMollyExt.jl">ext/AnalyticMathLabMollyExt.jl</a>; <a href="../repository/notebooks/molly_companion.jl">notebooks/molly_companion.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/m10d_extensions.jl">test/m10d_extensions.jl</a></p>
```

<!-- aml-api: {"symbol": "AtomisticSnapshot", "family": "F15", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "type / constructors", "variant_count": 1} -->
## [AtomisticSnapshot](@id api-AtomisticSnapshot)

**Identity:** type / constructors; F15; **PUBLIC_STABLE**; explicitly exported.

**Stored fields:** `positions`, `velocities`, `masses`, `species`, `dimension`, `boundary`, `time`, `provenance`, `potential_energy`, `forces`, `distance`. Immutable outer record; referenced payloads may still be mutable. Obtain validated outputs through the operations described below; a raw record constructor does not itself certify scientific consistency.

<!-- aml-contract: {"variant": 0, "digest": "152e8814f5b94eff23fe501b699525d476844ca60600ee00e2cb2c5465db9ebc"} -->
**Purpose and output:** Borrowed analysis snapshot, not simulation object

**Source declarations and forwarding context:**

```text
struct AtomisticSnapshot{P,V,M,S,B,T,R,E,F,D} <: AbstractAnalysis; raw generated field constructor: (positions::P, velocities::V, masses::M, species::S, dimension::Int, boundary::B, time::T, provenance::R, potential_energy::E, forces::F, distance::D)

function AtomisticSnapshot(positions;velocities=nothing,masses=nothing,species=nothing,
dimension=isempty(positions) ? 0 : length(first(positions)),boundary=(kind=:open,),
time=nothing,provenance=(source=:generic,units=:unknown),potential_energy=nothing,
forces=nothing,distance=nothing,copy_data=false)
```

**Inputs:** Particle-major positions plus literal metadata keywords; dimension default from first position

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError negative/noninteger dimension

**Numerical limitations:** Malformed values deliberately retained for mdcheck. copy_data=true deepcopies positions, velocities, masses, species, boundary, forces only. Does not copy provenance/time/potential_energy/distance closure.

**Units:** Supported Unitful arithmetic retained; unitless data are physically unknown unless caller declares provenance; labels never convert data.

**Ownership:** Borrowed by default; selected fields deepcopied on opt-in, outer immutable not deeply immutable.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: DETAILED type. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/atomistic/core.jl:9; src/atomistic/core.jl:22.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:78; test/atomistic_core.jl:5; examples/inference/lj_gate.jl:18.

```@raw html
<p>Repository resources: <a href="../repository/examples/inference/lj_gate.jl">examples/inference/lj_gate.jl</a>; <a href="../repository/src/atomistic/core.jl">src/atomistic/core.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/atomistic_core.jl">test/atomistic_core.jl</a></p>
```

<!-- aml-api: {"symbol": "AtomisticTrajectoryView", "family": "F15", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "type / constructors", "variant_count": 1} -->
## [AtomisticTrajectoryView](@id api-AtomisticTrajectoryView)

**Identity:** type / constructors; F15; **PUBLIC_STABLE**; explicitly exported.

**Stored fields:** `frame_count`, `getframe`, `times`, `provenance`. Immutable outer record; referenced payloads may still be mutable. Obtain validated outputs through the operations described below; a raw record constructor does not itself certify scientific consistency.

<!-- aml-contract: {"variant": 0, "digest": "8fed9f7c33d5dfb2594cf890bb3fff7cd692370d21c51e016fd2b9b76efbea5d"} -->
**Purpose and output:** Lazy read-only indexed snapshot view

**Source declarations and forwarding context:**

```text
struct AtomisticTrajectoryView{F,T,P} <: AbstractAnalysis; raw generated field constructor: (frame_count::Int, getframe::F, times::T, provenance::P)

function AtomisticTrajectoryView(n::Integer,getframe;times=nothing,provenance=(source=:generic,))
```

**Inputs:** n::Integer and getframe(i); times=nothing, provenance=(source=:generic,)

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError negative n; DimensionMismatch time length; BoundsError getindex out of range

**Numerical limitations:** No collected history; times missing not assumed uniform/physical. Native backing mutations remain visible.

**Units:** Supported Unitful arithmetic retained; unitless data are physically unknown unless caller declares provenance; labels never convert data.

**Ownership:** Borrows times/provenance/getframe closure; lazy snapshot conversion.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: DETAILED type. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/atomistic/core.jl:41; src/atomistic/core.jl:47.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:78; test/atomistic_core.jl:13; examples/inference/lj_gate.jl:23.

```@raw html
<p>Repository resources: <a href="../repository/examples/inference/lj_gate.jl">examples/inference/lj_gate.jl</a>; <a href="../repository/src/atomistic/core.jl">src/atomistic/core.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/atomistic_core.jl">test/atomistic_core.jl</a></p>
```

## [F16: Snapshot inspection and pair geometry](@id family-F16)

<!-- aml-api: {"symbol": "AtomisticSystemAnalysis", "family": "F16", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "type / constructors", "variant_count": 1} -->
## [AtomisticSystemAnalysis](@id api-AtomisticSystemAnalysis)

**Identity:** type / constructors; F16; **PUBLIC_STABLE**; explicitly exported.

**Stored fields:** `source`, `checks`, `observations`, `notes`. Immutable outer record; referenced payloads may still be mutable. Obtain validated outputs through the operations described below; a raw record constructor does not itself certify scientific consistency.

<!-- aml-contract: {"variant": 0, "digest": "4d91fe06a9fefd6c7bdc11f158b77b5cf870bfef52f0b4de76a45ebb0158274a"} -->
**Purpose and output:** Snapshot observations, not simulation validity

**Source declarations and forwarding context:**

```text
struct AtomisticSystemAnalysis{S,C,O} <: AbstractAnalysis; raw generated field constructor: (source::S, checks::C, observations::O, notes::Vector{String})
```

**Inputs:** Construct through mdcheck; raw source/checks/observations/notes

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** No additional refusal specified in this audited route; raw records do not establish validation.

**Numerical limitations:** Missing velocities/species check missing rather than false; timestep stability always unknown.

**Units:** Supported Unitful arithmetic retained; unitless data are physically unknown unless caller declares provenance; labels never convert data.

**Ownership:** Strong source retention and borrowed arrays.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: BRIEF. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/atomistic/inspection.jl:2.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:79.

```@raw html
<p>Repository resources: <a href="../repository/src/atomistic/inspection.jl">src/atomistic/inspection.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a></p>
```

<!-- aml-api: {"symbol": "inspect_particle", "family": "F16", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [inspect_particle](@id api-inspect-particle)

**Identity:** generic function; F16; **PUBLIC_STABLE**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "af3c542be1ef9740c3c94cd3b61d7e1f6c36f5f641b72972acb03467a44d7988"} -->
**Purpose and output:** NamedTuple borrowed particle fields plus local distance/speed/energy/neighbor evidence

**Source declarations and forwarding context:**

```text
function inspect_particle(s::AtomisticSnapshot,i::Integer;cutoff=nothing)

inspect_particle(x,i;kwargs...)=inspect_particle(atomistic_snapshot(x),i;kwargs...)
```

**Inputs:** Snapshot/backend, integer i, optional positive cutoff

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** BoundsError invalid index; ArgumentError invalid cutoff; distance callback errors can propagate

**Numerical limitations:** No bonding/radius inference; O(N) local distances are not governed by max_pairs/max_bytes.

**Units:** Supported Unitful arithmetic retained; unitless data are physically unknown unless caller declares provenance; labels never convert data.

**Ownership:** Borrowed position/velocity/provenance; new local list.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: BRIEF. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/atomistic/inspection.jl:90; src/atomistic/inspection.jl:107.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:79; test/atomistic_core.jl:40; notebooks/molly_companion.jl:40.

```@raw html
<p>Repository resources: <a href="../repository/notebooks/molly_companion.jl">notebooks/molly_companion.jl</a>; <a href="../repository/src/atomistic/inspection.jl">src/atomistic/inspection.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/atomistic_core.jl">test/atomistic_core.jl</a></p>
```

<!-- aml-api: {"symbol": "mdcheck", "family": "F16", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [mdcheck](@id api-mdcheck)

**Identity:** generic function; F16; **PUBLIC_STABLE**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "aa9236130212777ebb1a69e532da4148cf5a177bc1f5924fb4130758bf463c34"} -->
**Purpose and output:** AtomisticSystemAnalysis checks and heuristic physical observations

**Source declarations and forwarding context:**

```text
function mdcheck(s::AtomisticSnapshot;close_distance=nothing,force_threshold=nothing,max_pairs=1_000_000)

mdcheck(x;kwargs...)=mdcheck(atomistic_snapshot(x);kwargs...)
```

**Inputs:** Snapshot or backend; optional close_distance, force_threshold; max_pairs=1_000_000

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError nonpositive/nonfinite thresholds; supported incompatible arithmetic becomes unknown; unsupported errors propagate

**Numerical limitations:** No force engine; no max_bytes keyword; pair_distances default byte gate remains. Periodic center is supplied-image centroid not unwrapped center.

**Units:** Supported Unitful arithmetic retained; unitless data are physically unknown unless caller declares provenance; labels never convert data.

**Ownership:** Strong snapshot source retention.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: DETAILED. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/atomistic/inspection.jl:31; src/atomistic/inspection.jl:85.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:79; test/atomistic_core.jl:23; notebooks/molly_companion.jl:36.

```@raw html
<p>Repository resources: <a href="../repository/notebooks/molly_companion.jl">notebooks/molly_companion.jl</a>; <a href="../repository/src/atomistic/inspection.jl">src/atomistic/inspection.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/atomistic_core.jl">test/atomistic_core.jl</a></p>
```

<!-- aml-api: {"symbol": "pair_distances", "family": "F16", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [pair_distances](@id api-pair-distances)

**Identity:** generic function; F16; **PUBLIC_STABLE**; explicitly exported.

**Interpretation:** max_pairs controls output cardinality; max_bytes is a scoped estimate, not streaming or peak RSS. Selection arrays can already exist before preflight. Unknown geometry can return before limit validation; mdcheck forwards max_pairs, not max_bytes.

<!-- aml-contract: {"variant": 0, "digest": "c86ed03bddb07926f79998d16980bdb31afe05c628030a0a6824f76990b28439"} -->
**Purpose and output:** Heuristic PropertyResult pair list/distances/min/max/species/boundary/unit descriptor or unknown

**Source declarations and forwarding context:**

```text
function pair_distances(s::AtomisticSnapshot;species=nothing,max_pairs=1_000_000,max_bytes=512*1024^2)

pair_distances(x;kwargs...)=pair_distances(atomistic_snapshot(x);kwargs...)
```

**Inputs:** Snapshot or backend via atomistic_snapshot; species pair, max_pairs=1_000_000, max_bytes=512*1024^2

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError invalid species tuple and noninteger/nonnegative controls; unknown unsupported shape/boundary/species/distance or budget

**Numerical limitations:** BigInt pair count; estimated64*pairs+sizeof(Int)*(|A|+|B|) after selected-index allocation. Output gate not RSS, still quadratic work. Same pairs unordered, distinct species A→B.

**Units:** Supported Unitful arithmetic retained; unitless data are physically unknown unless caller declares provenance; labels never convert data.

**Ownership:** New pair/distance vectors; boundary retained.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: DETAILED. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/atomistic/core.jl:102; src/atomistic/core.jl:125.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:79; test/atomistic_core.jl:45; examples/integration/one_system_many_methods.jl:150.

```@raw html
<p>Repository resources: <a href="../repository/examples/integration/one_system_many_methods.jl">examples/integration/one_system_many_methods.jl</a>; <a href="../repository/src/atomistic/core.jl">src/atomistic/core.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/atomistic_core.jl">test/atomistic_core.jl</a></p>
```

## [F17: Supplied radial potentials](@id family-F17)

<!-- aml-api: {"symbol": "analyze_potential", "family": "F17", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [analyze_potential](@id api-analyze-potential)

**Identity:** generic function; F17; **PUBLIC_STABLE**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "a30acd969c3e9d8166c56ac00f8f97520e03828992e3c3c289e8b31e3b6a0c45"} -->
**Purpose and output:** PotentialAnalysis

**Source declarations and forwarding context:**

```text
function analyze_potential(expression, variable::Symbolics.Num; interval=nothing,
provenance=(source=:user,), units=(length=:unspecified, energy=:unspecified),
cutoff=nothing, kwargs...)
```

**Inputs:** Symbolic expression/RealExpression and Num variable; positive interval optional; kwargs scalar residual controls

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError invalid cutoff or interval not in single established positive domain; underlying analyze failures propagate; DomainError on known excluded/nonpositive radius

**Numerical limitations:** Bound parameters only; numerical stationary search Float64; can construct unknown domain without search; known false refused, unknown may evaluate/fail.

**Units:** Units=(length=:unspecified, energy=:unspecified) descriptive only.

**Ownership:** Fresh derived report but provenance/units retained.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: DETAILED. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/atomistic/potentials.jl:93.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:80; test/atomistic_potentials.jl:6.

```@raw html
<p>Repository resources: <a href="../repository/src/atomistic/potentials.jl">src/atomistic/potentials.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/atomistic_potentials.jl">test/atomistic_potentials.jl</a></p>
```

<!-- aml-api: {"symbol": "lennard_jones_analysis", "family": "F17", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [lennard_jones_analysis](@id api-lennard-jones-analysis)

**Identity:** generic function; F17; **PUBLIC_STABLE**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "4357d42deb12a15fcc82835861dd239d13755202255c255f9de735e32f4d359a"} -->
**Purpose and output:** PotentialAnalysis with independent scaled-sixth-power minimum certificate

**Source declarations and forwarding context:**

```text
function lennard_jones_analysis(; epsilon=1, sigma=1, interval=nothing,
provenance=(source=:textbook, model=:lennard_jones_12_6), kwargs...)
```

**Inputs:** Positive finite real epsilon/sigma; interval optional, provenance/kwargs

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError invalid/unrepresentable scales/minimum radius/curvature

**Numerical limitations:** Binary floats embedded exact rational representation not physical measurement exactness; rmin/curvature displayed Float64; certificate does not upgrade global study.

**Units:** No implicit Unitful scales; descriptive units via analyze_potential.

**Ownership:** Fresh source/certificate; metadata retained.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: DETAILED. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/atomistic/potentials.jl:142.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:80; test/atomistic_potentials.jl:36; examples/inference/lj_gate.jl:9.

```@raw html
<p>Repository resources: <a href="../repository/examples/inference/lj_gate.jl">examples/inference/lj_gate.jl</a>; <a href="../repository/src/atomistic/potentials.jl">src/atomistic/potentials.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/atomistic_potentials.jl">test/atomistic_potentials.jl</a></p>
```

<!-- aml-api: {"symbol": "PotentialAnalysis", "family": "F17", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "type / constructors", "variant_count": 1} -->
## [PotentialAnalysis](@id api-PotentialAnalysis)

**Identity:** type / constructors; F17; **PUBLIC_STABLE**; explicitly exported.

**Stored fields:** `function_analysis`, `force_expression`, `numerical`, `radial_domain`, `provenance`, `units`, `cutoff`, `equilibria`, `evidence`, `limitations`. Immutable outer record; referenced payloads may still be mutable. Obtain validated outputs through the operations described below; a raw record constructor does not itself certify scientific consistency.

<!-- aml-contract: {"variant": 0, "digest": "87a4013c15e160b7eead35b1685c70a2d2a78e7161c7135199107048f853f8dd"} -->
**Purpose and output:** Bound radial scalar-energy analysis and F=−dU/dr, positive radial domain/equilibrium evidence

**Source declarations and forwarding context:**

```text
struct PotentialAnalysis{A,F,N,P,U,C,E,V} <: AbstractAnalysis; raw generated field constructor: (function_analysis::A, force_expression::F, numerical::N, radial_domain::RealDomain, provenance::P, units::U, cutoff::C, equilibria::E, evidence::V, limitations::Vector{String})
```

**Inputs:** analyze_potential/lennard_jones_analysis or raw fields

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** No additional refusal specified in this audited route; raw records do not establish validation.

**Numerical limitations:** r>0 intersection; real study is algebraic not negative-radius physical claim; cutoff metadata only; equilibrium list need not contain stationary non-extrema.

**Units:** Unit labels not conversion; consistent numeric scales required.

**Ownership:** Retains FunctionAnalysis and caller provenance/units; numerical closures retain report/domain.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: DETAILED. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/atomistic/potentials.jl:14.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:80.

```@raw html
<p>Repository resources: <a href="../repository/src/atomistic/potentials.jl">src/atomistic/potentials.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a></p>
```

## [F18: Distribution and coordination analysis](@id family-F18)

<!-- aml-api: {"symbol": "coordination", "family": "F18", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [coordination](@id api-coordination)

**Identity:** generic function; F18; **PUBLIC_STABLE**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "e1d31a65aa9261e9affc9e0486b087fd5e87dfb2d7677c4c52b8c907f753ec17"} -->
**Purpose and output:** Heuristic PropertyResult mean/counts/central indices

**Source declarations and forwarding context:**

```text
function coordination(s::AtomisticSnapshot;cutoff,species=nothing)
```

**Inputs:** Snapshot; required cutoff>=0; species optional

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** Unknown nonfinite/negative cutoff or missing positions/geometry/species/central selection; ArgumentError malformed species tuple

**Numerical limitations:** Inclusive cutoff and no self pairs; same pairs increment both central counts; cross only A; open geometry allowed. No homogeneous density normalization or work budget.

**Units:** Supported Unitful arithmetic retained; unitless data are physically unknown unless caller declares provenance; labels never convert data.

**Ownership:** New counts/index dictionary; boundary retained.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: DETAILED. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/atomistic/distributions.jl:32.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:81; test/atomistic_distributions.jl:28; examples/scaling/README.md:74.

```@raw html
<p>Repository resources: <a href="../repository/examples/scaling/README.md">examples/scaling/README.md</a>; <a href="../repository/src/atomistic/distributions.jl">src/atomistic/distributions.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/atomistic_distributions.jl">test/atomistic_distributions.jl</a></p>
```

<!-- aml-api: {"symbol": "radial_distribution", "family": "F18", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [radial_distribution](@id api-radial-distribution)

**Identity:** generic function; F18; **PUBLIC_STABLE**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "42116ff4406716e471682a933cccc29bc6e45ae9494e56d86779c362590e7005"} -->
**Purpose and output:** RadialDistributionAnalysis

**Source declarations and forwarding context:**

```text
function radial_distribution(s::AtomisticSnapshot;edges,species=nothing,frames=1:1)

function radial_distribution(t::AtomisticTrajectoryView;edges,species=nothing,frames=1:length(t))
```

**Inputs:** Snapshot/view; required ordered edges; optional species and frames

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError invalid edges/frame indices; unknown unsupported geometry/dimensions/range/species/pairs; incompatible units may propagate

**Numerical limitations:** Only orthorhombic periodic2D/3D; max radius half shortest box. Finite-N pair normalization summed per frame; changing populations supported; left-closed bins final edge inclusive. Float64 expected counts; quadratic traversal but bounded O(bins+frames+particles) output.

**Units:** Supported Unitful arithmetic retained; unitless data are physically unknown unless caller declares provenance; labels never convert data.

**Ownership:** Collects edges; streams snapshots; no full pair list.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: TYPE detailed; method reference incomplete. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/atomistic/distributions.jl:55; src/atomistic/distributions.jl:59.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:81; test/atomistic_distributions.jl:7; notebooks/molly_companion.jl:42.

```@raw html
<p>Repository resources: <a href="../repository/notebooks/molly_companion.jl">notebooks/molly_companion.jl</a>; <a href="../repository/src/atomistic/distributions.jl">src/atomistic/distributions.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/atomistic_distributions.jl">test/atomistic_distributions.jl</a></p>
```

<!-- aml-api: {"symbol": "RadialDistributionAnalysis", "family": "F18", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "type / constructors", "variant_count": 1} -->
## [RadialDistributionAnalysis](@id api-RadialDistributionAnalysis)

**Identity:** type / constructors; F18; **PUBLIC_STABLE**; explicitly exported.

**Stored fields:** `rdf`, `counts`, `edges`, `centers`, `expected_counts`, `frame_count`, `particle_populations`, `pair_populations`, `species`, `units`, `boundary_assumptions`, `method`, `notes`. Immutable outer record; referenced payloads may still be mutable. Obtain validated outputs through the operations described below; a raw record constructor does not itself certify scientific consistency.

<!-- aml-contract: {"variant": 0, "digest": "875b60b7378c832c62c731262dbb1d2e95d4e4a6cca45822643c127e810d1785"} -->
**Purpose and output:** Heuristic normalized rdf plus counts/expected/populations/assumptions

**Source declarations and forwarding context:**

```text
struct RadialDistributionAnalysis <: AbstractAnalysis; raw generated field constructor: (rdf::PropertyResult, counts::Vector{Int}, edges, centers, expected_counts, frame_count::Int, particle_populations, pair_populations, species, units, boundary_assumptions, method::Symbol, notes::Vector{String})
```

**Inputs:** radial_distribution or raw stored fields

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** No additional refusal specified in this audited route; raw records do not establish validation.

**Numerical limitations:** No equilibrium certification; partial arrays may survive unknown result.

**Units:** Supported Unitful arithmetic retained; unitless data are physically unknown unless caller declares provenance; labels never convert data.

**Ownership:** New count/edge/expected arrays and populations.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: DETAILED. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/atomistic/distributions.jl:10.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:81; test/atomistic_distributions.jl:85.

```@raw html
<p>Repository resources: <a href="../repository/src/atomistic/distributions.jl">src/atomistic/distributions.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/atomistic_distributions.jl">test/atomistic_distributions.jl</a></p>
```
