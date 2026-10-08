# M10D.3 semantic implementation and verification results

Status: **IMPLEMENTATION COMPLETE — CANONICAL PENDING**.
Starting verified HEAD: f8f233ba1d542d2a3a4e683a02523aa9524ad603.
M10D.1/M10D.2 are not reopened. Their inventory, graph, findings and accepted
canonical evidence are reused. M10D.2 detailed canonical counts remain unavailable;
none are reconstructed or guessed. This report concerns newly executed M10D.3
focused gates, not a new historical canonical.

## Changes and contract

The semantic census/specification is [m10d_semantics.md](m10d_semantics.md).
The qualified experimental `scientific_metadata` / `scientific_origin` interfaces
preserve native scientific payloads and exports. The canonical-required local
correction adds optional PropertyResult.metadata without changing PropertyResult{T}
or its four-argument constructors. No universal status enum, result
wrapper, provenance struct, scientific algorithm, subsystem or bridge is added.

- Claims retain scope/status/method/notes; execution/compatibility/domain/search
  vocabularies are not flattened into evidence strength.
- Numerical/unknown reference quality and caller trust are retained. Solver success
  does not become established physical truth; sampled agreement/residual is not
  continuum correctness. Analytical/exact labeling of simulation data is refused.
- Method, actual backend, approximation, tolerance and other options have separate
  inspection slots. Backend defaults not actually retained are not reconstructed.
- Unitful quantities and derived moments keep dimensions. Plain units remain
  unknown; strings remain declarations, not conversions. M10D.2 unit refusals hold.
- Native domains/coordinate order are preserved. Bounds are descriptive, not
  validity. Explicit contradictory PINN/heat coordinate names now fail rather
  than reinterpreting rows; unnamed legacy points retain positional contracts.
- Lightweight origin descriptors retain bounded immediate ancestry without native
  source objects. Mechanics conversion ancestry reaches trajectory/series/moments;
  models carry dataset origin/reference summaries without targets. Moments retain
  compact semantic context and inherited source approximation.
- Dataset retained/copying route is explicit and compatible; descriptor opt-in
  avoids retaining/copying source solution/context/callback/unselected labels.
  Its deliberate metadata weakening is listed in provenance.omitted.

See [m10d_provenance.md](m10d_provenance.md) for the ownership census, limitations
and observed byte sizes. Read-only metadata inspection may itself borrow arrays;
only the origin interface promises a detached descriptor.

## Required bounded tests and independent controls

| Requirement | Test evidence |
|---|---|
| 1 status/evidence cannot strengthen | Scoped symbolic energy vs heuristic trajectory/modes; unknown learning/PINN global correctness |
| 2 unknown remains unknown | Unknown property/reference error/units; failed execution does not imply physical falsehood |
| 3 not applicable differs | Unsupported backend slot not applicable; surrogate function-family query classification not applicable, guarantee none |
| 4 numerical reference stays numerical | Dataset -> model -> learning -> generalization; analytical/exact schema labels refused |
| 5 units survive | Unitful mean 2 m, variance 1 m²; existing nm atomistic bridge tests and Molly gate |
| 6 unknown units not invented | Numeric trajectory/series and dataset declarations unchanged; PINN units explicitly unknown |
| 7 coordinate order | Exact component 2/u2 or established v label; declared heat (t,x) and contradictory PINN block/global names refused |
| 8 domain meaning | Native mechanics/source domain identity; dataset bounds explicitly descriptive; PINN declared domains retained |
| 9 samples not continuum | PINNPoints domain unknown, sampled error/residual approximation, query guarantee none |
| 10 immediate origin | Descriptor tokens identify actual series/trajectory/conversion/dataset/training inputs |
| 11 multi-stage provenance | Mechanics -> dynamics -> trajectory -> series; dataset -> learning -> generalization; PINN -> diagnostics |
| 12 no accidental source retention | 8 vs 4096 values; source-capturing 4096-element ODE closure; detached dataset/context; unexpected parent-array counterexample |
| 13 method/backend distinct | Scientific integration/modes/diagnostics vs SciMLBase/LinearAlgebra/NeuralPDE/Lux/Optimization metadata |
| 14 approximation survives | Numerical source tag survives series/moments; linearization/modes/surrogate/sampled diagnostics scopes preserved |
| 15 actual tolerance retained | Trajectory abstol/reltol, mode atol/rtol, reference solver controls, generalization floor/PINN guard; unrelated options excluded |
| 16 learning cannot inflate quality | One affine network/one optimizer step; same numerical dataset reference and unknown error/global guarantee |
| 17 mechanics chain meaning | Small analytic oscillator; native label/domain and scoped conservation; no fabricated physical unit |
| 18 strengthening refused/unknown | Analytical/exact numerical reference refusal; partial/failed solver evidence unknown; zero sampled error not global proof |

Small oracles use the constant-derivative solution, harmonic oscillator/local
spectrum, exact unit arithmetic and a polynomial heat residual. There is no
large training, stress workload, new solver or benchmark. Direct positional
fixtures test existing claim/metadata contracts, not certification of arbitrary
caller records.

## Persistent gates

All commands used `env JULIA_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 julia +release`.
Persistent directory: `/home/lorenzozm/.hermes/logs/analyticmath-lab/m10d3/`.
The focused evidence JSON records exact commands, log hashes, parsed rows,
source/test snapshot hashes, exits and repository identity. Logs are retained
outside ephemeral scratch and outside the repository.

| Gate | Pass / reported testsets / exit | Log |
|---|---|---|
| Final base semantic + review regressions | 106/106, 6, exit 0 | focused-final.log |
| General architecture | 94/94, 3, exit 0 | focused-final.log |
| M10D.1 architecture/API freeze | 58/58, 3, exit 0 | focused-final.log |
| M10D.2 interoperability base | 189/189, 6, exit 0 | focused-final.log |
| Final touched scalar statistics | 98/98, 3, exit 0 | focused-final.log |
| Combined final focus | 545/545, 21, exit 0 | focused-final.log |
| Affected trajectories/statistics/uncertainty/modes/atomistic modes/inference/dataset regressions | 354/354, 17, exit 0 | affected-green.log |
| Affected mechanics dynamics | 94/94, 5, exit 0 | mechanics-green.log |
| Optional semantic learning + M10D.2 learning | 25/25 + 27/27, 2, exit 0 | learning-final.log |
| Optional semantic PINN + existing signed residual diagnostics | 23/23 + 66/66, 2, exit 0 | pinn-final.log |
| Optional Molly observable preservation | 22/22, 1, exit 0 | molly-final.log |

Counts are parsed from complete summary rows, not guessed. Gates overlap:
particularly the 98 scalar-statistics assertions occur in both affected and final
focus gates. Do not sum overlapping rows into a canonical total. Affected
numerical regression code was unchanged by the review's descriptor/inspection
fixes; final touched statistics/bridge and optional gates exercise those fixes.
Docstring-only dataset ownership clarification after optional gates changes no
operation. No full historical audit/review or canonical was repeated.

Development reds and intermediate fixture corrections are retained, not called
final failures: unsupported PINNPoints variables/ObservableSeries units keyword
fixtures were corrected to existing provenance/constructor forms; PropertyResult
notes require String[]. A combined 300-second gate was terminated by orchestration
while compiling mechanics_dynamics; no assertion failure was established and
buffered summaries were unavailable. The gate was split with explicit stdout
flushes and larger finite timeouts; complete final logs above all exit 0.
Precompilation/cache-version warnings were visible and are not hidden as success
or treated as scientific regressions.

## Exactly one bounded adversarial semantic review

Question: “Where can AnalyticMathLab make a scientific result appear stronger,
more precise, better sourced, or more physically meaningful than the evidence
actually supports?”

One parent review, no subagents and no independent approval claim. Scope: touched
bridges and accessors, negative semantic controls, native source ownership and
scientific display wording. It found three M10D.3 blockers:

- D031: open parent metadata retained an unexpected upstream array; malformed
  origin also failed. Fixed with a descriptor whitelist/schema and bounded chain.
- D032: accessor projections dropped numerical-source approximation in series and
  moments. Fixed by retaining the inherited numerical/sample scope.
- D033: solver options were all presented as tolerances, and model metadata could
  retain arbitrary reference-control payload. Fixed with known finite scalar
  tolerance-key projection; unspecified values stay unknown and options separate.

review-red.log reproduces retention/approximation/malformed-origin counterexamples;
final review regression tests pass, including eight-level truncation and
serialization. This is disposition verification, not a second review. D030
coordinate-name mismatch was separately reproduced/fixed during development.
No unresolved M10D.3 blocker remains. Existing truthful display disclaimers need
no visualization redesign. Deferred findings are D034 (M10D.4 comparability),
D035 plus D024/D011 (M10D.5 constructor/unit/default-thread hardening), and D036
(M10D.6 user navigation/Wiki). Older absent lineage/control metadata is explicitly
unknown, not invented; no claim of whole-library provenance completeness is made.

## Checkpoint and canonical boundary

Original implementation checkpoint:
`c645be415bf5b1b237fed85e6eb49948a6a0325d`,
`[m10d] Unify scientific semantics and provenance`.
Canonical was deferred at that checkpoint. The subsequent authorized original
canonical ran exactly once and FAILED; its history is retained below.

Original and authorized replacement canonical command:

```sh
env JULIA_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 \
    julia +release --project=. -e 'using Pkg; Pkg.test()'
```

## Original canonical failure and D037 correction

Original run: 2026-10-08T23:03:31.020574+00:00 through
2026-10-08T23:14:02.236850+00:00; tested c645be415bf5b1b237fed85e6eb49948a6a0325d.
Controlled JULIA_NUM_THREADS=1 / OPENBLAS_NUM_THREADS=1; exit 1.
Partial reported summaries: 3388 passed, 1 failed, 0 errored, 86 testsets.
Final marker: `ERROR: Package AnalyticMathLab errored during testing`.
Log/evidence: `/home/lorenzozm/.hermes/logs/analyticmath-lab/m10d3/canonical-20261008T230324Z/`.
These are not full-suite totals and do not supersede earlier focused successes.

First blocker: unchanged test/m10c_streaming.jl:12 (`lazy == stored`).
M10D.3 inserted origin/semantic_context into statistical_summary.value, making
equal numerical moments unequal solely because source identity differed. This
is an M10D.3 semantic/source compatibility regression, not a numeric, environment
or inherited-test failure. No original-canonical rerun or source edit occurred
during stop-on-failure finalization.

The authorized correction restores the exact seven-field value payload. Origin
and bounded semantic context move to optional PropertyResult.metadata; the
inspection interfaces read that metadata. Type parameter T, four-argument and
explicitly typed constructors remain supported. No custom equality, wrapper
result, global registry or strong source link is added. Equal values/hash and
different origins coexist; serialization preserves recorded ancestry. The
original M10C equality test is unmodified.

One bounded sibling search inspected the M10D.3 source/extension diff, result
constructors and accessor consumers. Only statistical_summary inserted identity
into a pre-existing .value payload. Trajectory diagnostics, dataset/model/PINN
provenance and native reference records are existing descriptive metadata slots,
not additional occurrences of that compatibility defect. No other source fix
was warranted. This is not a repeated census or adversarial review.

Corrective focused gates (all exit 0, logs in the persistent M10D.3 directory):
- Exact failed equality assertion: 1/1; new equality/hash/shape/identity,
  typed-constructor, unit, serialization and retention tests: 22/22
  (`value-compatibility-green.log`; prior red: 17 passed/5 failed).
- Affected gate: 431/431 across 17 reported testsets: M10C streaming 16,
  scalar statistics 98, relevant M10D.2 interoperability 189, M10D.3 semantics
  and existing review regressions 106, new compatibility 22
  (`correction-focused.log`). Counts overlap other gates and are not additive.
- Directly affected optional semantic learning 25/25, PINN 23/23 and Molly
  moments 22/22 (`correction-learning.log`, `correction-pinn.log`, `correction-molly.log`).
- Summary size 376 bytes and origin size 142 bytes at both 8 and 4096 samples.

Corrective checkpoint subject:
`[m10d] Separate scientific values from provenance identity`.
Replacement canonical is pending at this corrective checkpoint. Exactly one is
authorized after focused success, with a separate persistent pre-launch hash
manifest and full log/evidence. On failure stop without another invocation or
verified-completion commit. No earlier checkpoint is amended; no push/tag or
M10D.4 is started.
