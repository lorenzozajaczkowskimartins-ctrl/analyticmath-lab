# M10C scale-contract inventory

Recovery checkpoint: inspection inventory preserved unchanged; see
`m10c_results.md` for the recovered workstream table. At recovery all tracked
source/environment files still match baseline; no M10C timing had executed.

Baseline: `091492e03dbf5fc1346c9ffa3dfbdfcd3f2bbe93` (clean).
This is an inspected implementation inventory, not a universal performance promise.
Time/storage orders below describe the algorithm and output, not measured timings.
M10A mathematics and M10B numerical boundaries remain binding. Public API unification
is deferred to M10D. Execution evidence will be linked from `m10c_results.md`.

| Subsystem / operation | Expected work | Representation / materialization | Output / likely memory | Backend | Risk / scalable route | Verification |
|---|---|---|---|---|---|---|
| M7 `normal_modes` | dense O(n³) | `_nm_numeric`, mass eigenvectors, square roots, weighted matrix, full eigenspectrum and reconstruction are dense | multiple O(n²) matrices, full n modes | LinearAlgebra/LAPACK Float64 | sparse input does not imply sparse solve; guard before conversion; optional partial structured route | `src/mechanics/normal_modes.jl`; M10A mechanics, M10B linear algebra |
| M7 Cartesian mass | O(nd) construction | dense diagonal construction currently needs inspection at large nd | O((nd)²) if explicit dense | LinearAlgebra | known diagonal structure should remain structured on explicit scalable route | `cartesian_mass_matrix`, atomistic mode bridge |
| M7 Lagrangian / EL / linearization | expression-dependent; all second derivatives and exact elimination | symbolic Matrix, repeated expand/simplify, exact determinant/elimination | O(n²) entries plus expression graphs | Symbolics | symbolic growth may precede numeric solve boundary; measure phases, use known structured chain rather than claim generic sparse symbolic support | `mechanics/core.jl`, `legendre.jl`, `normal_modes.jl` |
| M4/M5 Hessian/Jacobian | all requested entries | generated scalar callables and dense derivative containers | O(n²), O(mn) plus symbolic graphs | Symbolics, ForwardDiff | differentiate full objects only where scientifically needed; controlled quadratic H*v benchmark | multivariate/vector analysis and calculus files |
| M6 `FirstOrderODE` / trajectory | RHS × evaluations + integration | currently limited to 32 states, out-of-place RHS plus Float64 copy, always dense history/every step | O(n × saved steps) plus interpolation coefficients | SciMLBase, Tsit5 | separate explicit in-place/scalable native route; reduced observable/save policy without changing legacy interpolation | `dynamical_systems/integration.jl` |
| M6 ensembles | trajectory count × per-solve work | no AML ensemble orchestration in inspected legacy path | full solutions vs bounded per-trajectory aggregates | SciMLBase native ensembles | use native ecosystem, bound concurrency/output; serial vs threaded measured locally | new scaling examples |
| M8 snapshot/frame view | O(1) borrowing/frame access | `copy_data=false` borrows; opt-in deep copy; lazy `getframe` | input-owned O(Nd); no trajectory history copied by view | AML/Molly adapter | distinguish source storage from analysis storage | `atomistic/core.jl` |
| M8 all-pair distances | O(N²d) | two selected-index arrays; per-pair coordinate copies; Any distances plus pair tuples | unavoidable O(N²) output | AML geometry or supplied backend distance | max_pairs exists but no byte estimate; explicit all-pairs semantics cannot drop pairs; summary-only alternative | `pair_distances`, M10A/B atomistic |
| M8 coordination/RDF | O(N²d), per frame for RDF | direct pair traversal; coordination O(N); histogram O(bins+frames+N) | bounded relative to pair count, not subquadratic work | AML/backend geometry | no second neighbor/force engine; aggregate traversal/guardrail rather than fictitious fast all-pairs | `atomistic/distributions.jl` |
| M8 summary/running moments | O(N) | `_ts_moments` already iterates, generic state, no collection unless running | summary O(1), cumulative output O(N) | AML Welford sample-variance recurrence | iterator not public; investigate boxing/allocation and resumable state, bounded checkpoint output | `trajectory/statistics.jl`, M10B statistics |
| M8 correlation / correlated mean | O(N maxlag) | scalar collect, centered array, autocovariance outputs | O(N+maxlag) | direct AML correlation | not O(1) for full autocorrelation; bounded lag/window or replayable/chunk method with explicit semantics | statistics/uncertainty |
| M8 blocks/transient | O(N × block levels) | collect scalar observations; retains block means | O(N + sum block counts) | AML | full returned block means are output obligation; separate online aggregate means when sufficient | `trajectory/uncertainty.jl` |
| M9 `PINNPoints` | O(dQ) | checked Float64 owned coordinates | O(dQ) | AML/NeuralPDE boundary | required owned storage; chunk construction rather than hidden precision change | diagnostics, optional PINN gate |
| M9 `sampled_summary` | O(Q) | collect, float/abs/normalized temporaries | O(Q) although summary O(1) | AML generic floating | measured fused/streaming reductions must retain BigFloat/subnormal/unknown semantics | diagnostics, M10B diagnostics |
| M9 `field_errors` | O(Q) | prediction/reference caller storage, difference and absolute array, metric temporaries | O(Q) absolute output required | AML | summary-only explicit route and bounded chunking; keep legacy returned absolute errors | surrogates |
| M9 datasets/scaling | O(total targets) and validation pair checks across samples | owned samples; deep metadata; hcat/vcat training arrays; transform temporary arrays | O(total targets) plus batches | AML | separate scientifically required copies from avoidable fitting reductions | surrogates/data contracts |
| M9 generalization | O(total targets) | retained predictions/errors plus vcat group arrays | multiple O(total targets) arrays | AML | existing full result intentionally stores evidence; explicit reduced analysis/batching avoids hidden full outputs | generalization |
| M9 native prediction | network cost × Q | giant network batch and network-input repeat/vcat | activation O(width × batch × layers), plus output | Lux/NeuralOperators/NeuralPDE | bound queries per batch; stateless pointwise restriction, compare to monolithic | optional extensions |
| M9 signed residual | compiled block batch loop | copies parameter state, small padded last batch; retains all residual values | O(Q) values plus backend workspace | NeuralPDE public residual/SII | summary-only route can consume batches, not pretend continuum norms | `ext/pinn_diagnostics.jl` |
| M9 CPU learning | architecture-dependent forward/backward | parameters, gradients, optimizer states, activations | at least multiple parameter payloads plus batch workspace | Lux, Optimization, AD | estimate before construction, CPU-only local stress, separate actual training opt-in | manual scaling ML example |
| Visualization | output-dependent | coordinate/value conversion and plotting arrays | O(plotted points/pixels) | Makie/CairoMakie | plot small measurement tables, never raw extreme arrays | scaling report figures |

## Measurement and safety contract

Four levels: 0 smoke, 1 local, 2 manual stress, 3 extreme explicit opt-in.
Default local operation estimate budget: 512 MiB; isolated process ceiling is a
separate, approximate RSS observation, not an exact allocator promise. Initial
host inspection: 16,433,725,440 bytes physical RAM, Intel i7-1355U. Set Julia and
BLAS thread counts explicitly, run heavy Julia processes serially, retain warmed
and first-call times separately. No intentional OOM. No automatic extreme run.

Report estimated numeric payload/workspace, allocated bytes, result `summarysize`,
and process RSS separately. Reject overflowed size arithmetic using BigInt before
any allocation. Progress/deadline streaming checks must record consumed count;
10^10 is a supported request, not presumed completion. Timeouts retain completed
rungs. Known full output contracts remain full output or explicitly refuse.

## Recovered-development evidence (not final verification)

See `m10c_shared_evidence.md` for executed shared gates and exact logs.
M8 Float64 lazy summary already allocates O(1) auxiliary storage (784 bytes for
100k and 1m range values); no kernel rewrite was justified. The example iterator
adds explicit consumed/requested counts and chunk-boundary deadline checks.
Full running/block/ACF result contracts remain materializing and are documented.
Tuple particle separation no longer collects three coordinate arrays per pair;
all-pair output has a byte-estimate refusal in addition to max_pairs. Coordination
is a bounded-output alternative, NOT a subquadratic algorithm.
Credit containment excludes new optional extremes and exploratory stress ladders.

## Consolidated supported routes

The initial table above is the pre-change inventory, not the final implementation.
`m10c_mechanics_evidence.md`, `m10c_ode_evidence.md`, `m10c_ml_evidence.md`, and
`m10c_shared_evidence.md` supply before/after evidence. Current supported additions:
- full dense modes have overflow-safe preflight; a separate optional ArnoldiMethod
  chain example uses matrix-free H action and structured shift-inverse, not a
  generic sparse-SPD or symbolic-HVP API;
- internal checked native ODE boundary is centrally included; native save/step/
  ensemble policies avoid full history without changing legacy32-state semantics;
- Float64 lazy statistics reuse the existing kernel; only orchestration is new;
- fixed tuple geometry avoids coordinate-array copies; explicit pair output has
  estimated-byte refusal and honest quadratic-work alternatives;
- array sampled reductions and summary-only field errors avoid O(Q) scratch;
  arbitrary public iterators snapshot once (length does not prove repeatability);
- explicit batch_size bounds tested pointwise neural activations, not full output
  size or total cumulative allocation; full analysis containers keep their existing
  evidence contracts. Internal residual summaries are not a public result redesign.

Complete original acceptance mapping: `m10c_dod.md`. Local measurements and figures
are under `m10c_measurements/`; large raw outputs remain ignored.

Final checkpoint: production consolidation and bounded review complete. Canonical
exit1 exposed missing test-target TOML; current SHA/TOML target declarations pass
the isolated guardrail gate21/21. No scientific kernel changed after source freeze.
Canonical completeness remains blocked, not inferred from focused success. Exact
next action needs authorization for a replacement canonical invocation; do not
repeat valid stress evidence, optional extremes or completed workstreams.

Final closure: the explicitly authorized replacement canonical passed4789/4789
across167 reported testsets,exit0. All172 executable/environment snapshot hashes
match. Existing scale evidence and supported boundaries remain unchanged; no
benchmark, optional extreme or workstream was restarted.
