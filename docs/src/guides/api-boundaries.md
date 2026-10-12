# [API boundaries and scientific evidence](@id api-boundaries)

This is a source-grounded pre-1.0 manual. PUBLIC_STABLE and
PUBLIC_EXPERIMENTAL describe audited AML ownership, not a finalized post-1.0
compatibility promise. The 177 exports have unique primary reference entries;
scientific_metadata and scientific_origin are two additional qualified
experimental names. Native backend objects are not automatically AML APIs.

## Constructors, operations and inspection

A validated factory checks only its stated prerequisites. An analytical operation
may establish a specific identity or return heuristic/unknown evidence. A raw
record constructor stores supplied fields; it does not certify their consistency.
Compatibility constructors preserve older layouts but are not added scientific
validators. Stored-result inspection does not rerun a calculation. An immutable
outer record can still contain borrowed mutable arrays, closures or backend state.
Read each entry's ownership contract before mutating or retaining payloads.
AbstractAnalysis is a marker, not a universal analyze/execute protocol.

PropertyResult has exactly value, status, method and notes. Established,
heuristic and unknown evidence are distinct; status is not a universal enum for
every result family. Unknown is not false or zero. Source retention, value
equality, declared units and scientific correctness are separate questions.

## Four failure categories

| Category | Interpretation | Example boundary |
|---|---|---|
| EXCEPTION | Invalid prerequisites, shapes, controls or propagated native failure | Direct normal_modes byte preflight can throw ArgumentError |
| UNKNOWN RESULT | Computation or evidence is unsupported/unavailable | Unsupported Legendre inversion; pair-distance output refusal |
| UNREQUESTED DIAGNOSTIC | The caller did not opt in, or did not request a search | No stationary-search bounds; omitted MD transport diagnostics |
| PARTIAL NUMERICAL RESULT | A solver returned retained partial output | trajectory requires success, completed and retcode inspection |

These categories do not impose one universal exception type. Empty heuristic
candidate lists are not nonexistence proofs. Absent uncertainty is not zero
uncertainty. Local equilibrium classification does not prove global nonlinear
stability. Zero curl alone does not prove a global potential on an arbitrary
multiply connected domain. Low fit loss does not certify physics or generalization.

## Resource controls are operation-specific

| Control | Scope | Not a guarantee of |
|---|---|---|
| normal_modes max_memory_bytes | Direct dense Float64 full-spectrum estimate; default 512*1024^2, estimate 24*sizeof(Float64)*n^2 | Peak RSS, sparse/partial solving, or preallocation in upstream adapters |
| pair_distances max_bytes | Pair-output estimate; default 512*1024^2; selection can already be allocated | Streaming, arbitrary-precision payload storage or peak RSS |
| pair_distances max_pairs | Output cardinality; default 1_000_000 | A work deadline or memory budget; mdcheck forwards max_pairs only |
| PINN/inference history capacity/stride | Earliest retained diagnostic entries and truncation | Optimizer/model/native solution memory |
| Surrogate/learned-dynamics history_limit | Rolling later diagnostic entries, supported 1:10000 | Training batch or AD state memory |
| predict batch_size | Temporary query chunks; pointwise deterministic networks assumed | Avoiding the complete output allocation or coupled-query detection |
| field_errors / heat_residual summary_only | Omit per-query output arrays | Releasing all inputs/metadata or a universal streaming API |
| ScientificDataset source_retention | Retain source or bounded descriptor with declared omissions | Compression, content identity or persistent provenance hashes |
| trajectory maxiters / saveat | Solver iteration ceiling / requested observations | Bounding all native adaptive history |

There is no global public AML memory-budget setter. Scalar-field analysis accepts
1 through 32 ordered variables; exactly 32 passes the guard, not a scalability
certificate. Dense symbolic Hessians remain expensive. No generic AML sparse
Hessian, HVP, matrix-free, sparse eigensolver or partial-spectrum interface is
advertised. Maintainer stress environment variables are not supported user knobs.

## Numerical, domain, ordering and unit boundaries

Original syntax must be captured before simplification to preserve original-domain
restrictions. FunctionAnalysis numerical evaluation does not automatically perform
original-domain membership checks; other overloads can have different guards.
Input-coordinate, component, particle and sample order are meaningful. Hamiltonian
phase order is (q...,p...), not (q...,v...). Mass normalization uses M, not necessarily
the Euclidean inner product. Degenerate modal bases are nonunique; unstable modes
can have unavailable real frequencies. A supplied snapshot Hessian does not prove
equilibrium.

Absent units are not automatically dimensionless. Unit labels do not convert
values. Float64 conversion boundaries and per-family supported shapes must be
respected. Saved observations are not identical to internal adaptive timesteps;
sample means are not generally continuous-time averages. Diffusion fitting
numerically accepts eligible index-time MSD, but physical interpretation requires
an appropriate physical clock, coordinate/identity assumptions and justified fit
window. No new physical-time refusal is invented.

## Optional extension activation

An extension activates only when AML and every listed trigger package are loaded.
Installation alone is not import/activation. These triggers come from the unchanged
root Project.toml; this docs environment does not install/load the optional stacks.

| Extension | All required triggers | Boundary |
|---|---|---|
| AnalyticMathLabMollyExt | Molly | Stored Molly adapters; base snapshots/views remain usable without it |
| AnalyticMathLabPINNExt | Lux, NeuralPDE, ModelingToolkit, Optimization, SymbolicIndexingInterface | PINN construction/training and trained-result diagnostics |
| AnalyticMathLabInferenceExt | Optimization | infer_parameters optimization; base forward/inspection routes differ |
| AnalyticMathLabDynamicsExt | Lux, Optimization | HNN/UDE learned dynamics, training and prediction |
| AnalyticMathLabSurrogateExt | Lux, Optimization, NeuralOperators | Surrogate/operator learning, including ordinary surrogate construction |

Stored PINNAnalysis loss_breakdown works in base; PINNTrainingResult diagnostic
recomputation requires the PINN triggers. Generic sampled_summary and base
field_errors/heat_residual metrics are not universal PDE solvers. Plotting names
are stable, but experimental ML payloads remain experimental. A rendering backend
must be loaded explicitly; a Figure is not a new scientific verification.

## F36: internal, not a public reference family

FieldZero, Equilibrium, LocalStabilityAnalysis, MultivariateRestriction,
LearningBatch, TrajectoryObservations and DeviationAnalysis are internal record
type names. Their documented returned fields may be inspected; direct constructor
and type-name compatibility are not public guarantees. Underscore helpers,
extension modules, AtomTypes, private scaling/partial-chain experiments and
imported dependency bindings are not additional exports. Do not use internal
constructors to circumvent public domain, dimension, precision or resource checks.

## Evidence and historical examples

STATIC_API_AUDIT / SOURCE_INSPECTED records current-source contracts, reconciled
against unchanged audit hashes. DOCSTRING_PRESENT records documentation presence,
not completeness. REFERENCE_COVERAGE_VERIFIED is a structured coverage check;
DOCUMENTER_BUILD_VERIFIED is an actual local build. No new scientific runnable
examples are introduced here. M10D.6C's tutorial executions and M10D.5's 5,649
assertions remain HISTORICAL_TEST_EVIDENCE. Candidate test paths from the audit are
not resolved call-graph coverage or newly executed tests.

The tutorials remain canonical outside docs/src. This site packages selected raw
repository resources after building, checks their bytes against the checkout, and
links them as downloads/inspectable source, not duplicated rendered tutorial pages.
Full rendered tutorial integration and deployment are outside this milestone.

```@raw html
<p>Source-grounded audit resources:
<a href="../repository/reports/m10d6/resource_controls.json">Resource controls</a>;
<a href="../repository/reports/m10d6/refusal_review.json">Refusal contracts</a>;
<a href="../repository/reports/m10d6/scientific_contracts.md">Scientific contracts (raw Markdown)</a>;
<a href="../repository/docs/tutorials/index.md">Executable tutorial learning path (raw Markdown)</a>.</p>
```
