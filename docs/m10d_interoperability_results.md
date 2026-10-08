# M10D.2 — Cross-milestone scientific interoperability

Status: **VERIFIED COMPLETE — CANONICAL PASSED**.
Starting verified HEAD: `adadf5ddd03b360c93a6c0451f31cba03d01f8ff`.
M10D.1 is not reopened. Its 36 family classifications, 177 exports and architecture
inventory are unchanged. The existing integration graph's 24 rows are revalidated
in order in m10d_integration_matrix.md, not independently rediscovered.

## Implemented public routes

### TrajectoryResult → ObservableSeries

`observable_series(path; component=1)` selects a stored state index;
`component=:position` or `component="position"` selects a unique source label.
Alternatively supply `observable=(u,t)->...` and optionally `name=:...`.
Exactly one selector is required. This extends the existing stable F19 public
factory; no selector type, export, new algorithm or convenience interpolation.

The result owns copied saved times and materialized scalar observations. The
callable receives a state copy at each saved time. Source identity, source labels,
domain predicate, unchanged numerical diagnostics, selection and explicit caller
`context` are available in provenance. Full native solution access remains only
through the intentional source link, not backend objects masquerading as values.

- Saved order is exact. No interpolation, time sorting, uniform-grid assumption,
  hidden resampling, dropped samples or inferred integrator timestep.
- Backward/duplicate times are refused under existing SamplingInfo semantics;
  irregular increasing samples work, with autocorrelation appropriately unknown.
- Partial source results are allowed; failure/incompletion remains visible in
  diagnostics. Descriptive statistics are not completeness or accuracy evidence.
- Source ODE numerical state/time values have no established physical-unit schema.
  Their units remain `"unknown (unitless values)"`. A callback may return Unitful
  quantities; compatible dimensions are preserved, incompatible dimensions or
  known/unknown mixtures refused. No conversion from state index to particle ID.
- Missing/duplicate selectors, unknown/ambiguous labels, wrong callable arity,
  non-scalar/nonfinite values, inconsistent state shapes and incompatible problem
  types fail at the local boundary with ArgumentError/DimensionMismatch.

### Constrained simulation → ScientificDataset

Exactly one workflow is supported: a completed FirstOrderODE TrajectoryResult
becomes one scalar-field surrogate sample via `ScientificDataset(path; schema)`.
F31 remains experimental; this is not a universal simulation constructor.
The method docstring in src/scientific_ml/trajectory_dataset.jl and the dataset
test in test/m10d_interoperability.jl give the executable schema.

The NamedTuple schema explicitly supplies family, sample ID, ordered input vector
and input names, `coordinate_names=(:t,)`, descriptive input/time bounds, scalar
selection, split, reference description/error, ordered unit strings, grid semantics,
RNG provenance, and optional context. No field is inferred from trajectory order.

- The query matrix is one saved-time row in original column order. Values are
  exactly the selected stored output, checked against the existing Float64-only
  sample contract. No shape flattening or hidden resampling.
- Parameters and unit labels are caller assertions, explicitly marked as such.
  They cannot be recovered from arbitrary ODE closures. Unknown strings are
  preserved; dimensional Unitful outputs are refused rather than stripped.
- The split must be supplied. The existing dataset contract requires at least one
  training sample, so this deliberately one-run route accepts an explicitly
  training run and rejects standalone non-training runs. It does not invent a
  train/validation/test partition or extend the existing split vocabulary.
- Reference kind is necessarily `:numerical`. Solver/algorithm/tolerances/requested
  span/saved grid/diagnostics come from the actual source. Error is explicitly
  `:unknown` or a documented caller estimate, never a certified global bound.
  Analytical/manufactured/experimental truth labels cannot be attached to solver
  targets by this route. Existing dataset constructors still represent those
  other reference families; their global metadata conventions are not redesigned.
- Source/context, selector, observable name, labels and original domain predicate
  are retained under the existing dataset deepcopy policy. The copied native
  source can be larger than the selected data (D028); this is not a scale adapter.
- Ordinary classify_query, fit_scaling/transform/inverse_transform, learning_model,
  training_data, one-step train/predict and GeneralizationAnalysis accept the
  result without special dispatch or backend hacks.

## Existing bridges verified

The dedicated bounded test family also verifies:

- Mechanics → dynamics → trajectory: canonical labels, original-domain restriction,
  source identity in MechanicsDynamics, analytic harmonic samples cos(2t) and
  -2sin(2t), energy 2 and heuristic-only saved energy drift; unrelated path refused.
- Affine Legendre map: canonical momentum order and independent harmonic energy.
- Mechanical linearization → modes: source identity, equilibrium/domain evidence,
  coupled-oscillator stiffness [2 -1; -1 2] and spectrum [1,3]; non-equilibrium and
  damping do not manufacture a spectrum.
- Scalar-field derivatives and radial-potential force/equilibrium: explicit
  variable ordering, original-domain refusal, unit/provenance/cutoff metadata.
- Atomistic geometry → pair observations → statistics/inference: exact distances
  [1,2,3] nm, mean 2 nm, sample variance 1 nm², frozen pair/time order, source link,
  unknown correlated standard error, and explicit inference unit scales.
- Supplied Cartesian Hessian → modes: particle-major reconstruction, unit scales,
  known diagonal spectrum; `equilibrium_status=:not_verified` remains intact.
- Molly historical view/scalar logger composition: existing two-particle,
  eight-step gate; explicit saved times/stride and missing-time/coordinate refusal.
- Dataset → learning → generalization: one Dense(3=>1) layer, four affine
  parameters, one optimizer step, explicit RNG/normalization. Numerical reference
  quality and unknown global generalization survive; no heldout group invented.

Rejected generic edges remain rejected: ODE state is not particle identity;
unknown observables cannot be inferred from storage; solver/optimizer success is
not physical truth; zero finite-sample error is not continuum proof; arbitrary
scientific results are not automatically comparable. No artificial refusal APIs.

## Metadata and exact deferrals

The integration matrix records units, domain, coordinates, times, context,
evidence, reference, omitted information, refusal and test evidence for every
edge touched here. Plain ODE/mechanics physical units are absent at source, not
lost. Source labels are coordinate identifiers, not physical interpretation.

Intentional projection excludes unselected states from series values/learning
targets; the source still retains them. Local modes discard nonlinear dynamics as
outputs, not as stored source. Compact statistical moments omit times/source;
ComparisonInput or the parent series remains necessary (existing D007).

Fixed new losses: D025 rejects inconsistent observable unit meanings and D026
retains the selected observable name in dataset provenance. No existing public
contract was weakened.

M10D.3, not this phase, owns:

- D006/D017: scoped status/evidence/method/tolerance access conventions;
- D007/D027: lightweight parent/source retention, including mechanics or learned
  fit context not directly attached to existing TrajectoryResult objects;
- D010/D029: unknown-unit versus dimensionless policy, symbolic/callable/descriptive
  domain distinctions, numerical-reference error-quality and backend normalization;
- D028: explicit borrowed/copied source/context lifetimes without universal wrappers.

D024 thread portability remains M10D.5. No flagship, broad hardening, Wiki,
large-scale benchmark, new scientific subsystem or final 1.0 audit is started.

## Exactly one bounded parent interoperability review

Question: "Where can scientific meaning or metadata still be silently lost when
an AML result crosses a subsystem boundary?"

Scope: both new adapters, their immediate source/target contracts and dedicated
base/optional tests, plus the touched edges of the M10D.1 graph. No subagent.

Checked unit loss, coordinate/time reordering, source/context, reference inflation,
solver-success-as-truth, interpolation/resampling, inferred splits, shape
reinterpretation, particle identity, evidence strengthening and backend leakage.
Findings D025 and D026 were reproduced as three failing assertions (185 passes,
three failures, zero errors), then locally corrected and verified. Broader D027–
D029 issues were recorded, not redesigned. Review closed with no unresolved
M10D.2 blocker; post-fix regression checks are not a second review.

## Executed bounded verification

All commands used `JULIA_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1` and `julia +release`.
Historical logs: `/home/lorenzozm/.hermes/cache/scratch/m10d2-gates-XMDfjU/`.
This ephemeral directory is no longer available after scratch cleanup; the
established focused results below are retained evidence, not rerun results.

| Gate | Result | Command / log |
|---|---|---|
| New M10D.2 base tests | 189/189, six testsets, exit 0 | `--project=. -e 'include("test/m10d_interoperability.jl"); include("test/architecture.jl"); include("test/m10d_architecture.jl")'`; focused-final.log |
| M10D.1-specific regressions | 58/58 (54+3+1), three testsets, exit 0 | Same focused-final.log; all frozen exports/classifications/registration checks pass |
| General architecture regressions | 93/93 (10+67+16), three testsets, exit 0 | Same focused-final.log; two extra registration-file assertions reflect the two new files |
| Affected subsystem regressions, including architecture | 599/599, 28 testsets, exit 0 | affected.log; trajectories, trajectory_statistics, trajectory_uncertainty, mechanics_dynamics, normal_modes, atomistic_modes, trajectory_inference, surrogate_data, surrogate_contracts, architecture, m10d_architecture |
| Optional learning/generalization | 27/27, one testset, exit 0 after final source fixes | `--project=examples/operators test/m10d_interoperability_learning.jl`; learning-postfix.log |
| Optional Molly preservation | 22/22, one testset, exit 0 | `--project=examples/molly -e 'include("test/molly_trajectory_statistics.jl")'`; molly.log |
| Review counterexamples | Expected exit 1 before fixes; all corresponding tests green above | review-red.log |

The combined final focus log has 340 assertions / 12 reported testsets. Gate
counts overlap: do not add architecture assertions again to the affected total.
Only new overloads changed production behavior; final review fixes affect those
new routes, not the legacy subsystem calls. Optional learning was rerun after
those fixes. No extension source, dependency metadata, manifests, or examples
changed. Other optional loading evidence remains the frozen M10D.1 evidence.

Development test-fixture failures were corrected without modifying scientific
code: Legendre's payload already is HamiltonianAnalysis; symbolic polynomial
comparison needs expand; optional packages also export transform, requiring AML
qualification. Nonfatal Julia precompilation/cache-version warnings occurred.
These are not suppressed or mislabeled as source regressions.

## Recovered final canonical evidence

Implementation checkpoint: `689efc8413789f60725e9554a0303cfa05c288ee`,
`[m10d] Add cross-milestone scientific interoperability`.
The controlled canonical was executed from that checkpoint:

```sh
env JULIA_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 \
    julia +release --project=. -e 'using Pkg; Pkg.test()'
```

- Canonical execution classification: **PASSED**.
- Environment: `JULIA_NUM_THREADS=1`, `OPENBLAS_NUM_THREADS=1`.
- Exit code: **0**; persistent completion reason: `exited`.
- Persistent process-result evidence:
  `/home/lorenzozm/.hermes/logs/process-results/proc_d037234502c4.json`.
  It records the exact command, correct repository working directory, exit code
  and `Canonical exit: 0`; the wrapper propagates the Julia command's exit status.
- Assertion count: **unavailable**.
- Reported testset count: **unavailable**.
- Detailed canonical stdout/stderr: **unavailable after scratch cleanup**.
  Output was redirected to the now-removed ephemeral `canonical.log`; its final
  summaries and test-runner completion marker are unavailable. No canonical
  counts may be reconstructed, extrapolated from focused gates, or guessed.

This is loss of reporting detail, not loss of canonical exit-status evidence.
Finalization accepts the persistent exit evidence without repeating execution.
Recovered session `20261004_224437_daa37f`, messages 5513/5515, establishes that
the audited candidate hashes matched staged and committed blobs at this exact
checkpoint; message 5529 records unchanged executable/environment hashes during
canonical execution. At recovery all 11 checkpoint candidate blobs again match
working files and index by SHA-256. The original scratch hash manifests are no
longer available; no fresh comparison to those missing manifests is claimed.

Only this report and m10d_plan.md change during finalization. Scientific source,
tests and environments remain unchanged; established focused gates and the one
closed review are reused. Diff/index checks are required before the separate
`[verified] Complete M10D.2 scientific interoperability` completion commit.
No checkpoint amendment, rerun, push, tag or M10D.3 work is authorized.
