# Vector fields and differential operators

Input-coordinate order and component order are separate. A Jacobian may be rectangular; divergence/curl have route-specific dimensional requirements. Zero curl is not by itself a global potential certificate on arbitrary domains.

Read [API boundaries and evidence semantics](@ref api-boundaries) for the distinction between raw constructors, validated factories, exceptions, unknown claims and unrequested/partial diagnostics. Signatures are text, not runnable examples. Backend forwarding/context lines do not create public helper APIs.

```@raw html
<p>Repository resources: <a href="../repository/docs/tutorials/scripts/vector_calculus.jl">docs/tutorials/scripts/vector_calculus.jl</a>; <a href="../repository/docs/tutorials/vector-calculus.md">docs/tutorials/vector-calculus.md</a>; <a href="../repository/docs/vector_fields.md">docs/vector_fields.md</a>; <a href="../repository/reports/m10d6/tutorial_verification.json">reports/m10d6/tutorial_verification.json</a></p>
```

Overload map: [analyze](@ref dispatch-analyze).

Overload map: [evaluate](@ref dispatch-evaluate).

Overload map: [plot](@ref dispatch-plot).

## [F07: Vector calculus](@id family-F07)

<!-- aml-api: {"symbol": "curl", "family": "F07", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [curl](@id api-curl)

**Identity:** generic function; F07; **PUBLIC_STABLE**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "6a336b77740a0cb622348915707cefd857c5e6a1b7a4974fba6b6868ec1d7b70"} -->
**Purpose and output:** PropertyResult of scalar dQ/dx-dP/dy for square2D, 3-vector curl for square3D, unknown/unsupported otherwise.

**Source declarations and forwarding context:**

```text
curl(report::VectorFieldAnalysis)
```

**Inputs:** Stored VectorFieldAnalysis; no recomputation or point argument.

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** No explicit accessor validation/errors for a valid stored report; unsupported mathematics represented as unknown PropertyResult during analysis.

**Numerical limitations:** No curl for rectangular or other dimensions; formal smooth-locus identity, not global topology.

**Units:** Plain ordered input/output numeric coordinates; no general Unitful or physical scale inference; field residual scale caller-defined.

**Ownership:** Returns deepcopy of stored PropertyResult and mutable contents.

**Dependencies:** Symbolics.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: PRESENT_BRIEF. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/vector_fields/calculus.jl:7-8; src/vector_fields/calculus.jl:45-100.

Inventory-listed candidate references (not a verified call graph or new execution): test/vector_calculus.jl:5-36; test/vector_regressions.jl:22-29; notebooks/vector_field_analysis.jl:6-37.

```@raw html
<p>Repository resources: <a href="../repository/notebooks/vector_field_analysis.jl">notebooks/vector_field_analysis.jl</a>; <a href="../repository/src/vector_fields/calculus.jl">src/vector_fields/calculus.jl</a>; <a href="../repository/test/vector_calculus.jl">test/vector_calculus.jl</a>; <a href="../repository/test/vector_regressions.jl">test/vector_regressions.jl</a></p>
```

<!-- aml-api: {"symbol": "divergence", "family": "F07", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [divergence](@id api-divergence)

**Identity:** generic function; F07; **PUBLIC_STABLE**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "27a88e9b56d4733eaf6793604878c69f5fff04ad27c7f653aacc1884de9c803e"} -->
**Purpose and output:** PropertyResult of formal trace(J) for square fields, unknown/unsupported otherwise.

**Source declarations and forwarding context:**

```text
divergence(report::VectorFieldAnalysis)
```

**Inputs:** Stored VectorFieldAnalysis; no recomputation or point argument.

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** No explicit accessor validation/errors for a valid stored report; unsupported mathematics represented as unknown PropertyResult during analysis.

**Numerical limitations:** Square fields only; identity on smooth locus, no boundary differentiability claim.

**Units:** Plain ordered input/output numeric coordinates; no general Unitful or physical scale inference; field residual scale caller-defined.

**Ownership:** Returns deepcopy of stored PropertyResult and mutable contents.

**Dependencies:** Symbolics.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: PRESENT_BRIEF. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/vector_fields/calculus.jl:5-6; src/vector_fields/calculus.jl:45-100.

Inventory-listed candidate references (not a verified call graph or new execution): test/vector_calculus.jl:5-36; test/vector_regressions.jl:22-29; notebooks/vector_field_analysis.jl:6-37.

```@raw html
<p>Repository resources: <a href="../repository/notebooks/vector_field_analysis.jl">notebooks/vector_field_analysis.jl</a>; <a href="../repository/src/vector_fields/calculus.jl">src/vector_fields/calculus.jl</a>; <a href="../repository/test/vector_calculus.jl">test/vector_calculus.jl</a>; <a href="../repository/test/vector_regressions.jl">test/vector_regressions.jl</a></p>
```

<!-- aml-api: {"symbol": "jacobian", "family": "F07", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [jacobian](@id api-jacobian)

**Identity:** generic function; F07; **PUBLIC_STABLE**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "2f9850a1b4067a829e8f5d85293ab9a5ec947fa7d74b78be2c7e9bf0ceb37002"} -->
**Purpose and output:** m×n formal copied symbolic matrix, or freshly evaluated matrix with component rows and variable columns.

**Source declarations and forwarding context:**

```text
jacobian(report::VectorFieldAnalysis)

jacobian(report::VectorFieldAnalysis, point::Union{Tuple,AbstractVector})

jacobian(r::DynamicalSystemAnalysis)

jacobian(r::DynamicalSystemAnalysis, p::Union{Tuple,AbstractVector})
```

**Inputs:** Stored rectangular vector map or autonomous report; optional n-coordinate finite real point.

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** DimensionMismatch for point length; DomainError for invalid/nonfinite point/result or unsupported open-smooth neighborhood; underlying compiled-callable errors propagate.

**Numerical limitations:** Formal Jacobian not a boundary differentiability proof; point queries require known smooth original neighborhood; no repeated differentiation.

**Units:** Plain ordered input/output numeric coordinates; no general Unitful or physical scale inference; field residual scale caller-defined.

**Ownership:** Formal shallow array copy; fresh numeric matrix; autonomous methods delegate to field.

**Dependencies:** Symbolics.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: PARTIAL_FORMAL_VECTOR_METHOD_BRIEF_OTHERS_ABSENT. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/vector_fields/analysis.jl:94-100; src/dynamical_systems/analysis.jl:59-60.

Inventory-listed candidate references (not a verified call graph or new execution): test/vector_fields.jl:9-19; test/vector_regressions.jl:20-21; notebooks/vector_field_analysis.jl:6-37.

```@raw html
<p>Repository resources: <a href="../repository/notebooks/vector_field_analysis.jl">notebooks/vector_field_analysis.jl</a>; <a href="../repository/src/dynamical_systems/analysis.jl">src/dynamical_systems/analysis.jl</a>; <a href="../repository/src/vector_fields/analysis.jl">src/vector_fields/analysis.jl</a>; <a href="../repository/test/vector_fields.jl">test/vector_fields.jl</a>; <a href="../repository/test/vector_regressions.jl">test/vector_regressions.jl</a></p>
```

<!-- aml-api: {"symbol": "potential", "family": "F07", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [potential](@id api-potential)

**Identity:** generic function; F07; **PUBLIC_STABLE**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "95f45a44071105cf274d32adfbf6b072b7cc4f2dd1f83677c9b7fbf4fa3a1737"} -->
**Purpose and output:** PropertyResult of verified scalar polynomial potential (additive constant omitted), or unknown.

**Source declarations and forwarding context:**

```text
potential(report::VectorFieldAnalysis)
```

**Inputs:** Stored VectorFieldAnalysis; no recomputation or point argument.

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** No explicit accessor validation/errors for a valid stored report; unsupported mathematics represented as unknown PropertyResult during analysis.

**Numerical limitations:** Only rational coefficient polynomial fields total degree<=8 with established supported open original syntax; radial homotopy result differentiated componentwise. Zero curl not a global potential proof; unsupported is not nonexistence.

**Units:** Plain ordered input/output numeric coordinates; no general Unitful or physical scale inference; field residual scale caller-defined.

**Ownership:** Returns deepcopy of stored PropertyResult and mutable contents.

**Dependencies:** Symbolics.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: PRESENT_BRIEF. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/vector_fields/calculus.jl:9-10; src/vector_fields/calculus.jl:45-100.

Inventory-listed candidate references (not a verified call graph or new execution): test/vector_calculus.jl:5-36; test/vector_regressions.jl:22-29; notebooks/vector_field_analysis.jl:6-37.

```@raw html
<p>Repository resources: <a href="../repository/notebooks/vector_field_analysis.jl">notebooks/vector_field_analysis.jl</a>; <a href="../repository/src/vector_fields/calculus.jl">src/vector_fields/calculus.jl</a>; <a href="../repository/test/vector_calculus.jl">test/vector_calculus.jl</a>; <a href="../repository/test/vector_regressions.jl">test/vector_regressions.jl</a></p>
```

<!-- aml-api: {"symbol": "VectorFieldAnalysis", "family": "F07", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "type / constructors", "variant_count": 1} -->
## [VectorFieldAnalysis](@id api-VectorFieldAnalysis)

**Identity:** type / constructors; F07; **PUBLIC_STABLE**; explicitly exported.

**Stored fields:** `components`, `original_components`, `variables`, `input_dimension`, `output_dimension`, `jacobian_expression`, `numerical`, `domain`, `component_domains`, `field_zeros`, `divergence`, `curl`, `conservative`, `potential`. Immutable outer record; referenced payloads may still be mutable. Obtain validated outputs through the operations described below; a raw record constructor does not itself certify scientific consistency.

<!-- aml-contract: {"variant": 0, "digest": "0332c6e5bfc73ed489f5a5344f00d925082decca1b37e4e0c0d4ebaca39897af"} -->
**Purpose and output:** Rectangular map with cached Jacobian, domain/component_domains, field_zeros and separate calculus/potential evidence.

**Source declarations and forwarding context:**

```text
VectorFieldAnalysis(components, original_components, variables, input_dimension, output_dimension, jacobian_expression, numerical, domain, component_domains, field_zeros, divergence, curl, conservative, potential)
```

**Inputs:** Normally analyze(component vector/tuple, ordered variables); raw full field constructor retains caller objects.

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** Generated constructors enforce declared Julia field/type constraints, not mathematical validity; no general invariant-validation promise.

**Numerical limitations:** Independent input/output dimensions1–32; exact square affine/separable zeros only. Rectangular numerical least-squares candidate steps still require residual acceptance. Zero curl alone never proves global potential.

**Units:** Plain ordered input/output numeric coordinates; no general Unitful or physical scale inference; field residual scale caller-defined.

**Ownership:** Immutable outer record does not imply deep immutability; stored arrays/Expr are read-only by convention. Raw generated constructors generally retain supplied references and do not validate scientific invariants.

**Dependencies:** Symbolics.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: PRESENT_BRIEF. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/vector_fields/analysis.jl:2.

Inventory-listed candidate references (not a verified call graph or new execution): test/vector_fields.jl:5-38; test/vector_calculus.jl:5-46; notebooks/vector_field_analysis.jl:6-37.

```@raw html
<p>Repository resources: <a href="../repository/notebooks/vector_field_analysis.jl">notebooks/vector_field_analysis.jl</a>; <a href="../repository/src/vector_fields/analysis.jl">src/vector_fields/analysis.jl</a>; <a href="../repository/test/vector_calculus.jl">test/vector_calculus.jl</a>; <a href="../repository/test/vector_fields.jl">test/vector_fields.jl</a></p>
```
