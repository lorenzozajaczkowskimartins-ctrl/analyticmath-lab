# Scalar analysis and real domains

A scalar expression and one Symbolics variable produce univariate analysis. Domain evidence describes original syntax, while numerical evaluation has its own contract. Interval-restricted stationary search is heuristic and may be unrequested.

Read [API boundaries and evidence semantics](@ref api-boundaries) for the distinction between raw constructors, validated factories, exceptions, unknown claims and unrequested/partial diagnostics. Signatures are text, not runnable examples. Backend forwarding/context lines do not create public helper APIs.

```@raw html
<p>Repository resources: <a href="../repository/docs/m10d_provenance.md">docs/m10d_provenance.md</a>; <a href="../repository/docs/tutorials/calculus.md">docs/tutorials/calculus.md</a>; <a href="../repository/docs/tutorials/scripts/calculus.jl">docs/tutorials/scripts/calculus.jl</a>; <a href="../repository/reports/m10d6/tutorial_verification.json">reports/m10d6/tutorial_verification.json</a></p>
```

Overload map: [plot](@ref dispatch-plot).

## [analyze overloads](@id dispatch-analyze)

<!-- aml-dispatch: {"symbol": "analyze", "variants": 5} -->
### analyze: dispatch-oriented map

| Input contract | Supported signature | Result | Dependencies | Scientific contract | Destination |
|---|---|---|---|---|---|
| Scalar/captured expression and one Num | `analyze(expression::Real, variable::Symbolics.Num; interval=nothing, residual_tolerance::Real=1e-8, residual_rtol::Real=0, residual_scale::Real=1, original_expression=expression)` | FunctionAnalysis | Symbolics, Roots, LinearAlgebra | Route-specific status, numerical and ownership contract below | [primary contract](@ref api-analyze); [family](@ref family-F03) |
| Scalar/captured expression and one Num | `analyze(captured::RealExpression, variable::Symbolics.Num; kwargs...)` | FunctionAnalysis | Symbolics, Roots, LinearAlgebra | Route-specific status, numerical and ownership contract below | [primary contract](@ref api-analyze); [family](@ref family-F03) |
| Scalar/captured expression and ordered 1–32 variables | `analyze(expression::Real, variables::Union{Tuple,AbstractVector}; bounds=nothing, grid::Integer=7, iterations::Integer=40, residual_tolerance::Real=1e-8, residual_rtol::Real=0, residual_scale::Real=1, classification_atol::Real=1e-10, classification_rtol::Real=1e-8, original_expression=expression)` | ScalarFieldAnalysis | Symbolics, Roots, LinearAlgebra | Route-specific status, numerical and ownership contract below | [primary contract](@ref api-analyze); [family](@ref family-F06) |
| Scalar/captured expression and ordered 1–32 variables | `analyze(captured::RealExpression, variables::Union{Tuple,AbstractVector}; kwargs...)` | ScalarFieldAnalysis | Symbolics, Roots, LinearAlgebra | Route-specific status, numerical and ownership contract below | [primary contract](@ref api-analyze); [family](@ref family-F06) |
| Ordered vector components and variables | `analyze(components::Union{AbstractVector,Tuple}, variables::Union{Tuple,AbstractVector}; original_expression=components, bounds=nothing, grid::Integer=7, iterations::Integer=40, residual_tolerance::Real=1e-8, residual_rtol::Real=0, residual_scale::Real=1)` | VectorFieldAnalysis | Symbolics, Roots, LinearAlgebra | Route-specific status, numerical and ownership contract below | [primary contract](@ref api-analyze); [family](@ref family-F07) |
| AutonomousSystem | `analyze(system::AutonomousSystem; classification_atol::Real=1e-10, classification_rtol::Real=1e-8)` | DynamicalSystemAnalysis | Symbolics, Roots, LinearAlgebra | Route-specific status, numerical and ownership contract below | [primary contract](@ref api-analyze); [family](@ref family-F08) |
| LagrangianSystem | `function analyze(s::LagrangianSystem)` | LagrangianAnalysis | Core | Route-specific status, numerical and ownership contract below | [primary contract](@ref api-analyze); [family](@ref family-F10) |
| HamiltonianSystem | `function analyze(s::HamiltonianSystem)` | HamiltonianAnalysis | Core | Route-specific status, numerical and ownership contract below | [primary contract](@ref api-analyze); [family](@ref family-F11) |
| AtomisticTrajectoryView | `function analyze(t::AtomisticTrajectoryView;observables=(),series=NamedTuple(),correlations=(), window=nothing,maxlag=min(max(length(t)-1,0),128),transients=false, msd=false,vacf=false,fit_window=nothing,transport_options=NamedTuple(), observable_options=NamedTuple(),time_options=NamedTuple())` | MDTrajectoryAnalysis | Core | Route-specific status, numerical and ownership contract below | [primary contract](@ref api-analyze); [family](@ref family-F24) |
| PINNTrainingResult | `analyze(r::PINNTrainingResult;kwargs...)=_pinn_extension().analyze_pinn(r;kwargs...)` | PINNAnalysis (experimental) | Lux, NeuralPDE, ModelingToolkit, Optimization, SymbolicIndexingInterface | Route-specific status, numerical and ownership contract below | [primary contract](@ref api-analyze); [family](@ref family-F27) |
| ScientificLearningResult | `function analyze(r::ScientificLearningResult;physics=nothing,timing=nothing,relative_floor=1e-12)` | GeneralizationAnalysis (experimental) | Lux, Optimization, NeuralOperators | Route-specific status, numerical and ownership contract below | [primary contract](@ref api-analyze); [family](@ref family-F34) |

## [evaluate overloads](@id dispatch-evaluate)

<!-- aml-dispatch: {"symbol": "evaluate", "variants": 2} -->
### evaluate: dispatch-oriented map

| Input contract | Supported signature | Result | Dependencies | Scientific contract | Destination |
|---|---|---|---|---|---|
| FunctionAnalysis plus ordered point | `evaluate(report::FunctionAnalysis, x::Number; order::Integer=0)` | scalar value or derivative (order 0/1/2) | Symbolics | Route-specific status, numerical and ownership contract below | [primary contract](@ref api-evaluate); [family](@ref family-F03) |
| ScalarFieldAnalysis plus ordered point | `evaluate(report::ScalarFieldAnalysis, point::Union{Tuple,AbstractVector})` | scalar value | Symbolics | Route-specific status, numerical and ownership contract below | [primary contract](@ref api-evaluate); [family](@ref family-F06) |
| VectorFieldAnalysis plus ordered point | `evaluate(report::VectorFieldAnalysis, point::Union{Tuple,AbstractVector})` | ordered component vector | Symbolics | Route-specific status, numerical and ownership contract below | [primary contract](@ref api-evaluate); [family](@ref family-F07) |
| DynamicalSystemAnalysis plus ordered point | `evaluate(r::DynamicalSystemAnalysis, p::Union{Tuple,AbstractVector})` | ordered vector-field value | Symbolics | Route-specific status, numerical and ownership contract below | [primary contract](@ref api-evaluate); [family](@ref family-F08) |
| PotentialAnalysis plus ordered point | `function evaluate(report::PotentialAnalysis, r::Real; order::Integer=0)` | radial value or derivative | Core | Route-specific status, numerical and ownership contract below | [primary contract](@ref api-evaluate); [family](@ref family-F17) |

## [F03: Scalar function analysis](@id family-F03)

<!-- aml-api: {"symbol": "analyze", "family": "F03", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 5} -->
## [analyze](@id api-analyze)

**Identity:** generic function; F03; **PUBLIC_STABLE**; explicitly exported.

**Interpretation:** One-element variable collections still select the scalar-field route. Shared stable name classification does not make PINN/learning payload contracts stable. Bounds omitted means a search may be unrequested, not a proof that no stationary points exist.

<!-- aml-contract: {"variant": 0, "digest": "dedf0ee003edf4c151c11e28563d054afd864931e992a83c52848cc1f0cd49c6"} -->
### Dispatch contract 1

**Purpose and output:** FunctionAnalysis / ScalarFieldAnalysis / VectorFieldAnalysis / DynamicalSystemAnalysis according to dispatch. One-element variable collection still selects multivariate API.

**Source declarations and forwarding context:**

```text
analyze(expression::Real, variable::Symbolics.Num; interval=nothing, residual_tolerance::Real=1e-8, residual_rtol::Real=0, residual_scale::Real=1, original_expression=expression)

analyze(captured::RealExpression, variable::Symbolics.Num; kwargs...)

analyze(expression::Real, variables::Union{Tuple,AbstractVector}; bounds=nothing, grid::Integer=7, iterations::Integer=40, residual_tolerance::Real=1e-8, residual_rtol::Real=0, residual_scale::Real=1, classification_atol::Real=1e-10, classification_rtol::Real=1e-8, original_expression=expression)

analyze(captured::RealExpression, variables::Union{Tuple,AbstractVector}; kwargs...)

analyze(components::Union{AbstractVector,Tuple}, variables::Union{Tuple,AbstractVector}; original_expression=components, bounds=nothing, grid::Integer=7, iterations::Integer=40, residual_tolerance::Real=1e-8, residual_rtol::Real=0, residual_scale::Real=1)

analyze(system::AutonomousSystem; classification_atol::Real=1e-10, classification_rtol::Real=1e-8)
```

**Inputs:** Scalar expression/constant plus one Num -> univariate; scalar plus ordered 1–32 distinct Symbolics variables -> scalar field; 1–32 components plus variables -> vector map; captured wrapper dispatches by evaluated payload. No unbound parameters. AutonomousSystem -> structural reuse.

**Keywords:**

| Scope | Keyword | Default / constraint |
|---|---|---|
| univariate | `interval` | nothing; finite increasing Tuple{Real,Real} for legacy stationary search |
| univariate | `residual_tolerance` | 1e-8; finite positive Real |
| univariate | `residual_rtol` | 0; finite nonnegative Real |
| univariate | `residual_scale` | 1; finite positive Real; effective threshold must remain finite |
| univariate | `original_expression` | expression; trusted matching original syntax |
| scalar_field | `bounds` | nothing; one finite increasing Tuple pair per ordered variable |
| scalar_field | `grid` | 7; Integer in 2:25; grid^dimension <= 50000 when bounds supplied |
| scalar_field | `iterations` | 40; Integer in 1:200 |
| scalar_field | `residual_tolerance` | 1e-8; finite positive Real |
| scalar_field | `residual_rtol` | 0; finite nonnegative Real |
| scalar_field | `residual_scale` | 1; finite positive Real; effective threshold must remain finite |
| scalar_field | `classification_atol` | 1e-10; finite nonnegative Real |
| scalar_field | `classification_rtol` | 1e-8; finite nonnegative Real |
| scalar_field | `original_expression` | expression |
| vector_field | `bounds` | nothing; one finite increasing Tuple pair per ordered variable |
| vector_field | `grid` | 7; Integer in 2:25; grid^dimension <= 50000 when bounds supplied |
| vector_field | `iterations` | 40; Integer in 1:200 |
| vector_field | `residual_tolerance` | 1e-8; finite positive Real |
| vector_field | `residual_rtol` | 0; finite nonnegative Real |
| vector_field | `residual_scale` | 1; finite positive Real; effective threshold must remain finite |
| vector_field | `original_expression` | components; matching syntax per component |
| route | `captured` | kwargs forwarded with original_expression=captured.original; do not also supply original_expression |
| autonomous | `classification_atol` | 1e-10; finite nonnegative Real |
| autonomous | `classification_rtol` | 1e-8; finite nonnegative Real |

**Failure and refusal:** ArgumentError for invalid symbolic variables, unbound parameters, size/controls/bounds/resource grid; conversion/dispatch errors for unsupported types. DomainError/nonfinite evaluation or underlying Symbolics/Roots failure can propagate; budgeted exact inference returns unknown/resource_budget, not a global runtime sandbox.

**Numerical limitations:** Numerical search Float64, heuristic and smooth-interval assumption; residual is not a root-position bound. Numerical evaluation does not enforce real_analysis domain. Exact rational polynomial/factorization class, outer sqrt/log and sin(variable); irrational unresolved roots remain unknown. Degree64/bits4096/work200000/AST512/depth48 budgets; interval only enables heuristic roots, not domain truncation. 1–32 ordered variables; exact stationary completeness only nonsingular rational affine-gradient/separable polynomial classes. Bounded multistart Newton heuristic; exact Cartesian4096/grid50000 limits; sufficient original-domain open-smoothness gate. Independent input/output dimensions1–32; exact square affine/separable zeros only. Rectangular numerical least-squares candidate steps still require residual acceptance. Zero curl alone never proves global potential. Square autonomous fields; inherited zero evidence. Local stability only; exact rational diagonal/planar tests, diagnostic Float64 eigenspectrum; nonhyperbolic nonlinear center not inferred.

**Units:** No universal physical unit schema. Ordered coordinates/components preserved; residual scales caller-consistent; tolerance formula absolute+relative*scale. Float64 searches/classification are not general Unitful paths.

**Ownership:** Fresh reports/cached callables; inputs/report payloads generally read-only by convention. Vector originals are deep-copied; scalar original syntax retained. Autonomous analysis retains identical field/domain, copies candidate point/value/notes.

**Dependencies:** Symbolics; Roots; LinearAlgebra.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: PARTIAL_UNIVARIATE_DETAILED_OTHER_ANALYZE_METHODS_UNDOCUMENTED. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/symbolic.jl:1-51; src/multivariate_analysis.jl:283-343; src/vector_fields/analysis.jl:42-71; src/dynamical_systems/analysis.jl:34-49.

Inventory-listed candidate references (not a verified call graph or new execution): test/runtests.jl:15-178; test/real_analysis_integration.jl:5-39; notebooks/function_analysis.jl:7-15.

```@raw html
<p>Repository resources: <a href="../repository/notebooks/function_analysis.jl">notebooks/function_analysis.jl</a>; <a href="../repository/src/dynamical_systems/analysis.jl">src/dynamical_systems/analysis.jl</a>; <a href="../repository/src/multivariate_analysis.jl">src/multivariate_analysis.jl</a>; <a href="../repository/src/symbolic.jl">src/symbolic.jl</a>; <a href="../repository/src/vector_fields/analysis.jl">src/vector_fields/analysis.jl</a>; <a href="../repository/test/real_analysis_integration.jl">test/real_analysis_integration.jl</a>; <a href="../repository/test/runtests.jl">test/runtests.jl</a></p>
```

<!-- aml-contract: {"variant": 1, "digest": "26060f5524889db3c62e51823bd6d3a0c6c6b8d6530ffb1ac6c4b5e0dbe37b20"} -->
### Dispatch contract 2

**Purpose and output:** LagrangianAnalysis or HamiltonianAnalysis

**Source declarations and forwarding context:**

```text
function analyze(s::LagrangianSystem)

function analyze(s::HamiltonianSystem)
```

**Inputs:** LagrangianSystem or HamiltonianSystem

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** Keyword factories validate ordered distinct scalar symbolic names and equal conjugate dimensions; DimensionMismatch/ArgumentError for contradictory parameter/nonzero/force declarations. Raw positional constructors do not validate scientific invariants.

**Numerical limitations:** Formal smooth-original-locus identities under explicit finite parameter/nonzero assumptions; no global dynamics proof. Nonzero is not positive. No general symbolic work/RAM budget for mechanics determinant/adjugate operations.

**Units:** Caller-managed physical units/coordinate ordering; symbolic identities do not infer positivity or dimensions.

**Ownership:** Retains source/system/domain; fresh derivative/equation arrays.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: ABSENT for these analyze methods. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/mechanics/core.jl:172; src/mechanics/hamiltonian.jl:40.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:65; test/architecture.jl:112; examples/inference/m10a_gate.jl:9.

```@raw html
<p>Repository resources: <a href="../repository/examples/inference/m10a_gate.jl">examples/inference/m10a_gate.jl</a>; <a href="../repository/src/mechanics/core.jl">src/mechanics/core.jl</a>; <a href="../repository/src/mechanics/hamiltonian.jl">src/mechanics/hamiltonian.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a></p>
```

<!-- aml-contract: {"variant": 2, "digest": "4aabb9fa9018de81674cbb70dd4657b504f117c2e9b675592bdaae898465f3f3"} -->
### Dispatch contract 3

**Purpose and output:** MDTrajectoryAnalysis

**Source declarations and forwarding context:**

```text
function analyze(t::AtomisticTrajectoryView;observables=(),series=NamedTuple(),correlations=(),
window=nothing,maxlag=min(max(length(t)-1,0),128),transients=false,
msd=false,vacf=false,fit_window=nothing,transport_options=NamedTuple(),
observable_options=NamedTuple(),time_options=NamedTuple())
```

**Inputs:** AtomisticTrajectoryView; explicit observables/series/correlations and opt-ins

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError wrong series or mismatched times; DimensionMismatch count; requested routines errors propagate

**Numerical limitations:** No burn-in/score; transport_options forwarded to MSD only. VACF call does not forward fixed_particles/species/transport_options; relies on view provenance to assert order.

**Units:** Compatible Unitful arithmetic preserved; units unknown for plain values; variance/covariance squared units. Time spacing does not infer simulation dt.

**Ownership:** Borrowed supplied series, requested history routines materialize scalar/velocity data.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: TYPE attached doc; method not separate. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/trajectory/analyst.jl:101.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:65; test/architecture.jl:112; examples/inference/m10a_gate.jl:9.

```@raw html
<p>Repository resources: <a href="../repository/examples/inference/m10a_gate.jl">examples/inference/m10a_gate.jl</a>; <a href="../repository/src/trajectory/analyst.jl">src/trajectory/analyst.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a></p>
```

<!-- aml-contract: {"variant": 3, "digest": "92c335fdc5a0cc59c2cd00943717c693611557ebbb341d3345966dd1794ed4b2"} -->
### Dispatch contract 4

**Purpose and output:** PINNAnalysis

**Source declarations and forwarding context:**

```text
analyze(r::PINNTrainingResult;kwargs...)=_pinn_extension().analyze_pinn(r;kwargs...)

Backend controls: function analyze_pinn(r::AML.PINNTrainingResult;residual_points=Dict(),condition_roles=Dict(),
reference=nothing,reference_points=nothing,
reference_provenance=(kind=:user_supplied_unknown_trust,),relative_guard=1e-12,
provenance=NamedTuple())
```

**Inputs:** PINNTrainingResult; residual_points Dict block-index→PINNPoints, condition_roles, reference/reference_points/provenance,relative_guard=1e-12

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError invalid block/BC role/integral block/coordinate names/nonfinite ref/guard; DimensionMismatch coords/residual/ref outputs

**Numerical limitations:** Public core wrapper delegates analyze_pinn. Signed backend sampled residual, fixed collocation batch padding, no continuum bound/training-set independence. BC vs IC requires caller role. Reference callable trust asserted; relative unavailable under guard; adaptive weight evolution unsupported.

**Units:** No implicit physical units conversion; PINN diagnostics Float64 samples; learned dynamics uses backend numeric AD, prediction public Float64.

**Ownership:** Retains training and points; new residual/collocation/reference arrays; public route stores full residual values, private summary_only is not public option.

**Dependencies:** Lux; NeuralPDE; ModelingToolkit; Optimization; SymbolicIndexingInterface.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: Core forwarding only. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/scientific_ml/diagnostics.jl:66.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:65; test/architecture.jl:112; examples/inference/m10a_gate.jl:9.

```@raw html
<p>Repository resources: <a href="../repository/examples/inference/m10a_gate.jl">examples/inference/m10a_gate.jl</a>; <a href="../repository/src/scientific_ml/diagnostics.jl">src/scientific_ml/diagnostics.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a></p>
```

<!-- aml-contract: {"variant": 4, "digest": "e14a08968aba40e83a4b9e86df2dec2d5d3c27c33663231bc805faf549c5f58b"} -->
### Dispatch contract 5

**Purpose and output:** GeneralizationAnalysis

**Source declarations and forwarding context:**

```text
function analyze(r::ScientificLearningResult;physics=nothing,timing=nothing,relative_floor=1e-12)
```

**Inputs:** ScientificLearningResult; physics=nothing,timing=nothing,relative_floor=1e-12

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** Prediction/query/field-errors failures propagate

**Numerical limitations:** Per-split unweighted target aggregation; per-coordinate RMS only identical grids; physics/timing retained caller data not automatically measured.

**Units:** Checked Float64 sample/scaling coordinates; units metadata never converts numbers. field_errors/AD use supported value promotion, not universal precision.

**Ownership:** Materializes each case predictions/full errors and pooled split arrays.

**Dependencies:** Lux; Optimization; NeuralOperators.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: ABSENT method. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/scientific_ml/generalization.jl:12.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:65; test/architecture.jl:112; examples/inference/m10a_gate.jl:9.

```@raw html
<p>Repository resources: <a href="../repository/examples/inference/m10a_gate.jl">examples/inference/m10a_gate.jl</a>; <a href="../repository/src/scientific_ml/generalization.jl">src/scientific_ml/generalization.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a></p>
```

<!-- aml-api: {"symbol": "CriticalPoint", "family": "F03", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "type / constructors", "variant_count": 1} -->
## [CriticalPoint](@id api-CriticalPoint)

**Identity:** type / constructors; F03; **PUBLIC_STABLE**; explicitly exported.

**Stored fields:** `x`, `value`, `residual`, `second_derivative`, `classification`. Immutable outer record; referenced payloads may still be mutable. Obtain validated outputs through the operations described below; a raw record constructor does not itself certify scientific consistency.

<!-- aml-contract: {"variant": 0, "digest": "38514bd091a68cc6d2a2d448b8e8f2436c69d86502d6daaadd0d3d2524be8fb5"} -->
**Purpose and output:** Numerical stationary candidate (library factory stores Float64); not certified extrema.

**Source declarations and forwarding context:**

```text
CriticalPoint(x, value, residual, second_derivative, classification)
```

**Inputs:** x, value, residual, second_derivative of one T<:Real; classification::Symbol.

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** Generated constructors enforce declared Julia field/type constraints, not mathematical validity; no general invariant-validation promise.

**Numerical limitations:** Numerical search Float64, heuristic and smooth-interval assumption; residual is not a root-position bound. Numerical evaluation does not enforce real_analysis domain.

**Units:** No unit schema; caller supplies residual scale in first-derivative units, relative tolerance dimensionless; no automatic Unitful conversion.

**Ownership:** Immutable outer record does not imply deep immutability; stored arrays/Expr are read-only by convention. Raw generated constructors generally retain supplied references and do not validate scientific invariants.

**Dependencies:** Symbolics.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: PRESENT_BRIEF. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/analysis.jl:23.

Inventory-listed candidate references (not a verified call graph or new execution): test/runtests.jl:74-101; notebooks/function_analysis.jl:7-15.

```@raw html
<p>Repository resources: <a href="../repository/notebooks/function_analysis.jl">notebooks/function_analysis.jl</a>; <a href="../repository/src/analysis.jl">src/analysis.jl</a>; <a href="../repository/test/runtests.jl">test/runtests.jl</a></p>
```

<!-- aml-api: {"symbol": "CriticalPointAnalysis", "family": "F03", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "type / constructors", "variant_count": 1} -->
## [CriticalPointAnalysis](@id api-CriticalPointAnalysis)

**Identity:** type / constructors; F03; **PUBLIC_STABLE**; explicitly exported.

**Stored fields:** `points`, `interval`, `status`, `method`, `residual_tolerance`, `rejected_candidates`, `residual_relative_tolerance`, `residual_scale`, `effective_residual_tolerance`, `rejections`. Immutable outer record; referenced payloads may still be mutable. Obtain validated outputs through the operations described below; a raw record constructor does not itself certify scientific consistency.

<!-- aml-contract: {"variant": 0, "digest": "1c6ad8bcd06e21f09e2f16a6d189befc9f961ffe44e09e908b517b28d8e58b2a"} -->
**Purpose and output:** Search status, interval, accepted Float64 candidates, rejected records/count and absolute+relative scale threshold.

**Source declarations and forwarding context:**

```text
CriticalPointAnalysis(points, interval, status, method, residual_tolerance, rejected_candidates, residual_relative_tolerance, residual_scale, effective_residual_tolerance, rejections)

CriticalPointAnalysis(points, interval, status, method, tolerance, rejected)

CriticalPointAnalysis{I}(points, interval, status, method, tolerance, rejected) where {I}
```

**Inputs:** Factory-produced bounded search data or legacy six-argument constructor; legacy nonzero rejection count has rejections=nothing.

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** Generated constructors enforce declared Julia field/type constraints, not mathematical validity; no general invariant-validation promise.

**Numerical limitations:** Numerical search Float64, heuristic and smooth-interval assumption; residual is not a root-position bound. Numerical evaluation does not enforce real_analysis domain.

**Units:** No unit schema; caller supplies residual scale in first-derivative units, relative tolerance dimensionless; no automatic Unitful conversion.

**Ownership:** Immutable outer record does not imply deep immutability; stored arrays/Expr are read-only by convention. Raw generated constructors generally retain supplied references and do not validate scientific invariants.

**Dependencies:** Symbolics.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: PRESENT_DETAILED. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/analysis.jl:31-76.

Inventory-listed candidate references (not a verified call graph or new execution): test/runtests.jl:104-178; notebooks/function_analysis.jl:7-15.

```@raw html
<p>Repository resources: <a href="../repository/notebooks/function_analysis.jl">notebooks/function_analysis.jl</a>; <a href="../repository/src/analysis.jl">src/analysis.jl</a>; <a href="../repository/test/runtests.jl">test/runtests.jl</a></p>
```

<!-- aml-api: {"symbol": "evaluate", "family": "F03", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 2} -->
## [evaluate](@id api-evaluate)

**Identity:** generic function; F03; **PUBLIC_STABLE**; explicitly exported.

**Interpretation:** FunctionAnalysis evaluation does not automatically enforce original-domain membership. PotentialAnalysis has its own radius-domain checks; do not transfer one overload’s behavior to another.

<!-- aml-contract: {"variant": 0, "digest": "31ac10e4338b8c80f31ae57758aead3adc757350c6868a40a3f45d9612c1269a"} -->
### Dispatch contract 1

**Purpose and output:** Scalar cached callable value (FunctionAnalysis order0/1/2; ScalarFieldAnalysis scalar); fresh vector for vector/dynamical reports.

**Source declarations and forwarding context:**

```text
evaluate(report::FunctionAnalysis, x::Number; order::Integer=0)

evaluate(report::ScalarFieldAnalysis, point::Union{Tuple,AbstractVector})

evaluate(report::VectorFieldAnalysis, point::Union{Tuple,AbstractVector})

evaluate(r::DynamicalSystemAnalysis, p::Union{Tuple,AbstractVector})
```

**Inputs:** Stored report and scalar Number or ordered tuple/vector of finite real coordinates matching dimension.

**Keywords:**

| Scope | Keyword | Default / constraint |
|---|---|---|
| FunctionAnalysis | `order` | 0; only 0, 1 or 2 |

**Failure and refusal:** ArgumentError for invalid univariate order; underlying callable errors propagate and NaN is preserved. DimensionMismatch for point length; DomainError for nonfinite coordinates/results or known original-domain exclusions on multivariate/vector routes.

**Numerical limitations:** Univariate numerical callable does not check stored original domain; cancellation and NaNMath behavior preserved. Multivariate/vector/dynamical evaluates even if membership unresolved, but never certifies validity; finite real result required; numeric type follows generated operations, machine integers can overflow.

**Units:** Generated arithmetic where supported, no universal units inference/conversion; point order must match stored variables.

**Ownership:** Does not repeat symbolic analysis or mutate input reports; vector values newly allocated.

**Dependencies:** Symbolics.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: PARTIAL_UNIVARIATE_AND_VECTOR_PRESENT_SCALAR_AND_DYNAMICAL_METHODS_ABSENT. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/numerical.jl:1-16; src/multivariate_analysis.jl:88-103; src/vector_fields/analysis.jl:73-92; src/dynamical_systems/analysis.jl:58.

Inventory-listed candidate references (not a verified call graph or new execution): test/runtests.jl:28-72; test/multivariate_analysis.jl:12-16; README.md:79-98.

```@raw html
<p>Repository resources: <a href="../repository/README.md">README.md</a>; <a href="../repository/src/dynamical_systems/analysis.jl">src/dynamical_systems/analysis.jl</a>; <a href="../repository/src/multivariate_analysis.jl">src/multivariate_analysis.jl</a>; <a href="../repository/src/numerical.jl">src/numerical.jl</a>; <a href="../repository/src/vector_fields/analysis.jl">src/vector_fields/analysis.jl</a>; <a href="../repository/test/multivariate_analysis.jl">test/multivariate_analysis.jl</a>; <a href="../repository/test/runtests.jl">test/runtests.jl</a></p>
```

<!-- aml-contract: {"variant": 1, "digest": "2c73857b35a81114454c525f553c9f7e635ff06946a80d8a53576737a4be82a6"} -->
### Dispatch contract 2

**Purpose and output:** Stored radial energy/first/second derivative

**Source declarations and forwarding context:**

```text
function evaluate(report::PotentialAnalysis, r::Real; order::Integer=0)
```

**Inputs:** PotentialAnalysis, positive finite r::Real; order::Integer=0

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** DomainError nonpositive/nonfinite/known excluded; invalid order from scalar evaluate

**Numerical limitations:** Unknown radial membership not certification; original stored positive-radius restrictions checked.

**Units:** No metadata conversion.

**Ownership:** Stored callable, no new analysis.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: BRIEF. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/atomistic/potentials.jl:122.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:67; test/architecture.jl:125; examples/inference/lj_gate.jl:36.

```@raw html
<p>Repository resources: <a href="../repository/examples/inference/lj_gate.jl">examples/inference/lj_gate.jl</a>; <a href="../repository/src/atomistic/potentials.jl">src/atomistic/potentials.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a></p>
```

<!-- aml-api: {"symbol": "FunctionAnalysis", "family": "F03", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "type / constructors", "variant_count": 1} -->
## [FunctionAnalysis](@id api-FunctionAnalysis)

**Identity:** type / constructors; F03; **PUBLIC_STABLE**; explicitly exported.

**Stored fields:** `expression`, `variable`, `first_derivative`, `second_derivative`, `numerical`, `critical_points`, `real_analysis`. Immutable outer record; referenced payloads may still be mutable. Obtain validated outputs through the operations described below; a raw record constructor does not itself certify scientific consistency.

<!-- aml-contract: {"variant": 0, "digest": "f36bb6b3e7402de321a18ea841543f1b9b3b4adf7238d178b81ab2927ab0bf86"} -->
**Purpose and output:** FunctionAnalysis record

**Source declarations and forwarding context:**

```text
FunctionAnalysis(expression, variable, first_derivative, second_derivative, numerical, critical_points, real_analysis)

FunctionAnalysis(e, v, d1, d2, n, c)
```

**Inputs:** Usually analyze(expression, variable); seven raw fields or compatibility six fields (real_analysis=nothing).

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** Generated constructors enforce declared Julia field/type constraints, not mathematical validity; no general invariant-validation promise.

**Numerical limitations:** Numerical search Float64, heuristic and smooth-interval assumption; residual is not a root-position bound. Numerical evaluation does not enforce real_analysis domain.

**Units:** No unit schema; caller supplies residual scale in first-derivative units, relative tolerance dimensionless; no automatic Unitful conversion.

**Ownership:** Immutable outer record does not imply deep immutability; stored arrays/Expr are read-only by convention. Raw generated constructors generally retain supplied references and do not validate scientific invariants.

**Dependencies:** Symbolics.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: PRESENT_DETAILED. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/analysis.jl:2-20.

Inventory-listed candidate references (not a verified call graph or new execution): test/runtests.jl:15-201; notebooks/function_analysis.jl:7-15.

```@raw html
<p>Repository resources: <a href="../repository/notebooks/function_analysis.jl">notebooks/function_analysis.jl</a>; <a href="../repository/src/analysis.jl">src/analysis.jl</a>; <a href="../repository/test/runtests.jl">test/runtests.jl</a></p>
```

## [F04: Real domains and exact studies](@id family-F04)

<!-- aml-api: {"symbol": "domain_contains", "family": "F04", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [domain_contains](@id api-domain-contains)

**Identity:** generic function; F04; **PUBLIC_STABLE**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "477ee608938f11fecaadfea887d75dbd86b1aa782c95b687f163bfd7e52e3dd3"} -->
**Purpose and output:** true / false / nothing: unknown univariate domains always nothing; multivariate partial constraints can reject points but otherwise remain nothing.

**Source declarations and forwarding context:**

```text
domain_contains(d::RealDomain, x::Real)

domain_contains(domain::MultivariateDomain, point::Union{Tuple,AbstractVector})
```

**Inputs:** Stored domain and scalar or dimension-matching ordered real coordinates.

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** DimensionMismatch for multivariate coordinate length; unsupported argument types dispatch-fail. Internal constraint failures except interrupts are treated unresolved rather than thrown.

**Numerical limitations:** Membership is not smoothness; raw domain constructors do not certify contents. Multivariate nonfinite coordinates return false; established univariate membership is ordinary interval comparison. Bounded exact integer/rational constraint evaluation avoids machine overflow, unsupported/resource-limited constraints can be unresolved.

**Units:** No automatic conversion; values must match caller coordinate scales/order.

**Ownership:** Reads stored constraints without mutation.

**Dependencies:** Symbolics.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: PRESENT_BRIEF_BOTH_METHODS. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/real_analysis_domain.jl:1-2; src/multivariate_domain.jl:94-115.

Inventory-listed candidate references (not a verified call graph or new execution): test/real_analysis_core.jl:71-180; test/multivariate_regressions.jl:4-24; notebooks/real_function_analysis.jl:7-19.

```@raw html
<p>Repository resources: <a href="../repository/notebooks/real_function_analysis.jl">notebooks/real_function_analysis.jl</a>; <a href="../repository/src/multivariate_domain.jl">src/multivariate_domain.jl</a>; <a href="../repository/src/real_analysis_domain.jl">src/real_analysis_domain.jl</a>; <a href="../repository/test/multivariate_regressions.jl">test/multivariate_regressions.jl</a>; <a href="../repository/test/real_analysis_core.jl">test/real_analysis_core.jl</a></p>
```

<!-- aml-api: {"symbol": "PeriodicIntervalSet", "family": "F04", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "type / constructors", "variant_count": 1} -->
## [PeriodicIntervalSet](@id api-PeriodicIntervalSet)

**Identity:** type / constructors; F04; **PUBLIC_STABLE**; explicitly exported.

**Stored fields:** `left`, `right`, `period`, `left_closed`, `right_closed`. Immutable outer record; referenced payloads may still be mutable. Obtain validated outputs through the operations described below; a raw record constructor does not itself certify scientific consistency.

<!-- aml-contract: {"variant": 0, "digest": "d7ee301c85c5a0a0326068c717efc40b697c3fe83d6ddf9f3aaa97adc277adaa"} -->
**Purpose and output:** PeriodicIntervalSet record

**Source declarations and forwarding context:**

```text
PeriodicIntervalSet(left, right, period, left_closed, right_closed)
```

**Inputs:** Raw positional fields in declaration order: left, right, period, left_closed, right_closed. Prefer the documented factory where applicable.

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** Generated constructors enforce declared Julia field/type constraints, not mathematical validity; no general invariant-validation promise.

**Numerical limitations:** All integer translates by period of exact symbolic interval endpoints; constructor does not validate period or endpoint consistency.

**Units:** Formal real variable; no physical units schema/conversion. Exact symbolic values are unevaluated data.

**Ownership:** Immutable outer record does not imply deep immutability; stored arrays/Expr are read-only by convention. Raw generated constructors generally retain supplied references and do not validate scientific invariants.

**Dependencies:** Symbolics.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: PRESENT_BRIEF. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/real_analysis_periodic.jl:7.

Inventory-listed candidate references (not a verified call graph or new execution): test/real_analysis_core.jl:181-205; README.md:166-188.

```@raw html
<p>Repository resources: <a href="../repository/README.md">README.md</a>; <a href="../repository/src/real_analysis_periodic.jl">src/real_analysis_periodic.jl</a>; <a href="../repository/test/real_analysis_core.jl">test/real_analysis_core.jl</a></p>
```

<!-- aml-api: {"symbol": "PeriodicPointSet", "family": "F04", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "type / constructors", "variant_count": 1} -->
## [PeriodicPointSet](@id api-PeriodicPointSet)

**Identity:** type / constructors; F04; **PUBLIC_STABLE**; explicitly exported.

**Stored fields:** `offset`, `period`. Immutable outer record; referenced payloads may still be mutable. Obtain validated outputs through the operations described below; a raw record constructor does not itself certify scientific consistency.

<!-- aml-contract: {"variant": 0, "digest": "b7ffa472cbf34acddbf38a65bfaa106c55104678be76967ff62a865d6bbb2d02"} -->
**Purpose and output:** PeriodicPointSet record

**Source declarations and forwarding context:**

```text
PeriodicPointSet(offset, period)
```

**Inputs:** Raw positional fields in declaration order: offset, period. Prefer the documented factory where applicable.

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** Generated constructors enforce declared Julia field/type constraints, not mathematical validity; no general invariant-validation promise.

**Numerical limitations:** Exact integer translates offset+k*period; Symbol/Expr values are unevaluated data; constructor does not validate positive/nonzero period.

**Units:** Formal real variable; no physical units schema/conversion. Exact symbolic values are unevaluated data.

**Ownership:** Immutable outer record does not imply deep immutability; stored arrays/Expr are read-only by convention. Raw generated constructors generally retain supplied references and do not validate scientific invariants.

**Dependencies:** Symbolics.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: PRESENT_BRIEF. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/real_analysis_periodic.jl:2.

Inventory-listed candidate references (not a verified call graph or new execution): test/real_analysis_core.jl:181-205; README.md:166-188.

```@raw html
<p>Repository resources: <a href="../repository/README.md">README.md</a>; <a href="../repository/src/real_analysis_periodic.jl">src/real_analysis_periodic.jl</a>; <a href="../repository/test/real_analysis_core.jl">test/real_analysis_core.jl</a></p>
```

<!-- aml-api: {"symbol": "RealDomain", "family": "F04", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "type / constructors", "variant_count": 1} -->
## [RealDomain](@id api-RealDomain)

**Identity:** type / constructors; F04; **PUBLIC_STABLE**; explicitly exported.

**Stored fields:** `components`, `status`, `method`, `notes`. Immutable outer record; referenced payloads may still be mutable. Obtain validated outputs through the operations described below; a raw record constructor does not itself certify scientific consistency.

<!-- aml-contract: {"variant": 0, "digest": "1ba96f50fc2f467a8c0f5c254d3e62830f2811e7c27db6a899d9e3a12d6d6bf9"} -->
**Purpose and output:** Interval union components plus status/method/notes; empty list only proves empty domain when established.

**Source declarations and forwarding context:**

```text
RealDomain(components, status, method, notes)
```

**Inputs:** Raw positional fields in declaration order: components, status, method, notes. Prefer the documented factory where applicable.

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** Generated constructors enforce declared Julia field/type constraints, not mathematical validity; no general invariant-validation promise.

**Numerical limitations:** Exact rational polynomial/factorization class, outer sqrt/log and sin(variable); irrational unresolved roots remain unknown. Degree64/bits4096/work200000/AST512/depth48 budgets; interval only enables heuristic roots, not domain truncation.

**Units:** Formal real variable; no physical units schema/conversion. Exact symbolic values are unevaluated data.

**Ownership:** Immutable outer record does not imply deep immutability; stored arrays/Expr are read-only by convention. Raw generated constructors generally retain supplied references and do not validate scientific invariants.

**Dependencies:** Symbolics.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: ABSENT_ON_TYPE. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/real_analysis.jl:11.

Inventory-listed candidate references (not a verified call graph or new execution): test/real_analysis_core.jl:16-245; test/real_analysis_integration.jl:5-39; notebooks/real_function_analysis.jl:7-19.

```@raw html
<p>Repository resources: <a href="../repository/notebooks/real_function_analysis.jl">notebooks/real_function_analysis.jl</a>; <a href="../repository/src/real_analysis.jl">src/real_analysis.jl</a>; <a href="../repository/test/real_analysis_core.jl">test/real_analysis_core.jl</a>; <a href="../repository/test/real_analysis_integration.jl">test/real_analysis_integration.jl</a></p>
```

<!-- aml-api: {"symbol": "RealFunctionStudy", "family": "F04", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "type / constructors", "variant_count": 1} -->
## [RealFunctionStudy](@id api-RealFunctionStudy)

**Identity:** type / constructors; F04; **PUBLIC_STABLE**; explicitly exported.

**Stored fields:** `original_expression`, `simplified_expression`, `domain`, `roots`, `intercepts`, `sign`, `continuity`, `limits`, `monotonicity`, `extrema`, `concavity`, `inflections`, `asymptotes`, `symmetry`. Immutable outer record; referenced payloads may still be mutable. Obtain validated outputs through the operations described below; a raw record constructor does not itself certify scientific consistency.

<!-- aml-contract: {"variant": 0, "digest": "da484cb8459c839616c91a6fd001ae7241ccccf8c017a4887d1170e56b6cc644"} -->
**Purpose and output:** Original/simplified expression, domain and eleven scoped PropertyResult qualitative properties.

**Source declarations and forwarding context:**

```text
RealFunctionStudy(original_expression, simplified_expression, domain, roots, intercepts, sign, continuity, limits, monotonicity, extrema, concavity, inflections, asymptotes, symmetry)
```

**Inputs:** Usually report.real_analysis from univariate analyze; raw full field constructor remains available.

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** Generated constructors enforce declared Julia field/type constraints, not mathematical validity; no general invariant-validation promise.

**Numerical limitations:** Exact rational polynomial/factorization class, outer sqrt/log and sin(variable); irrational unresolved roots remain unknown. Degree64/bits4096/work200000/AST512/depth48 budgets; interval only enables heuristic roots, not domain truncation.

**Units:** Formal real variable; no physical units schema/conversion. Exact symbolic values are unevaluated data.

**Ownership:** Immutable outer record does not imply deep immutability; stored arrays/Expr are read-only by convention. Raw generated constructors generally retain supplied references and do not validate scientific invariants.

**Dependencies:** Symbolics.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: ABSENT_ON_TYPE_INTERNAL_FACTORY_DOCUMENTED. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/real_analysis.jl:17.

Inventory-listed candidate references (not a verified call graph or new execution): test/real_analysis_core.jl:16-245; test/real_analysis_integration.jl:5-39; notebooks/real_function_analysis.jl:7-19.

```@raw html
<p>Repository resources: <a href="../repository/notebooks/real_function_analysis.jl">notebooks/real_function_analysis.jl</a>; <a href="../repository/src/real_analysis.jl">src/real_analysis.jl</a>; <a href="../repository/test/real_analysis_core.jl">test/real_analysis_core.jl</a>; <a href="../repository/test/real_analysis_integration.jl">test/real_analysis_integration.jl</a></p>
```

<!-- aml-api: {"symbol": "RealInterval", "family": "F04", "stability": "PUBLIC_STABLE", "qualified": false, "kind": "type / constructors", "variant_count": 1} -->
## [RealInterval](@id api-RealInterval)

**Identity:** type / constructors; F04; **PUBLIC_STABLE**; explicitly exported.

**Stored fields:** `left`, `right`, `left_closed`, `right_closed`. Immutable outer record; referenced payloads may still be mutable. Obtain validated outputs through the operations described below; a raw record constructor does not itself certify scientific consistency.

<!-- aml-contract: {"variant": 0, "digest": "730454bb17801413e7648087f591644ff62a6e5c9b28b5e37ba109bc5c999806"} -->
**Purpose and output:** RealInterval record

**Source declarations and forwarding context:**

```text
RealInterval(left, right, left_closed, right_closed)
```

**Inputs:** left::Real, right::Real, left_closed::Bool, right_closed::Bool. Factory uses exact rational finite boundaries, floating infinities.

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** Generated constructors enforce declared Julia field/type constraints, not mathematical validity; no general invariant-validation promise.

**Numerical limitations:** Raw constructor does not enforce order/exact endpoints; interval fields alone do not certify a domain.

**Units:** Formal real variable; no physical units schema/conversion. Exact symbolic values are unevaluated data.

**Ownership:** Immutable outer record does not imply deep immutability; stored arrays/Expr are read-only by convention. Raw generated constructors generally retain supplied references and do not validate scientific invariants.

**Dependencies:** Symbolics.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: PRESENT_BRIEF. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/real_analysis.jl:5.

Inventory-listed candidate references (not a verified call graph or new execution): test/real_analysis_core.jl:71-93; test/real_analysis_core.jl:120-160; notebooks/real_function_analysis.jl:7-19.

```@raw html
<p>Repository resources: <a href="../repository/notebooks/real_function_analysis.jl">notebooks/real_function_analysis.jl</a>; <a href="../repository/src/real_analysis.jl">src/real_analysis.jl</a>; <a href="../repository/test/real_analysis_core.jl">test/real_analysis_core.jl</a></p>
```
