# M10C-B — executed native ODE scaling evidence

## Outcome and scope

Implemented the internal native in-place adapter in `src/dynamical_systems/scaling.jl`, plus `examples/scaling/large_oscillator_ode.jl` and `examples/scaling/ode_ensemble.jl`. Preserved the recovered `test/m10c_ode_scale.jl` assertions and extended them. No solver rewrite, new dependency, public export, or change to the legacy 32-state `FirstOrderODE` / `trajectory` API.

The adapter owns a Float64 initial-state copy; rejects nonreal/nonfinite/unrepresentable initial values; checks dimension, state, domain membership and complete finite derivatives at each RHS call. Filling `du` with NaN detects unwritten components without a derivative allocation. Caller-performed Float64 arithmetic can underflow before the boundary sees it; this adapter does not certify arithmetic or continuous domain membership between stages. Native SciML owns storage, stepping, solving and ensembles.

Completed: 100/1000/10000/100000 **states** (up to 50000 independent oscillators), native storage comparisons, reduced-observable oracle, and serial/two-thread ensembles at 100/1000 trajectories. At 100000 states the dense-history solve was **refused before allocation**, while sparse/endpoints/reduced solves completed. No intentional OOM, timeout, extreme run, stiff subsystem, canonical Pkg.test, review, commit, push, tag or M10D work was performed by this workstream.

## Configuration and measurement meanings

- Julia 1.12.7; SciMLBase 3.54.0; OrdinaryDiffEqTsit5 2.1.4; Float64.
- CPU: 13th Gen Intel(R) Core(TM) i7-1355U.
- Oscillators: one Julia thread / one BLAS thread. Explicit ensemble comparison: two Julia threads / one BLAS thread; serial backend also measured in that process.
- Estimated workload storage budget: 536870912 bytes (512 MiB). Cooperative per-measurement time ceiling: 120 seconds; external process timeout: 300 seconds. All Julia processes serialized with the shared flock.
- Warmup is separate; reported time/allocation is the arithmetic mean of two subsequent executions, not a universal benchmark or formal scaling exponent. Runtime/JIT/GC noise is visible, especially full-history storage.
- `estimated_bytes` is conservative planned live workload storage/workspace. `allocated_bytes` is Julia allocation over a call, not peak storage. `result_bytes` is `Base.summarysize` of the returned object, including native references/caches where retained. These quantities are not interchangeable.
- Lifetime process RSS high-water reached 1416994816 bytes (1351.35 MiB) in the oscillator stress process. This includes AML dependencies/JIT/runtime and is **not** a per-workload peak or a 512 MiB process cap. The harness measures only lifetime RSS; isolated workload peak RSS is unavailable.

## TDD and legacy boundary audit

The first resumed action executed the existing test, before production changes: exit 1, one pass / one expected failure (`_scale_ode_problem` absent). Before implementation, a warmed legacy decay RHS audit measured 224 bytes at 2 states and 1184 bytes at 32 states. Source inspection identifies both the user out-of-place derivative vector and AML's `Float64[value...]` conversion vector. This is an avoidable-allocation boundary for a new numerical large-state path, not permission to change legacy semantics.

After implementation the original boundary assertions passed 10/10. A second RED gate failed because the two requested example files were absent; after adding native storage and ensemble workflows their behavioral/oracle checks passed 9/9. The final affected gate passed **601 assertions** across:

- `test/m10c_ode_scale.jl` (19);
- `test/m10a_calculus_dynamics.jl`;
- `test/m10b_nonfinite.jl`;
- `test/m10b_types.jl`;
- `test/m10b_inference_scaling.jl`.

The same-size oscillator audit and larger in-place ladder follow. Time is the mean of two warmed 1000-call loops from the stress log, divided by 1000. Allocation is a separately warmed **single RHS call**, not the harness row's construction-plus-loop allocation.

| States | Route | RHS ns/call | RHS allocated bytes/call |
|---:|---|---:|---:|
| 32 | legacy out-of-place | 825.325 | 1184 |
| 32 | checked native in-place | 34.354 | 0 |
| 100 | checked native in-place | 95.325 | 0 |
| 1000 | checked native in-place | 961.597 | 0 |
| 10000 | checked native in-place | 10210.931 | 0 |
| 100000 | checked native in-place | 123990.425 | 0 |

Observed RHS work grows with state dimension, as expected for the oscillator loop plus O(n) validation. The allocation change is verified at the boundary; solve construction and native solver workspace still allocate.

## Storage versus solve

Independent oscillators satisfy `q'=v`, `v'=-q`, with initial `(q,v)=(1,0)`. Native Tsit5 uses fixed dt=0.05 to t=5, so each completed solve reports **601 native solver RHS evaluations**, excluding the adapter's initial validation call. Fixed stepping deliberately holds integration work constant across storage policies; this is not an adaptive-accuracy claim.

- Full: every step plus native dense interpolation, 101 saved states.
- Sparse: six states at t=0,1,...,5; dense interpolation disabled.
- Endpoints: two saved states; dense interpolation disabled.
- Reduced: native `init` / `step!` with no stored state snapshots, retaining selected coordinate, total energy and RMS at 101 times (303 scalars). This is O(number of requested observations) small output, not a claim of constant storage in time; solver workspace remains O(n).

`verify_storage()` compares the reduced trace against the **small fully stored native solution** at the same times, and all policies against `cos(t),-sin(t)`, energy n/4 and RMS sqrt(1/2). Assertions require error <1e-7. Measured endpoint max error was 6.953e-11 and reduced normalized-observable max error below 1.339e-10 throughout the completed ladder.

| States | Policy | Warmed ms | Allocated bytes | Returned object bytes | Preflight bytes | Status |
|---:|---|---:|---:|---:|---:|---|
| 10000 | full | 266.111 | 65517632 | 65245264 | 80065536 | completed |
| 10000 | sparse | 10.454 | 1847016 | 1601584 | 3265536 | completed |
| 10000 | endpoints | 11.007 | 1526456 | 1281336 | 2625536 | completed |
| 10000 | reduced | 10.297 | 1304536 | 6448 | 2625536 | completed |
| 100000 | full | — | — | — | 800065536 | refused before allocation |
| 100000 | sparse | 146.594 | 18407016 | 16001584 | 32065536 | completed |
| 100000 | endpoints | 141.786 | 15206456 | 12801336 | 25665536 | completed |
| 100000 | reduced | 138.578 | 12824536 | 6448 | 25665536 | completed |

The full 10000-state warmup took 42.504 ms versus 266.111 ms mean measured execution: substantial GC/runtime variation makes a precise speedup claim inappropriate. The returned-storage difference is direct evidence that dense history can dominate this controlled problem. A small number of native saved states can still retain solver workspace, explaining why endpoint result size exceeds its two-state scalar payload.

## Native ensemble evidence

SciML `EnsembleProblem` uses deterministic decay rates `0.5+(i%10)/10`, independent copied initial states, Tsit5 fixed dt=0.05 to t=1, and `EnsembleSerial` / `EnsembleThreads`. Current SciMLBase's `(prob,ctx)` and `(sol,ctx)` hooks identify members through `ctx.sim_id`. Full mode retains all native trajectories (21 saved states each). Aggregate mode uses native `output_func` and a native reduction over batches of at most 32, returning sum/count/max-error/RHS-call-count, rather than retaining all member outputs. No shared mutable RHS cache is used.

`verify_ensemble()` compares aggregate sum with a small full run and both with analytic exp(-rate*t), and exercises threaded/full and threaded/aggregate paths when two threads are present. Every measured member completed successfully; full-mode maximum analytic error was 3.786e-11. Each trajectory used 121 native RHS calls: 12100 for 100 members, 121000 for 1000, excluding construction validation.

| Trajectories | Backend / output | Warmed ms | Allocated bytes | Returned object bytes |
|---:|---|---:|---:|---:|
| 100 | serial / aggregate | 0.413 | 477568 | 104 |
| 100 | serial / full | 1.200 | 1803944 | 1151984 |
| 100 | threaded / aggregate | 0.439 | 481472 | 104 |
| 100 | threaded / full | 17.291 | 1807848 | 1151984 |
| 1000 | serial / aggregate | 3.575 | 4763360 | 104 |
| 1000 | serial / full | 6.373 | 18084968 | 11524880 |
| 1000 | threaded / aggregate | 2.510 | 4794592 | 104 |
| 1000 | threaded / full | 9.049 | 18116200 | 11524880 |

Aggregate returned storage stayed bounded while allocation increased with trajectories, as expected. Thread overhead and GC dominate these cheap solves; the table does **not** support a universal parallel speedup.

## Reproduction and preserved artifacts

Working directory: `/home/lorenzozm/PROJETOS/analyticmath-lab`. Scratch prefix: `/home/lorenzozm/.hermes/cache/scratch/m10c-ode-`. The saved runner `run.py` records exact commands, exits and source SHA256 hashes and copies completed CSV/TOML reports to per-gate scratch names. Examples generate small reports under ignored `output/scaling/`; later runs replace those paths, whereas per-gate scratch copies preserve the evidence used above.

All executed commands use this prefix, with the listed environment and final Julia argument:

```sh
flock /home/lorenzozm/.hermes/cache/scratch/m10c-julia.lock \
  timeout --signal=TERM --kill-after=10s 300s \
  env JULIA_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 \
  AML_MAX_THREADS=1 AML_SCALE_LEVEL=0 \
  julia +release --startup-file=no --project=. <target>
```

| Preserved log suffix | Target / differences | Exit |
|---|---|---:|
| `red.log` | `test/m10c_ode_scale.jl`; original RED, before source implementation | 1 expected |
| `baseline.log` | scratch `m10c-ode-baseline.jl`; legacy RHS audit before source implementation | 0 |
| `green.log` | `test/m10c_ode_scale.jl`; original assertions GREEN | 0 |
| `storage-red.log` | `test/m10c_ode_scale.jl`; examples absent RED | 1 expected |
| `storage-green.log` | `test/m10c_ode_scale.jl`; storage/ensemble GREEN | 0 |
| `oscillator-safe.log` | `examples/scaling/large_oscillator_ode.jl`, level 0 | 0 |
| `oscillator-local.log` | same, `AML_SCALE_LEVEL=1` | 0 |
| `oscillator-stress.log` | same, `AML_SCALE_LEVEL=2`; source of RHS/storage tables | 0 |
| `ensemble-safe.log` | `examples/scaling/ode_ensemble.jl`, level 0, one thread | 0 |
| `ensemble-local.log` | same, `AML_SCALE_LEVEL=1`, `JULIA_NUM_THREADS=2`, `AML_MAX_THREADS=2`; source of ensemble table | 0 |
| `affected.log` | scratch `m10c-ode-affected.jl`; five affected test files listed above | 0 |

The earlier RED/baseline commands predate the runner and omit AML budget variables because they invoke only small direct tests/audits; their exact commands are the first line of their logs. Example gates have sibling `.csv` and `.toml` snapshots. TOML contains hardware/thread metadata and source/dependency hashes. The exact bounded re-execution helper is:

```sh
python3 /home/lorenzozm/.hermes/cache/scratch/m10c-ode-run.py \
  oscillator-safe 1 0 examples/scaling/large_oscillator_ode.jl
```

Relevant executed source SHA256 values:

```text
842e3bad74653f72a83db524f8e5015fd94296f9fe6960a54698447124ec99fc  src/dynamical_systems/scaling.jl
440ac1dbfd9dc4551a9746b2e3616af55392cf7ee4419af3d7347e821e8f5917  test/m10c_ode_scale.jl
65edd97dc30c7a815514b15968e101a1a06502d258791e688e1bf477bd49c6ea  examples/scaling/large_oscillator_ode.jl
33853bd27ffc6f358c7a998054e33bcd6e4164e5f9e6d1103fe93e0b7bb6ffac  examples/scaling/ode_ensemble.jl
c24898550d5d97fc1c1c7c21f94cf2916213c11d18f99b403c9cc3e487b07b43  examples/scaling/harness.jl
```

## Remaining integration / explicitly unexecuted requirements

Parent owns the entry module, canonical test runner, architecture inventory and shared milestone reports. **Register `include("dynamical_systems/scaling.jl")` after `integration.jl` and register `test/m10c_ode_scale.jl` in the safe test runner.** At handoff, tests/examples have a temporary conditional internal-source include so they were genuinely exercised before that parent-owned registration. Do not interpret this workstream's gate as final package integration or whole-M10C completion; parent must carry its results into shared inventory/ledger/results and perform the reserved finalization gates.

Original sections 21–25 and mandatory bounded work of section 27 have executed evidence above. Section 26's stiff-system experiment is optional and not attempted. The conceptual 100000-oscillator / 200000-state level-3 example is implemented but **not executed**; level 3 requires `AML_EXTREME=1`. Ensemble levels 2/3 (10000/100000 members) are **not executed**. No workload beyond the reported ladders is claimed completed. The 100000-state full-history configuration remains **guardrail-refused**, not solved. No additional optional experiment is needed for this bounded workstream; user credit containment stopped further ladders.
