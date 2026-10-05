# M10D — Cross-milestone integration and 1.0 stabilization

## Authority and baseline

Baseline: `ff28e89bb08f95015d241091de7406d8f02d5861`, parent
`091492e03dbf5fc1346c9ffa3dfbdfcd3f2bbe93`. M10C is closed: replacement
canonical 4789/4789 assertions, 167 reported testsets, exit 0. Its measurement
CSV/TOML and provenance are frozen evidence, not benchmarks to repeat.

Current authorized phase: **M10D.2 only**; M10D.1 is VERIFIED COMPLETE at
`adadf5ddd03b360c93a6c0451f31cba03d01f8ff`. The historical M10D.1 record below
is frozen. Its API policy is a pre-1.0 freeze,
not a version bump or a claim that the final 1.0 audit has passed.
Architectural integration means making existing scientific contracts discoverable,
registered and composable without erasing assumptions. It does not mean inventing
new science, forcing all subsystems into one result type, or connecting every pair.

## Roadmap

| Phase | Deliverable | Boundary |
|---|---|---|
| M10D.1 Architecture & Public API Freeze | Complete family/export inventory, ownership, dispatch/extension audit, minimal layout fixes, seam and semantic maps | VERIFIED COMPLETE, not reopened |
| M10D.2 Cross-Milestone Scientific Interoperability | Prioritized legitimate bridges with preservation/refusal tests | Current phase only; no invented particle identities, time, units, reference truth or domains |
| M10D.3 Unified Scientific Semantics & Provenance | Consistent evidence vocabulary and lightweight source retention | No oversized universal provenance/result wrapper |
| M10D.4 One System, Many Methods | One scientifically justified flagship using existing methods | No new algorithm/model family |
| M10D.5 User & Research Hardening | Constructor/error boundaries, reproducibility, packaging, supported workflows | Bounded workloads and explicit resource limitations |
| M10D.6 Documentation & GitHub Wiki | User/research navigation and wiki matching tested APIs | Wiki is not started in M10D.1 |
| M10D.7 Adversarial 1.0 Audit | Negative controls, integration failures, release/readiness closure | Final 1.0 verdict is deferred |

## Global non-goals

No new scientific subsystem, eigensolver, ODE integrator, second MD engine,
GPU framework, DFT/electronic structure, nuclear physics, PINN architecture,
scientific-ML model family, JuliaDynamics/recurrence analysis, FFT/spectral
expansion, 100000/1000000-particle MD, giant stress workload, or speculative
research feature. No M10A/B/C reopening without a demonstrated integration
regression. No changes to frozen M10C measurements.

## Final M10D Definition of Done (future release gate)

1. Public/internal boundaries and intended 1.0 API are explicit and tested.
2. Scientifically valid supported bridges preserve units, ordering, domain,
   evidence and source information; invalid/underspecified conversions refuse.
3. Evidence and provenance semantics are coherent without type homogenization.
4. One-system/many-methods example compares like scientific quantities and
   separates exact, numerical, empirical and learned evidence.
5. Normal user/research workflows use package APIs and declared optional environments;
   errors, constructors, backend absence and resource limits are documented/tested.
6. Repository docs and wiki agree with supported behavior and limitations.
7. Adversarial audit and authorized final verification pass with no release blocker.
   No 1.0 tag or publication follows automatically from this phase checkpoint.

## M10D.1 acceptance checklist

- Entire relevant public surface inventoried, including unexported returned records.
- Every major family assigned exactly one classification; no export left unowned.
- Public versus internal constructors, helpers and backend access documented.
- No normal example loads production files manually; internal benchmark use labeled.
- All five optional extensions mapped; base absence and present loading checked.
- `analyze` and related generic dispatch audited, including AML-owned ambiguities.
- Duplicate/conflicting concepts fixed only when clearly a phase-1 defect, otherwise
  individually recorded with owning later phase.
- Cross-milestone graph and M10D.3 semantic/provenance targets recorded.
- No scientific subsystem, algorithm or adapter expansion.
- Focused regression/example checks and diff checks pass.
- One bounded parent architecture review, no unresolved phase-1 blocker.

## Checkpoints and verification budget

- Baseline Git status/log/diffs verified clean at the exact expected HEAD.
- Source registration, exports, result fields, constructors, dispatch, optional
  projects/extensions and representative contract fixtures inspected in batches.
- Tracking documents created before changes; inventory is reused, not rediscovered.
- No subagents. One bounded parent review. No benchmarks, stress or training.
- Tests: layout regression red/green, package/export/dispatch checks, bounded
  existing ODE example correctness functions, extension loading only.
- Canonical is not a development gate. At most one final run is authorized if
  execution budget permits; otherwise explicitly report CANONICAL PENDING.
- Completion and exact gate outcomes are appended after execution, not inferred.

## Deferred work

The issue ledger assigns individual findings to M10D.2–M10D.6. M10D.2 should
start with explicit trajectory-to-series selection and source/units/order
preservation, then simulation-to-dataset requirements, not a universal adapter.
M10D.3 owns evidence vocabularies, ownership and lightweight provenance.
The flagship, wiki and final 1.0 audit remain unstarted. Stop after one local
`[m10d] Freeze public API and architecture inventory` checkpoint; no push/tag.

## Continuation recovery and M10D.1 closure

Recovered HEAD was the exact baseline above, with six modified tracked files and
six untracked M10D files, no staged changes and no checkpoint commit. All four
tracking documents, both new tests, the runner include and example/notebook fixes
survived. No apparent truncation was found. The interrupted table-row regex in
`test/m10d_architecture.jl` was **COMPLETE** and needed no correction: its first
focused run passed 54 ownership, 3 registration and 1 notebook assertions.
The inherited red/green claims in D001/D003 are historical evidence; this
continuation independently verified the surviving green implementation.

### Definition-of-Done disposition

| Item | Status | Evidence / scope |
|---|---|---|
| 1. Relevant public API inventoried | COMPLETE | F01–F36, all 177 exports owned exactly once; reachable unexported records included |
| 2. Major families classified | COMPLETE | 26 PUBLIC_STABLE (130 exports), 9 PUBLIC_EXPERIMENTAL (47 exports), 1 INTERNAL; zero REDUNDANT/RENAME_BEFORE_1_0/REMOVE_BEFORE_1_0 |
| 3. Public/internal boundaries | COMPLETE | Inventory policy, factory/constructor limits, dependency bindings, backend payloads, maintainer-only helpers |
| 4. Normal examples independent of source includes | COMPLETE | Layout scan passes; obsolete scaling source injection removed; notebook uses public Symbolics validation |
| 5. Optional architecture mapped and sane | COMPLETE | Five extensions; base absence plus four present environments; D021/D022 loader issues fixed |
| 6. analyze dispatch audited | COMPLETE | Nine conceptual families, eleven AML methods; base and loaded-extension ambiguity checks pass |
| 7. Conflicting concepts disposed | COMPLETE | D005/D015 distinctions documented, semantic/hardening obligations explicitly deferred |
| 8. Cross-milestone seams mapped | COMPLETE | Integration matrix includes existing, missing conditional and invalid bridges; implementation DEFERRED_TO_M10D_2 |
| 9. Semantic inconsistencies inventoried | COMPLETE | Inventory semantic table and D006/D007/D010/D017; implementation DEFERRED_TO_M10D_3 |
| 10. No new scientific subsystem | COMPLETE | No src/ or ext/ changes, no new scientific algorithm or adapter |
| 11. Focused affected tests | COMPLETE | Gate results below |
| 12. Diff checks | COMPLETE | git diff --check; candidate-wide staged check required before checkpoint |
| 13. One bounded architecture review | COMPLETE | Parent review below; no unresolved M10D.1 blocker |

No item is MISSING_MANDATORY or NOT_APPLICABLE. Completion here refers to the
bounded M10D.1 implementation and focused gates, not a canonical or 1.0 verdict.

### One bounded parent architecture review

Question: "What evidence remains that AnalyticMathLab exposes multiple disconnected
or conflicting public API languages?"

Reviewed the recovered inventory, integration matrix, ledger, complete candidate
diff/tests, module exports/registration, affected examples and runtime dispatch/
loader evidence. This was one parent review, not an independent/subagent review.

- Duplicate concepts and naming: differentiated domains, trajectories, data and
  metrics have distinct scientific obligations (D005/D015); no safe alias removal
  or rename demonstrated. Specialized verbs remain deliberate.
- Accidental exports: exact ownership set equals all 177 exported names; no
  underscore helper exported. Reachable internal records are not constructor APIs.
- Layout coupling: production registration is package-owned; both removed
  fallbacks stay removed. Ordinary notebook validation uses public operations.
- Extension loading: initial PINN failures exposed stale tracked manifests, not
  broken source registration. D021 repairs metadata and adds early regression
  detection; D022 corrects the tested transitive-trigger expectation.
- analyze coherence: all eleven methods remain AML-owned with no detected
  AML-owned ambiguity, including all loaded optional extension scopes.
- Stale examples: obsolete notebook MD statement corrected (D023); scaling
  experiments remain explicitly internal, without changing their kernels.
- Backend leakage: native payloads deliberately experimental; dependency-binding
  imports in optional examples remain the explicit D004 hardening obligation.
- Argument conventions: scalar vs variable collection, (K,M), canonical phase
  ordering and columns-as-points documented; no silent convention conversion.
- User-facing errors: D012/D014 record MethodError/ArgumentError inconsistency
  and an incomplete PINN setup hint for M10D.5. Loader metadata failure now has
  a documented Pkg.resolve/fresh-process recovery, not a manual include workaround.
- Semantic disconnection remains in status vocabulary, metadata and source
  retention (M10D.3), and missing explicit bridges (M10D.2); none is hidden as a
  phase-1 fix. No unresolved M10D.1 blocker; review is closed, not repeated.

### Executed focused gates

- `julia +release --project=. -e 'include("test/m10d_architecture.jl")'`:
  58/58 assertions in three testsets, exit 0.
- `julia +release --project=. -e 'include("test/architecture.jl")'`:
  91/91 assertions in three testsets (10 + 65 + 16), exit 0. Includes public export,
  dispatch, inference, dependency-direction and AML-owned ambiguity checks.
- `julia +release --project=examples/<environment> test/m10d_extensions.jl <environment>`:
  pinn, molly, inference and operators each 13/13 (metadata 2 + loading 11),
  final fail-fast loop exit 0. Five extensions covered; no training performed.
  Initial PINN 9/11 and post-refresh 10/11 failures are retained as D021/D022
  red evidence, not misreported as the provider interruption.
- Tracked manifests for pinn/molly/inference refreshed with offline
  Pkg.resolve after backup. Programmatic comparison confirmed only the AML
  dependency record changed; all Project files and dependency versions preserved.
  Recovery backup: `/home/lorenzozm/.hermes/cache/scratch/m10d-manifests-zmzSv3`.
- Affected ODE examples: included as modules, called only `verify_storage()`
  (10 states) and `verify_ensemble()` (12 members, two threads). Errors were
  1.338558153207714e-10 and 3.785066704509177e-11 respectively; exit 0.
  No main(), run_scaling(), harness measurement, benchmark or M10C evidence rerun.
- Mechanics addendum notebook: assertions and all four figure saves passed,
  exit 0. Only the output directory was redirected in memory to scratch to avoid
  overwriting existing artifacts. Final wording change is non-executable prose.
  Output: `/home/lorenzozm/.hermes/cache/scratch/m10d-notebook-1igi1Y`.
  A wrapper-variable soft-scope warning did not affect execution; initial extension
  loads also emitted Julia cache/precompilation warnings, not test failures.

### Final canonical verification

**M10D.1 VERIFIED COMPLETE.** Implementation checkpoint
`e9550bb0f0eadf537ba328ce28ee385926ca8a6e` initially left canonical verification
pending. The separately authorized replacement canonical now closes that gate:

```sh
env JULIA_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 \
    julia +release --project=. -e 'using Pkg; Pkg.test()'
```

- Environment: `JULIA_NUM_THREADS=1`, `OPENBLAS_NUM_THREADS=1`.
- Result: **4847/4847 assertions, 170 reported testsets, exit 0**; zero assertion
  failures and zero test errors. The log contains `Testing AnalyticMathLab tests
  passed` and `CANONICAL_EXIT=0`; totals were parsed from the reported summaries.
- M10D ownership/registration/notebook testsets passed 54/3/1 respectively within
  canonical, confirming the focused tests are registered in the full runner.
- Exact tested HEAD: `e9550bb0f0eadf537ba328ce28ee385926ca8a6e`; Git tree:
  `66a5373f016b9a8580235cbdc12429016d15beff`. Working tree was clean before and
  after the run. Finalization changes only this plan and the issue ledger.
- Replacement log:
  `/home/lorenzozm/.hermes/cache/scratch/m10d1-replacement-canonical-aApgFc.log`.
- Earlier default-environment canonical exited 1 with 3360 passed assertions,
  zero assertion failures and one test error across 85 reported testsets, before
  reaching M10D tests. Julia used one thread while BLAS used six; the existing
  M10C guardrail correctly rejected a ceiling of one. This incomplete run is
  diagnostic history, **not final verification evidence**. Its preserved log is
  `/home/lorenzozm/.hermes/cache/scratch/m10d1-canonical-zlzN10.log`.
- The replacement was run exactly once after explicit authorization; no source,
  test, harness or manifest was changed to accommodate it. D024 assigns the
  default-thread portability observation to M10D.5, without redesign here.
- Pkg emitted a non-fatal warning that project dependencies/compat had changed
  since the manifest was resolved. The test run nevertheless completed; no
  dependency refresh or additional canonical run was performed.
- Prior focused 201/201, optional loading, affected-example and bounded parent
  review evidence is reused. No separate focused tests, architecture audit,
  optional training or M10C benchmarks were repeated. Frozen M10C evidence remains
  unchanged and is distinct from this M10D canonical result.

Finalization creates a new `[verified] Complete M10D.1 architecture and public API
freeze` commit; it does not amend the implementation checkpoint, push or tag.
At M10D.1 closure M10D.2 remained unstarted; later-phase ledger obligations are
not a 1.0 verdict. The separately authorized M10D.2 execution follows.

## M10D.2 implementation and focused closure

Starting HEAD and clean status verified exactly as requested:
`adadf5ddd03b360c93a6c0451f31cba03d01f8ff`. No reset, stash, restore, discard,
push or tag. Read/reused all four authoritative M10D documents before implementation.
No inventory rediscovery, classification change, architecture re-audit or subagent.

**M10D.2 IMPLEMENTATION COMPLETE — CANONICAL PENDING.**

The existing graph's 24 rows were revalidated in place. Two formerly missing
bridges now exist: explicit saved-trajectory scalar selection through
observable_series, and exactly one explicit-schema trajectory-to-ScientificDataset
route. Public names/classifications are unchanged. Two package includes are added
to architecture.md solely to satisfy existing registration invariants.

### Definition-of-Done disposition

| Items | Disposition / evidence |
|---|---|
| 1 graph revalidated | COMPLETE; all original rows classified in integration matrix |
| 2–5 trajectory selection/time/order/unknowns | COMPLETE; explicit index/unique label/callable; exact saved samples only; no unit or particle inference; 61 focused selection/boundary assertions |
| 6–9 dataset/schema/splits/reference | COMPLETE; one completed ODE run, explicit scalar schema and split; numerical reference only, actual solver metadata, unknown/error estimate; 69 focused assertions |
| 10 mechanics/dynamics/trajectory | COMPLETE; analytic harmonic trajectory/domain/source/drift tests |
| 11 linearization/modes | COMPLETE; coupled spectrum, source identity, equilibrium/damping negative controls |
| 12 atomistic/statistical bridges | COMPLETE; exact geometry/units/statistics/inference/modes and tiny optional Molly gate |
| 13 refusal semantics | COMPLETE; selectors/shape/time/units/reference/split errors, absent invalid generic particle/comparison APIs, no artificial throwing API |
| 14 metadata matrix | COMPLETE; every touched edge distinguishes preservation, intentional projection, and absent-at-source quantities |
| 15 M10D.3 deferrals | COMPLETE; D027–D029 plus existing D006/D007/D010/D017, not implemented |
| 16–17 no new subsystem or weakened contract | COMPLETE; two overloads using existing types/functions; no exports, extension/dependency changes or algorithm |
| 18 focused tests | COMPLETE; 189/189 new base assertions; 599/599 affected regressions including architecture; optional learning 27/27 and Molly 22/22 |
| 19 M10D.1 regressions | COMPLETE; 58/58 frozen ownership/registration/notebook plus 93/93 general architecture, final combined focus 340/340 |
| 20 diff/index checks | Working diff check passes; candidate-wide check repeated before checkpoint |
| 21 one bounded review | COMPLETE; D025/D026 counterexamples reproduced and fixed, no unresolved M10D.2 blocker; no repeat review |

Full route contracts, exact tests/oracles, source/ownership limitations, commands,
logs and review disposition: [m10d_interoperability_results.md](m10d_interoperability_results.md).
All bounded gates used `JULIA_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1`.
Gate logs: `/home/lorenzozm/.hermes/cache/scratch/m10d2-gates-XMDfjU/`.
No canonical was used during development. No stress ladder, large training,
100k-particle/state workload, streaming benchmark or frozen M10C rerun.

### Checkpoint and final verification policy

Create `[m10d] Add cross-milestone scientific interoperability` as a recoverable
implementation checkpoint after explicit candidate/index checks. If budget permits,
run exactly one controlled-thread canonical from that clean checkpoint:

```sh
env JULIA_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 \
    julia +release --project=. -e 'using Pkg; Pkg.test()'
```

Record the exact checkpoint, assertion/testset counts, exit/environment/log and
completion marker below when available. A passing canonical permits only a separate
`[verified] Complete M10D.2 scientific interoperability` completion commit. A failed
canonical is classified, preserved and not automatically rerun. Do not amend,
push, tag or begin M10D.3. D024 remains intentionally deferred to M10D.5.
