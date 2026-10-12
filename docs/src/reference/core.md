# Evidence atoms and expression capture

Reports contain scientific claims; their constructors are not universal validators. Capturing original syntax must happen before symbolic simplification if domain restrictions are to survive.

Read [API boundaries and evidence semantics](@ref api-boundaries) for the distinction between raw constructors, validated factories, exceptions, unknown claims and unrequested/partial diagnostics. Signatures are text, not runnable examples. Backend forwarding/context lines do not create public helper APIs.

```@raw html
<p>Repository resources: <a href="../repository/docs/m10d_semantics.md">docs/m10d_semantics.md</a>; <a href="../repository/docs/tutorials/calculus.md">docs/tutorials/calculus.md</a>; <a href="../repository/docs/tutorials/scripts/calculus.jl">docs/tutorials/scripts/calculus.jl</a>; <a href="../repository/reports/m10d6/tutorial_verification.json">reports/m10d6/tutorial_verification.json</a></p>
```

## Native docstring (supplementary)

DOCSTRING_PRESENT: the registered docstring below supplements, but does not replace, the primary manual contract.

```@docs
AnalyticMathLab.PropertyResult
```

## [F01: Evidence and analysis markers](@id family-F01)

<!-- aml-api: {"symbol": "AbstractAnalysis", "family": "F01", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "abstract type", "variant_count": 1} -->
## [AbstractAnalysis](@id api-AbstractAnalysis)

**Identity:** abstract type; F01; **PUBLIC_STABLE**; explicitly exported.

**Interpretation:** This abstract marker does not define an execution protocol. Obtain concrete reports from their documented operations; it cannot be instantiated.

<!-- aml-contract: {"variant": 0, "digest": "3971bc801fcc49be1b4375448dc5aa75d9051a55408ecd9f78b71aceba94cc33"} -->
**Purpose and output:** Not applicable (abstract marker).

**Source declarations and forwarding context:**

```text
abstract type AbstractAnalysis end
```

**Inputs:** No value constructor; extension supertype for some reusable reports.

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** Cannot instantiate an abstract type.

**Numerical limitations:** Marker/container contracts only; no universal execution protocol or scientific certification.

**Units:** Payload-specific; no universal units schema and no inference of dimensionlessness.

**Ownership:** No storage or ownership protocol implied.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: PRESENT_BRIEF. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/core/contracts.jl:2.

Inventory-listed candidate references (not a verified call graph or new execution): test/real_analysis_core.jl:59-61; test/convergence.jl:131-134; README.md:128-138.

```@raw html
<p>Repository resources: <a href="../repository/README.md">README.md</a>; <a href="../repository/src/core/contracts.jl">src/core/contracts.jl</a>; <a href="../repository/test/convergence.jl">test/convergence.jl</a>; <a href="../repository/test/real_analysis_core.jl">test/real_analysis_core.jl</a></p>
```

<!-- aml-api: {"symbol": "PropertyResult", "family": "F01", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "type / constructors", "variant_count": 1} -->
## [PropertyResult](@id api-PropertyResult)

**Identity:** type / constructors; F01; **PUBLIC_STABLE**; explicitly exported.

**Stored fields:** `value`, `status`, `method`, `notes`. Immutable outer record; referenced payloads may still be mutable. Obtain validated outputs through the operations described below; a raw record constructor does not itself certify scientific consistency.

**Interpretation:** The layout is exactly value, status, method, notes. :established, :heuristic and :unknown are evidence distinctions, not a universal enum for unrelated records. Unknown is neither false nor zero.

<!-- aml-contract: {"variant": 0, "digest": "be791d15f073600aebf062193503a3b18e615638aa31cab0031ce4b85251977b"} -->
**Purpose and output:** Four-field scoped claim: value/status/method/notes; unknown may retain partial payload.

**Source declarations and forwarding context:**

```text
PropertyResult(value, status, method, notes)
```

**Inputs:** Arbitrary value, status::Symbol, method::Symbol, notes::Vector{String}; statuses remain permissive.

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** Generated constructors enforce declared Julia field/type constraints, not mathematical validity; no general invariant-validation promise.

**Numerical limitations:** Established only within recorded claim/method/assumptions; heuristic and unknown distinct; empty payload is absence only when status and scope justify it. Constructors do not validate status vocabulary.

**Units:** Payload-specific; no universal units schema and no inference of dimensionlessness.

**Ownership:** Immutable outer record does not imply deep immutability; stored arrays/Expr are read-only by convention. Raw generated constructors generally retain supplied references and do not validate scientific invariants.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: PRESENT_DETAILED. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/core/contracts.jl:35.

Inventory-listed candidate references (not a verified call graph or new execution): test/real_analysis_core.jl:161-180; test/vector_calculus.jl:5-35; README.md:128-138.

```@raw html
<p>Repository resources: <a href="../repository/README.md">README.md</a>; <a href="../repository/src/core/contracts.jl">src/core/contracts.jl</a>; <a href="../repository/test/real_analysis_core.jl">test/real_analysis_core.jl</a>; <a href="../repository/test/vector_calculus.jl">test/vector_calculus.jl</a></p>
```

## [F02: Original-expression capture](@id family-F02)

<!-- aml-api: {"symbol": "@real_function", "family": "F02", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "macro", "variant_count": 1} -->
## [@real_function](@id api-macro-real-function)

**Identity:** macro; F02; **PUBLIC_STABLE**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "8fdf8082a56ec8c822af5bfab5f80b0b806a9d768456663df1bcede9866362ab"} -->
**Purpose and output:** RealExpression(expression, original_syntax)

**Source declarations and forwarding context:**

```text
@real_function expression
```

**Inputs:** Julia expression in caller scope, evaluated once; original syntax quoted before cancellation.

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** Caller expression evaluation errors propagate; not an untrusted-input parser or sandbox.

**Numerical limitations:** Captures before simplification; caller-supplied syntax equivalence and naming are trusted. Unsupported local names/containers yield unknown domain, not reconstruction.

**Units:** No unit conversion or dimensional validation in syntax wrapper.

**Ownership:** Stores evaluated object and quoted syntax without deep-copy guarantee.

**Dependencies:** Symbolics.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: SHARED_TYPE_DOCSTRING_NOT_SEPARATELY_ATTACHED. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/core/expressions.jl:1-20.

Inventory-listed candidate references (not a verified call graph or new execution): test/source_capture.jl:5-20; test/real_analysis_integration.jl:14-22; notebooks/real_function_analysis.jl:7-14.

```@raw html
<p>Repository resources: <a href="../repository/notebooks/real_function_analysis.jl">notebooks/real_function_analysis.jl</a>; <a href="../repository/src/core/expressions.jl">src/core/expressions.jl</a>; <a href="../repository/test/real_analysis_integration.jl">test/real_analysis_integration.jl</a>; <a href="../repository/test/source_capture.jl">test/source_capture.jl</a></p>
```

<!-- aml-api: {"symbol": "RealExpression", "family": "F02", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "type / constructors", "variant_count": 1} -->
## [RealExpression](@id api-RealExpression)

**Identity:** type / constructors; F02; **PUBLIC_STABLE**; explicitly exported.

**Stored fields:** `expression`, `original`. Immutable outer record; referenced payloads may still be mutable. Obtain validated outputs through the operations described below; a raw record constructor does not itself certify scientific consistency.

<!-- aml-contract: {"variant": 0, "digest": "69e0f68acbe5cf0ce6c7d44fc325341e3fab90dc2ed835d7b054d7a314d4910a"} -->
**Purpose and output:** RealExpression record

**Source declarations and forwarding context:**

```text
RealExpression(expression, original)
```

**Inputs:** Evaluated expression and original syntax; prefer @real_function before Symbolics cancellation.

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** Generated constructors enforce declared Julia field/type constraints, not mathematical validity; no general invariant-validation promise.

**Numerical limitations:** Captures before simplification; caller-supplied syntax equivalence and naming are trusted. Unsupported local names/containers yield unknown domain, not reconstruction.

**Units:** No unit conversion or dimensional validation in syntax wrapper.

**Ownership:** Raw constructor retains expression/original references; captured Expr is mutable and must be treated read-only.

**Dependencies:** Symbolics.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: PRESENT_SHARED_WITH_MACRO. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/core/expressions.jl:13.

Inventory-listed candidate references (not a verified call graph or new execution): test/source_capture.jl:5-20; test/real_analysis_integration.jl:14-22; notebooks/real_function_analysis.jl:7-14.

```@raw html
<p>Repository resources: <a href="../repository/notebooks/real_function_analysis.jl">notebooks/real_function_analysis.jl</a>; <a href="../repository/src/core/expressions.jl">src/core/expressions.jl</a>; <a href="../repository/test/real_analysis_integration.jl">test/real_analysis_integration.jl</a>; <a href="../repository/test/source_capture.jl">test/source_capture.jl</a></p>
```
