# M10D.3 semantic implementation and verification results

Status: **VERIFIED COMPLETE — M10D.3**.
Starting verified HEAD: f8f233ba1d542d2a3a4e683a02523aa9524ad603.
M10D.1/M10D.2 are not reopened. Their inventory, graph, findings and accepted
canonical evidence are reused. M10D.2 detailed canonical counts remain unavailable;
none are reconstructed or guessed. This report records M10D.3 focused gates,
preserved failed attempts and the final successful canonical below.

## Changes and contract

The semantic census/specification is [m10d_semantics.md](m10d_semantics.md).
The qualified experimental `scientific_metadata` / `scientific_origin` interfaces
preserve native scientific payloads and exports. The D038 correction restores
PropertyResult's exact four-field layout and generated constructors; leaf origin
is explicitly unavailable rather than stored or fabricated. No universal status enum, result
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
  source objects. Mechanics conversion ancestry reaches trajectory/series;
  models carry dataset origin/reference summaries without targets. Moments retain
  only their original scientific payload and heuristic evidence; source context
  and inherited approximation remain on the series, not the isolated leaf.
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
| 10 immediate origin | Descriptor tokens identify actual series/trajectory/conversion/dataset/training inputs; isolated PropertyResult reports unavailable |
| 11 multi-stage provenance | Mechanics -> dynamics -> trajectory -> series; dataset -> learning -> generalization; PINN -> diagnostics |
| 12 no accidental source retention | 8 vs 4096 values; source-capturing 4096-element ODE closure; detached dataset/context; unexpected parent-array counterexample |
| 13 method/backend distinct | Scientific integration/modes/diagnostics vs SciMLBase/LinearAlgebra/NeuralPDE/Lux/Optimization metadata |
| 14 approximation survives | Numerical source tag survives in source-bearing series; isolated moments retain heuristic evidence, with no claim to recorded inherited tags; linearization/modes/surrogate/sampled diagnostics scopes preserved |
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
  moments. The initial fix retained inherited numerical/sample scope; D038 keeps
  that scope on source-bearing series, with isolated leaf context unavailable.
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

The first authorized correction (historical, superseded structurally by D038)
restores the exact seven-field value payload. Origin
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
At that corrective checkpoint one replacement canonical was authorized after
focused success, with a separate persistent pre-launch hash manifest and full
log/evidence. It failed on D038 below and stopped without another invocation or
verified-completion commit. No earlier checkpoint was amended; no push/tag or
M10D.4 was started.

## Replacement canonical failure: D038 public structural compatibility

The replacement tested `d742e18b64d3bb1aa3ac40926978c909779bae7a`,
`[m10d] Separate scientific values from provenance identity`, with the same
controlled canonical command above. It ran from
2026-10-08T23:31:40.848489+00:00 to 2026-10-08T23:42:35.562865+00:00,
in `/home/lorenzozm/PROJETOS/analyticmath-lab`, with both thread counts set to 1.
Exit 1; partial summaries: 3456 passed, 1 failed, 0 errored, 94 reported testsets.
Final marker: `ERROR: Package AnalyticMathLab errored during testing`.
Durable log and evidence JSON are in
`/home/lorenzozm/.hermes/logs/analyticmath-lab/m10d3/replacement-canonical-20261008T233135Z/`.

First blocker: unchanged `test/architecture.jl:27` expected
`(:value,:status,:method,:notes)` but found an additional `:metadata` field.
This is an M10D.3 semantic/source regression, not an environmental failure.
D037 contaminated scientific-value equality with provenance identity; D038
changed an established public physical layout to store semantic metadata.
The first fix preserved value equality but was architecturally incomplete.

Derived rule: semantic inspection must not silently alter established scientific
payloads or public structural contracts. Scientific value equality is not
provenance identity; semantic inspection capability does not require metadata
storage in every leaf object.

The final correction restores `src/core/contracts.jl`,
`src/trajectory/statistics.jl` and `src/real_analysis_contract.md` to their verified
M10D.2 content. No custom equality/hash/propertynames, registry, pointer table,
wrapper, mutation or notes/method encoding is used. Leaf inspection reports the
actual claim/method and unavailable provenance/context. Unitful mean/variance
remain dimensioned; the generic leaf has no single result-wide units schema.
Source-bearing series/results retain the semantic/provenance layer and bounded
ancestry. Keep the existing series/ComparisonInput context when needed.

Existing architecture and M10C streaming tests are unmodified. M10D.3 tests that
depended on the rejected leaf storage now assert honest unavailability and test
source associations on source-bearing objects. Descriptor whitelist, malformed
parent, eight-level bound and serialization counterexamples now exercise the
existing TrajectoryResult diagnostics slot rather than the removed leaf field.

## One bounded structural audit and pre-canonical architectural review

Question: "Did M10D.3 change any established public payload or structural contract
merely to attach semantic metadata or provenance?"

Yes: D037 changed the seven-key scientific moment value; D038 changed the
four-field PropertyResult layout. Both are now restored to verified M10D.2
content. F01/F20 in the frozen inventory and unchanged architecture/streaming
tests support the orthogonal-inspection architecture. No overwhelming evidence
supports changing the leaf contract. This is one parent review, not a repeated
whole-repository census, independent review, or M10D.1/M10D.2 re-audit.

The bounded comparison covered every M10D.3-modified source/extension path:

| Boundary | Finding / disposition |
|---|---|
| core/contracts; trajectory/statistics; real_analysis_contract | Restored byte-for-byte to f8f233b. Original type parameter, physical fields, generated constructors, payload key order, Base equality/hash and serialization-visible leaf structure; no hidden source ownership |
| scientific_metadata | New qualified accessors construct detached inspection records; no mutation or replacement of native payload. Leaf origin unavailable. Removed the now-unused summary-context helper; whitelist/depth bounds preserved |
| mechanics/bridge | Existing four-field TrajectoryResult unchanged. Adds only diagnostics.origin in the existing parametric diagnostics slot, preserving native solution/problem/labels and all diagnostic keys. Detached parent, no conversion/source retention added |
| scientific_ml/trajectory_dataset | Existing ScientificDataset/sample physical layouts and numeric targets unchanged. Existing open provenance gains descriptive keys; default retained/copy behavior preserved. Explicit descriptor opt-in changes source detail/serialization content with documented omissions, not silently |
| AnalyticMathLabSurrogateExt | Existing parametric model provenance gains detached origin, reference-quality and scalar controls; network/schema/targets unaffected; no dataset target retention |
| pinn_diagnostics | Existing open PINNAnalysis.provenance gains actual reference guard; reference/scientific residual payloads unchanged. Coordinate-name validation does not reorder or reshape data |
| scientific_ml/generalization; AnalyticMathLab registration | Explicit coordinate check and qualified accessor registration only; no new result layout/payload or constructor replacement |

Open diagnostic/provenance records necessarily serialize the newly recorded
metadata and may have different NamedTuple types/keys. This is not claimed to
be byte-identical metadata serialization. The indexed contracts and direct
consumers use named scientific/diagnostic fields and explicitly open provenance;
no fixed key-count/destructuring or scientific equality contract was found for
these slots. All pre-existing keys remain. Native source ownership/copying stays
unchanged except the explicit detached dataset option. No additional blocker
was found in this bounded audit. No other source changes were justified.

## Shutdown recovery and structural-correction focused evidence

Recovery found HEAD still at d742e18 with the complete structural correction
uncommitted. No corrective commit or post-correction canonical had run. The
bounded structural audit above survived and was reused, not repeated. No source
or test edits were necessary during recovery; no truncated candidate files were
found. All 213 source/extension/test/example/environment hashes in each retained
focused manifest match the recovered files, and all four log SHA-256 values match.

Durable directory:
`/home/lorenzozm/.hermes/logs/analyticmath-lab/m10d3/structural-correction/`.
Each row has its exact command, timestamps, hashes and exit in `<gate>.json`,
with stdout/stderr in `<gate>.log`:

| Gate | Recovery classification | Assertions | Reported testsets | Exit |
|---|---|---|---|---|
| focused | PASSED | 607/607 | 23 | 0 |
| learning | PASSED | 52/52 | 2 | 0 |
| pinn | PASSED | 89/89 | 2 | 0 |
| molly | PASSED | 22/22 | 1 | 0 |

The focused gate includes unchanged architecture and M10C streaming regressions,
M10D.1 API, M10D.2 interoperability, M10D.3 semantics, constructor/equality/hash,
serialization and bounded ownership counterexamples. Optional learning includes
both semantic and interoperability gates; PINN includes existing diagnostics.
Retained process records `proc_3f548fce0ef5.json` and `proc_019c966bc885.json`
under `/home/lorenzozm/.hermes/logs/process-results/` independently record exit 0.
Thus none of these gates was interrupted or needs rerunning. Historical canonical
attempts remain FAILED (D037 and D038); the post-structural canonical is NOT_RUN
at recovery, not an inferred pass or an unrecoverable result.

Architectural rule: semantic metadata must remain orthogonal to established
scientific payload and public structural contracts unless that metadata was
already part of the contract.

## Isolated-test dependency failure and bounded preflight

The recovered structural checkpoint is
`69fe927b150341f2cde5fbfdbb57b33c55837a30`,
`[m10d] Preserve semantic metadata compatibility`. Its canonical ran once from
2026-10-09T11:01:03.399631+00:00 to 2026-10-09T11:15:15.082848+00:00 and exited 1.
Partial progress was 3885 passing assertions across 110 reported testsets, not a
full-suite result. First blocker: `test/m10d_semantics_review.jl:2`, included at
`test/runtests.jl:278`, could not import Serialization in the isolated test
environment. The final marker was `ERROR: Package AnalyticMathLab errored during testing`.
This was a test-dependency declaration defect, not an identified scientific/source
regression or a recurrence of D037/D038. Evidence is retained under the durable
`structural-correction/` directory above as `final-canonical.log`,
`final-canonical.json` and `final-canonical-failure.json`.

One bounded preflight inspected direct using/import statements throughout test/,
runner membership and directly included helpers, including M10D.3 files. It found
Serialization missing from extras/test targets in both semantic-review and
value-compatibility tests. Only that stdlib was added using the existing convention;
no transitive-only packages, dependency versions or optional backend promotions.

| Classification | Direct import roots |
|---|---|
| CORE_DEPENDENCY | CairoMakie, ForwardDiff, LinearAlgebra, Makie, OrdinaryDiffEqTsit5, Random, Roots, SciMLBase, Symbolics, Unitful |
| DECLARED_TEST_DEPENDENCY | SHA, TOML, Test; Serialization after correction |
| MISSING_TEST_DECLARATION | Serialization before correction; none afterward |
| OPTIONAL_ENVIRONMENT_ONLY | ADTypes, ArnoldiMethod, ComponentArrays, Integrals, Lux, ModelingToolkit, Molly, NeuralOperators, NeuralPDE, Optimization, OptimizationOptimisers, SymbolicIndexingInterface, Zygote |
| NOT_APPLICABLE | AnalyticMathLab (package under test), relative ControlledModes/ScaleHarness module imports |

Optional tests are not in the canonical runner; the optional partial-mode helper
is guarded by AML_PARTIAL_TEST=1. No optional gates or scientific focused tests
were repeated. Per-import path/line/classification and hash evidence are in
`/home/lorenzozm/.hermes/logs/analyticmath-lab/m10d3/dependency-correction/import-audit-before.json`
and `import-audit-after.json` in the same directory.

The cheap probe used the installed Pkg.test gen_target_project/sandbox machinery
with re-resolution fallback disabled, then a fresh Julia child with neither
global-environment nor @stdlib LOAD_PATH fallback. All 14 canonical external
import roots loaded, including Serialization. PropertyResult's exact four fields
were asserted; the sandbox's existing dependency versions were unchanged.
No test suite was invoked. Exit 0, 2026-10-09T11:19:01.274581+00:00 through
2026-10-09T11:19:22.790900+00:00; marker `ISOLATED_DEPENDENCY_PROBE_PASSED`.
Probe log/evidence: `structural-correction/dependency-probe.log` and
`dependency-probe.json`. The probe script and isolated Project/Manifest snapshots
are retained in `dependency-correction/`.

Scientific src/, ext/, all tests and the root Manifest are byte-unchanged from
69fe927. Semantic contracts and the value/provenance correction remain untouched.
Only Project.toml test metadata and this results/plan documentation change.
The authorized checkpoint is `[m10d] Fix M10D.3 isolated test dependencies`,
followed by one new controlled canonical; any failure stops without a rerun.

## Final successful canonical and M10D.3 closure

Dependency correction checkpoint:
`8a4ee4a1ec0f0a5026ffa17df32bd37ac9261525`,
`[m10d] Fix M10D.3 isolated test dependencies`, parent
`69fe927b150341f2cde5fbfdbb57b33c55837a30`.

Exactly one newly authorized canonical ran on that clean checkpoint:

```sh
env JULIA_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 \
    julia +release --project=. -e 'using Pkg; Pkg.test()'
```

- Working directory: `/home/lorenzozm/PROJETOS/analyticmath-lab`.
- Start UTC: 2026-10-09T11:20:21.856906+00:00.
- End UTC: 2026-10-09T11:43:31.835099+00:00.
- JULIA_NUM_THREADS=1; OPENBLAS_NUM_THREADS=1.
- Exit 0; **5191/5191 assertions, 183 reported testsets**, no failed or errored assertions.
- Final marker: `Testing AnalyticMathLab tests passed`.
- Log: `/home/lorenzozm/.hermes/logs/analyticmath-lab/m10d3/structural-correction/dependency-corrected-canonical.log`.
- Evidence: `/home/lorenzozm/.hermes/logs/analyticmath-lab/m10d3/structural-correction/dependency-corrected-canonical.json`.
- Log SHA-256: `124cb51d7c7219f2fa944c54bed1ac5be74a405555a71ec39b4dc315ff8bbc25`.
- Process record: `proc_b19a4928c1d7`.

The 213-file pre-launch manifest matches the tested commit; no recorded file
changed during execution. Reported testset names are unique, and all 23 recovered
base focused summary rows match the canonical's counts exactly, including the
unchanged architecture/streaming regressions and M10D.3 serialization/ownership
counterexamples. Optional learning 52/52, PINN 89/89 and Molly 22/22 remain separate
reused focused evidence, not extra canonical assertions.

D037 scientific-value contamination, D038 physical-layout contamination and the
isolated Serialization declaration failure remain preserved historical findings.
No scientific source or test changes were needed after the structural checkpoint.
Completion changes only documentation and does not invalidate tested hashes.
The separate `[verified] Complete M10D.3 scientific semantics and provenance`
commit closes M10D.3. M10D.4 is not begun; deferred D024/D034/D035/D036 and other
later-phase obligations remain deferred. No amend, push, tag or subagents.
