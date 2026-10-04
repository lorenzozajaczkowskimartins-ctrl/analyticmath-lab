# Scale and large-object examples (M10C)

These are reproducible, resource-budgeted local demonstrations, not universal
performance rankings. Begin at level 0. Full results and limits are in
[the M10C report](../../docs/m10c_results.md) and its four workstream reports.

## Setup and bounded execution

From the repository root, use Julia 1.12. The root environment already owns the
base numerical dependencies. Only the controlled partial-chain examples need the
separate ArnoldiMethod environment; it does not change AML's mandatory dependencies.

```sh
julia +release --project=. -e 'using Pkg; Pkg.instantiate()'
julia +release --project=examples/scaling -e 'using Pkg; Pkg.develop(path="."); Pkg.instantiate()'
mkdir -p output/scaling
# Linux: serialize all commands and apply a hard process deadline, including JIT.
scale() {
  flock output/scaling/run.lock timeout --signal=TERM --kill-after=10s 360s \
    env JULIA_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 \
    julia +release --startup-file=no "$@"
}
scale --project=examples/scaling examples/scaling/when_dense_dies.jl
scale --project=examples/scaling examples/scaling/partial_modes.jl
scale --project=examples/scaling examples/scaling/mass_spring_mechanics.jl
scale --project=examples/scaling examples/scaling/symbolic_mechanics_scaling.jl
scale --project=. examples/scaling/large_oscillator_ode.jl
scale --project=. examples/scaling/ode_ensemble.jl
scale --project=. examples/scaling/million_sample_statistics.jl
scale --project=. examples/scaling/large_atomistic_geometry.jl
scale --project=. examples/scaling/million_query_analysis.jl
scale --project=. examples/scaling/memory_guardrails.jl
scale --project=. examples/scaling/extreme_streaming_statistics.jl --samples=1000000 --max-seconds=30
```

The examples default to small smoke configurations, not necessarily their title's
largest workload. Set `AML_SCALE_LEVEL=1` in the environment for the local ladders
(including one million observations/field queries). Levels 2 and 3 are manual
stress/extreme; level 3 requires `AML_EXTREME=1`. Do not run stress in CI.

Controls: `AML_MAX_BYTES` (default 536870912 estimated workload bytes),
`AML_MAX_SECONDS` (default 120 cooperative seconds per measurement),
`AML_MAX_THREADS` (default 1), `AML_SCALE_LEVEL` (0–3). Actual Julia/BLAS thread
counts must not exceed the ceiling. Explicit ensemble comparison uses
`JULIA_NUM_THREADS=2 AML_MAX_THREADS=2 OPENBLAS_NUM_THREADS=1` under the same lock.

The harness checks deadlines between calls; it cannot interrupt arbitrary native
code. The external timeout is required for hard deadlines. Exit 124 means process
timeout, not numerical failure. Preserve already-written rows; absence of a final
row is not completion. CSV/TOML are atomically checkpointed after measured rungs.
Estimate budgets are not process RSS limits: dependencies/JIT occupy extra memory.

## Scientific scope

These are repository-maintainer experiments, not the stable public API tutorial.
In particular, `large_oscillator_ode.jl` and `ode_ensemble.jl` deliberately use
AML's internal `_scale_ode_problem`; statistics and partial-mode audits also use
internal helpers. `using AnalyticMathLab` owns all production registration: no
example injects source into the package. Includes of neighboring example/harness
files compose the experiment only. These helpers are not promoted to public API.
M10D.1 removed obsolete registration fallbacks without changing measured kernels;
the frozen M10C CSV/TOML/source provenance still describes the historical runs.

| Example | Demonstration and independent check |
|---|---|
| when_dense_dies | Dense payload versus structured M/K; full-mode residual/eigenvalue oracle; preflight refusal |
| partial_modes | Four lowest chain modes using maintained ArnoldiMethod and structured shift-inverse; direct KΦ−MΦΛ and mass orthogonality |
| mass_spring_mechanics | AML Lagrangian/EL, linearization, modal and dynamics layers; analytic chain trajectory |
| symbolic_mechanics_scaling | Construction, differentiation, simplification, generation, first call and warmed evaluation separated; Hessian/Jacobian polynomial oracles |
| large_oscillator_ode | Checked native in-place RHS; full/sparse/endpoint/reduced output; analytic sine/cosine and energy |
| ode_ensemble | Native serial/threaded ensembles, full versus batch reduction; exact exponential decay |
| million_sample_statistics | Existing M10B Welford on lazy/stored identical observations; unbiased sample variance; bounded-prefix running/block/ACF costs |
| extreme_streaming_statistics | O(1) lazy requested workload, chunk deadline/progress, consumed-prefix summary; no hidden trajectory |
| large_atomistic_geometry | Exact line-particle distances/counts; quadratic pair output versus bounded coordination; explicit refusal |
| million_query_analysis | Full/summary field errors, sampled summaries, owned data/normalization, sampled heat residual |
| memory_guardrails | Deliberately unsafe dense requests refused before the kernel executes |

Partial modes are a controlled fixed-end chain route with positive diagonal mass,
not general sparse-SPD support or a generic symbolic Hessian-vector API. Backend
convergence is checked; returned eigenpair residuals remain the scientific oracle.

All-pair geometry and coordination still do quadratic work. Coordination reduces
returned storage, not pair enumeration cost. Public full PINN/GeneralizationAnalysis
results intentionally retain their evidence; internal PINN residual summaries and
public `heat_residual(...; summary_only=true)` are explicitly separate routes.

## Optional CPU neural backends

Use the existing optional environments (instantiate them as documented in their
own READMEs). No GPU support is claimed or installed by M10C.

```sh
scale --project=examples/operators examples/scaling/optional_scaling_gate.jl
scale --project=examples/operators examples/scaling/generalization_scale.jl
scale --project=examples/operators examples/scaling/ml_training_stress.jl
# PINN gate, same external lock/deadline:
AML_PINN_SCALE=1 scale --project=examples/pinn examples/scaling/optional_scaling_gate.jl
```

`batch_size` preserves prediction only for query-independent stateless networks.
Tests cover pointwise Lux/DeepONet/PINN cases, including partial final chunks.
Chunking bounds activation width; cumulative allocated bytes may increase.
The CPU example separates forward, backward, Adam state/update and three-step
optimization. Small/local tiers completed; their loss is a computational observation,
not physical convergence. Cold model setup/first-gradient compilation is unmeasured
in the historical training reports; do not interpret warmup rows as total startup.
Stress-tier training requires `AML_ML_TRAIN=1`; extreme also `AML_EXTREME=1`.

## Manual extreme stream: implemented, not completed here

```sh
AML_EXTREME=1 scale --project=. examples/scaling/extreme_streaming_statistics.jl \
  --samples=10000000000 --chunk-size=1000000 --max-seconds=120
```

This requests O(10^10) work with O(1) summary state. It is not a promise to finish
within the deadline. Read `requested`, `consumed`, and `status` separately.
M10C completed one million observations; it did NOT complete a real 10^10 run.
Do not execute this command as a default test or to reproduce the small figures.

## Reports and plots

Generated measurements live under ignored `output/scaling/`. CSV columns separate
estimated bytes, total Julia allocation, returned object bytes, warmup/warmed time,
correctness metric, output count and status. TOML contains CPU, Julia/BLAS threads,
process-lifetime RSS high-water and source hashes. Some returned objects borrow
input arrays; `summarysize` counts reachable storage, not exclusive ownership.

Committed lightweight CSV snapshots and plots live in
[`docs/m10c_measurements/`](../../docs/m10c_measurements/). No raw large arrays/models
are committed. `oscillator_stress.csv` and `ensemble_local.csv` preserve the original
largest completed ODE runs, rather than later lower-tier output overwrites.

`python3 examples/scaling/plot_reports.py` (matplotlib required) renders existing
reports only, never reruns workloads. It uses the preserved oscillator snapshot if
present, otherwise the current oscillator CSV. Refused rows are annotated, never
plotted as zero-time successes. All plots are descriptive local evidence.
