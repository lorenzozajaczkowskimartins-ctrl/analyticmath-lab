# M10C bounded final scalability/correctness review

One parent review, not independent approval: the user prohibited any new subagent.
Scope: tracked source/extension diff; all new scaling helpers, examples and tests;
runner/include ownership; recovered numerical/optional gates; measurement CSVs,
status semantics, source hashes and original51-item DoD. No redundant reviewer.

## Findings and disposition

- Consolidation compatibility defect (resolved before final review): sized public
  generators are not necessarily replayable. Red16 versus4 evaluations and wrong
  norm; snapshot non-array public input once, use private deterministic mapped
  reduction internally. Final focused326 and100k/1m allocation reconfirmation passed.
- R1: ODE/ensemble wrappers checkpointed only after the entire ladder. A hard
  timeout could lose completed rows. Moved report calls inside rung loops; numerical
  kernels and measured workloads unchanged. Small safe scripts completed again,
  without repeating the100000-state or1000-member heavy evidence.
- R2: tiny mass-spring budget could refuse construction then dereference an empty
  holder, while structured rungs silently skipped. Added preflight branches before
  symbolic construction and explicit refusal rows before structured allocation.
  `example_guardrail_gate.jl`:3 low-budget checks +4 artifact checks passed;
  exact exit0 in `m10c-review-resolution.exit`.

No unresolved blocking finding remains in the reviewed supported scope.

## Checked boundaries

- BigInt estimates precede dangerous dense conversion and full-pair output.
  They are documented workload estimates, NOT exact peak-RSS guarantees.
- Partial solver is maintained ArnoldiMethod, controlled chain with diagonal mass,
  independent generalized residual and orthogonality; no homegrown eigensolver,
  generic sparse-SPD claim, or generic symbolic-HVP claim.
- Native SciML owns integration, interpolation, stepping, ensembles and reduction;
  no solver rewrite or implicit change to legacy32-state trajectories.
- Existing Welford numerics retained, no new IID uncertainty or sample dropping.
- All-pair full output remains quadratic; coordination reduces retained storage,
  not traversal complexity. No second MD engine.
- Summary-only and batch paths have explicit contracts. Native chunk allocation
  may increase; no unmeasured peak-memory reduction claimed. Public full analysis
  containers intentionally retain evidence. Nonfinite/underflow/type oracles pass.
- No GPU, real10^10 completion or giant training claimed. Extreme model evidence
  is preflight refusal only. Unknown cold neural setup remains explicitly unknown.
- Only bounded tests are registered. Optional large runs are outside Pkg.test.
- Every required conceptual showcase has executed safe/local evidence or an explicit
  guardrail outcome. Generalization100/10000 gap passed36 assertions; one tiny
  optimizer step is real, not an invented trained-result fixture.
- Final six-panel figure inspected directly: axes distinguish result storage and
  allocation, local context shown, refused rungs annotated without zero-time points,
  no clipped titles/legends. CSV checksums accompany17 lightweight snapshots.
- Root environment unchanged; optional ArnoldiMethod environment is relative-path
  based. Source hashes validated before reuse; unrelated concurrent source additions
  do not invalidate a completed workstream's numerical evidence.

## Candidate/security and source freeze

`m10c_candidate_scan.py` scanned Git's bounded changed/untracked candidate set:
68 files,1175900 bytes at initial scan, zero findings for credential/key/token/URL,
unsafe Python shell/deserialization, forbidden artifacts, or files over2MB.
Generated data are only small CSV/TOML-derived summaries and figures; large raw
outputs/models remain ignored. Final documentation changes require a cheap final
candidate/index scan, not another scientific review.

`git diff --check` passed. `m10c-precanonical-source.json` freezes172 executable
source/test/example/environment files. Canonical gate is the next action; its
result must be read before a verified commit is permitted. This review does not
claim a canonical pass in advance.

Post-review closure (not another review): isolated canonical exposed missing
SHA/TOML test-target declarations. Their focused correction passed21/21; the user
authorized one replacement canonical, which passed4789/4789 in167 reported
testsets,exit0. Production source and tests are unchanged from the review snapshot;
only test-target Project.toml declarations differ. Final documentation records this
closure; final index hashes must match the tested source and audited candidate.
