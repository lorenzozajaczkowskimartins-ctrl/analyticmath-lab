# Derivative evidence and multivariate calculus

Finite-difference discrepancy is not a certified true-error bound. Ordered scalar-field analysis accepts 1 through 32 variables: 32 passes the guard but does not guarantee affordable dense symbolic Hessians.

Read [API boundaries and evidence semantics](@ref api-boundaries) for the distinction between raw constructors, validated factories, exceptions, unknown claims and unrequested/partial diagnostics. Signatures are text, not runnable examples. Backend forwarding/context lines do not create public helper APIs.

```@raw html
<p>Repository resources: <a href="../repository/docs/tutorials/multivariate.md">docs/tutorials/multivariate.md</a>; <a href="../repository/docs/tutorials/scripts/multivariate.jl">docs/tutorials/scripts/multivariate.jl</a>; <a href="../repository/docs/vector_fields.md">docs/vector_fields.md</a>; <a href="../repository/reports/m10d6/tutorial_verification.json">reports/m10d6/tutorial_verification.json</a></p>
```

Overload map: [analyze](@ref dispatch-analyze).

Overload map: [evaluate](@ref dispatch-evaluate).

Overload map: [plot](@ref dispatch-plot).

```@raw html
<p>Repository resources: <a href="../repository/docs/tutorials/calculus.md">docs/tutorials/calculus.md</a>; <a href="../repository/docs/tutorials/scripts/calculus.jl">docs/tutorials/scripts/calculus.jl</a></p>
```

## [F05: Derivative evidence](@id family-F05)

<!-- aml-api: {"symbol": "compare_derivatives", "family": "F05", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [compare_derivatives](@id api-compare-derivatives)

**Identity:** generic function; F05; **PUBLIC_STABLE**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "90d1424a0c6389d0a5a9a80f1a87bf5da79b91cf4cf862d50524b72722e50f73"} -->
**Purpose and output:** DerivativeComparison(point,:symbolic, (symbolic,automatic,central), (automatic_error,central_error)).

**Source declarations and forwarding context:**

```text
compare_derivatives(report::FunctionAnalysis, x::Real)
```

**Inputs:** Reusable FunctionAnalysis and finite real point; caller ensures smooth neighborhood.

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** DomainError for nonfinite point/value/derivative; mathematical domain/backend derivative errors propagate.

**Numerical limitations:** FiniteDiff central default step, no h keyword. Point uses float(x), not unconditional Float64; smoothness/domain not proved. Errors are absolute discrepancies from evaluated symbolic reference.

**Units:** No automatic unit handling; x and h in caller coordinate scale, derivative errors in derivative scale, relative errors dimensionless.

**Ownership:** New result, input report unchanged; evaluates cached f and derivative plus ForwardDiff/FiniteDiff.

**Dependencies:** ForwardDiff; FiniteDiff.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: PRESENT_DETAILED. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/numerical.jl:70-90.

Inventory-listed candidate references (not a verified call graph or new execution): test/runtests.jl:180-200; test/m10a_calculus_dynamics.jl:23-41; notebooks/function_analysis.jl:13-15.

```@raw html
<p>Repository resources: <a href="../repository/notebooks/function_analysis.jl">notebooks/function_analysis.jl</a>; <a href="../repository/src/numerical.jl">src/numerical.jl</a>; <a href="../repository/test/m10a_calculus_dynamics.jl">test/m10a_calculus_dynamics.jl</a>; <a href="../repository/test/runtests.jl">test/runtests.jl</a></p>
```

<!-- aml-api: {"symbol": "derivative_convergence", "family": "F05", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [derivative_convergence](@id api-derivative-convergence)

**Identity:** generic function; F05; **PUBLIC_STABLE**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "8480376d863f5a85d30df5a466a10661b16d4e0b3967111723dbac842a7c5b1b"} -->
**Purpose and output:** DerivativeConvergenceAnalysis with decreasing log grid, approximations, absolute/relative discrepancies, first sampled minimum and optional stable-window observed order.

**Source declarations and forwarding context:**

```text
derivative_convergence(report::FunctionAnalysis, x::Real; method=:central, hmin::Real=1e-12, hmax::Real=1e-1, samples::Integer=45)
```

**Inputs:** Stored FunctionAnalysis and finite point, controls all converted to Float64; smooth stencil assumed.

**Keywords:**

| Scope | Keyword | Default / constraint |
|---|---|---|
| route | `method` | :central; :forward or :central |
| route | `hmin` | 1e-12; finite positive Float64-convertible |
| route | `hmax` | 1e-1; finite Float64-convertible, hmin<hmax |
| route | `samples` | 45; Integer >=3; generated steps must be strictly distinct |

**Failure and refusal:** ArgumentError for method/point/step controls, indistinguishable/nonfinite x±h, overflowed central 2h, or duplicate step grid. DomainError for nonfinite evaluated reference/stencil/arithmetic, or propagated domain failures; unsupported Float64 conversions may also fail.

**Numerical limitations:** Float64 only; no sample-count maximum other than caller resources. Relative error nothing for zero reference/overflow. First minimum ties favor larger h. Observed order only earliest three stable positive slopes (within10% mean) before first plateau/increase/zero; no later regime searched; sampled discrepancies not certified errors.

**Units:** No automatic unit handling; x and h in caller coordinate scale, derivative errors in derivative scale, relative errors dimensionless.

**Ownership:** New experiment-owned vectors, no source report/callable/backend retained; source unchanged.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: PRESENT_DETAILED. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/convergence.jl:36-97.

Inventory-listed candidate references (not a verified call graph or new execution): test/convergence.jl:6-159; test/m10a_calculus_dynamics.jl:23-58; notebooks/derivative_convergence.jl:7-18.

```@raw html
<p>Repository resources: <a href="../repository/notebooks/derivative_convergence.jl">notebooks/derivative_convergence.jl</a>; <a href="../repository/src/convergence.jl">src/convergence.jl</a>; <a href="../repository/test/convergence.jl">test/convergence.jl</a>; <a href="../repository/test/m10a_calculus_dynamics.jl">test/m10a_calculus_dynamics.jl</a></p>
```

<!-- aml-api: {"symbol": "DerivativeComparison", "family": "F05", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "type / constructors", "variant_count": 1} -->
## [DerivativeComparison](@id api-DerivativeComparison)

**Identity:** type / constructors; F05; **PUBLIC_STABLE**; explicitly exported.

**Stored fields:** `point`, `reference_method`, `values`, `absolute_errors`. Immutable outer record; referenced payloads may still be mutable. Obtain validated outputs through the operations described below; a raw record constructor does not itself certify scientific consistency.

<!-- aml-contract: {"variant": 0, "digest": "2a15adf53267030ce7b2a2655d804d786d054ff34a3663a5c85d8d7a0fa860eb"} -->
**Purpose and output:** Values named tuple(symbolic,automatic,central) and discrepancy tuple(automatic,central).

**Source declarations and forwarding context:**

```text
DerivativeComparison(point, reference_method, values, absolute_errors)
```

**Inputs:** Normally compare_derivatives(report,x); raw point/reference_method/values/absolute_errors.

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** Generated constructors enforce declared Julia field/type constraints, not mathematical validity; no general invariant-validation promise.

**Numerical limitations:** Discrepancies from evaluated symbolic reference, not certified errors; smooth sampled neighborhood assumed; convergence Float64, order empirical and optionally unavailable.

**Units:** No automatic unit handling; x and h in caller coordinate scale, derivative errors in derivative scale, relative errors dimensionless.

**Ownership:** Immutable outer record does not imply deep immutability; stored arrays/Expr are read-only by convention. Raw generated constructors generally retain supplied references and do not validate scientific invariants.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: PRESENT_DETAILED. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/analysis.jl:85.

Inventory-listed candidate references (not a verified call graph or new execution): test/runtests.jl:180-200; notebooks/derivative_convergence.jl:7-18.

```@raw html
<p>Repository resources: <a href="../repository/notebooks/derivative_convergence.jl">notebooks/derivative_convergence.jl</a>; <a href="../repository/src/analysis.jl">src/analysis.jl</a>; <a href="../repository/test/runtests.jl">test/runtests.jl</a></p>
```

<!-- aml-api: {"symbol": "DerivativeConvergenceAnalysis", "family": "F05", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "type / constructors", "variant_count": 1} -->
## [DerivativeConvergenceAnalysis](@id api-DerivativeConvergenceAnalysis)

**Identity:** type / constructors; F05; **PUBLIC_STABLE**; explicitly exported.

**Stored fields:** `expression`, `variable`, `point`, `method`, `reference`, `steps`, `approximations`, `absolute_errors`, `relative_errors`, `best_step`, `minimum_error`, `observed_order`, `order_indices`. Immutable outer record; referenced payloads may still be mutable. Obtain validated outputs through the operations described below; a raw record constructor does not itself certify scientific consistency.

<!-- aml-contract: {"variant": 0, "digest": "5065f3b90ee33e24a9b77b70a6d7ce8893e45e4d677ce60c333156fe61a4358c"} -->
**Purpose and output:** Float64 sampled steps/approximations/errors/minimum; relative entries and observed_order can be nothing; order_indices explicit.

**Source declarations and forwarding context:**

```text
DerivativeConvergenceAnalysis(expression, variable, point, method, reference, steps, approximations, absolute_errors, relative_errors, best_step, minimum_error, observed_order, order_indices)
```

**Inputs:** Normally derivative_convergence(report,x); stored raw fields including vectors and optional observed order.

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** Generated constructors enforce declared Julia field/type constraints, not mathematical validity; no general invariant-validation promise.

**Numerical limitations:** Discrepancies from evaluated symbolic reference, not certified errors; smooth sampled neighborhood assumed; convergence Float64, order empirical and optionally unavailable.

**Units:** No automatic unit handling; x and h in caller coordinate scale, derivative errors in derivative scale, relative errors dimensionless.

**Ownership:** Experiment-owned mutable vectors; source report/callables/backend not retained. Raw constructor borrows its arguments.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: PRESENT_DETAILED. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/convergence.jl:20.

Inventory-listed candidate references (not a verified call graph or new execution): test/convergence.jl:6-159; test/m10a_calculus_dynamics.jl:23-58; notebooks/derivative_convergence.jl:7-18.

```@raw html
<p>Repository resources: <a href="../repository/notebooks/derivative_convergence.jl">notebooks/derivative_convergence.jl</a>; <a href="../repository/src/convergence.jl">src/convergence.jl</a>; <a href="../repository/test/convergence.jl">test/convergence.jl</a>; <a href="../repository/test/m10a_calculus_dynamics.jl">test/m10a_calculus_dynamics.jl</a></p>
```

## [F06: Multivariate scalar fields](@id family-F06)

<!-- aml-api: {"symbol": "directional_derivative", "family": "F06", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [directional_derivative](@id api-directional-derivative)

**Identity:** generic function; F06; **PUBLIC_STABLE**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "3d6101d2ba059add782c2fbeb1fd9ffadd458d73654a4718182d4ba47bd30d6d"} -->
**Purpose and output:** Finite scalar dot(gradient(point), normalized_direction).

**Source declarations and forwarding context:**

```text
directional_derivative(report::ScalarFieldAnalysis, point, direction)
```

**Inputs:** Dimension-matching finite real point and nonzero tuple/vector direction; direction normalized using scale-safe norm.

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError for unsupported point container; DimensionMismatch for point/direction lengths or direction container; DomainError for invalid domain/smoothness, nonfinite or zero direction, or nonfinite derivative.

**Numerical limitations:** Normalizes direction rather than returning derivative scaled by its magnitude; sufficient smoothness gate, not general differentiability inference.

**Units:** Plain ordered numeric coordinates; no inferred physical units or nondimensionalization; residual norm/scale must be caller-consistent.

**Ownership:** Fresh normalization buffers; input arrays/report not mutated.

**Dependencies:** Symbolics; LinearAlgebra.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: ABSENT_ON_METHOD. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/multivariate_analysis.jl:345-357.

Inventory-listed candidate references (not a verified call graph or new execution): test/multivariate_analysis.jl:43-44; test/multivariate_regressions.jl:13-16; README.md:454-462.

```@raw html
<p>Repository resources: <a href="../repository/README.md">README.md</a>; <a href="../repository/src/multivariate_analysis.jl">src/multivariate_analysis.jl</a>; <a href="../repository/test/multivariate_analysis.jl">test/multivariate_analysis.jl</a>; <a href="../repository/test/multivariate_regressions.jl">test/multivariate_regressions.jl</a></p>
```

<!-- aml-api: {"symbol": "gradient", "family": "F06", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [gradient](@id api-gradient)

**Identity:** generic function; F06; **PUBLIC_STABLE**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "438be5051b1138aa960bef26ef29ca3df7739cd33ef63158e11827621dd552a8"} -->
**Purpose and output:** Formal copied gradient vector, or newly evaluated numeric vector ordered by variables.

**Source declarations and forwarding context:**

```text
gradient(report::ScalarFieldAnalysis)

gradient(report::ScalarFieldAnalysis, point::Union{Tuple,AbstractVector})
```

**Inputs:** Stored ScalarFieldAnalysis; optional finite real point with report.dimension coordinates.

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** DimensionMismatch for point length; DomainError for known exclusions, nonfinite inputs/results or unsupported open-smooth neighborhood; underlying callable failures propagate.

**Numerical limitations:** Formal derivatives do not certify smoothness. Numeric queries require sufficient supported open original-domain smoothness gate, rejecting canceled sqrt/abs corners and unknown domain. No repeated differentiation.

**Units:** Plain ordered numeric coordinates; no inferred physical units or nondimensionalization; residual norm/scale must be caller-consistent.

**Ownership:** Formal arrays copied, numerical arrays freshly allocated; stored report unchanged.

**Dependencies:** Symbolics.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: ABSENT_ON_METHODS. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/multivariate_analysis.jl:104-116.

Inventory-listed candidate references (not a verified call graph or new execution): test/multivariate_analysis.jl:5-77; test/multivariate_regressions.jl:4-51; README.md:454-462.

```@raw html
<p>Repository resources: <a href="../repository/README.md">README.md</a>; <a href="../repository/src/multivariate_analysis.jl">src/multivariate_analysis.jl</a>; <a href="../repository/test/multivariate_analysis.jl">test/multivariate_analysis.jl</a>; <a href="../repository/test/multivariate_regressions.jl">test/multivariate_regressions.jl</a></p>
```

<!-- aml-api: {"symbol": "hessian", "family": "F06", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [hessian](@id api-hessian)

**Identity:** generic function; F06; **PUBLIC_STABLE**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "984be4f02ddc3fa9aea5d31a3c48788d632affeb1eae867e32585229cabe5783"} -->
**Purpose and output:** Formal copied n×n Hessian, or newly evaluated n×n numeric matrix in variable order.

**Source declarations and forwarding context:**

```text
hessian(report::ScalarFieldAnalysis)

hessian(report::ScalarFieldAnalysis, point::Union{Tuple,AbstractVector})
```

**Inputs:** Stored ScalarFieldAnalysis; optional finite real point with report.dimension coordinates.

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** DimensionMismatch for point length; DomainError for known exclusions, nonfinite inputs/results or unsupported open-smooth neighborhood; underlying callable failures propagate.

**Numerical limitations:** Formal derivatives do not certify smoothness. Numeric queries require sufficient supported open original-domain smoothness gate, rejecting canceled sqrt/abs corners and unknown domain. No repeated differentiation.

**Units:** Plain ordered numeric coordinates; no inferred physical units or nondimensionalization; residual norm/scale must be caller-consistent.

**Ownership:** Formal arrays copied, numerical arrays freshly allocated; stored report unchanged.

**Dependencies:** Symbolics; LinearAlgebra.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: ABSENT_ON_METHODS. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/multivariate_analysis.jl:105-116.

Inventory-listed candidate references (not a verified call graph or new execution): test/multivariate_analysis.jl:5-77; test/multivariate_regressions.jl:4-51; README.md:454-462.

```@raw html
<p>Repository resources: <a href="../repository/README.md">README.md</a>; <a href="../repository/src/multivariate_analysis.jl">src/multivariate_analysis.jl</a>; <a href="../repository/test/multivariate_analysis.jl">test/multivariate_analysis.jl</a>; <a href="../repository/test/multivariate_regressions.jl">test/multivariate_regressions.jl</a></p>
```

<!-- aml-api: {"symbol": "levelset", "family": "F06", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [levelset](@id api-levelset)

**Identity:** generic function; F06; **PUBLIC_STABLE**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "68ed34faa0cca9b8538b1802bb8c55e5dfac0bb4064fa37783e6df5b027e7a53"} -->
**Purpose and output:** Symbolics.Equation report.expression ~ c.

**Source declarations and forwarding context:**

```text
levelset(report::ScalarFieldAnalysis, c::Real)
```

**Inputs:** Stored scalar field and finite numerical real level, not Symbolics.Num.

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError for symbolic level; DomainError for nonfinite level.

**Numerical limitations:** Implicit equation only; no solved curve/surface, original-domain attachment, emptiness or regularity certificate. Consumers must retain report.domain separately.

**Units:** Plain ordered numeric coordinates; no inferred physical units or nondimensionalization; residual norm/scale must be caller-consistent.

**Ownership:** New equation, references symbolic report expression; no report mutation.

**Dependencies:** Symbolics.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: ABSENT_ON_METHOD. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/multivariate_analysis.jl:366-370.

Inventory-listed candidate references (not a verified call graph or new execution): test/multivariate_analysis.jl:50-52; test/multivariate_regressions.jl:47; README.md:454-462.

```@raw html
<p>Repository resources: <a href="../repository/README.md">README.md</a>; <a href="../repository/src/multivariate_analysis.jl">src/multivariate_analysis.jl</a>; <a href="../repository/test/multivariate_analysis.jl">test/multivariate_analysis.jl</a>; <a href="../repository/test/multivariate_regressions.jl">test/multivariate_regressions.jl</a></p>
```

<!-- aml-api: {"symbol": "linearization", "family": "F06", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [linearization](@id api-linearization)

**Identity:** generic function; F06; **PUBLIC_STABLE**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "77c4a91a6d38076dc410ccba4d317fea6e2e39157321c3cd895b8fcabdd76142"} -->
**Purpose and output:** Named tuple(expression,base_point,value,coefficients); scalar affine expression and gradient vector, or m expressions and m×n Jacobian.

**Source declarations and forwarding context:**

```text
linearization(report::ScalarFieldAnalysis, point)

linearization(report::VectorFieldAnalysis, point::Union{Tuple,AbstractVector})

linearization(r::DynamicalSystemAnalysis, p::Union{Tuple,AbstractVector})
```

**Inputs:** Stored scalar/vector/dynamical report, ordered point in a supported open smooth neighborhood.

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError for scalar unsupported point container; DimensionMismatch for point length; DomainError for domain/smoothness/nonfinite failures; cached backend errors may propagate.

**Numerical limitations:** Local first-order affine map, no nonlinear stability/remainder/error bound; not mechanical second-order linearization.

**Units:** Plain ordered numeric coordinates; no inferred physical units or nondimensionalization; residual norm/scale must be caller-consistent.

**Ownership:** Collects base-point copy, fresh values/coefficients/expression; dynamical route delegates to identical field.

**Dependencies:** Symbolics.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: ABSENT_ON_METHODS. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/multivariate_analysis.jl:359-364; src/vector_fields/calculus.jl:103-108; src/dynamical_systems/analysis.jl:61.

Inventory-listed candidate references (not a verified call graph or new execution): test/multivariate_analysis.jl:45-49; test/vector_calculus.jl:37-43; README.md:454-462.

```@raw html
<p>Repository resources: <a href="../repository/README.md">README.md</a>; <a href="../repository/src/dynamical_systems/analysis.jl">src/dynamical_systems/analysis.jl</a>; <a href="../repository/src/multivariate_analysis.jl">src/multivariate_analysis.jl</a>; <a href="../repository/src/vector_fields/calculus.jl">src/vector_fields/calculus.jl</a>; <a href="../repository/test/multivariate_analysis.jl">test/multivariate_analysis.jl</a>; <a href="../repository/test/vector_calculus.jl">test/vector_calculus.jl</a></p>
```

<!-- aml-api: {"symbol": "MultivariateDomain", "family": "F06", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "type / constructors", "variant_count": 1} -->
## [MultivariateDomain](@id api-MultivariateDomain)

**Identity:** type / constructors; F06; **PUBLIC_STABLE**; explicitly exported.

**Stored fields:** `restrictions`, `variables`, `status`, `method`, `notes`. Immutable outer record; referenced payloads may still be mutable. Obtain validated outputs through the operations described below; a raw record constructor does not itself certify scientific consistency.

<!-- aml-contract: {"variant": 0, "digest": "42d188ae870cdd6e0dc046221ea2f2ed449fba07aed898bef6fc5dcd38b9008d"} -->
**Purpose and output:** Original-syntax evaluable constraints; membership can be true/false/nothing.

**Source declarations and forwarding context:**

```text
MultivariateDomain(restrictions, variables, status, method, notes)
```

**Inputs:** Normally obtained through scalar/vector analyze; restrictions, ordered variables, status, method, notes.

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** Generated constructors enforce declared Julia field/type constraints, not mathematical validity; no general invariant-validation promise.

**Numerical limitations:** 1–32 ordered variables; exact stationary completeness only nonsingular rational affine-gradient/separable polynomial classes. Bounded multistart Newton heuristic; exact Cartesian4096/grid50000 limits; sufficient original-domain open-smoothness gate.

**Units:** Plain ordered numeric coordinates; no inferred physical units or nondimensionalization; residual norm/scale must be caller-consistent.

**Ownership:** Immutable outer record does not imply deep immutability; stored arrays/Expr are read-only by convention. Raw generated constructors generally retain supplied references and do not validate scientific invariants.

**Dependencies:** Symbolics.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: PRESENT_BRIEF. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/multivariate_domain.jl:8.

Inventory-listed candidate references (not a verified call graph or new execution): test/multivariate_analysis.jl:59-74; test/multivariate_regressions.jl:4-24; README.md:454-462.

```@raw html
<p>Repository resources: <a href="../repository/README.md">README.md</a>; <a href="../repository/src/multivariate_domain.jl">src/multivariate_domain.jl</a>; <a href="../repository/test/multivariate_analysis.jl">test/multivariate_analysis.jl</a>; <a href="../repository/test/multivariate_regressions.jl">test/multivariate_regressions.jl</a></p>
```

<!-- aml-api: {"symbol": "ScalarFieldAnalysis", "family": "F06", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "type / constructors", "variant_count": 1} -->
## [ScalarFieldAnalysis](@id api-ScalarFieldAnalysis)

**Identity:** type / constructors; F06; **PUBLIC_STABLE**; explicitly exported.

**Stored fields:** `expression`, `original_expression`, `variables`, `dimension`, `gradient_expression`, `hessian_expression`, `numerical`, `domain`, `stationary_points`. Immutable outer record; referenced payloads may still be mutable. Obtain validated outputs through the operations described below; a raw record constructor does not itself certify scientific consistency.

<!-- aml-contract: {"variant": 0, "digest": "8fcfc45ff577fe3cbe918458404b13b336958e5b28a46cde7b827be7f6a8ab23"} -->
**Purpose and output:** Cached gradient/Hessian and numerical callables, original domain and stationary-point evidence.

**Source declarations and forwarding context:**

```text
ScalarFieldAnalysis(expression, original_expression, variables, dimension, gradient_expression, hessian_expression, numerical, domain, stationary_points)
```

**Inputs:** Normally analyze(scalar, ordered tuple/vector of Symbolics variables); raw stored-field constructor also available.

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** Generated constructors enforce declared Julia field/type constraints, not mathematical validity; no general invariant-validation promise.

**Numerical limitations:** 1–32 ordered variables; exact stationary completeness only nonsingular rational affine-gradient/separable polynomial classes. Bounded multistart Newton heuristic; exact Cartesian4096/grid50000 limits; sufficient original-domain open-smoothness gate.

**Units:** Plain ordered numeric coordinates; no inferred physical units or nondimensionalization; residual norm/scale must be caller-consistent.

**Ownership:** Immutable outer record does not imply deep immutability; stored arrays/Expr are read-only by convention. Raw generated constructors generally retain supplied references and do not validate scientific invariants.

**Dependencies:** Symbolics.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: PRESENT_BRIEF. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/multivariate_analysis.jl:21.

Inventory-listed candidate references (not a verified call graph or new execution): test/multivariate_analysis.jl:5-77; test/multivariate_regressions.jl:4-51; README.md:454-462.

```@raw html
<p>Repository resources: <a href="../repository/README.md">README.md</a>; <a href="../repository/src/multivariate_analysis.jl">src/multivariate_analysis.jl</a>; <a href="../repository/test/multivariate_analysis.jl">test/multivariate_analysis.jl</a>; <a href="../repository/test/multivariate_regressions.jl">test/multivariate_regressions.jl</a></p>
```

<!-- aml-api: {"symbol": "StationaryPoint", "family": "F06", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "type / constructors", "variant_count": 1} -->
## [StationaryPoint](@id api-StationaryPoint)

**Identity:** type / constructors; F06; **PUBLIC_STABLE**; explicitly exported.

**Stored fields:** `point`, `value`, `residual_norm`, `residual_threshold`, `hessian`, `eigenvalues`, `classification`, `classification_evidence`. Immutable outer record; referenced payloads may still be mutable. Obtain validated outputs through the operations described below; a raw record constructor does not itself certify scientific consistency.

<!-- aml-contract: {"variant": 0, "digest": "333324a57547b1cc7d6521a98735cf4d8b81d6f55c11bff02ef2b25226fc67dd"} -->
**Purpose and output:** Candidate point/value/residual+threshold/Hessian/eigenvalues/classification with separately scoped classification_evidence.

**Source declarations and forwarding context:**

```text
StationaryPoint(point, value, residual_norm, residual_threshold, hessian, eigenvalues, classification, classification_evidence)
```

**Inputs:** Raw positional fields in declaration order: point, value, residual_norm, residual_threshold, hessian, eigenvalues, classification, classification_evidence. Prefer the documented factory where applicable.

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** Generated constructors enforce declared Julia field/type constraints, not mathematical validity; no general invariant-validation promise.

**Numerical limitations:** Point acceptance does not alone prove exactness or completeness; inspect enclosing stationary_points and classification_evidence independently.

**Units:** Plain ordered numeric coordinates; no inferred physical units or nondimensionalization; residual norm/scale must be caller-consistent.

**Ownership:** Immutable outer record does not imply deep immutability; stored arrays/Expr are read-only by convention. Raw generated constructors generally retain supplied references and do not validate scientific invariants.

**Dependencies:** Symbolics.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: PRESENT_BRIEF. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/multivariate_analysis.jl:3.

Inventory-listed candidate references (not a verified call graph or new execution): test/multivariate_analysis.jl:21-41; test/multivariate_regressions.jl:25-51; README.md:454-462.

```@raw html
<p>Repository resources: <a href="../repository/README.md">README.md</a>; <a href="../repository/src/multivariate_analysis.jl">src/multivariate_analysis.jl</a>; <a href="../repository/test/multivariate_analysis.jl">test/multivariate_analysis.jl</a>; <a href="../repository/test/multivariate_regressions.jl">test/multivariate_regressions.jl</a></p>
```
