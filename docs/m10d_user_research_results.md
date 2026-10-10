# M10D.5 recovery and verification results

Status: VERIFIED COMPLETE. Implementation checkpoint
`c913f9e7dcb285ecb3780ce3964e6f4c1d17d720` passed the single plain canonical:
5649/5649 assertions, 198 reported testsets, exit 0 and final success marker.

## Recovered state

Recovered HEAD: `d769f15489a2318f1b74e5d192f40b527a601794`, verified M10D.4.
No M10D.5 checkpoint existed. The index was empty; 20 tracked files were modified,
with four new user-test files and a new Stranger directory. No partially written
source/TOML/module or conflict marker was found. Tests and docs were not yet
registered/finalized. Nothing was reset, restored, stashed, cleaned or discarded.

Surviving changes: dataset property errors; series name/time/unit validation;
learned-dynamics absent-backend fallbacks; complete PINN activation hint; D024 test
budget correction; SparseArrays test dependency; optional example direct imports
and three resolved project hashes. Surviving tests cover user input errors,
packaging, fresh processes and optional families. The continuation corrected two
fixtures (scalar output row shape and explicit RNG provenance), fixed empty Molly
logger handling and registered the base tests. No new scientific algorithm/API.

Durable evidence directory (all basenames below are relative to it):

`/home/lorenzozm/.hermes/logs/analyticmath-lab/m10d5/`

Original logs/JSON and process-result records remain unchanged. `recovery-ledger.json`
records the recovered classifications and hash mismatches. The previous session's
last retained executed action wrote the optional harness; it did not execute any
optional family/load-order permutation. Its 429 is not used to infer test outcomes.

| Recovered gate | Classification | Disposition |
|---|---|---|
| d024-red, schema-red, observable-red, optional-absence-red, packaging-red | FAILED | Historical focused counterexamples; preserve, do not repeat |
| d024-green, schema-green, observable-green, optional-absence-green, packaging-green | PASSED for recorded candidates | Earlier candidates differ; final affected focused checks below replace stale evidence |
| clean-install | PASSED for earlier candidate | Source changed during execution; not reusable as final candidate proof; replaced |
| optional-resolve | PASSED | Resolution completed; all dependency records/versions unchanged, only manifest project hashes changed |
| stranger-first | FAILED | Real dataset shape error: 10 dataset assertions passed, one error; not an interruption |
| load/student/physicist/research/atomistic child workflows | PASSED | Child exits 0 and markers; original candidate hashes matched at recovery; reuse |
| optional family/load-order cases | NOT_STARTED | Harness intact, no completed or interrupted invocation found |
| first-hour review, checkpoint, canonical | NOT_STARTED | No durable completion/history existed; continue once |

There is no evidence requiring an INTERRUPTED classification for a started M10D.5
gate. Incomplete implementation/registration is not mislabeled a failed test.
The first Stranger runner's aggregate includes parent assertions and partial child
results; it is not an overall pass. Successful children remain independently useful.

## Focused verification

Each gate JSON records exact argv, cwd, tested commit, candidate SHA-256 inventory,
start/end UTC, environment, exit, summary rows, log path/hash and in-run changes.
All final gates below exited zero. Counts overlap; do not sum them into a unique
scientific-coverage count. Standalone assertions outside a testset are not invented
as parsed testset counts.

| Gate/evidence basename | Result | Scope |
|---|---|---|
| focused-final | 303/303, 13 reported testsets | User errors/packaging and affected statistics, dataset/scaling, learned base regressions |
| dataset-final | 12/12 | Corrected dataset child from an unrelated headless directory with spaces |
| molly-regression | 47/47, 2 testsets | Existing tiny stored-logger, unitful, ownership and device-refusal adapter regression |
| d024-default-final | 22/22 | Julia 1 thread / BLAS 6 threads, no forced variables |
| d024-multithread | 33/33, 2 testsets | Explicit Julia 2 / BLAS 3; base import leaves BLAS unchanged and budget refusal retained |
| clean-install-final | Completion marker, exit 0 | New environment, instantiate/precompile/load from path with spaces, existing depot |
| headless-final | Completion marker, exit 0 | Explicit CairoMakie output with DISPLAY/WAYLAND_DISPLAY unset, saved nonempty PNG |
| isolated-imports | 15 direct imports loaded, exit 0 | Pkg.test-style sandbox, no global/@stdlib fallback, pinned versions unchanged |

Reused standalone Stranger children: load 11, student 17, physicist 10, research 23,
atomistic 12 assertions. Only the failed dataset case was rerun before canonical.
The Molly-only extension correction cannot affect these base processes: the load
gate proves Molly is absent. Their scripts, base source and environments are unchanged.
All six run normally again only as part of the final registered regression suite.

### Optional activation and bounded functionality

| Family | AML first | Backend first | Evidence basename prefix |
|---|---|---|---|
| Molly | 5/5 | 5/5 | optional-molly-*-complete |
| Inference/Lux | 6/6 | 6/6 | optional-inference-*-complete |
| Operators/Lux | 6/6 | 6/6 | optional-operators-*-final |
| PINN/Lux | 6/6 | 6/6 | optional-pinn-*-final |

Eight fresh processes, 46 assertions total, zero ambiguity findings. No training.
The initial Molly focused failure identified the empty-tuple logger bug; the first
operators fixture omitted required rng_provenance. Both red logs are retained.
Only failed/missing cases continued; no successful permutation was repeated.

`optional-reuse-proof.json` reconstructs and verifies the exact earlier harness
hash: its sole later change is RNG provenance inside the operators branch, not
executed by Molly/inference. Their production/environment hashes match; the separate
runtests registration is not part of these direct-script gates. Final operator/PINN
candidate inventories match completely. This is scoped evidence reuse, not a claim
that unrelated whole-tree hashes were identical.

## One bounded first-hour review

Exactly one parent review used: “What would frustrate or confuse a competent new
AML user within their first hour?” Scope and findings are in `recovery_review.md`;
its executable candidate inventory is `review-candidate-hashes.json`. No subagent
or independent-review claim. Existing hardening was retained, fixture errors were
corrected explicitly, and the Molly refusal blocker was fixed. No further blocker
was found in the bounded scope. Raw positional records/open metadata and borrowed
mutable arrays retain their documented limitations rather than breaking compatibility.

## Pre-canonical and canonical

`import-audit-after.json` includes registered tests, standalone Stranger children,
known included helpers and source fixtures. Zero missing direct declarations;
Serialization and SparseArrays are explicitly in extras/test targets. Optional
imports remain optional. `probe_isolated.jl` uses the installed Pkg sandbox builder
without running the suite and preserves its generated Project/Manifest beside the
log. This prevents the historical missing-Serialization failure class.

Before the sole canonical, candidate/index/commit-blob SHA-256 agreement, whitespace
and secret/artifact checks, a clean implementation checkpoint, and successful
focused gates were verified. `implementation-audit.json` and
`checkpoint-result.json` retain the 36-file audited candidate and commit read-back.
Canonical command:

```sh
julia +release --project=. -e 'using Pkg; Pkg.test()'
```

No JULIA_NUM_THREADS or OPENBLAS_NUM_THREADS override was present. Exactly one
invocation ran, with no replacement, retry or controlled-thread fallback.

### Final canonical evidence

- Tested commit: `c913f9e7dcb285ecb3780ce3964e6f4c1d17d720`
- Subject: `[m10d] Harden AML for external users`
- Cwd: `/home/lorenzozm/PROJETOS/analyticmath-lab`
- UTC start: `2026-10-10T16:53:21.396648+00:00`
- UTC end: `2026-10-10T17:07:34.276882+00:00`
- Julia 1.12.7, Linux x86_64; Julia threads=1, BLAS threads=6.
- BLAS: `LBTConfig([ILP64] libopenblas64_.so)`.
- JULIA_NUM_THREADS and OPENBLAS_NUM_THREADS unset; JULIA_LOAD_PATH and
  JULIA_DEPOT_PATH unset in the invoking environment. Full relevant environment
  and the runtime preflight are embedded in the JSON.
- Assertions: **5649 passed, 0 failed, 0 errors; 198 reported testsets**.
  These are emitted summary rows, including child-process assertions and their
  separate parent orchestration checks; not a unique scientific-claim count.
- Final marker: `Testing AnalyticMathLab tests passed`.
- Exit code: **0**. Process result: `proc_0930e501a192`.
- Log: `canonical-final.log`; JSON: `canonical-final.json`.
- Log SHA-256: `c6e3d20aa0b29ece733a34c2daaf33b0f9b88a05edee58dc3db35c1f35289266`.
- `canonical-verification.json` independently reparses all summary rows and
  confirms the log hash, all candidate hashes and six fresh-process exit-zero
  markers. No executable/environment file changed during canonical.

All six Stranger workflows passed in the normal regression gate. The base-load
child independently printed the same Julia/BLAS 1/6 runtime and confirmed import
did not change BLAS or activate optional/rendering backends. D024 is resolved for
this default runtime and the separately verified 2/3 matrix; no global single-thread
configuration is required. No M10D.5 blocker remains in the verified scope.

Finalization changes only these results, the user report, plan and issue ledger.
The separate child commit is `[verified] Complete M10D.5 user and research hardening`;
the implementation checkpoint is not amended. No push, tag or M10D.6 work.

## Limitations and user readiness

See [m10d_user_research_hardening.md](m10d_user_research_hardening.md) for supported
first-hour workflows, constructors, ownership, optional activation, numeric/unit
boundaries and non-inference rules. Linux is the exercised platform; no macOS/
Windows certification, virgin depot claim, GPU support expansion or bitwise
cross-platform reproducibility claim. Optional stacks remain experimental.

User/research readiness is verified within the documented scope, backed by focused
and plain canonical success. This is not a 1.0 release approval.
M10D.6 navigation and M10D.7 final adversarial audit are not begun.
