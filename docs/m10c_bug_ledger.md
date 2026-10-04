# M10C scalability findings ledger

Recovery: all seven candidates remain hypotheses at interruption. Three surviving
red-test files were written but not executed. No fixes or measurements were lost
from the tracked tree; see `m10c_results.md` for filesystem/request-record evidence.

Baseline `091492e03dbf5fc1346c9ffa3dfbdfcd3f2bbe93`. Inventory written before source
changes. Findings below start as inspected risks, not measured or resolved defects.

Classification: A unnecessary materialization; B hidden copy/duplicate storage;
C asymptotically inappropriate implementation; D full-output overcomputation;
E allocation blowup; F scientifically equivalent streaming opportunity;
G symbolic explosion; H missing chunking; I missing resource guardrail;
J backend limitation; K hardware limit; L expected complexity; M oracle error.
Only measured A–I findings normally justify implementation changes.

| Candidate | Path | Hypothesis | Initial class | Status |
|---|---|---|---|---|
| C01 | normal modes | full dense spectrum/intermediates even for structured input; no preflight byte budget | D/I/L | measured n600 baseline; dense preflight and maintained controlled partial route; dense1200/partial30000x4 completed; focused56/M10A51/M10B90 |
| C02 | ODE | 32-state limit and duplicate out-of-place arrays; full dense history unavoidable in legacy route | B/H/J | separate internal checked native adapter; RHS1184→0 bytes at32; through100000 states; storage/ensemble oracles and affected601 |
| C03 | moments | iterator kernel may box per sample; no deadline/progress resumable summary | L/F | Float64 boxing hypothesis disproved: 784 bytes at 100k and 1m; existing kernel reused by deadline/lazy example, no production rewrite |
| C04 | pair geometry | per-pair coordinate copies; no byte-level explicit-output estimate | B/E/I | red 256-byte tuple distance; tuple copies removed, byte estimate refusal added; green10 + affected M10A290/M10B146+419; larger N1000 completed |
| C05 | sampled diagnostics | O(Q) temporary arrays for O(1) summaries | A/F | 100k summary2400536→320 bytes; summary-only field976 bytes through1m; existing numeric oracles preserved |
| C06 | prediction | unbounded query activation batch | H | explicit pointwise chunking; Lux/DeepONet/PINN10k tests; cumulative allocation increases, no isolated peak-memory claim; internal residual result107968→56 bytes |
| C07 | symbolic mechanics | dense all-entry symbolic derivatives and simplify/exact elimination | G/L | bounded phases through20; no pathological boundary proven, no speculative symbolic-engine rewrite |
| C08 | consolidation | sized generator mistaken for repeatable iteration | scientific compatibility regression | red16 evaluations instead of4; public iterators snapshot once, private deterministic maps use replayable helper; consolidated focused326 green |

## Evidence policy

Keep before/after results, same-size scientific checks, larger-size reruns, and
honest new boundaries. Never reclassify requested/estimated sizes as executed.
Final focused/optional gates and the one bounded review passed; canonical failed
on an undeclared test-only TOML dependency. No M10D work.

## C09: isolated canonical test dependencies

Canonical exit1: harness could not import TOML in Pkg.test's isolated environment.
Current Project.toml includes SHA/TOML extras and target entries. Focused isolated
target gate passed21/21 with global load-path fallback disabled. Only Project.toml
changed since the precanonical source snapshot. Full canonical pass remains absent;
no second invocation is authorized under ONCE, and no verified commit was made.

Final disposition: user subsequently authorized exactly one replacement canonical.
It passed4789/4789 across167 reported testsets,exit0. C09 is closed; the earlier
failed log remains preserved. No scientific implementation changed on replacement.

Shared evidence and exact logs: `m10c_shared_evidence.md`. Harness red/green21;
streaming red/green16, actual million-sample completion; optional 10^10 execution
is not claimed. Credit containment: finish current bounded workstreams only;
no new agents, optional extremes or repeated valid benchmarks.
