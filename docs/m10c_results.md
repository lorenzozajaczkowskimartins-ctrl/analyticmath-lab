# M10C execution results and recovery checkpoint

The recovery sections below are historical. The consolidated result and final-gate
status at the end supersede their former next-step/pending entries.

Status: VERIFIED by the authorized replacement canonical and retained focused evidence.
Historical recovery/blocker entries below are superseded by the final closure section.
Baseline/current recovery HEAD: `091492e03dbf5fc1346c9ffa3dfbdfcd3f2bbe93`.

## Authoritative interruption recovery

Tracked and staged diffs were empty. Exactly five untracked files survived:
`docs/m10c_scaling_inventory.md`, `docs/m10c_bug_ledger.md`,
`test/m10c_guardrails.jl`, `test/m10c_ode_scale.jl`, `test/m10c_chunking.jl`.
No `examples/scaling/` directory or M10C production edits existed.
No active Julia process or M10C measurement log was found in scratch.
All surviving work is retained. Provider exhaustion is infrastructure interruption,
not scientific/backend failure.

| Workstream | Recovered completed work | Red executed | Production/green/stress evidence | Last completed step | First unfinished action |
|---|---|---|---|---|---|
| A mechanics/symbolic | Source, M10A/B oracle, manifest and ArnoldiMethod public implementation inspection | none recorded | none recorded | inspected ArnoldiMethod `src/run.jl` | write/run bounded red test and baseline measurement |
| B ODE | integration source inspected; `test/m10c_ode_scale.jl` written | none recorded | none recorded | verified test-file write | run existing red test |
| C ML | diagnostics/surrogates/generalization/extensions/oracles inspected; `test/m10c_chunking.jl` written | none recorded | none recorded | verified test-file write | run existing red test and baseline allocations |
| Shared | inventory/ledger and guardrail test written | none recorded | harness absent | verified guardrail-test write | run existing red test; implement harness |

Recovered request records (local, outside repository):
- `~/.hermes/sessions/request_dump_20261003_154913_ad035d_20261003_154957_514132.json` (A)
- `~/.hermes/sessions/request_dump_20261003_154913_d07f65_20261003_155004_827147.json` (B)
- `~/.hermes/sessions/request_dump_20261003_154913_428f6f_20261003_155008_909782.json` (C)
Only conversation/tool payloads are relevant; do not copy request headers.
Original full specification recovered from session message 4369 to
`~/.hermes/cache/scratch/m10c-original-request.txt`; its complete 51-item DoD
remains binding. No completed measurement was discarded or repeated.

Recovery environment: `julia +release` reports 1.12.7; root Project/Manifest and
all tracked executable files equal baseline. Future Julia execution is serialized
with `flock ~/.hermes/cache/scratch/m10c-julia.lock`, explicit Julia/BLAS threads,
and bounded process timeout. Timings must carry source/environment identity.

## Remaining work / exact continuation

Resume existing red gates, resource-safe harness, and mechanics baseline/red gate.
Then complete same-size/larger reruns, streaming statistics (including an opt-in
10^10 request path), atomistic boundaries, optional ML, polished examples/figures.
Final focused/regression/optional/review/security/canonical verification remains
pending; do not run final canonical prematurely.

Largest M10C completed workload at recovery: NONE RECORDED.
10^10 observations: NOT EXECUTED. Large CPU training: NOT EXECUTED.
No estimates are execution claims; no push, tag, or M10D work.

## Continuation checkpoint: shared work completed

Detailed evidence: `m10c_shared_evidence.md`.
- Harness red reproduced; green21.
- Lazy/deadline streaming red reproduced; green16. Existing M10B kernel retained.
- Atomistic allocation/preflight red reproduced; green10; M10A M8 290,
  M10B atomistic146 and statistics419 passed (logs retained).
- Local million_sample_statistics and large_atomistic_geometry examples exited0.
- Local memory_guardrails and safe extreme_streaming_statistics CLI (only 1m
  observations requested) exited0; parent process `proc_d603b57ed404` exited0.
- Largest completed statistics workload: 1m observations; atomistic explicit
  output: N1000 / 499500 pairs. N100000 positions constructed, pair output refused.
- The three recovered workstreams continue from documented unfinished steps.

User credit containment is binding: keep current agents, spawn no additional
agent, no optional extremes/giant training/speculative ladders, preserve roughly
70 credits-equivalent effort for finalization. After current agents finish,
consolidate, run only affected gates, and map remaining full DoD. If it cannot be
completed safely, stop at a fully documented checkpoint; no premature commit.

Exact next parent step: consolidate completed agent reports and their source
registrations; inspect evidence, identify minimal missing mandatory showcases and
gates. Canonical/final review NOT YET RUN. Do not repeat completed valid benchmarks.

## Consolidated results

All three current agents finished and were consolidated without redelegation.
No overlapping production edits were lost: mechanics, ODE and ML ownership were
disjoint; shared include/runner/architecture registration was performed by parent.
The ODE source is centrally included after integration.jl. Six bounded M10C test
files are registered; optional ArnoldiMethod and neural stacks remain separate.

Original complete acceptance mapping: [m10c_dod.md](m10c_dod.md).
Polished usage: [examples/scaling/README.md](../examples/scaling/README.md).
Lightweight local rows and plots: [m10c_measurements/](m10c_measurements/).

### Execution context and interpretation

Baseline HEAD: `091492e03dbf5fc1346c9ffa3dfbdfcd3f2bbe93`.
Julia1.12.7, Intel i7-1355U, physical memory16433725440 bytes at recovery.
Julia/BLAS1 thread except explicit two-Julia-thread ensemble comparison.
Default workload estimate536870912 bytes; cooperative measurement120 seconds;
sequential processes bounded by external timeout. No intentional OOM.

Executed tiers: smoke/local plus the already-completed ODE100000-state level2
ladder. Credit containment stopped further exploratory ladders. Extreme neural
preflight was REFUSED before construction; it was not an executed model.
No real10^10 completion or giant neural training. No GPU capability claimed.

Estimated payload/workspace, cumulative Julia allocation, reachable result bytes
and process-lifetime RSS are distinct. Isolated per-kernel peak RSS is unavailable.
Timings below are local warmed observations; historical neural setup/first-gradient
cold compilation is unmeasured, not inferred from warmup columns.

### Largest demonstrated workloads

| Subsystem | Largest requested/attempted | Largest COMPLETED | Local warmed time | Memory/result and correctness | Boundary |
|---|---|---|---|---|---|
| Dense full modes | n30000 estimate/preflight | n1200 | 1.823054s | 450708424 allocated;69180215 result bytes; analytic eigenvalues/direct residual | n>=3000 REFUSED under512MiB estimate |
| Partial mechanics | n30000,k4 | n30000,k4 | 0.01421637s | 17800304 allocated;960404 result bytes; residual1.01e-15 and orthogonality | controlled chain, not generic sparse SPD |
| Symbolic/AD derivatives | n20,Jacobian40-state | n20 | Hessian differentiation0.00134316s | separate construction/simplification/generation/first-call/eval; polynomial oracle |50/100 unexecuted, no pathological limit claimed |
| AML mechanics/dynamics |5 symbolic coordinates;600 structured |same | EL0.03580517s;structured ODE0.00032273s | exact M/K; trajectory error6.25e-12/relative7.29e-11 | generic symbolic elimination not extended |
| ODE state/storage |100000 states, all policies preflight |100000 sparse/endpoints/reduced;10000 full | reduced0.138578s | reduced result6448 bytes; normalized observable error<1.339e-10; RHS0 allocation |100000 full history REFUSED |
| Ensembles |1000 members |1000 serial/two-thread,full/aggregate | aggregate0.003575s serial/0.002510s threaded | aggregate result104 bytes; exact exp oracle, no universal speedup |10000+ unexecuted |
| Statistics |10^10 lazy request/deadline smoke |1000000 observations |0.005879646s |864 allocated; sample-variance error1.9456e-12; standard error unknown |10^10 NOT COMPLETED; prefix correlation only |
| Atomistic geometry |100000 positions, pair preflight |1000 particles/499500 explicit pairs |0.0407022885s |16674225 result bytes; exact line-distance/count oracle |10000/100000 pair outputs REFUSED; work remains quadratic |
| Field/data analysis |1000000 queries |1000000 |field-summary0.0124200855s with input allocation |summary result80 bytes; existing-input kernel976 allocated; exact constant-field oracle |not a million-neural-prediction claim |
| Neural prediction/residual |10000 queries/collocation |10000 |PINN residual summary0.004862605s |summary56 result bytes; split/unsplit oracles |cumulative chunk allocation increases; full public containers unchanged |
| CPU model |268517377 parameters estimated only |17025 parameters,width128,batch256 |forward0.000676456s;backward0.001902679s |gradient136248,Adam272552 bytes; finite-difference component oracle |extreme34367602784-byte estimate REFUSED; three steps not convergence |
| GeneralizationAnalysis |10000 targets |10000 |0.007046153s |10807296 allocated;885833 reachable result bytes; direct case/group/pointwise oracle |full evidence output intentionally retained |

Exact detailed before/after results: mechanics/ODE/ML/shared evidence documents.
Original benchmark rows are preserved; the final array-reduction helper extraction
retained numerical operations and was checked again at100k/1m (320/976 bytes).
No heavy benchmark was repeated merely for reassurance.

### Consolidation and mandatory-gap closure

- Fixed a real compatibility regression in sized stateful generators: public
  iteration snapshots once; private deterministic maps use a replayable reduction.
  Red16 calls instead of4 and wrong norm preserved; final focused gate passed.
- GeneralizationAnalysis100/10000 gate passed36 checks. One real four-parameter
  optimizer step created its fixture; no fabricated trained result. Initial missing
  Zygote import was a script setup error, fixed before successful execution.
- No new scaling defect was demonstrated in existing O(1) Welford; no rewrite.
- One bounded parent review (no new agent) resolved delayed ODE checkpoints and
  low-budget mass-spring holder access. Seven focused resolution checks passed.
- Final figure inspected: six readable panels, local labels, distinct allocation/
  result axes, explicit refused rungs; no false zero-time completion points.
- Root dependencies unchanged. Optional ArnoldiMethod environment is committed
  with relative local-package path. Giant arrays/models are not candidates.

### Final gate ledger

| Gate | Status / evidence |
|---|---|
| Consolidated M10C + affected diagnostics + architecture | PASS326, `m10c-final-focused.log`,exit0 |
| Final existing-input100k/1m allocation confirmation | PASS320-byte summary /976-byte summary-only field |
| Generalization + affected optional operator oracles | PASS36+43+20, `m10c-final-operators-v2.log`,exit0 |
| Affected optional PINN numeric gate | PASS15, `m10c-final-pinn.log`,exit0 |
| Source-valid partial/batching/residual optional gates | REUSED52 partial,14 Lux/DeepONet,13 PINN; exact source/log hashes verified |
| Affected M10A/M10B base regressions | REUSED completed mechanics51/90, M8 290/146+419, ODE affected gate601 including19 M10C; final canonical also covers base regressions |
| Required safe/local examples | PASS existing structured rows; only changed checkpoint wrappers rerun at smoke sizes |
| Review-resolution example gate | PASS7, `m10c-review-resolution.log`,exit0 |
| Reports/figures | PASS17 CSV snapshots + SHA256 index + inspected PNG/SVG |
| Diff/security | Working diff clean; staged candidate has only classified generated SVG whitespace; all other staged paths pass; exact staged security scan zero findings |
| One bounded parent review | PASS with two resolved orchestration findings; `m10c_final_review.md` |
| Authorized replacement canonical Pkg.test | PASS4789/4789 across167 reported testsets; exit0; `m10c-replacement-canonical.log` |
| Final source/index identity and exact commit | All172 executable/environment hashes unchanged; final candidate/index checks recorded with local commit |

172 executable source/test/example/environment files were frozen in scratch
`m10c-precanonical-source.json` before canonical execution. Final documentation
does not invalidate those execution hashes. The verified commit is prohibited
until the canonical completion marker and exit0 are read and the candidate checked.

Deferred to M10D: public API/adapters/result-provenance unification, export and
1.0 documentation stabilization. No M10D work, push or tag performed.

### Historical checkpoint: canonical blocker (resolved below)

The canonical process finished, not timed out: exit1 at test/m10c_guardrails.jl
because TOML was absent from the isolated test target. Earlier M10A/M10B testsets
in that invocation passed; later tests were not reached. This is not a full pass.
Current Project.toml already adds SHA and TOML to extras and the test target.
Only Project.toml differs from the 172-file precanonical executable snapshot;
production source, tests and example kernels are unchanged. Runtime dependencies
remain unchanged, but test dependencies have changed.

A focused isolated project built from current runtime deps plus declared test
extras, with JULIA_LOAD_PATH=@:@stdlib, passed the failing guardrail file:21/21,
exit0. Logs: scratch/m10c-isolated-target-check.log and .exit. This validates the
target dependency correction, NOT the entire canonical suite.

All completed stress evidence is retained. The one bounded review and scan are
complete; no duplicate review, stress ladder, canonical invocation, or agent was
launched. Under the explicit ONCE constraint, M10C remains NOT VERIFIED and the
requested verified commit was not created. Exact next step requires authorization
for one replacement canonical run with the corrected test target, then candidate/
index checks and the conditional exact commit. Do not restart any workstream.

### Final closure: authorized replacement canonical

The user explicitly authorized exactly one replacement invocation after the
test-only dependency correction. Executed `julia +release --project=. -e 'using
Pkg; Pkg.test()'` with Julia/BLAS threads1, optional partial stress disabled,
automatic precompilation disabled, the sequential Julia lock and1800s process
timeout. It completed normally with exit0 and `AnalyticMathLab tests passed`.
Parsed all167 reported testset rows:4789 passed,4789 total, no failed/errored
rows or unparsed summary rows. No further canonical invocation was performed.

Logs and exact counts reside under `/home/lorenzozm/.hermes/cache/scratch/`:
`m10c-replacement-canonical.log`, `m10c-replacement-canonical.exit`,
`m10c-replacement-counts.json`, and `m10c-replacement-source.json`.
All172 source/test/example/environment hashes matched after execution. Compared
with the original reviewed executable snapshot, only the already-validated
Project.toml SHA/TOML test-target declarations changed. Remaining edits are final
documentation only. Prior stress, optional gates, figure inspection and the single
bounded review were reused, not rerun.

All mandatory scientific/functional verification is satisfied. The local commit
subject is `[verified] Complete M10C scale and large-object hardening`.
No push, tag, optional extreme, redelegation or M10D work is authorized/performed.

Final index check disposition: the unchanged Matplotlib SVG contains trailing
spaces within generated path attributes. Raw staged diff checking reports these;
all findings are restricted to that generated SVG, and the remaining staged paths
pass. This formatting-only exception preserves the inspected artifact byte-for-byte
rather than regenerating or changing reviewed evidence. No conflict markers or
other whitespace findings were accepted. The exact staged candidate has70 files;
staged bytes match audited working files and all tested executable hashes.
