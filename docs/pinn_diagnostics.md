# M9B — PINN residual analysis and diagnostics

**Small sampled residuals do not prove global PDE correctness.**
**Small training loss does not prove physical correctness.**

M9B extends the [M9A bridge](scientific_ml.md); construction, training, prediction
and native backend objects are unchanged. It adds `PINNPoints`, `PINNAnalysis`,
`analyze(::PINNTrainingResult)`, `sampled_summary`, `loss_breakdown`, and stored-result
views `residualplot`, `errorplot`, `collocationplot`, `losscomponentsplot`, `pinnplot`.
`pinn_inspect(::PINNAnalysis)` exposes the structured fields without reevaluation.

## Explicit coordinates and analysis

```julia
# result is an M9A PINNTrainingResult for u(t).
points = PINNPoints(reshape([0.03, 0.17, 0.41, 0.83], 1, :);
    generation=:user_supplied, provenance=(purpose=:diagnostics, units="s",))
a = analyze(result;
    residual_points=Dict(1=>points, 2=>PINNPoints(zeros(0,1))),
    condition_roles=Dict(2=>:ic),
    reference_points=points, reference=x->[exp(-x[1])],
    reference_provenance=(kind=:analytical, source="exp(-t)",),
    relative_guard=1e-12)
a.residuals[1].summary
a.reference.value.summary
loss_breakdown(a)
```

Residual dictionary keys are one-based indices in
`result.problem.backend_metadata.blocks`. Coordinate rows follow each block's
`ivs`, which can differ from the global independent variables. Fixed endpoint
conditions have zero free coordinates: use a `0 × N` matrix. Reference coordinates
follow the original global independent-variable order; reference functions accept
a coordinate vector and return one value per dependent variable in stored order.
Matrices are CPU Float64, with one sample per column. Generation method, units and
RNG metadata are caller-supplied provenance, not a certification of independence.
Arrays/backend objects are read-only by convention, as in M9A.

`PINNAnalysis` refers to the training result rather than cloning its model. It
stores raw signed residuals, original equation identity, backend kind, optional
caller-declared BC/IC role, free-variable order, supplied points, summaries,
point provenance, sampled evidence, collocation snapshots, losses, reference
comparison, adaptive-loss availability, global evidence and limitations.
Unevaluated blocks remain `nothing`/`:unknown`; omitted points are never silently
replaced by training data. Out-of-domain counts are reported, not forbidden.

### Backend-supported residual evaluation

The isolated adapter in `ext/pinn_diagnostics.jl` uses NeuralPDE 7.3's public
`pinn_metadata` / `ResidualBlock` and SymbolicIndexingInterface's `getu`, `getp`,
`setp`, `ProblemState`, `parameter_values`. It evaluates the backend's signed
**lhs − rhs** expression, never a square root of an aggregate cost. It copies
trained unknowns and returned-solution parameters before changing coordinates.
No rediscretization, retraining, resampling, PDE parser or AD engine is introduced.

Backend arrays have compiled batch sizes. Independent samples are evaluated in
those batches; only the final short batch repeats its last point and discards the
padding afterward. This requires the same pointwise, stateless Lux models as M9A.
Integral residual blocks with extra integration parameters are explicitly rejected;
derivative discretization error is not estimated. Raw diagnostics can be large:
callers choose and bound the evaluation set. All supported dimensions and equation
counts use the same adapter; outputs are never collapsed into one physics score.

`sampled_summary` reports count, finite count, RMS, mean absolute value, maximum
absolute value and sampled L2 (`RMS * sqrt(count)`). The normalization is explicitly
`:unweighted_samples`; these are not domain integrals or global functional norms.
If a sample is nonfinite, numerical summary fields are unavailable. Quadrature
training weights do not silently become weights on the supplied evaluation set.

## Reference error and evidence

Residual = governing operator applied to the PINN; error = PINN minus reference.
Neither substitutes for the other. Reference analysis retains prediction,
reference, signed error, absolute error, guarded absolute relative error and
per-dependent-variable summaries. Relative error is `missing` when the reference
magnitude is at or below `relative_guard`; absolute error is retained. No epsilon
is inserted into a denominator. The guard is explicit and stored.

With no reference, `a.reference.value === nothing`, status `:unknown`, method
`:reference_unavailable`; sampled residual evidence can still be useful. A supplied
reference defaults to `kind=:user_supplied_unknown_trust`. Callers can identify
analytical, manufactured, numerical or experimental references in provenance; AML
does not certify their accuracy or automatically run another solver.

Finite sampled residual/reference evidence is `:heuristic`. The symbolic system
retains equations, domains and variable order. Sampling independence, physical
units and reference trust are assumptions/provenance. Global correctness, uniqueness,
extrapolation validity and physical applicability remain unknown. Optimizer return
codes and termination budgets remain separate from physical correctness. No score
or automatic solved/good/bad flag is produced.

## PDE / BC / IC and losses

NeuralPDE 7.3 labels blocks `:pde` or `:bc`, not `:ic`. AML retains `backend_kind` and
original equation, while `condition_roles=Dict(block_index=>:ic)` explicitly marks
an initial condition. Roles can only classify backend BC blocks as BC/IC, never
reclassify a PDE. `role_source` records caller classification. No variable-name
heuristic is used. Additional loss components stay labeled `:additional` and have
no invented pointwise residual or inferred data-error interpretation.

`loss_breakdown` retains the reported objective, freshly evaluated returned-point
objective, unweighted backend components and their definitions, configured weights,
M9A bounded history, and optimizer termination. Weight provenance is construction
configuration, not necessarily the weights after an arbitrary caller callback.
History remains stride/capacity-limited M9A history, not a new parameter trace.

The installed NeuralPDE 7.3 API has **no built-in adaptive-loss strategy API**; older
`GradientScaleAdaptiveLoss`/`MiniMaxAdaptiveLoss` tutorials do not apply. Fixed or
symbolic configured weights remain inspectable. AML does not emulate an adaptive
algorithm, infer caller-managed schedules or fabricate evolving weights.
`adaptive_loss_metadata` is unavailable (`:unknown`, `:unsupported_backend_api`),
with `weight_evolution=:not_recorded` in loss diagnostics.

## Collocation and strategy semantics

The returned solution exposes a **snapshot**, not its complete sampling history.
Each block reports copied coordinates, bounds, global coordinate indices, count,
dimension, duplicate count, equation/kind and quadrature weights when available.
The snapshot source is `:returned_solution_parameters`; history is unavailable.
The analysis counts exact-coordinate overlap against this snapshot. Zero overlap
is not proof of independence from every training sample; independence stays
`:not_established` and all-training overlap stays `:unknown`.

Supported inspection includes GridTraining (deterministic grid), StochasticTraining
(uniform random), QuasiRandomTraining (not IID), and QuadratureTraining (nodes).
For PDEs in NeuralPDE 7.3, quadrature requires an explicit fixed-node rule, e.g.
`QuadratureTraining(quadrature_alg=Integrals.GaussLegendre(n=5))`; its default
adaptive cubature rule is not accepted by that backend PDE path. Integrals is a
direct dependency only of the optional example environment, already transitive
through NeuralPDE; the base package remains unchanged.

The original strategy object retains configuration. RNG type and caller seed
provenance are stored. QuasiRandomTraining does not forward the supplied RNG to its
sampler; full seeded reproducibility is not claimed. Sampling occurs at construction;
resampling requires explicit caller callbacks. Domain coverage is never asserted.

## Stored plots

`pinnplot(a; variable=1, equation=1)` provides reference, PINN, absolute error and
signed residual panels. Residual and reference sets may differ and retain their
own coordinates. Scalar-output/equation selection is explicit. Two-dimensional
complete tensor grids become heatmaps; irregular/duplicate coordinates become
colored scatter points. One-dimensional values are scattered against coordinates.
These are samples, not interpolated global certificates. Colorbars use raw values,
not an undocumented common normalization. Generic maps support up to two coordinate
rows; higher-dimensional fields require caller-defined stored slices/views. The
Navier–Stokes script plots stored 3D sample residuals against explicitly labeled
sample indices instead of pretending they form a two-dimensional field.

Core plotting neither imports nor activates CairoMakie, and never trains, samples,
evaluates residuals or invokes reference functions. The caller selects a backend.
Figures preserve these warnings:

- "Stored loss components — not physical error"
- "Snapshot only: resampling history and domain coverage are not established."
- "Adaptive weight evolution is not available."

## Executable benchmark ladder

Run expensive gates sequentially with Julia release, never in base CI:

```sh
julia +release --project=examples/pinn examples/pinn/runtests.jl
julia +release --project=examples/pinn notebooks/pinn_diagnostics.jl
julia +release --project=examples/pinn examples/pinn/benchmark_gate.jl standard
julia +release --project=examples/pinn examples/pinn/benchmark_gate.jl burgers
julia +release --project=examples/pinn examples/pinn/benchmark_gate.jl navier-stokes
```

All problems are defined in `examples/pinn/benchmarks.jl`. Logs print objectives,
budgets/return codes, every PDE/BC/IC residual summary, overlap and reference errors.
Plots go to ignored `notebooks/output/`. CPU compilation dominates tiny smoke runs;
allow several minutes per fresh process. Budgets are explicit, no unbounded training.

Measured seeded runs (Float64, seed 42, shared tanh [12,12] network, Adam 0.01,
GridTraining 0.25 unless noted; maxima/RMS are sampled, not bounds):

| Benchmark | Steps | Objective | Reference RMS | Reference max abs | PDE residual RMS |
|---|---:|---:|---|---|---|
| Heat | 1500 | 8.90541e-6 | 0.020598 | 0.046236 | 0.147255 |
| Poisson 2D | 1500 | 0.00580024 | 0.028791 | 0.080499 | 3.832574 |
| Coupled u,v | 1500 | 0.000700075 | 0.014366, 0.028692 | 0.035520, 0.050975 | 0.100648, 0.115494 |
| Burgers | 500 | 0.000287112 | 0.014641 | 0.051298 | 0.111941 |

Heat uses `u_t=0.1u_xx`, homogeneous boundary values and `u(x,0)=sin(pi*x)`;
reference `sin(pi*x)exp(-0.1pi²t)` on a 21×21 offset evaluation grid. Poisson uses
`-Δu=2pi²sin(pi*x)sin(pi*y)`, zero boundaries, and reference `sin(pi*x)sin(pi*y)`.
Its large unsampled-grid residual despite a small training objective is deliberately
reported, not hidden. Coupled heat/reaction uses `u_t=0.1u_xx+v`,
`v_t=0.1v_xx-u`, references `exp(-0.1pi²t)sin(pi*x)[cos(t),-sin(t)]`.
Burgers uses viscosity 0.1 and the traveling wave `1-tanh((x-t)/0.2)` with its
analytical BC/IC values. These three use 15×15 offset evaluation grids.

A controlled 200-step heat comparison uses the same problem/network/seed/evaluation
set: grid objective 0.000868385, residual RMS 0.197196, reference RMS 0.019913;
StochasticTraining(16) objective 0.00205903, residual RMS 0.189077, reference RMS
0.023724. This is one configuration, not a ranking of strategies, an IID uncertainty
estimate, or monotonic convergence evidence. No unavailable adaptive experiment is
fabricated, and no general experiment/study framework is added.

### Navier–Stokes stress, not production CFD

The opt-in gate represents `(x,y,t) -> (u,v,p)` on the unit cube, density 1 and
viscosity 0.1, with both full nonlinear momentum equations and incompressibility.
The controlled reference is transient shear `u=exp(-0.1t)sin(y), v=p=0`; it solves
the unforced equations. Velocity Dirichlet boundaries/initial data are supplied,
with pressure gauge `p(0,0,t)=0`. This is intentionally simpler than turbulent flow.
Three equation labels remain distinct: x-momentum, y-momentum, incompressibility.

A [4] hidden-layer network, grid spacing 0.5 and **two optimizer steps** produced
objective 6.50185; 27-point residual RMS values 1.58903, 1.08966, 1.26685 respectively.
Reference RMS values were 0.69129, 0.24368, 0.38293. All 14 blocks remain inspectable
(three PDE, nine BC/gauge, two IC). Zero v/p references have unavailable relative
errors. The structural/stress gate tests ordering, finite values, BC/IC identity,
independent finite-difference incompressibility and honest no-reference behavior.
It demonstrates representation and diagnosis, **not an accurate physical solution**,
well-posedness proof, validated CFD or production performance. Long stress training
is neither necessary for this gate nor part of base `Pkg.test()`.

## Boundaries

M9A regressions and optional ML tests are separate from base canonical tests. The
base tests cover summaries, point contracts, exports and isolation without ML.
No automatic M6/M7/M8 bridge, inverse problem, Hamiltonian/Lagrangian network,
learned force, neural operator or surrogate is added. M9C physics integration and
inverse problems, M9D generalization/surrogates, M10 stabilization and M11 stochastic
numerics remain future work. Gradient diagnostics and global validation are not
implemented. Reference trust, domain coverage and adaptive histories stay unavailable
unless actually established by a future supported workflow.
