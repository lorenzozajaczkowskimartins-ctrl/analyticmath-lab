# M9A — Scientific ML and PINN bridge

**Low training loss is not proof of a correct physical solution.**

M9A composes a ModelingToolkit `PDESystem`, Lux model, NeuralPDE discretization and
Optimization.jl solve into inspectable AML objects. It does not implement neural
layers, AD, optimizers, symbolic PDE lowering or a second residual engine.

## Optional environment

Base `using AnalyticMathLab` does not import Lux, NeuralPDE, ModelingToolkit or
Optimization. One extension, `AnalyticMathLabPINNExt`, activates when those packages
and SymbolicIndexingInterface are loaded. NeuralPDE loads SymbolicIndexingInterface;
users do not need another explicit import to activate the extension. Random is the
only new direct base dependency, and is a Julia standard library. No CUDA, AMDGPU,
Metal or Reactant dependency is required. NeuralPDE itself has substantial transitive
CPU dependencies, including AD engines; first compilation is not lightweight.

The separate reproducible environment is `examples/pinn`:

```sh
julia +release --project=examples/pinn -e 'using Pkg; Pkg.instantiate()'
julia +release --project=examples/pinn examples/pinn/runtests.jl
julia +release --project=examples/pinn notebooks/scientific_ml.jl
```

The environment pins the verified direct backend versions: Lux 1.31.4, NeuralPDE
7.3.0, ModelingToolkit 11.45.1, Optimization 5.9.1, OptimizationOptimisers 0.3.24
and ADTypes 1.24.0. Its manifest records transitive versions. The base environment
and base tests do not install or train this stack.

### Important current-API difference

NeuralPDE 7.3 does not use the older `PINNRepresentation`/`phi` workflow in many
online tutorials. `symbolic_discretize` produces a ModelingToolkit `System` with
symbolic costs and residual blocks; `discretize` constructs an `OptimizationProblem`.
`solve` returns a `PDENoTimeSolution` wrapping an `OptimizationSolution` accessible
as `original_sol`. AML preserves both. It calls `discretize` **once**, retaining its
exact symbolic system (`optimization_problem.f.sys`) and documented
`NeuralPDE.pinn_metadata` rather than constructing a second independently initialized
symbolic discretization.

## Minimal ODE construction and training

```julia
using AnalyticMathLab, Random
import Lux, NeuralPDE, ModelingToolkit, Optimization, OptimizationOptimisers, ADTypes
using ModelingToolkit: @parameters, @variables, @named, Differential, PDESystem

@parameters t
@variables u(..)
@named ode = PDESystem([Differential(t)(u(t)) ~ -u(t)], [u(0.) ~ 1.],
    [t ∈ (0.,1.)], [t], [u(t)])
network = pinn_network(1, 1; hidden=[8], activation=tanh)
problem = pinn_problem(ode; network, strategy=NeuralPDE.GridTraining(0.1),
    rng=Xoshiro(42), adtype=ADTypes.AutoZygote(), provenance=(seed=42,))
result = AnalyticMathLab.train(problem, OptimizationOptimisers.Adam(0.02);
    maxiters=500, history=true, log_every=25, history_capacity=100,
    record_components=true)
points = [0.07, 0.23, 0.37, 0.61, 0.73, 0.97] # not collocation-grid points
values = predict(result, reshape(points, 1, :))
maximum(abs, vec(values) .- exp.(-points)) # independent sampled error, not a bound
```

The constructor requires explicit `network`, `strategy`, `rng` and `adtype`.
`pinn_network` returns an ordinary Lux `Chain` of `Dense` layers, with the requested
hidden activation and a linear output layer. `hidden=[]` is a single affine layer.
It creates no learned parameters. Advanced users may pass any compatible Lux
model, including stateless SkipConnection compositions; AML does not require Dense.

NeuralPDE owns differentiation of the PDE. Its default is the public
`FiniteDifferenceDerivative()` spatial derivative lowering; this is separate from
the outer optimization AD choice (`AutoZygote()` in the verified examples).
Pass `derivative=...` explicitly to choose a different compatible public lowering.
AML never retries with another AD backend behind the user's back.

`optimization_options=(weights=[...], p=[parameter=>value,...], ...)` forwards
public options to NeuralPDE's OptimizationProblem construction. Fixed physical
parameters are supported by the backend. Inverse parameter estimation and boundary
constraints are not exposed as M9A features. `additional_loss` forwards NeuralPDE's
public `(phi, θ, p) -> cost` interface unchanged. Such a cost is labeled
`:additional`, never assumed to be data error or a statistically calibrated loss.

## Lux parameters, state and reproducibility

Models, trainable parameters and non-trainable states are separate:

- `problem.networks`: unique Lux models in network order;
- `problem.initial_parameters`: Float64 Lux parameter containers;
- `problem.initial_states`: separate state containers;
- `result.parameters`: native optimization vector;
- `result.network_parameters`: trained Lux parameter containers;
- `result.states`: final state containers.

**Current backend restriction:** NeuralPDE 7.3's ModelingToolkitNeuralNets path uses
LuxCore `stateless_apply`, whose contract requires empty state. AML initializes with
`Lux.setup(rng, model)`, checks `Lux.statelength(state)==0`, checks a batched forward
call and rejects state changes. BatchNorm, Dropout and recurrent/stateful layers
are rejected, not silently frozen or discarded. Nested empty states in ordinary
Lux containers are retained. Prediction calls `Lux.apply` with the trained
parameters and retained empty states. Supporting genuinely stateful models needs a
backend path with a defined state policy; it is not emulated here.

The supplied RNG is consumed for initialization and forwarded to NeuralPDE. Its
`StochasticTraining` sampler uses that RNG, but NeuralPDE 7.3's `QuasiRandomTraining`
does not forward it to `QuasiMonteCarlo.sample`. Randomized quasi-random algorithms
therefore need separate scrutiny of their randomness configuration; AML's RNG does
not guarantee reproducible collocation for every backend strategy. The verified
examples use deterministic `GridTraining`. AML itself does not silently use a global
RNG or choose a seed. Provenance retains RNG type,
package versions, CPU/Float64 policy, AD/derivative choices and caller metadata.
Supply a seed/experiment identifier in `provenance` if wanted. Equal seeded RNGs
produce equal initial vectors in the verified environment; this is not a promise
of bitwise reproducibility across package versions, hardware or thread settings.

Networks must be CPU-compatible, finite at the zero-coordinate dimension probe,
and independently act on each batch column as required by the backend. The probe
checks shape, not all mathematical properties of arbitrary user-defined layers.

## Variable order and prediction

AML retains the original system by identity and uses the declared independent and
dependent variable orders. Network input dimensions follow the actual arguments
of each dependent variable, not the spelling of names. M9A supports scalar arguments
that are declared independent variables, not array/compound symbolic arguments.

For multiple dependent variables, explicitly choose:

- `network_layout=:shared`: one network, one output per dependent variable. All
  dependent variables must have **identical ordered** arguments.
- `network_layout=:separate`: a vector of one scalar-output model per dependent
  variable, in dependent-variable order. Different argument subsets/orders are
  represented explicitly in `network_mapping`.

`predict(result, coordinate_vector_or_tuple)` returns a dependent-variable vector.
`predict(result, coordinate_matrix)` accepts a CPU Matrix with coordinates in rows
and independent points in columns, returning `(dependent variables × points)`.
A scalar is accepted only for a one-dimensional independent-variable space and
still returns a one-element/output vector, not an implicitly unwrapped scalar.
Global coordinate order always equals `problem.independent_variables`; the stored
mapping makes any per-network argument selection/reordering explicit. Dimension
mismatches and nonfinite coordinates raise errors. Evaluation outside the declared
domain is not forbidden; extrapolation carries no physical validity claim.

## Inspection and losses

`pinn_inspect(problem)` and `pinn_inspect(result)` expose documented named fields:
original equations, BCs/ICs, domains, variable order, network mapping, models,
parameters/state, strategy, discretization, symbolic system, native optimization
problem/solution, NeuralPDE metadata, costs and provenance. They do not retrain or
rediscretize. Direct fields on AML objects are also the expert escape hatch.

`problem.loss_components` retains each backend cost expression and the associated
original equation and lowered residual expression. Labels are `:pde`, `:bc` and
`:additional`. NeuralPDE groups initial and boundary conditions as `:bc`; AML does
not guess which is which from variable names or equation forms. Original equations
remain available for scientific interpretation. Costs are unweighted; user-provided
weights affect the total objective, not the reported component definition.

`result.losses.value` retains:

- `objective`: the optimizer-reported objective;
- `evaluated_objective`: a fresh evaluation at returned parameters;
- `components`: current unweighted backend costs, evaluated through public symbolic
  indexing, not a newly invented decomposition;
- `definitions`: the retained cost definitions.

Some optimizer configurations return parameters after the last reported objective;
keeping both objective values avoids asserting that they necessarily match.
These are training costs, never actual solution errors. Independent reference
errors in the examples are separately calculated on held-out points.

Optional history stores only `(iteration, objective, components)` entries.
`record_components=false` leaves history components as `nothing` (not measured).
The first callback and each `log_every` iteration are eligible. Storage is capped
at `history_capacity`; later records are dropped and `truncated=true`. Duplicate
callbacks for the same retained final iteration replace that entry. History is not
an exact trace of all optimizer steps and contains no parameter vectors.

`callback=(state, loss)->Bool` follows Optimization.jl and runs after history
capture. NeuralPDE's StochasticTraining/QuasiRandomTraining sample at construction;
use its public `resample!(state.p, problem.backend_metadata)` in an explicit callback
if resampling is intended. AML does not silently add a resampling schedule. Training
copies optimization parameters to protect the construction/earlier stages from
solver mutation. Backend objects and arrays remain read-only by convention.

`result.termination` records the backend retcode, backend success predicate,
reported iterations and requested budget. A `Default` or iteration-limited retcode
is preserved as-is. No retcode or objective establishes physical convergence:
`result.evidence` remains `:unknown` for physical validation. Finite sampled losses
are `:heuristic`. Explicit `train(result, next_optimizer; maxiters=...)` continues
from trained parameters with a fresh optimizer state; it does not claim to resume
Adam momentum or implement an automatic Adam→LBFGS scheduler.

## Verification and presentation

The optional tests separate deterministic construction/error/order checks from tiny
training integrations. The ODE uses `u'=-u`, `u(0)=1`; the Poisson PDE uses
`-u''=2`, `u(0)=u(1)=0`, with reference `u=x(1-x)`. Both use held-out coordinates,
finite/shape/retention checks and broad maximum-error thresholds (0.12), not exact
parameters, exact objectives or claims of universal PINN accuracy.

`lossplot(result)` (or `lossplot(history)`) renders stored scalar objective history
only. It neither evaluates residuals nor trains. The executable notebook explicitly
loads CairoMakie and plots prediction/reference and independent sampled error. Core
AML never activates a Makie backend. No generic prediction plotting abstraction is
needed for M9A.

M9B adds [independent residual and reference diagnostics](pinn_diagnostics.md) on
this bridge, without a new symbolic differentiation or resampling engine.
The M9A examples remain unchanged; the heat-equation showcase is separate.

## Boundaries

- M9B: sampled residual/reference analysis, collocation provenance, multidimensional
  and coupled benchmarks are documented separately; none proves global correctness.
- M9C: no automatic M6 dynamics, M7 mechanics or M8 trajectory conversion yet. The
  original system, backend objects and AML evidence/provenance stay accessible for
  those future bridges; no duplicate physical problem hierarchy is introduced.
- M9D: broader validation/surrogate workflows remain future work.
- M10: integration/stabilization refactors are not part of this milestone.

No GPU/distributed/mixed-precision training, learned potentials, neural operators,
Hamiltonian/Lagrangian networks, major inverse-problem API, stochastic rounding or
Monte Carlo is added. The Scientific ML M9 roadmap supersedes the older M8-era
placeholder that assigned stochastic/Monte Carlo work to M9.
