# M9D scientific surrogates and neural operators

M9D adds controlled scientific families, not a general-purpose ML framework.
Lux owns neural layers/state; Optimization owns training; NeuralOperators 0.7.3
owns the public two-network `DeepONet(branch,trunk)` implementation. See
[backend investigation](operator_backends.md). FNO's forward layout was probed,
but no trained FNO scientific route is supported or claimed. FFTs are not
implemented here. No new mandatory ML dependency is loaded by base AML.

## Public API and ownership

- `ScientificSample(id,input,coordinates,values;split,descriptor=nothing)` stores
  one scalar field: coordinate columns correspond exactly to target entries.
- `ScientificDataset(samples;kind,family,input_names,coordinate_names,domain,
  reference,units,grid,rng,sensors=nothing,provenance=NamedTuple())` distinguishes
  finite-dimensional `:surrogate` inputs from fixed-sensor `:operator` functions.
- `fit_scaling(dataset,:inputs/:coordinates/:outputs)`, `transform`, and
  `inverse_transform` expose explicit midpoint/half-range affine scaling.
  Only training samples fit statistics; constant rows use scale one.
- `learning_model(dataset,network;rng,normalization,rng_provenance)` initializes a
  native Lux model. Choose `:none` or `:train_minmax`; scaling is never implicit.
- `training_data(model,dataset)` snapshots training inputs/targets only.
  `learning_objective(model,parameters,batch)` is scaled mean squared error.
- `train(model,dataset;initial_parameters,optimizer,adtype,maxiters,
  reconstruct=identity,history_limit=100)` retains native optimization objects,
  bounded objective history, a borrowed dataset, trained model and provenance.
  The caller supplies an optimization-compatible vector (e.g. ComponentArray).
- `predict(model_or_result,input,query_matrix;sensors=...)` returns scalar values
  in query-column order. Coordinates can differ from training query coordinates;
  changing the operator's sensor grid is rejected, never silently resampled.
- `classify_query(dataset_or_model,input,query_matrix;descriptor=...,sensors=...)`
  separately classifies parameter, coordinate and function-family membership.
  Without operator descriptors, function-family membership is `:unknown`.
- `analyze(learning_result;physics=nothing,timing=nothing,relative_floor=1e-12)`
  returns `GeneralizationAnalysis`: per-case predictions/references, separate
  split groups, provenance, optional physics/timing evidence and limitations.
  Missing evidence stays unavailable, not zero. Arrays are read-only by convention.

`ScientificModel` contains schema and normalization, not reference targets.
Descriptors document the generating function family; they are not neural inputs.
Deterministic stateless networks are required. The operator batch uses sensors ×
functions and coordinates × queries; backend output is queries × functions.
Custom layers must preserve batch size and output shape during training, not
only single-case prediction. The objective relies on this caller contract; it
does not independently reject every possible broadcasting or state-changing
custom-layer behavior. The tested routes use Dense/Chain and public DeepONet.
Batched operator training requires identical explicit query grids. Generic
surrogate samples may use different query grids. Public arrays are mutable by
Julia convention: do not mutate a dataset after fitting preprocessing or training.

## Controlled analytical heat families

`examples/operators/heat_family.jl` constructs and verifies

    u(x,t) = sum(a[k] sin(k*pi*x) exp(-alpha*(k*pi)^2*t))
    u_t = alpha*u_xx, x in [0,1], u(0,t)=u(1,t)=0.

The IC, BC and PDE consistency check runs before optimization. The reference is
analytical with floating-roundoff provenance, not a numerical solver represented
as exact truth. Units are dimensionless and queries are ordered `(x,t)`.

The parametric surrogate uses fixed IC `sin(pi*x)` and training alpha values
0.05:0.025:0.2. Six unseen interior midpoint values are interpolation cases.
Alpha 0.015, 0.3 and 0.45 are parameter extrapolation, excluded from training.
Training/evaluation times are [0,0.5]; [0.65,0.85] is a separate later-time case.

The genuine function-to-function route maps sampled `u0(x)` to `u(x,t)` at fixed
alpha=0.1. Nine explicitly stored sensors span [0,1]. The branch sees their
function values, not Fourier coefficients. Training uses 32 deterministic-seed
coefficient combinations of modes 1 and 2 in [-1,1]. Eight unseen combinations
are held out; three amplitude shifts and three nonzero mode-3 frequency shifts
are separate tests. Descriptors `(a1,a2,a3)` retain generating-family provenance.
A later-time query of a held-out function is separately classified. Input sensor
values and output/query coordinates are retained. No resampling/interpolation
occurs, and querying a coordinate network on denser points does not establish
operator discretization invariance or identify arbitrary functions from sensors.

## Leakage and scientific evidence

Dataset construction rejects duplicate IDs, repeated parameter/function input
representations (except disjoint coordinate-shift queries), invalid training or
interpolation domains, and mislabeled shifts. Explicit extrapolation samples
never enter `training_data`. Tests perturb held-out targets while checking that
training objectives and scaling remain unchanged.

For generic operators, the specific amplitude/frequency shift label is
caller-declared: construction validates out-of-domain descriptors, but cannot
infer the physical meaning of each descriptor axis. The heat-family generator
explicitly separates amplitudes outside [-1,1] from nonzero mode-3 coefficients.

`field_errors` reports physical-unit sample RMS, maximum/mean absolute difference
and relative sampled L2. A near-zero reference with RMS at/below the stated floor
has unavailable relative error. Group aggregation is unweighted target samples;
per-case RMS is retained and per-coordinate RMS is available only for identical
query grids. Different groups are never collapsed into a quality score.

`heat_residual(predictor,points::PINNPoints;alpha)` uses ForwardDiff gradients and
Hessians on a differentiable scalar `(x,t)` predictor. It evaluates
`u_t-alpha*u_xx` at the explicit points and reuses M9B `sampled_summary`. It does
not turn a surrogate/operator into a PINN, use finite-difference boundary
stencils, or label sampled RMS a continuum norm.

The contracts are deliberately distinct:

- training fit != interpolation generalization;
- interpolation != extrapolation;
- parameter extrapolation != function-family extrapolation;
- reference difference != PDE residual;
- numerical reference difference != exact solution error;
- sampled residual != global correctness;
- operator learning != automatic discretization invariance;
- good benchmark performance != universal generalization;
- fast inference != more accurate physics.

No automatic model ranking, global quality score, or unproven long-term stability
claim is produced. An unconstrained learned field can violate IC/BC/PDE even when
its reference difference is small; residual evidence must be inspected separately.

## Timing and amortization

`benchmark_queries(reference,inference;training_seconds,repetitions=11,context)`
measures caller-defined complete equivalent queries, warms both, and alternates
measurement order. First timed calls are separate and may include compilation;
they are not necessarily first calls in the process. Arrays of timings, medians,
CPU/Julia/thread context and supplied training cost are retained. A descriptive
break-even estimate is withheld unless every measured reference cost exceeds
every inference cost. Supplied training cost must include the applicable training
work; unmeasured data-generation/engineering costs are explicitly excluded.
The analytical benchmark reference is not an expensive numerical PDE solver;
its evaluation timing must not be advertised as numerical-solver speedup.

## Verification

From the repository root, with Julia 1.12:

    julia +release --project=examples/operators -e 'using Pkg; Pkg.instantiate()'
    julia +release --project=examples/operators examples/operators/focused_gate.jl
    julia +release --project=examples/operators examples/operators/analysis_gate.jl
    julia +release --project=examples/operators examples/operators/isolation_gate.jl
    JULIA_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 julia +release --project=examples/operators examples/operators/integration_gate.jl

The integration gate trains the two heat models sequentially, once each, with
fixed seeds 911/912 and 3,000 full-batch Adam steps. It generates the parametric
and function-to-function showcases, reports, numeric parameter checkpoints and
eight figures under `notebooks/output/m9d_heat/`. The fixed interpolation
acceptance threshold is relative sampled L2 <0.15, not a universal accuracy
promise. All extrapolation results and residuals are reported without accuracy
thresholds or model ranking. Checkpoint prediction can then be exercised without
repeating training:

    julia +release --project=examples/operators examples/operators/heat_demo.jl --reuse

`heat_demo.jl` without `--reuse` is an alternative fresh showcase, not an extra
required run after the integration gate. Numeric checkpoints contain fitted
parameters, not optimizer state, and require unchanged example architecture,
heat-family data/preprocessing and compatible backend versions. Reports and
plots use the training run's stored evidence; reload does not fabricate history.

Run optional jobs sequentially. Base `Pkg.test()` covers structural, split,
normalization, analytical reference, residual and timing contracts without
loading the optional ML stack. Heavy training and showcases stay optional.
Generated figures/reports belong under ignored `notebooks/output/`.
