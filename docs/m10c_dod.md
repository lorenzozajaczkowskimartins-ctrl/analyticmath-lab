# M10C original Definition of Done mapping

This maps all original section79 items; it does not replace or weaken them.
Workstream reports provide exact commands, source identity, statuses and limitations.
Pending final gates are not claimed passed. Optional extremes are explicitly excluded
by the user, not silently counted as completed workloads.

| Item | Requirement | Evidence / disposition |
|---:|---|---|
| 1 | Scaling inventory | m10c_scaling_inventory.md |
| 2 | Bug ledger | m10c_bug_ledger.md |
| 3 | Budgeted harness | harness.jl; red/green21 |
| 4 | Four explicit tiers | StressBudget and examples/scaling/README.md |
| 5 | Dense preflight | normal_modes before coefficient access; unreadable huge matrix test |
| 6 | Dense Hessian scaling | when_dense_dies rows and refusal |
| 7 | Full-mode cost measured | mechanics baseline n600; completed n1200 |
| 8 | Maintained partial backend | ArnoldiMethod optional environment |
| 9 | Direct partial residual | n30000 k4 residual1.01e-15 |
| 10 | Structured mechanics | diagonal mass/tridiagonal chain |
| 11 | Controlled matrix-free action | ChainAction mul!; n30000 without dense H |
| 12 | Mass-spring showcase | AML n3,5 and structured dynamics n150,600 |
| 13 | Symbolic growth | n5,10,20 phase rows |
| 14 | Symbolic/numeric separated | construction/diff/simplify/generation/first-call/eval rows |
| 15 | Large ODE state | 100000 states, reduced/sparse/endpoints completed |
| 16 | RHS allocation audit | legacy1184 bytes at32; checked in-place0 through100000 |
| 17 | Storage scaling | full history versus sparse/endpoints/reduced |
| 18 | Reduced-observable equivalence | native stored small-run + analytic energy oracle |
| 19 | Ensembles | native serial/two-thread100/1000 aggregate/full |
| 20 | O(1) summary storage | existing M10B kernel retained; lazy Float64 allocation measured |
| 21 | Million observations | 1m completed |
| 22 | 10^10 lazy request | constant-size lazy object; opted-in immediate-deadline smoke |
| 23 | 10^10 execution honest | NOT COMPLETED; no real extreme run |
| 24 | Correlation limits | O(N*lags) work/O(N+lags) memory; bounded prefix only |
| 25 | Pair growth quantified | N1000 499500 returned pairs; larger counts estimated |
| 26 | Pair guardrail/alternative | max_pairs+byte preflight; coordination bounded output |
| 27 | No second MD engine | existing shared distance/RDF/coordination reused |
| 28 | Million ML-side queries | 1m field/data analysis completed; neural prediction10k distinct |
| 29 | Chunk equivalence | field, Lux/DeepONet/PINN, heat residual focused gates |
| 30 | CPU safe/local forward/backward | 337/17025 parameters, gradient component oracle |
| 31 | Manual larger training example | tiers and explicit AML_ML_TRAIN opt-in |
| 32 | No invented GPU | CPU only |
| 33 | Materialization audit | ML and inventory tables; full outputs intentional |
| 34 | Proven defects fixed | C01/C02/C04/C05/C06 and consolidation generator regression |
| 35 | Before/after evidence | workstream logs + tables |
| 36 | Largest-workload table | m10c_results.md consolidation table |
| 37 | Hardware/config metadata | report TOML and evidence docs |
| 38 | Executed/estimated separation | CSV status and refusal-only estimates |
| 39 | Polished GitHub examples | examples/scaling/README.md; scripts; lightweight CSV/figures |
| 40 | Extreme not in canonical | runner includes only bounded correctness tests |
| 41 | No giant artifacts | bounded candidate size scan required |
| 42 | Affected M10A green | reused mechanics51/M8 290/ODE gate; operator43 refreshed |
| 43 | Affected M10B green | reused and affected refreshed gates |
| 44 | M10C focused + safe/local | consolidated focused326; source-valid example evidence reused |
| 45 | Optional gates | partial52; batching14/PINN13 reused; affected operator/PINN regressions refreshed |
| 46 | One canonical suite | Authorized replacement PASS4789/4789 across167 reported testsets,exit0 |
| 47 | One bounded review | COMPLETED; two orchestration findings resolved,7 checks passed |
| 48 | Coherent candidate tree |172 tested executable/environment hashes unchanged; bounded final index validation |
| 49 | Exact local verified commit | Verification satisfied; exact authorized subject recorded in local Git history |
| 50 | No push | local only |
| 51 | No M10D | scope unchanged |

## Mandatory consolidation gaps and disposition

1. Entry-module/architecture and six small-test registrations: applied, included in
   consolidated focused gate (326 assertions). No duplicate source includes/exports.
2. Sized stateful generator regression: reproduced (16 evaluations instead of4),
   fixed public one-pass snapshot semantics; internal deterministic reductions retain
   bounded memory. Same100k and larger1m allocation gates confirm320/976 bytes.
3. GeneralizationAnalysis lacked any scale measurement: bounded100/10000-target
   example added; real one-step four-parameter training fixture, no invented result.
   Native AD import typo fixed before successful measurement (gate pending at mapping).
4. GitHub usage/report/figure integration: README and snapshot renderer created;
   existing stress data reused, no new ladder. Figure inspection required after final render.
5. Candidate/security scan, one parent review (no subagents authorized), one canonical
   Pkg.test and exact local commit: reserved final gates, pending at mapping creation.

Not mandatory expansion: generic sparse-SPD solvers; arbitrary symbolic HVP;
public PINN analyzer result redesign; million-query neural prediction; million-point
optional residual; symbolic50/100; real10^10 completion; giant training; isolated
peak-RSS instrumentation. Existing full-result contracts retain their evidence.
The tested supported routes and unmeasured boundaries are stated explicitly.
Cold neural setup/first-gradient compilation is unmeasured, not hidden in warmed claims.

Final disposition superseding mapping-time pending notes: generalization36 checks,
figure inspection and bounded candidate scan completed. SHA/TOML test-target
correction was present on resumption and passed21 isolated checks. Canonical was
invoked once and failed; no second invocation or verified commit. Mandatory item46
is unsatisfied. Replacing that invocation requires explicit authorization.

Final closure supersedes the preceding historical blocker: user authorized one
replacement canonical; it passed4789 assertions across167 reported testsets with
exit0. All172 frozen executable/environment hashes match. No stress, review or
optional gate was repeated. Items46–49 are closed by this result and the final
local candidate/index/commit checks; no push, tag or M10D work.
