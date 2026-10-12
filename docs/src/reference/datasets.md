# Experimental scientific datasets and scaling

Explicit schema, sample/query order, splits and reference declarations govern learning data. Array copying does not certify labels or references. Fit normalization on training samples only; AffineScaling is not unit conversion.

Read [API boundaries and evidence semantics](@ref api-boundaries) for the distinction between raw constructors, validated factories, exceptions, unknown claims and unrequested/partial diagnostics. Signatures are text, not runnable examples. Backend forwarding/context lines do not create public helper APIs.

```@raw html
<p>Repository resources: <a href="../repository/docs/surrogates.md">docs/surrogates.md</a>; <a href="../repository/docs/tutorials/one-system-many-methods.md">docs/tutorials/one-system-many-methods.md</a>; <a href="../repository/docs/tutorials/scripts/one_system_many_methods.jl">docs/tutorials/scripts/one_system_many_methods.jl</a>; <a href="../repository/reports/m10d6/tutorial_verification.json">reports/m10d6/tutorial_verification.json</a></p>
```

Overload map: [train](@ref dispatch-train).

Overload map: [predict](@ref dispatch-predict).

## [F31: Scientific datasets](@id family-F31)

<!-- aml-api: {"symbol": "classify_query", "family": "F31", "stability": "PUBLIC_EXPERIMENTAL", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [classify_query](@id api-classify-query)

**Identity:** generic function; F31; **PUBLIC_EXPERIMENTAL**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "7835acb9def04ed04586ad233810d31a9753d9219d3b4854390c87992e3d0a09"} -->
**Purpose and output:** parameter/coordinate/function_family inside|outside|unknown/not_applicable and guarantee=:none

**Source declarations and forwarding context:**

```text
classify_query(d::ScientificDataset,input,coordinates::AbstractMatrix;kwargs...)=_classify_learning_query(d,input,coordinates;kwargs...)

classify_query(m::ScientificModel,input,coordinates::AbstractMatrix;kwargs...)=_classify_learning_query(m.schema,input,coordinates;kwargs...)
```

**Inputs:** Dataset or ScientificModel, ordered input and query matrix; descriptor/sensors optional

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** DimensionMismatch row/input/descriptor order; ArgumentError changed sensor grid/nonfinite

**Numerical limitations:** No interpolation of sensors; inside is not validity.

**Units:** Checked Float64 sample/scaling coordinates; units metadata never converts numbers. field_errors/AD use supported value promotion, not universal precision.

**Ownership:** No new analysis/scaling; schema retained.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: ABSENT method. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/scientific_ml/surrogates.jl:103; src/scientific_ml/surrogates.jl:236.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:98; test/m10a_inference_operators.jl:208; examples/operators/focused_gate.jl:38.

```@raw html
<p>Repository resources: <a href="../repository/examples/operators/focused_gate.jl">examples/operators/focused_gate.jl</a>; <a href="../repository/src/scientific_ml/surrogates.jl">src/scientific_ml/surrogates.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/m10a_inference_operators.jl">test/m10a_inference_operators.jl</a></p>
```

<!-- aml-api: {"symbol": "ScientificDataset", "family": "F31", "stability": "PUBLIC_EXPERIMENTAL", "qualified": false, "kind": "type / constructors", "variant_count": 1} -->
## [ScientificDataset](@id api-ScientificDataset)

**Identity:** type / constructors; F31; **PUBLIC_EXPERIMENTAL**; explicitly exported.

**Stored fields:** `samples`, `kind`, `family`, `input_names`, `coordinate_names`, `domain`, `sensors`, `reference`, `units`, `grid`, `rng`, `provenance`. Immutable outer record; referenced payloads may still be mutable. Obtain validated outputs through the operations described below; a raw record constructor does not itself certify scientific consistency.

**Interpretation:** The trajectory adapter’s source_retention=:descriptor is bounded detached provenance with omissions, not compression or a persistent provenance hash. Unit labels remain declarations.

<!-- aml-contract: {"variant": 0, "digest": "31eae85522736630024260d802a2b7cff771955f2683d0a1c58e3b56f489e8f1"} -->
**Purpose and output:** ScientificDataset

**Source declarations and forwarding context:**

```text
struct ScientificDataset; raw generated field constructor: (samples::Vector{ScientificSample}, kind::Symbol, family, input_names::Tuple, coordinate_names::Tuple, domain, sensors, reference, units, grid, rng, provenance)

function ScientificDataset(samples;kind,family,input_names,coordinate_names,domain,
reference,units,grid,rng,sensors=nothing,provenance=NamedTuple())

function ScientificDataset(path::TrajectoryResult;schema=nothing,source_retention=:retained)
```

**Inputs:** Samples plus required kind/family/ordered names/domain/reference/units/grid/rng; sensors optional; or completed path with schema/source_retention

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError unsupported/missing schema/domain/reference/kind/split/duplicate IDs/representations/leakage/source success/Unitful output; DimensionMismatch rows/bounds/sensors/units

**Numerical limitations:** Surrogate versus operator distinct; bounds descriptive. Training required; numerical refs require solver/algorithm/tolerances/grid/tspan/parameters/error. Standalone path only training-compatible split; stored times sole coordinate, selected scalar target; unknown numerical error or documented estimate not exact truth.

**Units:** Checked Float64 sample/scaling coordinates; units metadata never converts numbers. field_errors/AD use supported value promotion, not universal precision.

**Ownership:** Sample container fresh but sample objects retained; deepcopies domain/sensors/reference/units/grid/rng/provenance. Path default retained may deepcopy native solution/callback/context; descriptor omits listed heavy fields but caller family/reference controls still retained.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: TYPE + path detailed. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/scientific_ml/surrogates.jl:65; src/scientific_ml/surrogates.jl:105; src/scientific_ml/trajectory_dataset.jl:33.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:98; test/m10b_diagnostics.jl:81; examples/integration/one_system_learning.jl:23.

```@raw html
<p>Repository resources: <a href="../repository/examples/integration/one_system_learning.jl">examples/integration/one_system_learning.jl</a>; <a href="../repository/src/scientific_ml/surrogates.jl">src/scientific_ml/surrogates.jl</a>; <a href="../repository/src/scientific_ml/trajectory_dataset.jl">src/scientific_ml/trajectory_dataset.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/m10b_diagnostics.jl">test/m10b_diagnostics.jl</a></p>
```

<!-- aml-api: {"symbol": "ScientificSample", "family": "F31", "stability": "PUBLIC_EXPERIMENTAL", "qualified": false, "kind": "type / constructors", "variant_count": 1} -->
## [ScientificSample](@id api-ScientificSample)

**Identity:** type / constructors; F31; **PUBLIC_EXPERIMENTAL**; explicitly exported.

**Stored fields:** `id`, `input`, `coordinates`, `values`, `split`, `descriptor`. Immutable outer record; referenced payloads may still be mutable. Obtain validated outputs through the operations described below; a raw record constructor does not itself certify scientific consistency.

<!-- aml-contract: {"variant": 0, "digest": "1d172027542cb0cee3529f3dd4db0c671da04c8e04dcf0153b256a63473ea1f2"} -->
**Purpose and output:** Copied Float64 scalar-field sample

**Source declarations and forwarding context:**

```text
struct ScientificSample

function ScientificSample(id,input,coordinates::AbstractMatrix,values;split,descriptor=nothing)
```

**Inputs:** id,input,coordinate rows×queries,values; explicit split, optional descriptor

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError unsupported split/empty/nonfinite/unrepresentable; DimensionMismatch columns/target count

**Numerical limitations:** Six explicit supported splits only; descriptor not training input or target.

**Units:** Checked Float64 sample/scaling coordinates; units metadata never converts numbers. field_errors/AD use supported value promotion, not universal precision.

**Ownership:** Copies numeric arrays and deepcopies descriptor.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: DETAILED. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/scientific_ml/surrogates.jl:42; src/scientific_ml/surrogates.jl:49.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:98; test/m10b_diagnostics.jl:47; examples/integration/one_system_learning.jl:24.

```@raw html
<p>Repository resources: <a href="../repository/examples/integration/one_system_learning.jl">examples/integration/one_system_learning.jl</a>; <a href="../repository/src/scientific_ml/surrogates.jl">src/scientific_ml/surrogates.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/m10b_diagnostics.jl">test/m10b_diagnostics.jl</a></p>
```

## [F32: Train-only affine scaling](@id family-F32)

<!-- aml-api: {"symbol": "AffineScaling", "family": "F32", "stability": "PUBLIC_EXPERIMENTAL", "qualified": false, "kind": "type / constructors", "variant_count": 1} -->
## [AffineScaling](@id api-AffineScaling)

**Identity:** type / constructors; F32; **PUBLIC_EXPERIMENTAL**; explicitly exported.

**Stored fields:** `offset`, `scale`, `fitted_ids`, `field`. Immutable outer record; referenced payloads may still be mutable. Obtain validated outputs through the operations described below; a raw record constructor does not itself certify scientific consistency.

<!-- aml-contract: {"variant": 0, "digest": "7fabc0dde56f8b0aaf84b1f65f0ba7829ee3e3d8b0fbd545830ddd13ce571693"} -->
**Purpose and output:** Checked Float64 affine map

**Source declarations and forwarding context:**

```text
struct AffineScaling

function AffineScaling(offset,scale,fitted_ids,field)
```

**Inputs:** offset,positive scale,fitted_ids,field

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError empty/invalid/unrepresentable scales; DimensionMismatch offset lengths

**Numerical limitations:** Constant rows scale1; explicit representation not automatic nondimensionalization.

**Units:** Checked Float64 sample/scaling coordinates; units metadata never converts numbers. field_errors/AD use supported value promotion, not universal precision.

**Ownership:** Copies numeric vectors/IDs.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: DETAILED. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/scientific_ml/surrogates.jl:7; src/scientific_ml/surrogates.jl:12.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:99; test/m10b_diagnostics.jl:48; examples/operators/m10b_gate.jl:24.

```@raw html
<p>Repository resources: <a href="../repository/examples/operators/m10b_gate.jl">examples/operators/m10b_gate.jl</a>; <a href="../repository/src/scientific_ml/surrogates.jl">src/scientific_ml/surrogates.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/m10b_diagnostics.jl">test/m10b_diagnostics.jl</a></p>
```

<!-- aml-api: {"symbol": "fit_scaling", "family": "F32", "stability": "PUBLIC_EXPERIMENTAL", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [fit_scaling](@id api-fit-scaling)

**Identity:** generic function; F32; **PUBLIC_EXPERIMENTAL**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "a7c47c55648beecc40be54d8b9626d095819e669b8b49817905cb1d573aa409e"} -->
**Purpose and output:** AffineScaling

**Source declarations and forwarding context:**

```text
function fit_scaling(d::ScientificDataset,field::Symbol)
```

**Inputs:** Dataset, field::Symbol inputs|coordinates|outputs

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError invalid field/unrepresentable midpoint/scale

**Numerical limitations:** Fitted training IDs only; minmax midpoint/half range; collects all training data no output budget.

**Units:** Checked Float64 sample/scaling coordinates; units metadata never converts numbers. field_errors/AD use supported value promotion, not universal precision.

**Ownership:** Materializes training matrices then fresh vectors.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: BRIEF. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/scientific_ml/surrogates.jl:158.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:99; test/m10a_inference_operators.jl:191; examples/operators/integration_gate.jl:55.

```@raw html
<p>Repository resources: <a href="../repository/examples/operators/integration_gate.jl">examples/operators/integration_gate.jl</a>; <a href="../repository/src/scientific_ml/surrogates.jl">src/scientific_ml/surrogates.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/m10a_inference_operators.jl">test/m10a_inference_operators.jl</a></p>
```

<!-- aml-api: {"symbol": "inverse_transform", "family": "F32", "stability": "PUBLIC_EXPERIMENTAL", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [inverse_transform](@id api-inverse-transform)

**Identity:** generic function; F32; **PUBLIC_EXPERIMENTAL**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "e4d1f9414ebe0471a6d54ee26abfe9522ae22f99f53134692c8e749a42e8d099"} -->
**Purpose and output:** Restored numeric array

**Source declarations and forwarding context:**

```text
function inverse_transform(s::AffineScaling,x::Union{AbstractVector,AbstractMatrix})
```

**Inputs:** AffineScaling and vector/matrix

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** Same row/data/scale/representability refusals

**Numerical limitations:** muladd used; not guaranteed lossless roundtrip under all floating arithmetic.

**Units:** Checked Float64 sample/scaling coordinates; units metadata never converts numbers. field_errors/AD use supported value promotion, not universal precision.

**Ownership:** Fresh output.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: No separate method doc. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/scientific_ml/surrogates.jl:30.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:99; test/m10b_diagnostics.jl:73.

```@raw html
<p>Repository resources: <a href="../repository/src/scientific_ml/surrogates.jl">src/scientific_ml/surrogates.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/m10b_diagnostics.jl">test/m10b_diagnostics.jl</a></p>
```

<!-- aml-api: {"symbol": "transform", "family": "F32", "stability": "PUBLIC_EXPERIMENTAL", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [transform](@id api-transform)

**Identity:** generic function; F32; **PUBLIC_EXPERIMENTAL**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "50c07766522fc9509182c3dec1949cedcc794d0b04ee7321a77f1ae1468ad664"} -->
**Purpose and output:** Normalized array

**Source declarations and forwarding context:**

```text
function transform(s::AffineScaling,x::Union{AbstractVector,AbstractMatrix})
```

**Inputs:** AffineScaling and AbstractVector/Matrix

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** DimensionMismatch rows; ArgumentError invalid data/scale or nonrepresentable result

**Numerical limitations:** No implicit row inference; scalar outputs need reshape; qualify AML.transform on name collisions.

**Units:** Checked Float64 sample/scaling coordinates; units metadata never converts numbers. field_errors/AD use supported value promotion, not universal precision.

**Ownership:** Fresh broadcast output.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: No separate method doc. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/scientific_ml/surrogates.jl:20.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:99; test/m10b_diagnostics.jl:73; examples/integration/one_system_many_methods.jl:121.

```@raw html
<p>Repository resources: <a href="../repository/examples/integration/one_system_many_methods.jl">examples/integration/one_system_many_methods.jl</a>; <a href="../repository/src/scientific_ml/surrogates.jl">src/scientific_ml/surrogates.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/m10b_diagnostics.jl">test/m10b_diagnostics.jl</a></p>
```
