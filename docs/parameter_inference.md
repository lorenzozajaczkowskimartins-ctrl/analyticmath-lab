# Deterministic physical parameter inference (M9C)

Load `AnalyticMathLab` for observations, forward prediction and local sensitivity;
load `Optimization` to activate `infer_parameters`. No NeuralPDE, Lux, GPU package
or new solver is needed for this route. The optional CPU environment is
`examples/inference`; from the repository root:

```sh
julia +release --project=examples/inference -e 'using Pkg; Pkg.instantiate()'
julia +release --project=examples/inference examples/inference/deterministic_gate.jl
julia +release --project=examples/inference examples/inference/parameter_showcase.jl
```

## Contracts

`ObservationSet(times, values; variables, units=nothing, weights=nothing,
kind=:user_supplied, role=:fit, provenance=...)` copies numeric times and values to
Float64. Rows follow the explicit variable order; columns follow strictly
increasing, possibly irregular times. Partial-state observations are supported.
Missing/nonfinite data are rejected rather than imputed. Units are metadata, not
implicit conversions; supply consistent numerical coordinates. Explicit weights
multiply squared residuals and are not assumed inverse variances. Kinds are
`:synthetic`, `:numerical`, `:experimental`, `:user_supplied`; roles are `:fit`,
`:heldout`, `:evaluation`, `:extrapolation`.

`InferenceParameters(names, initial; inferred, bounds=nothing, units=nothing,
provenance=...)` records full model order and a named inferred subset. Fixed
values remain at their initial values. Bounds are `(lower, upper)` in inferred
order and require a compatible backend optimizer. There are no implicit
positivity constraints or parameter transformations.

`ParameterInferenceProblem(factory, specification, observations; u0, tspan,
heldout=nothing, algorithm=Tsit5(), abstol=1e-10, reltol=1e-9,
maxiters=100_000, reference=nothing, provenance=...)` requires
`factory(full_parameters)::FirstOrderODE`. It retains the initial M6 model and
native SciML ODEProblem. Factories must preserve state labels/order and support
ForwardDiff dual numbers. It does not change M6's existing Float64 trajectory
boundary. The inference adapter preserves duals in the native solve instead.

`inference_predict(problem, theta, observations=problem.observations)` projects
the solution into the observation variable order. Evaluation times must lie in
the supplied forward tspan. `inference_objective(problem, theta)` computes the
sum of squared residuals, optionally weighted. It is not a likelihood.

Held-out observations must have `role=:heldout`, identical variable order and
unit metadata, and times disjoint from the objective observations. This checks
exclusion from this objective, not independence of data generation or all prior
model choices. Reference values are optional; when supplied they explicitly carry
`kind=:synthetic_truth` or `:user_reference`, values in inferred order, and
provenance. Neither reference nor held-out values enter the objective.

## Sensitivity and fitting

`local_sensitivity(problem, theta; rank_rtol=1e-8, rank_atol=0.)` differentiates
the numerical prediction using ForwardDiff. It retains the unweighted and
square-root-weighted observation Jacobian, economical SVD, singular values,
right vectors, numerical rank, and column cosines. Rows use column-major
observation order: variables within time. The rank cutoff is
`rank_atol + rank_rtol * maximum(singular_values)`; condition is infinite unless
rank equals the number of inferred parameters. In underdetermined cases the
thin right factor does not span the full nullspace. Column cosines describe
local sensitivity collinearity, not posterior correlations. Conditioning
changes with units and parameter scales. This is local numerical evidence,
not a structural/global identifiability method.

`infer_parameters(problem, optimizer; maxiters, history_stride=10,
history_capacity=1000, rank_rtol=1e-8, rank_atol=0., kwargs...)` uses Optimization
with ForwardDiff gradients through the native adaptive ODE solve. Independent
central differences validate these gradients in the oscillator gate. Failed or
incomplete forward solves propagate; they are not converted into attractive
objective values. Nonsmooth/domain-dependent models are not certified.

`ParameterInferenceResult` retains the original problem, native optimization
problem/solution, inferred and full parameter vectors, final fit solution,
fit/held-out predictions and errors, sensitivity report, optional reference
comparison, bounded objective-only history, termination and optimizer, provenance,
limitations, and global-physics evidence with status `:unknown`. Mutable fields
are read-only by convention; no intermediate trajectories are stored by default.
Backend termination and sampled recovery are separate facts.

`parameterfitplot(result)` consumes stored predictions, history and sensitivity
only. It does not solve, optimize, differentiate or activate a Makie backend.
The damped showcase saves `notebooks/output/m9c_parameter_inference.png`.

## Benchmarks and limitations

The harmonic benchmark infers stiffness with known mass. The damped benchmark
infers stiffness and damping with known mass. Both split alternating observation
times into fit and held-out sets. A separate rank-deficient test varies mass and
stiffness together: only their ratio affects the observed harmonic trajectory.
Thus a perfect fit need not constrain each parameter independently.

These are bounded noiseless synthetic benchmarks, not general inverse solvers.
There is no posterior, uncertainty interval, automatic quality score, global
identifiability proof, symbolic discovery, or automatic model selection.
Inference of initial conditions, missing-data masks, transformed parameters,
and arbitrary observation operators are not implemented. Extrapolation requires
an explicitly extended forward domain and must not be relabeled interpolation.
See [learned dynamics](learned_dynamics.md), [M8 bridge](trajectory_inference.md)
and [inverse heat](inverse_heat.md) for the separate scientific routes.
