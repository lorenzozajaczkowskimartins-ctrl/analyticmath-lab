# Experimental scientific computation

All payload families here are experimental. Construction, optimization, sampled residual evidence and generalization are separate stages. Low loss does not establish physical validity, continuum accuracy or extrapolation; no training is run by this reference build.

Read [API boundaries and evidence semantics](@ref api-boundaries) for the distinction between raw constructors, validated factories, exceptions, unknown claims and unrequested/partial diagnostics. Signatures are text, not runnable examples. Backend forwarding/context lines do not create public helper APIs.

```@raw html
<p>Repository resources: <a href="../repository/docs/scientific_ml.md">docs/scientific_ml.md</a>; <a href="../repository/docs/tutorials/one-system-many-methods.md">docs/tutorials/one-system-many-methods.md</a>; <a href="../repository/docs/tutorials/scripts/one_system_many_methods.jl">docs/tutorials/scripts/one_system_many_methods.jl</a>; <a href="../repository/reports/m10d6/tutorial_verification.json">reports/m10d6/tutorial_verification.json</a></p>
```

Overload map: [analyze](@ref dispatch-analyze).

Overload map: [train](@ref dispatch-train).

Overload map: [predict](@ref dispatch-predict).

Overload map: [loss_breakdown](@ref dispatch-loss_breakdown).

## [train overloads](@id dispatch-train)

<!-- aml-dispatch: {"symbol": "train", "variants": 3} -->
### train: dispatch-oriented map

| Input contract | Supported signature | Result | Dependencies | Scientific contract | Destination |
|---|---|---|---|---|---|
| PINNProblem or PINNTrainingResult with explicit optimizer; maxiters required; history=false,log_every=10,history_capacity=1000,record_components=false,callback/kwargs | `train(p::PINNProblem,optimizer;kwargs...)=_pinn_extension().train(p,optimizer;kwargs...)` | PINNTrainingResult | Lux, NeuralPDE, ModelingToolkit, Optimization, SymbolicIndexingInterface | Route-specific status, numerical and ownership contract below | [primary contract](@ref api-train); [family](@ref family-F26) |
| PINNProblem or PINNTrainingResult with explicit optimizer; maxiters required; history=false,log_every=10,history_capacity=1000,record_components=false,callback/kwargs | `train(r::PINNTrainingResult,optimizer;kwargs...)=_pinn_extension().train(r,optimizer;kwargs...)` | PINNTrainingResult | Lux, NeuralPDE, ModelingToolkit, Optimization, SymbolicIndexingInterface | Route-specific status, numerical and ownership contract below | [primary contract](@ref api-train); [family](@ref family-F26) |
| PINNProblem or PINNTrainingResult with explicit optimizer; maxiters required; history=false,log_every=10,history_capacity=1000,record_components=false,callback/kwargs | `function train(p::AML.PINNProblem,optimizer;kwargs...)` | PINNTrainingResult | Lux, NeuralPDE, ModelingToolkit, Optimization, SymbolicIndexingInterface | Route-specific status, numerical and ownership contract below | [primary contract](@ref api-train); [family](@ref family-F26) |
| PINNProblem or PINNTrainingResult with explicit optimizer; maxiters required; history=false,log_every=10,history_capacity=1000,record_components=false,callback/kwargs | `function train(r::AML.PINNTrainingResult,optimizer;kwargs...)` | PINNTrainingResult | Lux, NeuralPDE, ModelingToolkit, Optimization, SymbolicIndexingInterface | Route-specific status, numerical and ownership contract below | [primary contract](@ref api-train); [family](@ref family-F26) |
| HNN/UDE and data; required initial_parameters::AbstractVector,reconstruct,optimizer; maxiters=100,history_limit=100,objective_options | `train(m::Union{HamiltonianNN,UDEProblem},args...;kwargs...)=_dynamics_unavailable(train,m,args...)` | DynamicsTrainingResult | Lux, Optimization | Route-specific status, numerical and ownership contract below | [primary contract](@ref api-train); [family](@ref family-F26) |
| HNN/UDE and data; required initial_parameters::AbstractVector,reconstruct,optimizer; maxiters=100,history_limit=100,objective_options | `function AML.train(m::Union{AML.HamiltonianNN,AML.UDEProblem},data; initial_parameters::AbstractVector,reconstruct,optimizer,maxiters::Integer=100, history_limit::Integer=100,objective_options=NamedTuple())` | DynamicsTrainingResult | Lux, Optimization | Route-specific status, numerical and ownership contract below | [primary contract](@ref api-train); [family](@ref family-F26) |
| ScientificModel,Dataset; initial_parameters::AbstractVector,optimizer,adtype,maxiters required; reconstruct=identity,history_limit=100 | `train(m::ScientificModel,d::ScientificDataset;kwargs...)=_surrogate_extension().train(m,d;kwargs...)` | ScientificLearningResult | Lux, Optimization, NeuralOperators | Route-specific status, numerical and ownership contract below | [primary contract](@ref api-train); [family](@ref family-F26) |

## [predict overloads](@id dispatch-predict)

<!-- aml-dispatch: {"symbol": "predict", "variants": 3} -->
### predict: dispatch-oriented map

| Input contract | Supported signature | Result | Dependencies | Scientific contract | Destination |
|---|---|---|---|---|---|
| PINNTrainingResult, CPU scalar/Vector/Tuple or Matrix coord×points; batch_size=nothing or positive Integer | `predict(r::PINNTrainingResult,x;kwargs...)=_pinn_extension().predict(r,x;kwargs...)` | DV vector for point or DV×points matrix | Lux, NeuralPDE, ModelingToolkit, Optimization, SymbolicIndexingInterface | Route-specific status, numerical and ownership contract below | [primary contract](@ref api-predict); [family](@ref family-F26) |
| PINNTrainingResult, CPU scalar/Vector/Tuple or Matrix coord×points; batch_size=nothing or positive Integer | `function predict(r::AML.PINNTrainingResult,x;batch_size::Union{Nothing,Integer}=nothing)` | DV vector for point or DV×points matrix | Lux, NeuralPDE, ModelingToolkit, Optimization, SymbolicIndexingInterface | Route-specific status, numerical and ownership contract below | [primary contract](@ref api-predict); [family](@ref family-F26) |
| HNN/UDE or fitted result, initial state/time span; trajectory kwargs | `predict(m::Union{HamiltonianNN,UDEProblem,DynamicsTrainingResult},args...;kwargs...)=_dynamics_unavailable(predict,m,args...)` | TrajectoryResult | Lux, Optimization | Route-specific status, numerical and ownership contract below | [primary contract](@ref api-predict); [family](@ref family-F26) |
| HNN/UDE or fitted result, initial state/time span; trajectory kwargs | `function AML.predict(m::Union{AML.HamiltonianNN,AML.UDEProblem},u0,tspan;kwargs...)` | TrajectoryResult | Lux, Optimization | Route-specific status, numerical and ownership contract below | [primary contract](@ref api-predict); [family](@ref family-F26) |
| HNN/UDE or fitted result, initial state/time span; trajectory kwargs | `AML.predict(r::AML.DynamicsTrainingResult,u0,tspan;kwargs...)=AML.predict(r.model,u0,tspan;kwargs...)` | TrajectoryResult | Lux, Optimization | Route-specific status, numerical and ownership contract below | [primary contract](@ref api-predict); [family](@ref family-F26) |
| ScientificModel or ScientificLearningResult, ordered input/query matrix; sensors schema default,batch_size optional | `predict(m::ScientificModel,input,coordinates::AbstractMatrix;kwargs...)=_surrogate_extension().predict(m,input,coordinates;kwargs...)` | Scalar outputs vector query order | Lux, Optimization, NeuralOperators | Route-specific status, numerical and ownership contract below | [primary contract](@ref api-predict); [family](@ref family-F26) |
| ScientificModel or ScientificLearningResult, ordered input/query matrix; sensors schema default,batch_size optional | `predict(r::ScientificLearningResult,input,coordinates::AbstractMatrix;kwargs...)=predict(r.model,input,coordinates;kwargs...)` | Scalar outputs vector query order | Lux, Optimization, NeuralOperators | Route-specific status, numerical and ownership contract below | [primary contract](@ref api-predict); [family](@ref family-F26) |

## [loss_breakdown overloads](@id dispatch-loss_breakdown)

<!-- aml-dispatch: {"symbol": "loss_breakdown", "variants": 1} -->
### loss_breakdown: dispatch-oriented map

| Input contract | Supported signature | Result | Dependencies | Scientific contract | Destination |
|---|---|---|---|---|---|
| PINNAnalysis or PINNTrainingResult | `function loss_breakdown(r::AML.PINNTrainingResult)` | Stored loss diagnostic NamedTuple | Lux, NeuralPDE, ModelingToolkit, Optimization, SymbolicIndexingInterface | Route-specific status, numerical and ownership contract below | [primary contract](@ref api-loss-breakdown); [family](@ref family-F27) |
| PINNAnalysis | `loss_breakdown(a::PINNAnalysis)=a.loss_diagnostics` | Stored loss diagnostic NamedTuple | Core stored accessor | No recomputation or extension required | [primary contract](@ref api-loss-breakdown); [family](@ref family-F27) |
| PINNAnalysis or PINNTrainingResult | `loss_breakdown(r::PINNTrainingResult)=_pinn_extension().loss_breakdown(r)` | Stored loss diagnostic NamedTuple | Lux, NeuralPDE, ModelingToolkit, Optimization, SymbolicIndexingInterface | Route-specific status, numerical and ownership contract below | [primary contract](@ref api-loss-breakdown); [family](@ref family-F27) |

## [F26: PINN construction and training](@id family-F26)

<!-- aml-api: {"symbol": "pinn_inspect", "family": "F26", "stability": "PUBLIC_EXPERIMENTAL", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [pinn_inspect](@id api-pinn-inspect)

**Identity:** generic function; F26; **PUBLIC_EXPERIMENTAL**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "037509459f0b7218f0f8ca6b3d49c447cc2986d8490f0135794245ff6a64f3e5"} -->
**Purpose and output:** NamedTuple of actual retained fields

**Source declarations and forwarding context:**

```text
function pinn_inspect(p::PINNProblem)

function pinn_inspect(r::PINNTrainingResult)

pinn_inspect(a::PINNAnalysis)=(training=a.training,residuals=a.residuals,reference=a.reference,
```

**Inputs:** PINNProblem/PINNTrainingResult/PINNAnalysis

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** No additional refusal specified in this audited route; raw records do not establish validation.

**Numerical limitations:** No new discretization/training.

**Units:** CPU Float64 construction/coordinates/prediction; metadata units descriptive, no automatic dimensional normalization.

**Ownership:** Borrows stored objects/arrays, not detached metadata.

**Dependencies:** Lux; NeuralPDE; ModelingToolkit; Optimization; SymbolicIndexingInterface.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: BRIEF. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/scientific_ml/pinn.jl:83; src/scientific_ml/pinn.jl:93; src/scientific_ml/diagnostics.jl:67.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:90; test/pinn_base.jl:5; notebooks/scientific_ml.jl:15.

```@raw html
<p>Repository resources: <a href="../repository/notebooks/scientific_ml.jl">notebooks/scientific_ml.jl</a>; <a href="../repository/src/scientific_ml/diagnostics.jl">src/scientific_ml/diagnostics.jl</a>; <a href="../repository/src/scientific_ml/pinn.jl">src/scientific_ml/pinn.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/pinn_base.jl">test/pinn_base.jl</a></p>
```

<!-- aml-api: {"symbol": "pinn_network", "family": "F26", "stability": "PUBLIC_EXPERIMENTAL", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [pinn_network](@id api-pinn-network)

**Identity:** generic function; F26; **PUBLIC_EXPERIMENTAL**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "0c42befdccabeca82dd9f6cf52261cd56206b5b1f8511072165ea2f9050afcc0"} -->
**Purpose and output:** Genuine Lux.Chain with identity final activation

**Source declarations and forwarding context:**

```text
pinn_network(args...;kwargs...)=_pinn_extension().pinn_network(args...;kwargs...)

function pinn_network(input_dim::Integer,output_dim::Integer;hidden=[32,32],activation=tanh)
```

**Inputs:** Positive input/output dimension; hidden=[32,32],activation=tanh

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError invalid dims/hidden widths or missing extension

**Numerical limitations:** No default scientific accuracy/architecture suitability claim.

**Units:** CPU Float64 construction/coordinates/prediction; metadata units descriptive, no automatic dimensional normalization.

**Ownership:** New model; setup occurs on explicit RNG later.

**Dependencies:** Lux; NeuralPDE; ModelingToolkit; Optimization; SymbolicIndexingInterface.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: BRIEF. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/scientific_ml/pinn.jl:69; ext/AnalyticMathLabPINNExt.jl:9.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:89; test/m10d_semantics_pinn.jl:12; examples/pinn/benchmarks.jl:63.

```@raw html
<p>Repository resources: <a href="../repository/examples/pinn/benchmarks.jl">examples/pinn/benchmarks.jl</a>; <a href="../repository/ext/AnalyticMathLabPINNExt.jl">ext/AnalyticMathLabPINNExt.jl</a>; <a href="../repository/src/scientific_ml/pinn.jl">src/scientific_ml/pinn.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/m10d_semantics_pinn.jl">test/m10d_semantics_pinn.jl</a></p>
```

<!-- aml-api: {"symbol": "pinn_problem", "family": "F26", "stability": "PUBLIC_EXPERIMENTAL", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [pinn_problem](@id api-pinn-problem)

**Identity:** generic function; F26; **PUBLIC_EXPERIMENTAL**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "a0d82104ab3c90afc13b6ebcd173541472ad2337ed44147ae36704ccae1af51d"} -->
**Purpose and output:** PINNProblem

**Source declarations and forwarding context:**

```text
pinn_problem(args...;kwargs...)=_pinn_extension().pinn_problem(args...;kwargs...)

function pinn_problem(system::MTK.PDESystem;network,strategy,rng::Random.AbstractRNG,adtype,
network_layout=:auto,derivative=NeuralPDE.FiniteDifferenceDerivative(),
additional_loss=nothing,param_estim::Bool=false,eval_points::Integer=32,optimization_options=NamedTuple(),
provenance=NamedTuple())

pinn_problem(system;kwargs...)=throw(ArgumentError("pinn_problem requires a ModelingToolkit PDESystem"))
```

**Inputs:** ModelingToolkit.PDESystem; required network,strategy,rng::AbstractRNG,adtype; literal optional layout/derivative/additional_loss/param_estim/eval_points

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError missing triggers/wrong system/layout/stateful model/invalid DV scalar arguments/cost labeling; DimensionMismatch output/layout

**Numerical limitations:** Multiple DVs require explicit shared/separate; shared ordered input args equal. Genuine stateless Lux only, f64 setup; discretizes once. param_estim all declared or none, not arbitrary inferred subset.

**Units:** CPU Float64 construction/coordinates/prediction; metadata units descriptive, no automatic dimensional normalization.

**Ownership:** Retains original system and native backend once, consumed explicit RNG recorded by type not implicit seed.

**Dependencies:** Lux; NeuralPDE; ModelingToolkit; Optimization; SymbolicIndexingInterface.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: BRIEF core; full extension signature. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/scientific_ml/pinn.jl:71; ext/AnalyticMathLabPINNExt.jl:18; ext/AnalyticMathLabPINNExt.jl:87.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:89; test/m10d_extensions.jl:57; examples/pinn/benchmarks.jl:63.

```@raw html
<p>Repository resources: <a href="../repository/examples/pinn/benchmarks.jl">examples/pinn/benchmarks.jl</a>; <a href="../repository/ext/AnalyticMathLabPINNExt.jl">ext/AnalyticMathLabPINNExt.jl</a>; <a href="../repository/src/scientific_ml/pinn.jl">src/scientific_ml/pinn.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/m10d_extensions.jl">test/m10d_extensions.jl</a></p>
```

<!-- aml-api: {"symbol": "PINNHistory", "family": "F26", "stability": "PUBLIC_EXPERIMENTAL", "qualified": false, "kind": "type / constructors", "variant_count": 1} -->
## [PINNHistory](@id api-PINNHistory)

**Identity:** type / constructors; F26; **PUBLIC_EXPERIMENTAL**; explicitly exported.

**Stored fields:** `entries`, `stride`, `capacity`, `truncated`. Mutable outer record. Obtain validated outputs through the operations described below; a raw record constructor does not itself certify scientific consistency.

**Interpretation:** Capacity/stride limit retained diagnostics, not optimizer or model memory. PINN/inference histories retain earliest entries; surrogate/learned-dynamics rolling history retains later entries.

<!-- aml-contract: {"variant": 0, "digest": "40b1423a7e30dc298f6ef9a19aae78ff537eaf66df3f5dadaacacf7deddea34d"} -->
**Purpose and output:** Mutable bounded first-record history

**Source declarations and forwarding context:**

```text
mutable struct PINNHistory <: AbstractAnalysis

function PINNHistory(;stride::Integer=10,capacity::Integer=1000)
```

**Inputs:** stride::Integer=10,capacity::Integer=1000

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError nonpositive controls

**Numerical limitations:** First entries retained on exhaustion with truncated=true; no parameter snapshots/RSS bound.

**Units:** CPU Float64 construction/coordinates/prediction; metadata units descriptive, no automatic dimensional normalization.

**Ownership:** New entries vector.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: DETAILED. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/scientific_ml/pinn.jl:34; src/scientific_ml/pinn.jl:29.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:89; test/pinn_base.jl:5; examples/pinn/m10b_gate.jl:14.

```@raw html
<p>Repository resources: <a href="../repository/examples/pinn/m10b_gate.jl">examples/pinn/m10b_gate.jl</a>; <a href="../repository/src/scientific_ml/pinn.jl">src/scientific_ml/pinn.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/pinn_base.jl">test/pinn_base.jl</a></p>
```

<!-- aml-api: {"symbol": "PINNProblem", "family": "F26", "stability": "PUBLIC_EXPERIMENTAL", "qualified": false, "kind": "type / constructors", "variant_count": 1} -->
## [PINNProblem](@id api-PINNProblem)

**Identity:** type / constructors; F26; **PUBLIC_EXPERIMENTAL**; explicitly exported.

**Stored fields:** `system`, `independent_variables`, `dependent_variables`, `domains`, `equations`, `boundary_conditions`, `networks`, `network_mapping`, `initial_parameters`, `initial_states`, `strategy`, `discretization`, `symbolic_discretization`, `optimization_problem`, `backend_metadata`, `loss_components`, `provenance`, `evidence`. Immutable outer record; referenced payloads may still be mutable. Obtain validated outputs through the operations described below; a raw record constructor does not itself certify scientific consistency.

<!-- aml-contract: {"variant": 0, "digest": "5a17a31b7b63771f9cd21907032e4b85470885e1bb9cf49476431c64453785da"} -->
**Purpose and output:** Retained symbolic PDESystem and native discretization/Optimization construction

**Source declarations and forwarding context:**

```text
struct PINNProblem <: AbstractAnalysis; raw generated field constructor: (system, independent_variables, dependent_variables, domains, equations, boundary_conditions, networks, network_mapping, initial_parameters, initial_states, strategy, discretization, symbolic_discretization, optimization_problem, backend_metadata, loss_components, provenance, evidence::PropertyResult)
```

**Inputs:** pinn_problem or raw fields

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** No additional refusal specified in this audited route; raw records do not establish validation.

**Numerical limitations:** Construction evidence shape/backend only not solution truth.

**Units:** CPU Float64 construction/coordinates/prediction; metadata units descriptive, no automatic dimensional normalization.

**Ownership:** Strong symbolic/network/native graph retention, read-only convention.

**Dependencies:** Lux; NeuralPDE; ModelingToolkit; Optimization; SymbolicIndexingInterface.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: DETAILED. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/scientific_ml/pinn.jl:4.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:89; test/pinn_base.jl:5.

```@raw html
<p>Repository resources: <a href="../repository/src/scientific_ml/pinn.jl">src/scientific_ml/pinn.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/pinn_base.jl">test/pinn_base.jl</a></p>
```

<!-- aml-api: {"symbol": "PINNTrainingResult", "family": "F26", "stability": "PUBLIC_EXPERIMENTAL", "qualified": false, "kind": "type / constructors", "variant_count": 1} -->
## [PINNTrainingResult](@id api-PINNTrainingResult)

**Identity:** type / constructors; F26; **PUBLIC_EXPERIMENTAL**; explicitly exported.

**Stored fields:** `problem`, `optimization_problem`, `solution`, `backend_solution`, `parameters`, `network_parameters`, `states`, `history`, `losses`, `termination`, `optimizer`, `provenance`, `evidence`, `notes`. Immutable outer record; referenced payloads may still be mutable. Obtain validated outputs through the operations described below; a raw record constructor does not itself certify scientific consistency.

<!-- aml-contract: {"variant": 0, "digest": "f228c0f90cf90ed483366bf317ee78f0be8b1a026b5326188fd311f0f1f1f2b8"} -->
**Purpose and output:** Native PDE wrapper and Optimization result, parameters, states, costs, termination/history

**Source declarations and forwarding context:**

```text
struct PINNTrainingResult <: AbstractAnalysis; raw generated field constructor: (problem::PINNProblem, optimization_problem, solution, backend_solution, parameters, network_parameters, states, history, losses::PropertyResult, termination, optimizer, provenance, evidence::PropertyResult, notes::Vector{String})
```

**Inputs:** train or raw fields

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** No additional refusal specified in this audited route; raw records do not establish validation.

**Numerical limitations:** Low loss not physics; backend status separated and physical evidence unknown.

**Units:** CPU Float64 construction/coordinates/prediction; metadata units descriptive, no automatic dimensional normalization.

**Ownership:** Strong construction/native retention; continuation copies u0/deepcopies native p.

**Dependencies:** Lux; NeuralPDE; ModelingToolkit; Optimization; SymbolicIndexingInterface.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: DETAILED. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/scientific_ml/pinn.jl:45.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:89; test/pinn_base.jl:5; examples/pinn/m10b_gate.jl:13.

```@raw html
<p>Repository resources: <a href="../repository/examples/pinn/m10b_gate.jl">examples/pinn/m10b_gate.jl</a>; <a href="../repository/src/scientific_ml/pinn.jl">src/scientific_ml/pinn.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/pinn_base.jl">test/pinn_base.jl</a></p>
```

<!-- aml-api: {"symbol": "predict", "family": "F26", "stability": "PUBLIC_EXPERIMENTAL", "qualified": false, "kind": "generic function", "variant_count": 3} -->
## [predict](@id api-predict)

**Identity:** generic function; F26; **PUBLIC_EXPERIMENTAL**; explicitly exported.

**Interpretation:** Query chunking still allocates the complete output. It assumes deterministic query-independent networks and is not training minibatching or a global memory control.

<!-- aml-contract: {"variant": 0, "digest": "df8edb10c505beead5e2054d3b2874004107d38d664ee262a2d3511f9a8f1902"} -->
### Dispatch contract 1

**Purpose and output:** DV vector for point or DV×points matrix

**Source declarations and forwarding context:**

```text
predict(r::PINNTrainingResult,x;kwargs...)=_pinn_extension().predict(r,x;kwargs...)

function predict(r::AML.PINNTrainingResult,x;batch_size::Union{Nothing,Integer}=nothing)
```

**Inputs:** PINNTrainingResult, CPU scalar/Vector/Tuple or Matrix coord×points; batch_size=nothing or positive Integer

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError device/layout/nonfinite/unrepresentable coordinates/state change/batch; DimensionMismatch coordinate/output shape; DomainError invalid output

**Numerical limitations:** No domain membership/physical accuracy certification. batch_size bounds temporary activations, not total full output; empty queries still need rows matching.

**Units:** CPU Float64 construction/coordinates/prediction; metadata units descriptive, no automatic dimensional normalization.

**Ownership:** Fresh Float64 output; copies state for apply.

**Dependencies:** Lux; NeuralPDE; ModelingToolkit; Optimization; SymbolicIndexingInterface.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: DETAILED core. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/scientific_ml/pinn.jl:80; ext/AnalyticMathLabPINNExt.jl:155.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:90; test/m10d_extensions.jl:60; examples/inference/neural_gate.jl:59.

```@raw html
<p>Repository resources: <a href="../repository/examples/inference/neural_gate.jl">examples/inference/neural_gate.jl</a>; <a href="../repository/ext/AnalyticMathLabPINNExt.jl">ext/AnalyticMathLabPINNExt.jl</a>; <a href="../repository/src/scientific_ml/pinn.jl">src/scientific_ml/pinn.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/m10d_extensions.jl">test/m10d_extensions.jl</a></p>
```

<!-- aml-contract: {"variant": 1, "digest": "9bfaecc98053b53a12efb47093d436b391df58a1afbd443a720caf5cecaad4ca"} -->
### Dispatch contract 2

**Purpose and output:** TrajectoryResult

**Source declarations and forwarding context:**

```text
predict(m::Union{HamiltonianNN,UDEProblem,DynamicsTrainingResult},args...;kwargs...)=_dynamics_unavailable(predict,m,args...)

function AML.predict(m::Union{AML.HamiltonianNN,AML.UDEProblem},u0,tspan;kwargs...)

AML.predict(r::AML.DynamicsTrainingResult,u0,tspan;kwargs...)=AML.predict(r.model,u0,tspan;kwargs...)
```

**Inputs:** HNN/UDE or fitted result, initial state/time span; trajectory kwargs

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** Public FirstOrderODE/trajectory cap/conversion/domain/solver errors propagate

**Numerical limitations:** Prediction creates FirstOrderODE and uses public Float64 trajectory; not a new large-state method.

**Units:** No implicit physical units conversion; PINN diagnostics Float64 samples; learned dynamics uses backend numeric AD, prediction public Float64.

**Ownership:** Native solution retained; fitted result delegates model.

**Dependencies:** Lux; Optimization.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: Typed fallback only. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/scientific_ml/learned_dynamics.jl:69; ext/AnalyticMathLabDynamicsExt.jl:84; ext/AnalyticMathLabDynamicsExt.jl:90.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:90; test/m10d_extensions.jl:60; examples/inference/neural_gate.jl:59.

```@raw html
<p>Repository resources: <a href="../repository/examples/inference/neural_gate.jl">examples/inference/neural_gate.jl</a>; <a href="../repository/ext/AnalyticMathLabDynamicsExt.jl">ext/AnalyticMathLabDynamicsExt.jl</a>; <a href="../repository/src/scientific_ml/learned_dynamics.jl">src/scientific_ml/learned_dynamics.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/m10d_extensions.jl">test/m10d_extensions.jl</a></p>
```

<!-- aml-contract: {"variant": 2, "digest": "80c878e833877a450510d51a3ba16b047e24013c78bf1c3e21fa593be1e9b175"} -->
### Dispatch contract 3

**Purpose and output:** Scalar outputs vector query order

The unqualified predict(m,input,q;...) below is extension-local implementation context. AML requires the typed ScientificModel/ScientificLearningResult wrappers and ordered query matrix shown with it.

**Source declarations and forwarding context:**

```text
function predict(m,input,q;sensors=m.schema.sensors,batch_size::Union{Nothing,Integer}=nothing)

predict(m::ScientificModel,input,coordinates::AbstractMatrix;kwargs...)=_surrogate_extension().predict(m,input,coordinates;kwargs...)

predict(r::ScientificLearningResult,input,coordinates::AbstractMatrix;kwargs...)=predict(r.model,input,coordinates;kwargs...)
```

**Inputs:** ScientificModel or ScientificLearningResult, ordered input/query matrix; sensors schema default,batch_size optional

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError sensor/classification/state/batch error; DimensionMismatch shape; DomainError nonfinite

**Numerical limitations:** Pointwise/query-independent network batching only; no automatic detection of coupled query columns. Complete output O(query count), no implicit domain validity.

**Units:** Learning numeric outputs Float64 normalized/scaled; plotting Float64 view conversion, not units engine.

**Ownership:** Fresh output; no resampling.

**Dependencies:** Lux; Optimization; NeuralOperators.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: DETAILED core. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: ext/AnalyticMathLabSurrogateExt.jl:32; src/scientific_ml/surrogates.jl:234; src/scientific_ml/surrogates.jl:235.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:90; test/m10d_extensions.jl:60; examples/inference/neural_gate.jl:59.

```@raw html
<p>Repository resources: <a href="../repository/examples/inference/neural_gate.jl">examples/inference/neural_gate.jl</a>; <a href="../repository/ext/AnalyticMathLabSurrogateExt.jl">ext/AnalyticMathLabSurrogateExt.jl</a>; <a href="../repository/src/scientific_ml/surrogates.jl">src/scientific_ml/surrogates.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/m10d_extensions.jl">test/m10d_extensions.jl</a></p>
```

<!-- aml-api: {"symbol": "train", "family": "F26", "stability": "PUBLIC_EXPERIMENTAL", "qualified": false, "kind": "generic function", "variant_count": 3} -->
## [train](@id api-train)

**Identity:** generic function; F26; **PUBLIC_EXPERIMENTAL**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "a20ad570c7dc7e108cd04504674a2778b59c5587ef24b6ceb79f2827882d40e4"} -->
### Dispatch contract 1

**Purpose and output:** PINNTrainingResult

**Source declarations and forwarding context:**

```text
train(p::PINNProblem,optimizer;kwargs...)=_pinn_extension().train(p,optimizer;kwargs...)

train(r::PINNTrainingResult,optimizer;kwargs...)=_pinn_extension().train(r,optimizer;kwargs...)

function train(p::AML.PINNProblem,optimizer;kwargs...)

function train(r::AML.PINNTrainingResult,optimizer;kwargs...)

Controls from _train(p,source,optimizer;maxiters::Integer,history::Bool=false,log_every::Integer=10,history_capacity::Integer=1000,record_components::Bool=false,callback=nothing,kwargs...) at ext/AnalyticMathLabPINNExt.jl:107-109
```

**Inputs:** PINNProblem or PINNTrainingResult with explicit optimizer; maxiters required; history=false,log_every=10,history_capacity=1000,record_components=false,callback/kwargs

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError invalid controls/missing triggers; native errors propagate

**Numerical limitations:** Continuation explicit, not schedule; unweighted component costs not independent errors; history capacity only stored scalar records.

**Units:** CPU Float64 construction/coordinates/prediction; metadata units descriptive, no automatic dimensional normalization.

**Ownership:** Copies starting parameters/native p to protect prior stage; exposes native solutions, states copied.

**Dependencies:** Lux; NeuralPDE; ModelingToolkit; Optimization; SymbolicIndexingInterface.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: BRIEF core; helper carries literal controls. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/scientific_ml/pinn.jl:73; src/scientific_ml/pinn.jl:75; ext/AnalyticMathLabPINNExt.jl:100; ext/AnalyticMathLabPINNExt.jl:103.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:90; test/m10d_interoperability_learning.jl:29; examples/inference/neural_gate.jl:48.

```@raw html
<p>Repository resources: <a href="../repository/examples/inference/neural_gate.jl">examples/inference/neural_gate.jl</a>; <a href="../repository/ext/AnalyticMathLabPINNExt.jl">ext/AnalyticMathLabPINNExt.jl</a>; <a href="../repository/src/scientific_ml/pinn.jl">src/scientific_ml/pinn.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/m10d_interoperability_learning.jl">test/m10d_interoperability_learning.jl</a></p>
```

<!-- aml-contract: {"variant": 1, "digest": "eb6c5c90e5887f4fdce69ae1638a92b063a48e97b8d6353c0d48bf33ece0879c"} -->
### Dispatch contract 2

**Purpose and output:** DynamicsTrainingResult

**Source declarations and forwarding context:**

```text
train(m::Union{HamiltonianNN,UDEProblem},args...;kwargs...)=_dynamics_unavailable(train,m,args...)

function AML.train(m::Union{AML.HamiltonianNN,AML.UDEProblem},data;
initial_parameters::AbstractVector,reconstruct,optimizer,maxiters::Integer=100,
history_limit::Integer=100,objective_options=NamedTuple())
```

**Inputs:** HNN/UDE and data; required initial_parameters::AbstractVector,reconstruct,optimizer; maxiters=100,history_limit=100,objective_options

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError controls outside1:10000 or empty/nonfinite params/backend; objective errors propagate

**Numerical limitations:** History rolling last values (different from PINN first entries). Optimization AutoForwardDiff; reconstructed container explicit. No optimizer schedule/accuracy promise.

**Units:** No implicit physical units conversion; PINN diagnostics Float64 samples; learned dynamics uses backend numeric AD, prediction public Float64.

**Ownership:** Copies flat parameters, retains training data/source, history scalar only.

**Dependencies:** Lux; Optimization.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: Typed fallback only. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/scientific_ml/learned_dynamics.jl:68; ext/AnalyticMathLabDynamicsExt.jl:53.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:90; test/m10d_interoperability_learning.jl:29; examples/inference/neural_gate.jl:48.

```@raw html
<p>Repository resources: <a href="../repository/examples/inference/neural_gate.jl">examples/inference/neural_gate.jl</a>; <a href="../repository/ext/AnalyticMathLabDynamicsExt.jl">ext/AnalyticMathLabDynamicsExt.jl</a>; <a href="../repository/src/scientific_ml/learned_dynamics.jl">src/scientific_ml/learned_dynamics.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/m10d_interoperability_learning.jl">test/m10d_interoperability_learning.jl</a></p>
```

<!-- aml-contract: {"variant": 2, "digest": "61210399174626c286674b90ccec9a2371f02af0d417e5043c7408c79aa70916"} -->
### Dispatch contract 3

**Purpose and output:** ScientificLearningResult

The unqualified train(m,d;...) below is extension-local implementation context. The AML entrypoint is the typed ScientificModel/ScientificDataset wrapper shown with it; arbitrary inputs are not supported.

**Source declarations and forwarding context:**

```text
function train(m,d;initial_parameters::AbstractVector,optimizer,adtype,maxiters::Integer,
reconstruct=identity,history_limit::Integer=100)

train(m::ScientificModel,d::ScientificDataset;kwargs...)=_surrogate_extension().train(m,d;kwargs...)
```

**Inputs:** ScientificModel,Dataset; initial_parameters::AbstractVector,optimizer,adtype,maxiters required; reconstruct=identity,history_limit=100

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError maxiters outside1:100000/history outside1:10000 or empty/nonfinite parameters; ErrorException nonfinite history/final

**Numerical limitations:** Deterministic full batch of training only; scalar rolling history not memory cap. Optimization timing excludes preprocessing; global generalization unknown.

**Units:** Learning numeric outputs Float64 normalized/scaled; plotting Float64 view conversion, not units engine.

**Ownership:** Copies flat initial parameters; retains single borrowed dataset/native optimization objects.

**Dependencies:** Lux; Optimization; NeuralOperators.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: ABSENT core method. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: ext/AnalyticMathLabSurrogateExt.jl:77; src/scientific_ml/surrogates.jl:229.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:90; test/m10d_interoperability_learning.jl:29; examples/inference/neural_gate.jl:48.

```@raw html
<p>Repository resources: <a href="../repository/examples/inference/neural_gate.jl">examples/inference/neural_gate.jl</a>; <a href="../repository/ext/AnalyticMathLabSurrogateExt.jl">ext/AnalyticMathLabSurrogateExt.jl</a>; <a href="../repository/src/scientific_ml/surrogates.jl">src/scientific_ml/surrogates.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/m10d_interoperability_learning.jl">test/m10d_interoperability_learning.jl</a></p>
```

## [F27: Sampled PINN diagnostics](@id family-F27)

<!-- aml-api: {"symbol": "loss_breakdown", "family": "F27", "stability": "PUBLIC_EXPERIMENTAL", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [loss_breakdown](@id api-loss-breakdown)

**Identity:** generic function; F27; **PUBLIC_EXPERIMENTAL**; explicitly exported.

**Interpretation:** The PINNAnalysis accessor returns stored diagnostics in base without optional imports. Recomputing diagnostics from PINNTrainingResult requires the five-trigger PINN extension; the audited dependency list below applies to that route.

<!-- aml-contract: {"variant": 0, "digest": "e1b24c7ea7668ed4da77934011c528d40b42d30fe08a8913777157376883c4f3"} -->
**Purpose and output:** Stored loss diagnostic NamedTuple

**Source declarations and forwarding context:**

```text
function loss_breakdown(r::AML.PINNTrainingResult)

loss_breakdown(a::PINNAnalysis)=a.loss_diagnostics

loss_breakdown(r::PINNTrainingResult)=_pinn_extension().loss_breakdown(r)
```

**Inputs:** PINNAnalysis or PINNTrainingResult

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** No additional refusal specified in this audited route; raw records do not establish validation.

**Numerical limitations:** Unweighted costs and configured fixed weights, no inferred weight evolution or physical error.

**Units:** No implicit physical units conversion; PINN diagnostics Float64 samples; learned dynamics uses backend numeric AD, prediction public Float64.

**Ownership:** Borrows history/termination/defs/components; configured weights deepcopied.

**Dependencies:** Lux; NeuralPDE; ModelingToolkit; Optimization; SymbolicIndexingInterface.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: ABSENT independent public doc. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: ext/pinn_diagnostics.jl:74; src/scientific_ml/diagnostics.jl:71; src/scientific_ml/diagnostics.jl:72.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:91; test/pinn_diagnostics.jl:43.

```@raw html
<p>Repository resources: <a href="../repository/ext/pinn_diagnostics.jl">ext/pinn_diagnostics.jl</a>; <a href="../repository/src/scientific_ml/diagnostics.jl">src/scientific_ml/diagnostics.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/pinn_diagnostics.jl">test/pinn_diagnostics.jl</a></p>
```

<!-- aml-api: {"symbol": "PINNAnalysis", "family": "F27", "stability": "PUBLIC_EXPERIMENTAL", "qualified": false, "kind": "type / constructors", "variant_count": 1} -->
## [PINNAnalysis](@id api-PINNAnalysis)

**Identity:** type / constructors; F27; **PUBLIC_EXPERIMENTAL**; explicitly exported.

**Stored fields:** `training`, `residuals`, `reference`, `collocation_metadata`, `loss_diagnostics`, `adaptive_loss_metadata`, `evidence`, `provenance`, `limitations`. Immutable outer record; referenced payloads may still be mutable. Obtain validated outputs through the operations described below; a raw record constructor does not itself certify scientific consistency.

<!-- aml-contract: {"variant": 0, "digest": "3ef7660730a0dcb0fde3b9f0313b23673d5114cac80b0a96d032f50f07836804"} -->
**Purpose and output:** Retained training plus sampled residual/reference/loss diagnostics

**Source declarations and forwarding context:**

```text
struct PINNAnalysis <: AbstractAnalysis; raw generated field constructor: (training::PINNTrainingResult, residuals::Vector{NamedTuple}, reference::PropertyResult, collocation_metadata, loss_diagnostics, adaptive_loss_metadata::PropertyResult, evidence::PropertyResult, provenance, limitations::Vector{String})
```

**Inputs:** analyze(training) or raw fields

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** No additional refusal specified in this audited route; raw records do not establish validation.

**Numerical limitations:** Global correctness remains unknown.

**Units:** CPU Float64 construction/coordinates/prediction; metadata units descriptive, no automatic dimensional normalization.

**Ownership:** Strong trained result retention; arrays produced by diagnostics batch.

**Dependencies:** Lux; NeuralPDE; ModelingToolkit; Optimization; SymbolicIndexingInterface.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: DETAILED. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/scientific_ml/diagnostics.jl:54.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:91; test/pinn_diagnostics.jl:24.

```@raw html
<p>Repository resources: <a href="../repository/src/scientific_ml/diagnostics.jl">src/scientific_ml/diagnostics.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/pinn_diagnostics.jl">test/pinn_diagnostics.jl</a></p>
```

<!-- aml-api: {"symbol": "PINNPoints", "family": "F27", "stability": "PUBLIC_EXPERIMENTAL", "qualified": false, "kind": "type / constructors", "variant_count": 1} -->
## [PINNPoints](@id api-PINNPoints)

**Identity:** type / constructors; F27; **PUBLIC_EXPERIMENTAL**; explicitly exported.

**Stored fields:** `coordinates`, `generation`, `provenance`. Immutable outer record; referenced payloads may still be mutable. Obtain validated outputs through the operations described below; a raw record constructor does not itself certify scientific consistency.

<!-- aml-contract: {"variant": 0, "digest": "e8effbb080a04b1c7b609b742dedd7745c3792428f55ae0b2bd8343a9458304a"} -->
**Purpose and output:** Copied checked Float64 coordinates

**Source declarations and forwarding context:**

```text
struct PINNPoints

function PINNPoints(X::AbstractMatrix;generation::Symbol=:user_supplied,provenance=NamedTuple())
```

**Inputs:** CPU-compatible AbstractMatrix coordinate rows×samples; generation=:user_supplied,provenance

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError empty/nonreal/nonfinite/unrepresentable

**Numerical limitations:** Coordinate rows tied to residual block IV order or global reference order; labels/provenance caller metadata.

**Units:** CPU Float64 construction/coordinates/prediction; metadata units descriptive, no automatic dimensional normalization.

**Ownership:** Copies coordinates, retains provenance.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: DETAILED. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/scientific_ml/diagnostics.jl:5; src/scientific_ml/diagnostics.jl:9.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:91; test/m10a_inference_operators.jl:166; examples/operators/analysis_gate.jl:22.

```@raw html
<p>Repository resources: <a href="../repository/examples/operators/analysis_gate.jl">examples/operators/analysis_gate.jl</a>; <a href="../repository/src/scientific_ml/diagnostics.jl">src/scientific_ml/diagnostics.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/m10a_inference_operators.jl">test/m10a_inference_operators.jl</a></p>
```

<!-- aml-api: {"symbol": "sampled_summary", "family": "F27", "stability": "PUBLIC_EXPERIMENTAL", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [sampled_summary](@id api-sampled-summary)

**Identity:** generic function; F27; **PUBLIC_EXPERIMENTAL**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "a6c215980d4ed0f9ec0adf128df6e4615ed71c78d53c5acb445cb9fff8b092e6"} -->
**Purpose and output:** NamedTuple count/finite_count/rms/mean_absolute/max_absolute/sampled_l2/normalization

**Source declarations and forwarding context:**

```text
function sampled_summary(values)
```

**Inputs:** Iterable finite real residuals/errors

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** Empty/nonfinite/nonreal metrics unavailable (nothing); underlying iterable errors propagate

**Numerical limitations:** Unweighted finite samples no domain measure/global norm; promoted float including BigFloat; L2 can unavailable while RMS available.

**Units:** Float promotion per values, including BigFloat; not a universal Unitful path.

**Ownership:** Arrays replayed; non-array iterable materialized exactly once to avoid state/RNG double consumption.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: DETAILED. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/scientific_ml/diagnostics.jl:23.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:91; test/m10b_diagnostics.jl:7; examples/inference/lj_gate.jl:55.

```@raw html
<p>Repository resources: <a href="../repository/examples/inference/lj_gate.jl">examples/inference/lj_gate.jl</a>; <a href="../repository/src/scientific_ml/diagnostics.jl">src/scientific_ml/diagnostics.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/m10b_diagnostics.jl">test/m10b_diagnostics.jl</a></p>
```

## [F28: Parameter inference](@id family-F28)

<!-- aml-api: {"symbol": "infer_parameters", "family": "F28", "stability": "PUBLIC_EXPERIMENTAL", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [infer_parameters](@id api-infer-parameters)

**Identity:** generic function; F28; **PUBLIC_EXPERIMENTAL**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "b30d45d0ca9249a02d07955d2d7cc979dd09044d32105a2442a505a9f2175ee2"} -->
**Purpose and output:** ParameterInferenceResult

**Source declarations and forwarding context:**

```text
function infer_parameters(p::ParameterInferenceProblem,optimizer;kwargs...)

function infer_parameters(p::AML.ParameterInferenceProblem,optimizer;maxiters::Integer,
history_stride::Integer=10,history_capacity::Integer=1000,rank_rtol=1e-8,rank_atol=0.,kwargs...)
```

**Inputs:** Problem, explicit Optimization-compatible optimizer; required maxiters, history_stride=10,history_capacity=1000,rank tolerances/kwargs

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError missing Optimization or invalid positive history/iteration controls; native optimizer/forward failures propagate

**Numerical limitations:** Only backend-supported explicit bounds; no inferred positivity. history_capacity caps records only not native solver/model memory. Optimizer success not correct physics or global identifiability.

**Units:** Caller-declared numeric coordinate/parameter scales; solver Float64, Dual(Float64) supported locally. No units conversion.

**Ownership:** Fresh opt/result, strongly retained fitted native trajectory; no intermediate trajectories in history.

**Dependencies:** Optimization.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: BRIEF core + extension literal signature. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/scientific_ml/parameter_inference.jl:191; ext/AnalyticMathLabInferenceExt.jl:6.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:94; test/inference_base.jl:36; examples/inference/deterministic_gate.jl:27.

```@raw html
<p>Repository resources: <a href="../repository/examples/inference/deterministic_gate.jl">examples/inference/deterministic_gate.jl</a>; <a href="../repository/ext/AnalyticMathLabInferenceExt.jl">ext/AnalyticMathLabInferenceExt.jl</a>; <a href="../repository/src/scientific_ml/parameter_inference.jl">src/scientific_ml/parameter_inference.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/inference_base.jl">test/inference_base.jl</a></p>
```

<!-- aml-api: {"symbol": "inference_objective", "family": "F28", "stability": "PUBLIC_EXPERIMENTAL", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [inference_objective](@id api-inference-objective)

**Identity:** generic function; F28; **PUBLIC_EXPERIMENTAL**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "f9d760759a204561514c0f016caaab2b298aa35f2078f15fdd6463fbfaae3708"} -->
**Purpose and output:** Weighted/unweighted squared residual sum

**Source declarations and forwarding context:**

```text
function inference_objective(p::ParameterInferenceProblem,theta)
```

**Inputs:** Problem, theta

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** Prediction errors propagate

**Numerical limitations:** Not likelihood/noise model; weights supplied multiplying squares.

**Units:** Caller-declared numeric coordinate/parameter scales; solver Float64, Dual(Float64) supported locally. No units conversion.

**Ownership:** Per-call solve output temporary.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: BRIEF. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/scientific_ml/parameter_inference.jl:135.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:94; test/inference_base.jl:34; examples/inference/deterministic_gate.jl:32.

```@raw html
<p>Repository resources: <a href="../repository/examples/inference/deterministic_gate.jl">examples/inference/deterministic_gate.jl</a>; <a href="../repository/src/scientific_ml/parameter_inference.jl">src/scientific_ml/parameter_inference.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/inference_base.jl">test/inference_base.jl</a></p>
```

<!-- aml-api: {"symbol": "inference_predict", "family": "F28", "stability": "PUBLIC_EXPERIMENTAL", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [inference_predict](@id api-inference-predict)

**Identity:** generic function; F28; **PUBLIC_EXPERIMENTAL**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "a1623fc6001d7e32d265eba513ddb2a30f25f704a066be994aefd7cb6f75e9b8"} -->
**Purpose and output:** Variables×requested-times matrix

**Source declarations and forwarding context:**

```text
function inference_predict(p::ParameterInferenceProblem,theta,obs::ObservationSet=p.observations)
```

**Inputs:** Problem, theta in inferred order, obs default fit set

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError variable/units/time span mismatch; ErrorException failed/incomplete native solve; domain errors propagate

**Numerical limitations:** Direct forward solve must produce exact requested saved time vector and successful retcode; no partial success.

**Units:** Caller-declared numeric coordinate/parameter scales; solver Float64, Dual(Float64) supported locally. No units conversion.

**Ownership:** New output from native solve; no hidden observations.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: BRIEF. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/scientific_ml/parameter_inference.jl:128.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:94; test/inference_base.jl:33; examples/inference/lj_gate.jl:64.

```@raw html
<p>Repository resources: <a href="../repository/examples/inference/lj_gate.jl">examples/inference/lj_gate.jl</a>; <a href="../repository/src/scientific_ml/parameter_inference.jl">src/scientific_ml/parameter_inference.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/inference_base.jl">test/inference_base.jl</a></p>
```

<!-- aml-api: {"symbol": "InferenceParameters", "family": "F28", "stability": "PUBLIC_EXPERIMENTAL", "qualified": false, "kind": "type / constructors", "variant_count": 1} -->
## [InferenceParameters](@id api-InferenceParameters)

**Identity:** type / constructors; F28; **PUBLIC_EXPERIMENTAL**; explicitly exported.

**Stored fields:** `names`, `initial`, `inferred`, `indices`, `bounds`, `units`, `provenance`. Immutable outer record; referenced payloads may still be mutable. Obtain validated outputs through the operations described below; a raw record constructor does not itself certify scientific consistency.

<!-- aml-contract: {"variant": 0, "digest": "b07cd76ae30e0821474aad297186175c6ba6ad6677e05e43e11b7df222d942c8"} -->
**Purpose and output:** Float64 full vector/inferred indices/bounds

**Source declarations and forwarding context:**

```text
struct InferenceParameters

function InferenceParameters(names,initial;inferred,bounds=nothing,units=nothing,
provenance=NamedTuple())
```

**Inputs:** Full ordered names/initial; required inferred subset, bounds optional

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError duplicate/unknown inferred names, invalid/nonfinite initial/bounds; DimensionMismatch ordering lengths

**Numerical limitations:** Bounds inferred order can contain infinities, no transform/positivity invented.

**Units:** Caller-declared numeric coordinate/parameter scales; solver Float64, Dual(Float64) supported locally. No units conversion.

**Ownership:** Copies numeric values and bounds; units/provenance retained.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: DETAILED. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/scientific_ml/parameter_inference.jl:4; src/scientific_ml/parameter_inference.jl:12.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:93; test/inference_base.jl:25; examples/inference/deterministic_gate.jl:21.

```@raw html
<p>Repository resources: <a href="../repository/examples/inference/deterministic_gate.jl">examples/inference/deterministic_gate.jl</a>; <a href="../repository/src/scientific_ml/parameter_inference.jl">src/scientific_ml/parameter_inference.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/inference_base.jl">test/inference_base.jl</a></p>
```

<!-- aml-api: {"symbol": "local_sensitivity", "family": "F28", "stability": "PUBLIC_EXPERIMENTAL", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [local_sensitivity](@id api-local-sensitivity)

**Identity:** generic function; F28; **PUBLIC_EXPERIMENTAL**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "543cedfbe97e2ccf85cdde535d9546da141a6fdae7f8fccf7630bac4cdf4c97c"} -->
**Purpose and output:** Heuristic PropertyResult observation Jacobian, weighted SVD, rank/order/collinearity

**Source declarations and forwarding context:**

```text
function local_sensitivity(p::ParameterInferenceProblem,theta;rank_rtol=1e-8,rank_atol=0.)
```

**Inputs:** Problem, theta; rank_rtol=1e-8,rank_atol=0.

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError invalid/nonfinite tolerances/parameter/conversion/J/threshold; solve errors propagate

**Numerical limitations:** Local scale/unit dependent, not global/structural identifiability or posterior correlation. rank deficient condition Inf; zero column cosines NaN deliberate diagnostic.

**Units:** Caller-declared numeric coordinate/parameter scales; solver Float64, Dual(Float64) supported locally. No units conversion.

**Ownership:** New Jacobian/SVD arrays no intermediate history stored.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: DETAILED. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/scientific_ml/parameter_inference.jl:145.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:94; test/inference_base.jl:44.

```@raw html
<p>Repository resources: <a href="../repository/src/scientific_ml/parameter_inference.jl">src/scientific_ml/parameter_inference.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/inference_base.jl">test/inference_base.jl</a></p>
```

<!-- aml-api: {"symbol": "ObservationSet", "family": "F28", "stability": "PUBLIC_EXPERIMENTAL", "qualified": false, "kind": "type / constructors", "variant_count": 1} -->
## [ObservationSet](@id api-ObservationSet)

**Identity:** type / constructors; F28; **PUBLIC_EXPERIMENTAL**; explicitly exported.

**Stored fields:** `times`, `values`, `variables`, `units`, `weights`, `kind`, `role`, `provenance`. Immutable outer record; referenced payloads may still be mutable. Obtain validated outputs through the operations described below; a raw record constructor does not itself certify scientific consistency.

<!-- aml-contract: {"variant": 0, "digest": "6154c7d6f240133f8cc26ef511d64db62cc0d7c4566d55231de8fff7f647b833"} -->
**Purpose and output:** Frozen Float64 numeric observations

**Source declarations and forwarding context:**

```text
struct ObservationSet

function ObservationSet(s::ObservableSeries;time_scale=nothing,length_scale=nothing,
weights=nothing,kind=:user_supplied,role=:fit)

function ObservationSet(times,values::AbstractMatrix;variables,units=nothing,
weights=nothing,kind=:user_supplied,role=:fit,provenance=NamedTuple())
```

**Inputs:** times,variables×times matrix; required variable names; optional units/weights/kind/role/provenance; or ObservableSeries with explicit scales

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** DimensionMismatch shape/weights; ArgumentError empty/duplicate identities/nonfinite/bad roles/kinds/nonincreasing times/invalid or allzero weights; series refuses unknown/index times and implicit Unitful stripping

**Numerical limitations:** Weights multiply squared residuals, not inferred inverse noise variance. Main factory checked Float64/no nonzero underflow. Series bridge divides by scales then Float64 before checked factory: earlier underflow/rounding not recovered; precision limitation must remain explicit.

**Units:** Inference numeric coordinate system explicitly scaled; unit strings descriptive not conversion.

**Ownership:** Copies numeric times/values/weights; units/provenance retained and series strong source retained.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: DETAILED type+bridge. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/scientific_ml/inference.jl:6; src/scientific_ml/trajectory_inference.jl:45; src/scientific_ml/inference.jl:15.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:93; test/inference_base.jl:10; examples/inference/deterministic_gate.jl:17.

```@raw html
<p>Repository resources: <a href="../repository/examples/inference/deterministic_gate.jl">examples/inference/deterministic_gate.jl</a>; <a href="../repository/src/scientific_ml/inference.jl">src/scientific_ml/inference.jl</a>; <a href="../repository/src/scientific_ml/trajectory_inference.jl">src/scientific_ml/trajectory_inference.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/inference_base.jl">test/inference_base.jl</a></p>
```

<!-- aml-api: {"symbol": "ParameterInferenceProblem", "family": "F28", "stability": "PUBLIC_EXPERIMENTAL", "qualified": false, "kind": "type / constructors", "variant_count": 1} -->
## [ParameterInferenceProblem](@id api-ParameterInferenceProblem)

**Identity:** type / constructors; F28; **PUBLIC_EXPERIMENTAL**; explicitly exported.

**Stored fields:** `factory`, `model`, `native_problem`, `parameters`, `observations`, `heldout`, `indices`, `solver`, `reference`, `provenance`. Immutable outer record; referenced payloads may still be mutable. Obtain validated outputs through the operations described below; a raw record constructor does not itself certify scientific consistency.

<!-- aml-contract: {"variant": 0, "digest": "d4a2c2aaa1c6d2cc86f0cdd5b159631fce66d9e8d8665cf1f6d788d8e9c453d7"} -->
**Purpose and output:** Initial FirstOrderODE and native ODEProblem plus explicit fit schema

**Source declarations and forwarding context:**

```text
struct ParameterInferenceProblem <: AbstractAnalysis; raw generated field constructor: (factory, model::FirstOrderODE, native_problem, parameters::InferenceParameters, observations::ObservationSet, heldout, indices::Vector{Int}, solver, reference, provenance)

function ParameterInferenceProblem(factory,spec::InferenceParameters,obs::ObservationSet;
u0,tspan,heldout=nothing,algorithm=OrdinaryDiffEqTsit5.Tsit5(),
abstol=1e-10,reltol=1e-9,maxiters=100_000,reference=nothing,provenance=NamedTuple())
```

**Inputs:** factory(full_parameters), spec, fit observations; required u0/tspan; optional heldout/algorithm/abstol/reltol/maxiters/reference/provenance

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError factory/layout/unbound control/role/reference/heldout ordering/time overlap errors; DimensionMismatch state; DomainError domain/RHS

**Numerical limitations:** Factory called through RHS and must support ForwardDiff duals with same layout; Float64 native solve. Reference kind synthetic_truth only with synthetic observations. Heldout excluded from objective.

**Units:** Caller-declared numeric coordinate/parameter scales; solver Float64, Dual(Float64) supported locally. No units conversion.

**Ownership:** Strong factory/model/native/data/source retention.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: DETAILED type. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/scientific_ml/parameter_inference.jl:46; src/scientific_ml/parameter_inference.jl:59.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:93; test/inference_base.jl:22; examples/inference/deterministic_gate.jl:23.

```@raw html
<p>Repository resources: <a href="../repository/examples/inference/deterministic_gate.jl">examples/inference/deterministic_gate.jl</a>; <a href="../repository/src/scientific_ml/parameter_inference.jl">src/scientific_ml/parameter_inference.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/inference_base.jl">test/inference_base.jl</a></p>
```

<!-- aml-api: {"symbol": "ParameterInferenceResult", "family": "F28", "stability": "PUBLIC_EXPERIMENTAL", "qualified": false, "kind": "type / constructors", "variant_count": 1} -->
## [ParameterInferenceResult](@id api-ParameterInferenceResult)

**Identity:** type / constructors; F28; **PUBLIC_EXPERIMENTAL**; explicitly exported.

**Stored fields:** `problem`, `optimization_problem`, `solution`, `parameters`, `full_parameters`, `trajectory`, `prediction`, `fit`, `heldout`, `sensitivity`, `reference_comparison`, `history`, `termination`, `optimizer`, `objective`, `evidence`, `provenance`, `limitations`. Immutable outer record; referenced payloads may still be mutable. Obtain validated outputs through the operations described below; a raw record constructor does not itself certify scientific consistency.

<!-- aml-contract: {"variant": 0, "digest": "e357a04c53cf1e44eab5576ed7c058aacda1617de29042070963b8426d1c32ca"} -->
**Purpose and output:** Native optimization/forward result plus fit/heldout/local sensitivity/reference/history/termination

**Source declarations and forwarding context:**

```text
struct ParameterInferenceResult <: AbstractAnalysis; raw generated field constructor: (problem::ParameterInferenceProblem, optimization_problem, solution, parameters, full_parameters, trajectory, prediction, fit, heldout, sensitivity::PropertyResult, reference_comparison, history, termination, optimizer, objective, evidence::PropertyResult, provenance, limitations::Vector{String})
```

**Inputs:** infer_parameters or raw fields

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** No additional refusal specified in this audited route; raw records do not establish validation.

**Numerical limitations:** Physics evidence independently unknown even backend_success; no posterior/interval.

**Units:** Caller-declared numeric coordinate/parameter scales; solver Float64, Dual(Float64) supported locally. No units conversion.

**Ownership:** Strong problem/native result/fitted trajectory retention; bounded scalar history.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: DETAILED. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/scientific_ml/parameter_inference.jl:169.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:93.

```@raw html
<p>Repository resources: <a href="../repository/src/scientific_ml/parameter_inference.jl">src/scientific_ml/parameter_inference.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a></p>
```

## [F29: Distance-observation bridge](@id family-F29)

<!-- aml-api: {"symbol": "distance_observations", "family": "F29", "stability": "PUBLIC_EXPERIMENTAL", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [distance_observations](@id api-distance-observations)

**Identity:** generic function; F29; **PUBLIC_EXPERIMENTAL**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "3e9c7a0dd978c292125a640c91caaccf29999296b8ca9c88d7e147a65cc8f91c"} -->
**Purpose and output:** Frozen distance ObservableSeries

**Source declarations and forwarding context:**

```text
function distance_observations(view::AtomisticTrajectoryView,pair::Tuple;
frames=1:length(view),name=:r,units=nothing)
```

**Inputs:** View and explicit pair; increasing selected frames; name=:r,units=nothing

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError invalid pair/frames/positions/boundary/time conflicts/distance; sampling validation errors

**Numerical limitations:** No unknown time inference; partial time missing -> all times unknown; explicit backend/minimum image; labels not conversion; fixed identity meaning caller responsibility.

**Units:** Compatible Unitful arithmetic preserved; units unknown for plain values; variance/covariance squared units. Time spacing does not infer simulation dt.

**Ownership:** Fresh values/times/frame metadata deepcopies, strong source view retained.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: DETAILED. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/scientific_ml/trajectory_inference.jl:10.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:95; test/m10a_inference_operators.jl:136; examples/inference/lj_gate.jl:25.

```@raw html
<p>Repository resources: <a href="../repository/examples/inference/lj_gate.jl">examples/inference/lj_gate.jl</a>; <a href="../repository/src/scientific_ml/trajectory_inference.jl">src/scientific_ml/trajectory_inference.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/m10a_inference_operators.jl">test/m10a_inference_operators.jl</a></p>
```

## [F30: Learned dynamics](@id family-F30)

<!-- aml-api: {"symbol": "aligned_energy", "family": "F30", "stability": "PUBLIC_EXPERIMENTAL", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [aligned_energy](@id api-aligned-energy)

**Identity:** generic function; F30; **PUBLIC_EXPERIMENTAL**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "ce7c55f85791f5f9130f44369adc481d69a1f7a6c8b0a6399972cba7cab715f3"} -->
**Purpose and output:** Learned H(u)−H(reference)

**Source declarations and forwarding context:**

```text
aligned_energy(m::HamiltonianNN,args...;kwargs...)=_dynamics_unavailable(aligned_energy,m,args...)

AML.aligned_energy(m::AML.HamiltonianNN,u;reference) = AML.learned_energy(m,u)-AML.learned_energy(m,reference)
```

**Inputs:** HamiltonianNN,u; required reference

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** Learned-energy errors propagate

**Numerical limitations:** Offset alignment not independent energy validation.

**Units:** No implicit physical units conversion; PINN diagnostics Float64 samples; learned dynamics uses backend numeric AD, prediction public Float64.

**Ownership:** No new training.

**Dependencies:** Lux; Optimization.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: EMPTY generic+typed fallback. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/scientific_ml/learned_dynamics.jl:64; ext/AnalyticMathLabDynamicsExt.jl:17.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:97; examples/inference/m10a_gate.jl:27.

```@raw html
<p>Repository resources: <a href="../repository/examples/inference/m10a_gate.jl">examples/inference/m10a_gate.jl</a>; <a href="../repository/ext/AnalyticMathLabDynamicsExt.jl">ext/AnalyticMathLabDynamicsExt.jl</a>; <a href="../repository/src/scientific_ml/learned_dynamics.jl">src/scientific_ml/learned_dynamics.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a></p>
```

<!-- aml-api: {"symbol": "DerivativeData", "family": "F30", "stability": "PUBLIC_EXPERIMENTAL", "qualified": false, "kind": "type / constructors", "variant_count": 1} -->
## [DerivativeData](@id api-DerivativeData)

**Identity:** type / constructors; F30; **PUBLIC_EXPERIMENTAL**; explicitly exported.

**Stored fields:** `states`, `derivatives`. Immutable outer record; referenced payloads may still be mutable. Obtain validated outputs through the operations described below; a raw record constructor does not itself certify scientific consistency.

<!-- aml-contract: {"variant": 0, "digest": "b1cb0a24b0c97c4bfcf4483b4d6e4c3cfd3e454243e39ce58a751f2f71e050b5"} -->
**Purpose and output:** Borrowed derivative data

**Source declarations and forwarding context:**

```text
struct DerivativeData{X,Y}

function DerivativeData(x::AbstractMatrix,y::AbstractMatrix)
```

**Inputs:** State/derivative matrices equal nonempty finite sizes

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** DimensionMismatch shapes; ArgumentError nonfinite/empty

**Numerical limitations:** Columns states canonical q...,p... convention but not independently symbol-validated; no Float64 normalization here.

**Units:** No implicit physical units conversion; PINN diagnostics Float64 samples; learned dynamics uses backend numeric AD, prediction public Float64.

**Ownership:** Borrows both matrices.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: BRIEF. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/scientific_ml/learned_dynamics.jl:2; src/scientific_ml/learned_dynamics.jl:5.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:95; test/learned_dynamics_base.jl:7; examples/inference/m10a_gate.jl:30.

```@raw html
<p>Repository resources: <a href="../repository/examples/inference/m10a_gate.jl">examples/inference/m10a_gate.jl</a>; <a href="../repository/src/scientific_ml/learned_dynamics.jl">src/scientific_ml/learned_dynamics.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/learned_dynamics_base.jl">test/learned_dynamics_base.jl</a></p>
```

<!-- aml-api: {"symbol": "dynamics_objective", "family": "F30", "stability": "PUBLIC_EXPERIMENTAL", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [dynamics_objective](@id api-dynamics-objective)

**Identity:** generic function; F30; **PUBLIC_EXPERIMENTAL**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "fb51c9828acc98682f1dd3359cab2d0a806182c22c28ecfb283fef299734c933"} -->
**Purpose and output:** Mean squared derivative/trajectory mismatch

**Source declarations and forwarding context:**

```text
dynamics_objective(m::Union{HamiltonianNN,UDEProblem},args...;kwargs...)=_dynamics_unavailable(dynamics_objective,m,args...)

function AML.dynamics_objective(m::AML.HamiltonianNN,data::AML.DerivativeData)

function AML.dynamics_objective(m::AML.UDEProblem,data::AML.TrajectoryData;
algorithm=OrdinaryDiffEqTsit5.Tsit5(),abstol=1e-9,reltol=1e-7,maxiters=10000)
```

**Inputs:** HamiltonianNN+DerivativeData or UDEProblem+TrajectoryData and explicit solver options

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ErrorException UDE trajectory did not complete; dimension/domain/network errors

**Numerical limitations:** UDE solve native differentiable, not public Float64 presentation boundary. No likelihood/physics certificate.

**Units:** No implicit physical units conversion; PINN diagnostics Float64 samples; learned dynamics uses backend numeric AD, prediction public Float64.

**Ownership:** Temporary native trajectory; input data borrowed.

**Dependencies:** Lux; Optimization.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: EMPTY generic+typed fallback. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/scientific_ml/learned_dynamics.jl:67; ext/AnalyticMathLabDynamicsExt.jl:21; ext/AnalyticMathLabDynamicsExt.jl:38.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:97; examples/inference/m10a_gate.jl:31.

```@raw html
<p>Repository resources: <a href="../repository/examples/inference/m10a_gate.jl">examples/inference/m10a_gate.jl</a>; <a href="../repository/ext/AnalyticMathLabDynamicsExt.jl">ext/AnalyticMathLabDynamicsExt.jl</a>; <a href="../repository/src/scientific_ml/learned_dynamics.jl">src/scientific_ml/learned_dynamics.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a></p>
```

<!-- aml-api: {"symbol": "DynamicsTrainingResult", "family": "F30", "stability": "PUBLIC_EXPERIMENTAL", "qualified": false, "kind": "type / constructors", "variant_count": 1} -->
## [DynamicsTrainingResult](@id api-DynamicsTrainingResult)

**Identity:** type / constructors; F30; **PUBLIC_EXPERIMENTAL**; explicitly exported.

**Stored fields:** `model`, `solution`, `history`, `provenance`. Immutable outer record; referenced payloads may still be mutable. Obtain validated outputs through the operations described below; a raw record constructor does not itself certify scientific consistency.

<!-- aml-contract: {"variant": 0, "digest": "f112ad4e74221447420df1fbf510c64e55019c190ab5b93b13a41d884afc49b0"} -->
**Purpose and output:** Fitted model/native optimizer result/bounded history/provenance

**Source declarations and forwarding context:**

```text
struct DynamicsTrainingResult{M,S,H,P}; raw generated field constructor: (model::M, solution::S, history::H, provenance::P)
```

**Inputs:** train or raw fields

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** No additional refusal specified in this audited route; raw records do not establish validation.

**Numerical limitations:** Local fit not global physics; native success not correctness.

**Units:** No implicit physical units conversion; PINN diagnostics Float64 samples; learned dynamics uses backend numeric AD, prediction public Float64.

**Ownership:** Retains model/solution/training data in provenance.

**Dependencies:** Lux; Optimization.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: BRIEF. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/scientific_ml/learned_dynamics.jl:44.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:96.

```@raw html
<p>Repository resources: <a href="../repository/src/scientific_ml/learned_dynamics.jl">src/scientific_ml/learned_dynamics.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a></p>
```

<!-- aml-api: {"symbol": "HamiltonianNN", "family": "F30", "stability": "PUBLIC_EXPERIMENTAL", "qualified": false, "kind": "type / constructors", "variant_count": 1} -->
## [HamiltonianNN](@id api-HamiltonianNN)

**Identity:** type / constructors; F30; **PUBLIC_EXPERIMENTAL**; explicitly exported.

**Stored fields:** `mechanics`, `network`, `parameters`, `state`. Immutable outer record; referenced payloads may still be mutable. Obtain validated outputs through the operations described below; a raw record constructor does not itself certify scientific consistency.

<!-- aml-contract: {"variant": 0, "digest": "0608008419f2a75014e631a6fb6cde384faec04ae2bd67eefbf0c2925cde729e"} -->
**Purpose and output:** Lux scalar Hamiltonian model

**Source declarations and forwarding context:**

```text
struct HamiltonianNN{A,N,P,S}; raw generated field constructor: (mechanics::A, network::N, parameters::P, state::S)
```

**Inputs:** Mechanics canonical report/network/parameters/state raw constructor

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** No additional refusal specified in this audited route; raw records do not establish validation.

**Numerical limitations:** Not trained on analytic reference energy; H+C generates same dynamics. Raw fields permissive; genuine output/state checked on use.

**Units:** No implicit physical units conversion; PINN diagnostics Float64 samples; learned dynamics uses backend numeric AD, prediction public Float64.

**Ownership:** Retains network/source/parameters/state.

**Dependencies:** Lux; Optimization.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: BRIEF. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/scientific_ml/learned_dynamics.jl:23.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:95; test/learned_dynamics_base.jl:4; examples/inference/m10a_gate.jl:15.

```@raw html
<p>Repository resources: <a href="../repository/examples/inference/m10a_gate.jl">examples/inference/m10a_gate.jl</a>; <a href="../repository/src/scientific_ml/learned_dynamics.jl">src/scientific_ml/learned_dynamics.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/learned_dynamics_base.jl">test/learned_dynamics_base.jl</a></p>
```

<!-- aml-api: {"symbol": "learned_correction", "family": "F30", "stability": "PUBLIC_EXPERIMENTAL", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [learned_correction](@id api-learned-correction)

**Identity:** generic function; F30; **PUBLIC_EXPERIMENTAL**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "4f085f3f358fe4ace749e81a902126f5c987927433118585221b2e7cbe4f8590"} -->
**Purpose and output:** Full vector with network output on selected indices and zeros elsewhere

**Source declarations and forwarding context:**

```text
learned_correction(m::UDEProblem,args...;kwargs...)=_dynamics_unavailable(learned_correction,m,args...)

function AML.learned_correction(m::AML.UDEProblem,u,t=0.)
```

**Inputs:** UDEProblem,u,t default0

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** DimensionMismatch state/network; DomainError output; ArgumentError state/missing backend

**Numerical limitations:** Correction network receives state not explicit time; no symbolic discovery.

**Units:** No implicit physical units conversion; PINN diagnostics Float64 samples; learned dynamics uses backend numeric AD, prediction public Float64.

**Ownership:** Fresh correction vector.

**Dependencies:** Lux; Optimization.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: EMPTY generic+typed fallback. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/scientific_ml/learned_dynamics.jl:65; ext/AnalyticMathLabDynamicsExt.jl:24.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:96; test/m10d_user_optional.jl:45; examples/inference/m10a_gate.jl:49.

```@raw html
<p>Repository resources: <a href="../repository/examples/inference/m10a_gate.jl">examples/inference/m10a_gate.jl</a>; <a href="../repository/ext/AnalyticMathLabDynamicsExt.jl">ext/AnalyticMathLabDynamicsExt.jl</a>; <a href="../repository/src/scientific_ml/learned_dynamics.jl">src/scientific_ml/learned_dynamics.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/m10d_user_optional.jl">test/m10d_user_optional.jl</a></p>
```

<!-- aml-api: {"symbol": "learned_energy", "family": "F30", "stability": "PUBLIC_EXPERIMENTAL", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [learned_energy](@id api-learned-energy)

**Identity:** generic function; F30; **PUBLIC_EXPERIMENTAL**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "25fbebe4ff3e54cbecd577b51f6cf9a39cafe3c2785f607e151d92c0deaab186"} -->
**Purpose and output:** Scalar learned energy

**Source declarations and forwarding context:**

```text
learned_energy(m::HamiltonianNN,args...;kwargs...)=_dynamics_unavailable(learned_energy,m,args...)

function AML.learned_energy(m::AML.HamiltonianNN,u)
```

**Inputs:** HamiltonianNN,u

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** DimensionMismatch canonical length or scalar output; DomainError nonfinite; ArgumentError changing state/missing backend

**Numerical limitations:** No original mechanics domain gate in learned_energy; absolute energy unidentifiable from derivatives.

**Units:** No implicit physical units conversion; PINN diagnostics Float64 samples; learned dynamics uses backend numeric AD, prediction public Float64.

**Ownership:** Uses stored parameters/state without setup.

**Dependencies:** Lux; Optimization.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: EMPTY generic+typed fallback. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/scientific_ml/learned_dynamics.jl:63; ext/AnalyticMathLabDynamicsExt.jl:13.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:96; test/m10d_extensions.jl:62; examples/inference/m10a_gate.jl:23.

```@raw html
<p>Repository resources: <a href="../repository/examples/inference/m10a_gate.jl">examples/inference/m10a_gate.jl</a>; <a href="../repository/ext/AnalyticMathLabDynamicsExt.jl">ext/AnalyticMathLabDynamicsExt.jl</a>; <a href="../repository/src/scientific_ml/learned_dynamics.jl">src/scientific_ml/learned_dynamics.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/m10d_extensions.jl">test/m10d_extensions.jl</a></p>
```

<!-- aml-api: {"symbol": "learned_vector_field", "family": "F30", "stability": "PUBLIC_EXPERIMENTAL", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [learned_vector_field](@id api-learned-vector-field)

**Identity:** generic function; F30; **PUBLIC_EXPERIMENTAL**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "8b68a3774bb099f30ca312a041f60ccd903d5ba662133778c88d6d6c88826efd"} -->
**Purpose and output:** Canonical J∇H or known RHS+selected learned correction

**Source declarations and forwarding context:**

```text
learned_vector_field(m::Union{HamiltonianNN,UDEProblem},args...;kwargs...)=_dynamics_unavailable(learned_vector_field,m,args...)

function AML.learned_vector_field(m::AML.HamiltonianNN,u,t=0.)

function AML.learned_vector_field(m::AML.UDEProblem,u,t=0.)
```

**Inputs:** HamiltonianNN or UDEProblem,u,t default0

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** DomainError UDE known-domain/notfinite; DimensionMismatch; ArgumentError state/missing backend

**Numerical limitations:** HNN formal canonical structure but no original mechanics domain certification; UDE known-domain exactly true.

**Units:** No implicit physical units conversion; PINN diagnostics Float64 samples; learned dynamics uses backend numeric AD, prediction public Float64.

**Ownership:** Fresh field, stored source retained.

**Dependencies:** Lux; Optimization.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: EMPTY generic+typed fallback. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/scientific_ml/learned_dynamics.jl:66; ext/AnalyticMathLabDynamicsExt.jl:18; ext/AnalyticMathLabDynamicsExt.jl:29.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:96; test/m10d_user_inputs.jl:48; examples/inference/m10a_gate.jl:25.

```@raw html
<p>Repository resources: <a href="../repository/examples/inference/m10a_gate.jl">examples/inference/m10a_gate.jl</a>; <a href="../repository/ext/AnalyticMathLabDynamicsExt.jl">ext/AnalyticMathLabDynamicsExt.jl</a>; <a href="../repository/src/scientific_ml/learned_dynamics.jl">src/scientific_ml/learned_dynamics.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/m10d_user_inputs.jl">test/m10d_user_inputs.jl</a></p>
```

<!-- aml-api: {"symbol": "TrajectoryData", "family": "F30", "stability": "PUBLIC_EXPERIMENTAL", "qualified": false, "kind": "type / constructors", "variant_count": 1} -->
## [TrajectoryData](@id api-TrajectoryData)

**Identity:** type / constructors; F30; **PUBLIC_EXPERIMENTAL**; explicitly exported.

**Stored fields:** `times`, `states`. Immutable outer record; referenced payloads may still be mutable. Obtain validated outputs through the operations described below; a raw record constructor does not itself certify scientific consistency.

<!-- aml-contract: {"variant": 0, "digest": "9d5851c9ab31a3090bb556efe76ea7a5c977c8d4a388da32bd8bc26eb5e6277b"} -->
**Purpose and output:** Borrowed trajectory training data

**Source declarations and forwarding context:**

```text
struct TrajectoryData{T,Y}

function TrajectoryData(t::AbstractVector,y::AbstractMatrix)
```

**Inputs:** Strict increasing finite t AbstractVector, y states×times

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** DimensionMismatch time columns; ArgumentError invalid states/time

**Numerical limitations:** At least2 times; generic finite data not automatic physical units/reference.

**Units:** No implicit physical units conversion; PINN diagnostics Float64 samples; learned dynamics uses backend numeric AD, prediction public Float64.

**Ownership:** Borrows t/y.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: BRIEF. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/scientific_ml/learned_dynamics.jl:12; src/scientific_ml/learned_dynamics.jl:15.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:95; test/learned_dynamics_base.jl:9; examples/inference/m10a_gate.jl:57.

```@raw html
<p>Repository resources: <a href="../repository/examples/inference/m10a_gate.jl">examples/inference/m10a_gate.jl</a>; <a href="../repository/src/scientific_ml/learned_dynamics.jl">src/scientific_ml/learned_dynamics.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/learned_dynamics_base.jl">test/learned_dynamics_base.jl</a></p>
```

<!-- aml-api: {"symbol": "UDEProblem", "family": "F30", "stability": "PUBLIC_EXPERIMENTAL", "qualified": false, "kind": "type / constructors", "variant_count": 1} -->
## [UDEProblem](@id api-UDEProblem)

**Identity:** type / constructors; F30; **PUBLIC_EXPERIMENTAL**; explicitly exported.

**Stored fields:** `known`, `network`, `parameters`, `state`, `correction_indices`. Immutable outer record; referenced payloads may still be mutable. Obtain validated outputs through the operations described below; a raw record constructor does not itself certify scientific consistency.

<!-- aml-contract: {"variant": 0, "digest": "c9ff17d859ba427c200db88e70a4e97973fc93875727967337f61f88bb1aa951"} -->
**Purpose and output:** Known ODE plus inspectable correction

**Source declarations and forwarding context:**

```text
struct UDEProblem{O,N,P,S,I}

function UDEProblem(known::FirstOrderODE,network,parameters,state; correction_indices=Tuple(1:known.dimension))
```

**Inputs:** Known FirstOrderODE,network/parameters/state; correction_indices default all

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError empty/duplicate/out-ofrange indices

**Numerical limitations:** Correction selection explicit; no equation discovery.

**Units:** No implicit physical units conversion; PINN diagnostics Float64 samples; learned dynamics uses backend numeric AD, prediction public Float64.

**Ownership:** Borrows known/network/parameters/state; indices tuple.

**Dependencies:** Lux; Optimization.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: BRIEF. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/scientific_ml/learned_dynamics.jl:30; src/scientific_ml/learned_dynamics.jl:36.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:95; test/learned_dynamics_base.jl:6; examples/inference/m10a_gate.jl:44.

```@raw html
<p>Repository resources: <a href="../repository/examples/inference/m10a_gate.jl">examples/inference/m10a_gate.jl</a>; <a href="../repository/src/scientific_ml/learned_dynamics.jl">src/scientific_ml/learned_dynamics.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/learned_dynamics_base.jl">test/learned_dynamics_base.jl</a></p>
```

## [F33: Scientific surrogate and operator learning](@id family-F33)

<!-- aml-api: {"symbol": "learning_model", "family": "F33", "stability": "PUBLIC_EXPERIMENTAL", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [learning_model](@id api-learning-model)

**Identity:** generic function; F33; **PUBLIC_EXPERIMENTAL**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "c95ceb82c082fff40fc30b4bd6b62331688334ffac38ee93ab481601495e9779"} -->
**Purpose and output:** ScientificModel

**Source declarations and forwarding context:**

```text
function learning_model(d,network;rng,normalization::Symbol,rng_provenance)

learning_model(d::ScientificDataset,network;kwargs...)=_surrogate_extension().learning_model(d,network;kwargs...)
```

**Inputs:** Dataset,network; required rng,normalization::Symbol,rng_provenance

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError missing three-trigger extension/normalization/operator network mismatch; output shape/state errors

**Numerical limitations:** Even plain surrogate requires NeuralOperators trigger; operator DeepONet only. normalization none still computes fit_scaling before identity maps. Explicit RNG provenance not inferred.

**Units:** Learning numeric outputs Float64 normalized/scaled; plotting Float64 view conversion, not units engine.

**Ownership:** Deepcopies schema; stores network/setupf64/testmode state and bounded origin/reference descriptors, no dataset targets.

**Dependencies:** Lux; Optimization; NeuralOperators.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: ABSENT core method. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: ext/AnalyticMathLabSurrogateExt.jl:5; src/scientific_ml/surrogates.jl:226.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:100; test/m10d_extensions.jl:59; examples/integration/one_system_learning.jl:52.

```@raw html
<p>Repository resources: <a href="../repository/examples/integration/one_system_learning.jl">examples/integration/one_system_learning.jl</a>; <a href="../repository/ext/AnalyticMathLabSurrogateExt.jl">ext/AnalyticMathLabSurrogateExt.jl</a>; <a href="../repository/src/scientific_ml/surrogates.jl">src/scientific_ml/surrogates.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/m10d_extensions.jl">test/m10d_extensions.jl</a></p>
```

<!-- aml-api: {"symbol": "learning_objective", "family": "F33", "stability": "PUBLIC_EXPERIMENTAL", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [learning_objective](@id api-learning-objective)

**Identity:** generic function; F33; **PUBLIC_EXPERIMENTAL**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "3aeb9fefdccb1ea17a98d8c3d8d5ac27a1ea9c07da6b78dab7120b14d5be368c"} -->
**Purpose and output:** Normalized squared loss

**Source declarations and forwarding context:**

```text
function learning_objective(m,p,b)

learning_objective(m::ScientificModel,p,b::LearningBatch)=_surrogate_extension().learning_objective(m,p,b)
```

**Inputs:** Model,native parameter container,LearningBatch

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** DomainError nonfinite loss; backend shape/AD errors

**Numerical limitations:** Not physical error. This method ignores returned Lux state; prediction separately enforces no state change.

**Units:** Learning numeric outputs Float64 normalized/scaled; plotting Float64 view conversion, not units engine.

**Ownership:** Backend forward allocations, no source copy.

**Dependencies:** Lux; Optimization; NeuralOperators.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: ABSENT. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: ext/AnalyticMathLabSurrogateExt.jl:71; src/scientific_ml/surrogates.jl:228.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:101; test/m10d_interoperability_learning.jl:28; examples/integration/one_system_learning.jl:55.

```@raw html
<p>Repository resources: <a href="../repository/examples/integration/one_system_learning.jl">examples/integration/one_system_learning.jl</a>; <a href="../repository/ext/AnalyticMathLabSurrogateExt.jl">ext/AnalyticMathLabSurrogateExt.jl</a>; <a href="../repository/src/scientific_ml/surrogates.jl">src/scientific_ml/surrogates.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/m10d_interoperability_learning.jl">test/m10d_interoperability_learning.jl</a></p>
```

<!-- aml-api: {"symbol": "ScientificLearningResult", "family": "F33", "stability": "PUBLIC_EXPERIMENTAL", "qualified": false, "kind": "type / constructors", "variant_count": 1} -->
## [ScientificLearningResult](@id api-ScientificLearningResult)

**Identity:** type / constructors; F33; **PUBLIC_EXPERIMENTAL**; explicitly exported.

**Stored fields:** `model`, `dataset`, `optimization_problem`, `solution`, `optimizer`, `history`, `objective`, `normalization`, `timing`, `evidence`, `provenance`. Immutable outer record; referenced payloads may still be mutable. Obtain validated outputs through the operations described below; a raw record constructor does not itself certify scientific consistency.

<!-- aml-contract: {"variant": 0, "digest": "55a48e2703be5ed0fa812309753371d8cea11693f591a91ac4415828699b827e"} -->
**Purpose and output:** Native optimization objects/bounded history/borrowed dataset

**Source declarations and forwarding context:**

```text
struct ScientificLearningResult <: AbstractAnalysis; raw generated field constructor: (model::ScientificModel, dataset::ScientificDataset, optimization_problem, solution, optimizer, history::Vector{Float64}, objective, normalization, timing, evidence::PropertyResult, provenance)
```

**Inputs:** train or raw fields

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** No additional refusal specified in this audited route; raw records do not establish validation.

**Numerical limitations:** Evidence global physics unknown; no learning accuracy guarantee.

**Units:** Checked Float64 sample/scaling coordinates; units metadata never converts numbers. field_errors/AD use supported value promotion, not universal precision.

**Ownership:** Single borrowed dataset reference plus native result/model.

**Dependencies:** Lux; Optimization; NeuralOperators.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: BRIEF. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/scientific_ml/surrogates.jl:208.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:100.

```@raw html
<p>Repository resources: <a href="../repository/src/scientific_ml/surrogates.jl">src/scientific_ml/surrogates.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a></p>
```

<!-- aml-api: {"symbol": "ScientificModel", "family": "F33", "stability": "PUBLIC_EXPERIMENTAL", "qualified": false, "kind": "type / constructors", "variant_count": 1} -->
## [ScientificModel](@id api-ScientificModel)

**Identity:** type / constructors; F33; **PUBLIC_EXPERIMENTAL**; explicitly exported.

**Stored fields:** `architecture`, `network`, `parameters`, `state`, `schema`, `normalization`, `provenance`. Immutable outer record; referenced payloads may still be mutable. Obtain validated outputs through the operations described below; a raw record constructor does not itself certify scientific consistency.

<!-- aml-contract: {"variant": 0, "digest": "37d520a44953231f6541a2f29ba4fbefc012d7c8af9aea483ec411264e77e033"} -->
**Purpose and output:** Native network/parameters/state/schema/normalization/provenance

**Source declarations and forwarding context:**

```text
struct ScientificModel{N,P,S,C,Z,R}; raw generated field constructor: (architecture::Symbol, network::N, parameters::P, state::S, schema::C, normalization::Z, provenance::R)
```

**Inputs:** learning_model or raw fields

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** No additional refusal specified in this audited route; raw records do not establish validation.

**Numerical limitations:** No reference target stored in model; descriptor not input.

**Units:** Checked Float64 sample/scaling coordinates; units metadata never converts numbers. field_errors/AD use supported value promotion, not universal precision.

**Ownership:** Retains network/params/state and copied schema from extension.

**Dependencies:** Lux; Optimization; NeuralOperators.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: DETAILED. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/scientific_ml/surrogates.jl:193.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:100; examples/operators/heat_showcase.jl:67.

```@raw html
<p>Repository resources: <a href="../repository/examples/operators/heat_showcase.jl">examples/operators/heat_showcase.jl</a>; <a href="../repository/src/scientific_ml/surrogates.jl">src/scientific_ml/surrogates.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a></p>
```

<!-- aml-api: {"symbol": "training_data", "family": "F33", "stability": "PUBLIC_EXPERIMENTAL", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [training_data](@id api-training-data)

**Identity:** generic function; F33; **PUBLIC_EXPERIMENTAL**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "20271eee56c39bcd701408f26a80f285bcf6a76f0fb3a968b484378af9b64085"} -->
**Purpose and output:** Internal LearningBatch train inputs/targets/IDs

**Source declarations and forwarding context:**

```text
function training_data(m,d)

training_data(m::ScientificModel,d::ScientificDataset)=_surrogate_extension().training_data(m,d)
```

**Inputs:** ScientificModel,ScientificDataset

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError changed scientific schema/IDs or operator query grids

**Numerical limitations:** Training subset only; DeepONet requires identical query grids no resampling. Internal batch type is not export.

**Units:** Learning numeric outputs Float64 normalized/scaled; plotting Float64 view conversion, not units engine.

**Ownership:** Materializes full training inputs/targets; not memory-budgeted.

**Dependencies:** Lux; Optimization; NeuralOperators.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: ABSENT. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: ext/AnalyticMathLabSurrogateExt.jl:54; src/scientific_ml/surrogates.jl:227.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:100; test/m10d_interoperability_learning.jl:17; examples/inference/neural_gate.jl:53.

```@raw html
<p>Repository resources: <a href="../repository/examples/inference/neural_gate.jl">examples/inference/neural_gate.jl</a>; <a href="../repository/ext/AnalyticMathLabSurrogateExt.jl">ext/AnalyticMathLabSurrogateExt.jl</a>; <a href="../repository/src/scientific_ml/surrogates.jl">src/scientific_ml/surrogates.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/m10d_interoperability_learning.jl">test/m10d_interoperability_learning.jl</a></p>
```

## [F34: Generalization and sampled physics](@id family-F34)

<!-- aml-api: {"symbol": "benchmark_queries", "family": "F34", "stability": "PUBLIC_EXPERIMENTAL", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [benchmark_queries](@id api-benchmark-queries)

**Identity:** generic function; F34; **PUBLIC_EXPERIMENTAL**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "08c95a1f0ce2b97b53ff04901fdb8ae729152f1c784a9978f823ebf9d868e0db"} -->
**Purpose and output:** Local timings/runtime/break_even if full timing separation

**Source declarations and forwarding context:**

```text
function benchmark_queries(reference,inference;training_seconds,repetitions::Integer=11,context=NamedTuple())
```

**Inputs:** Comparable reference/inference zero-arg callbacks; training_seconds required,repetitions=11,context

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** ArgumentError invalid training_seconds or odd repetitions3:1001; callback errors propagate

**Numerical limitations:** Warm alternating runs; compilation may enter first timed calls; no correctness/memory/universal speedup claim; excludes unmeasured data/engineering cost.

**Units:** Checked Float64 sample/scaling coordinates; units metadata never converts numbers. field_errors/AD use supported value promotion, not universal precision.

**Ownership:** Stores timing scalar arrays/context.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: DETAILED. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/scientific_ml/generalization.jl:68.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:101; test/surrogate_diagnostics.jl:20; examples/operators/heat_showcase.jl:97.

```@raw html
<p>Repository resources: <a href="../repository/examples/operators/heat_showcase.jl">examples/operators/heat_showcase.jl</a>; <a href="../repository/src/scientific_ml/generalization.jl">src/scientific_ml/generalization.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/surrogate_diagnostics.jl">test/surrogate_diagnostics.jl</a></p>
```

<!-- aml-api: {"symbol": "field_errors", "family": "F34", "stability": "PUBLIC_EXPERIMENTAL", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [field_errors](@id api-field-errors)

**Identity:** generic function; F34; **PUBLIC_EXPERIMENTAL**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "354d645d92d4695176e67e4dcba5bc9064c3b153ae7a05ed29f133cb7bac5828"} -->
**Purpose and output:** Finite sampled summary, relative_sampled_l2, optional absolute array

**Source declarations and forwarding context:**

```text
function field_errors(prediction,reference;relative_floor=1e-12,summary_only::Bool=false)
```

**Inputs:** Equal-shape prediction/reference; relative_floor=1e-12,summary_only=false

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** DimensionMismatch shape; ArgumentError empty/nonreal/nonfinite/invalid floor/overflow difference

**Numerical limitations:** Unweighted samples no continuum norm; reference RMS <=floor -> relative nothing. Summary_only bounded live scratch machine floats omits absolute array; not peak RSS or arbitrary precision cap.

**Units:** Checked Float64 sample/scaling coordinates; units metadata never converts numbers. field_errors/AD use supported value promotion, not universal precision.

**Ownership:** Caller inputs borrowed; default allocates differences/absolute, summary_only replayable reductions.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: DETAILED. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/scientific_ml/surrogates.jl:177.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:99; test/m10a_inference_operators.jl:174; examples/integration/one_system_learning.jl:72.

```@raw html
<p>Repository resources: <a href="../repository/examples/integration/one_system_learning.jl">examples/integration/one_system_learning.jl</a>; <a href="../repository/src/scientific_ml/surrogates.jl">src/scientific_ml/surrogates.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/m10a_inference_operators.jl">test/m10a_inference_operators.jl</a></p>
```

<!-- aml-api: {"symbol": "GeneralizationAnalysis", "family": "F34", "stability": "PUBLIC_EXPERIMENTAL", "qualified": false, "kind": "type / constructors", "variant_count": 1} -->
## [GeneralizationAnalysis](@id api-GeneralizationAnalysis)

**Identity:** type / constructors; F34; **PUBLIC_EXPERIMENTAL**; explicitly exported.

**Stored fields:** `training`, `cases`, `groups`, `reference`, `physics`, `timing`, `evidence`, `limitations`. Immutable outer record; referenced payloads may still be mutable. Obtain validated outputs through the operations described below; a raw record constructor does not itself certify scientific consistency.

<!-- aml-contract: {"variant": 0, "digest": "6f54128ee0987d828385a12b6b8a201ebfc6fc2f0233d38c6abff452da0a7051"} -->
**Purpose and output:** Split-specific empirical case/group errors plus optional physics/timing

**Source declarations and forwarding context:**

```text
struct GeneralizationAnalysis <: AbstractAnalysis; raw generated field constructor: (training::ScientificLearningResult, cases::Vector{NamedTuple}, groups::Dict{Symbol,NamedTuple}, reference, physics, timing, evidence::PropertyResult, limitations::Vector{String})
```

**Inputs:** analyze(ScientificLearningResult) or raw fields

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** No additional refusal specified in this audited route; raw records do not establish validation.

**Numerical limitations:** Finite evaluated family only; numerical reference differences not exact truth; no universal generalization.

**Units:** Checked Float64 sample/scaling coordinates; units metadata never converts numbers. field_errors/AD use supported value promotion, not universal precision.

**Ownership:** Retains full training result/dataset and per-case outputs.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: BRIEF. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/scientific_ml/generalization.jl:2.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:101; examples/operators/analysis_gate.jl:5.

```@raw html
<p>Repository resources: <a href="../repository/examples/operators/analysis_gate.jl">examples/operators/analysis_gate.jl</a>; <a href="../repository/src/scientific_ml/generalization.jl">src/scientific_ml/generalization.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a></p>
```

<!-- aml-api: {"symbol": "heat_residual", "family": "F34", "stability": "PUBLIC_EXPERIMENTAL", "qualified": false, "kind": "generic function", "variant_count": 1} -->
## [heat_residual](@id api-heat-residual)

**Identity:** generic function; F34; **PUBLIC_EXPERIMENTAL**; explicitly exported.

<!-- aml-contract: {"variant": 0, "digest": "0ea97063cfddb0be1ea0a3475ba0987b48af8762bd6db9503196cb6e527c440e"} -->
**Purpose and output:** points,optional values,sampled summary,AD/order/evidence

**Source declarations and forwarding context:**

```text
function heat_residual(predictor,points::PINNPoints;alpha,summary_only::Bool=false)
```

**Inputs:** Differentiable scalar predictor(q),PINNPoints ordered x,t; required alpha; summary_only=false

**Keywords:** Controls are those in the declarations; forwarding does not imply unlimited native backend keywords.

**Failure and refusal:** DimensionMismatch rows; ArgumentError contradictory coordinate names/nonpositive alpha/nonfinite residual; AD errors propagate

**Numerical limitations:** ForwardDiff coordinate model u_t−alpha*u_xx; not true-field error. Summary_only re-evaluates deterministic predictor/AD, trades work for residual retention; no integral/global proof.

**Units:** Checked Float64 sample/scaling coordinates; units metadata never converts numbers. field_errors/AD use supported value promotion, not universal precision.

**Ownership:** Points borrowed, default residual array; summary_only no residual values.

**Dependencies:** Base AML route; no additional optional extension declared for this route.

**Evidence:** SOURCE_INSPECTED / STATIC_API_AUDIT. Docstring audit: DETAILED. Test/example locations below are HISTORICAL_TEST_EVIDENCE or inspected source, not new execution.

Source: src/scientific_ml/generalization.jl:44.

Inventory-listed candidate references (not a verified call graph or new execution): test/architecture.jl:101; test/m10a_inference_operators.jl:169; examples/operators/analysis_gate.jl:23.

```@raw html
<p>Repository resources: <a href="../repository/examples/operators/analysis_gate.jl">examples/operators/analysis_gate.jl</a>; <a href="../repository/src/scientific_ml/generalization.jl">src/scientific_ml/generalization.jl</a>; <a href="../repository/test/architecture.jl">test/architecture.jl</a>; <a href="../repository/test/m10a_inference_operators.jl">test/m10a_inference_operators.jl</a></p>
```
