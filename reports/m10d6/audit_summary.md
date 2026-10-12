# M10D.6A — source-grounded documentation audit

Status: STATIC AUDIT VERIFIED COMPLETE. This closes audit/inventory/design only,
not documentation implementation, a scientific runtime gate, a release verdict,
M10D.6B or Wiki publication.

Baseline: `377a3c45905d0e16dba1fc2adc9d8eb3dcff14ca` (verified M10D.5).
Working scope: `reports/m10d6/` only. README, source, tests, example programs,
Project/Manifest files and historical measurement evidence remain unchanged.

## Recovery and preservation

Both interrupted children failed on provider rate limits, not scientific tests.
They persisted useful core API and resource/refusal work. Their bounded artifacts
were hash-matched and reused, without treating child failure or partial work as
whole-audit completion. No new subagent was launched; continuation was sequential.

The handoff archive validates all 18 initial artifacts. Seventeen non-checkpoint
artifacts remain byte-for-byte unchanged. The mutable progress file was advanced;
its original is preserved as `handoff_progress.json`, its later pre-reconciliation
state as `checkpoint_before_reconciliation.json`. The original archive remains
local in `reports/m10d6_recovery/20261012T010229Z/`, excluded from the commit.
`handoff_recovery.json` records archive hashes, child-log locations and dispositions.
`preserved_inputs.json` additionally freezes 105 immutable inputs and batch records.

## Coverage, without conflating enumeration and review

- All 311 baseline repository entries have explicit coverage/disposition and hashes.
- 263 have full semantic read evidence. The other 48 are historical-document
  bookends, environment-lock/data enumeration or hash-only frozen assets; these
  are not falsely represented as complete semantic reads or freshly verified gates.
- All 70 source/extension entries, 103 Julia test files, 43 Julia example files
  and 13 Julia notebooks have full semantic read evidence, including recovered work.
- All 177 explicit exports are reconciled against source and frozen ownership:
  130 PUBLIC_STABLE and 47 PUBLIC_EXPERIMENTAL across 36 families, including the
  INTERNAL family with no promoted exports.
- The two deliberately qualified experimental scientific metadata/origin
  interfaces are inventoried separately, not added to the export count.
- Shared generic reviews retain all audited family variants; literal signatures,
  input/output shapes, defaults, refusal/error behavior, units, order, ownership,
  optional dependencies, limitations, documentation gaps and supporting references
  remain traceable to source and batch artifacts.
- 88 sequential batches were persisted. The inherited bounded reviews remain
  separately labeled; no fresh Julia method-introspection or branch-coverage
  completeness is claimed.

The current symbol-level reference remains partial. Completing this audit does
not mean every API is already fully documented. `api.json` distinguishes semantic
review from documentation coverage; its reviewed variants preserve the original
interpretation records rather than silently choosing one overload's contract.

## Principal findings and dispositions

1. Actual public byte-estimate controls are matrix
   `normal_modes(...;max_memory_bytes=512*1024^2)` and
   `pair_distances(...;max_bytes=512*1024^2)`. There is no global public AML
   memory-budget configuration function. Output counts, diagnostic-history
   limits, query chunking, summary-only results and source-retention policies
   are distinct controls, not whole-process memory guarantees.

2. Exactly 32 scalar-field variables passes the dimension guard; 3000 does not.
   A supplied 3000-square Float64 Hessian has a 72,000,000-byte single payload.
   The direct dense modal route estimates 1,728,000,000 bytes, exceeding its
   536,870,912-byte default. Those are calculated estimates, not observed RSS
   or new executions. Sparse input still densifies. Mechanical and snapshot
   adapters can allocate before reaching the direct matrix preflight.

3. Fixed exact-algebra and symbolic dimension/seed limits are not user RAM
   settings. Symbolics construction, compilation and some elimination operations
   are not bounded by those guards. Private partial-chain/native SciML scaling
   experiments do not create generic public HVP, sparse-Hessian, partial-mode
   or large-state trajectory escape hatches.

4. `diffusion_estimate` can fit eligible index-time MSD. Existing test source
   constructs an index-time estimate. The older family synopsis and original
   Q049 premise overstate the implementation when they imply a direct physical
   time refusal. Physical interpretation requires an appropriate declared time
   scale and a caller-justified fit interval. `docs/trajectory_statistics.md`
   already explains per-index output correctly. The reconciled Wiki inventory
   corrects the question without modifying runtime or historical evidence.

5. Scalar stationary-search recovery notes can suggest bounds even when the
   actual refusal is resource-budget/unknown-domain and numerical fallback will
   not run. Document that limitation; no source fix was authorized here.

6. Current M10D.2/M10D.3/M10D.5 behavior supersedes old missing-bridge,
   missing-backend and future-milestone prose. Preserve historical reports,
   but label them in navigation and do not copy their pending statements into
   current capability claims. A maintainer gate still uses AML's internal
   ForwardDiff binding (`examples/inference/lj_gate.jl:38,76`); do not reuse
   that import convention as supported tutorial API.

7. Native solver completion, numerical spectrum, small residual/loss, empirical
   sampled error, metadata availability and scientific validity remain separate.
   Unknown is not false, zero or absent work. PropertyResult retains its four
   fields; isolated leaf ancestry is intentionally unavailable. Origin tokens
   are process-local identities, not reproducibility hashes.

No contract ambiguity was silently converted into a capability or API. Adapter
preflight placement, the bounds recovery wording, any later runtime narrowing of
index-time diffusion and dedicated hard-limit test gaps remain explicit owner
follow-ups, not changes made or prerequisites concealed by this audit.

## Refusal and resource audit

`refusal_sites.json` preserves 876 lexical candidate sites. These include benign
catches and statuses and are not 876 proven runtime failures. `refusal_review.json`
combines 29 actionable grouped contracts with all exported APIs' error/limitation
records and complete source-read coverage. Semantic source review is distinct
from individually path-executed branches or a resolved Julia call graph.

`resource_controls.json` distinguishes byte estimates, cardinality, logging,
query activations, summary retention, provenance retention, fixed internal caps
and maintainer environment controls. It records the preflight scope, defaults,
outcomes and missing guarantees. All test references remain source evidence only.

## Documentation deliverables

- `api.json`: consolidated explicit exports, qualified interfaces and reviewed
  variants, with literal signatures and source hashes.
- `coverage.json`: every baseline path, review mode, hash and evidence pointer.
- `examples_tests_inventory.json`: tests, examples, notebooks and optional
  environment contracts, separated from execution claims.
- `documentation_inventory.json`: current guides and frozen history/assets,
  including heading and inspection-level inventories.
- `documentation_architecture_reconciled.md`: README → technical reference →
  question-led Wiki architecture, complete family destinations, alias policy,
  contract template, scientific corrections and later acceptance gates.
- `readme_inventory.json` plus preserved `readme_plan.md`: existing headings,
  migration/design plan and mandatory caveats; README is not rewritten.
- `wiki_inventory.json`: 90 source-linked proposed questions, including corrected
  diffusion wording and resource/history/chunking/retention questions. No answers
  were published; future destinations are proposals, not deployed links.
- `reconciliation.json`, `verification.json` and `progress.json`: totals,
  validation and phase disposition.

## Real verification and non-execution

Executed static checker:

    PYTHONDONTWRITEBYTECODE=1 python3 reports/m10d6/reconcile_audit.py --verify

It passes with no errors: 311 source hashes, 105 preserved input hashes,
177-export ownership/required-field reconciliation, qualified-interface handling,
mandatory source/test/example read coverage, 3,968 unique existing citation ranges
and 259 existing evidence paths. JSON parsing is checked for every report.
Proposed future technical/Wiki destinations are explicitly not deployed links.

The first checker invocation identified three Wiki references to qualified public
interfaces as unknown exports. Its validation logic was corrected to recognize
those two separately inventoried interfaces; export classification did not change.
This was an audit-validator defect, not a Julia test or scientific failure.

No Julia tests, canonical suite, installation, dependency resolution, optimization,
benchmark, stress ladder, new rendering or Documenter build ran in M10D.6A. Existing
scientific execution reports are preserved history, not new passing results.
The report helpers were actually exercised to build and validate the inventories.
Candidate/index checks and local commit read-back are finalization gates recorded
separately. No push, tag, history rewrite or M10D.6B action is included.
