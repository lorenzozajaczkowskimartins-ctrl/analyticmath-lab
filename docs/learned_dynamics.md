# Learned Hamiltonian and universal differential equations

This optional path composes **M7 canonical mechanics**, **M6 first-order ODEs**, Lux,
Optimization and the native Tsit5 solver. It does **not** route ODEs through PINNs
or import NeuralPDE, DiffEqFlux or SciMLSensitivity. Load `Lux` and `Optimization`
to activate `AnalyticMathLabDynamicsExt`.

## Objects and contracts

- `HamiltonianNN(mechanics::HamiltonianAnalysis, network, parameters, state)`
  holds a scalar-output Lux network and its explicit parameter/state containers.
  `learned_energy(model, u)` evaluates its scalar output.
  `learned_vector_field(model, u, t)` computes `mechanics.symplectic_matrix *
  ForwardDiff.gradient(H, u)`. States have M7 order `(q..., p...)`, **not**
  interleaved coordinates/momenta. The symbolic Hamiltonian is retained for
  provenance but is **not consulted** by the learned field or training objective.
- `DerivativeData(states, derivatives)` contains equally sized finite nonempty
  matrices with one observation per column. The HNN objective is mean squared
  vector-field error, not energy regression. Constants in the Hamiltonian are
  unidentifiable: `aligned_energy(model, u; reference=zeros(2))` subtracts the
  learned value at an explicit reference. Compare reference energies using the
  **same** alignment.
- `UDEProblem(known::FirstOrderODE, network, parameters, state;
  correction_indices=(...))` holds known physics separately from the network.
  `learned_correction(model,u,t)` returns the full correction vector with zeros
  outside the selected components. The network consumes state `u`; it is
  autonomous even when the known ODE depends on `t`.
  `learned_vector_field` adds the two contributions, respecting the known domain.
- `TrajectoryData(times, states)` requires increasing finite times and one state
  column per time. UDE training starts at its first observed state and minimizes
  trajectory MSE at the remaining and initial times (the initial term is zero).
  No derivative labels, reference force or reference parameters enter this loss.
  One trajectory per training call is supported in this slice.

Networks must be deterministic and have frozen state. Pass `Lux.testmode(state)`;
state transitions are rejected rather than silently discarding updates. Smooth
activations are required for meaningful HNN nested differentiation; ReLU kink
behavior is not certified. CPU real-valued vectors are the supported execution
path. Parameter reconstruction must preserve ForwardDiff dual numbers.

## Native training and prediction

```julia
result = train(model, data;
    initial_parameters = flat_vector,
    reconstruct = v -> native_lux_parameters(v),
    optimizer = OptimizationOptimisers.Adam(0.02),
    maxiters = 160,
    history_limit = 160)
trajectory_result = predict(result, initial_state, (0.0, 6.0))
```

The flat optimizer vector and explicit `reconstruct` callback are a caller-owned
parameterization boundary: no undocumented Lux flattening API or NeuralPDE
parameter adapter is used. The bundled examples rebuild simple `NamedTuple`
containers with `reshape` and vector slices; larger networks can use a public
external package adapter without changing this extension. This callback is not a
custom differentiator or optimizer.

`result.model.parameters` is the fitted native Lux container; `.state` is retained.
`result.solution` is the native Optimization solution (including its retcode and
problem), `.history` stores at most `history_limit` most recent callback objectives,
and `.provenance` retains initial/final objective values, differentiation method,
optimizer type, iteration budget, and UDE solver/accuracy options. A budget exit
is not proof of convergence. Global correctness is explicitly `:unknown`.
Provenance also retains the training-data object, a copy of the initial flat
parameters, `PropertyResult` evidence and explicit limitations. Training data are
borrowed and read-only by convention; do not mutate them during or after training.

`objective_options=(algorithm=Tsit5(), abstol=1e-9, reltol=1e-7,maxiters=10000)`
can configure the UDE training solver. ForwardDiff differentiates through the
native adaptive solver; parameter-typed initial states preserve dual numbers.
The Float64-only M6 validation boundary is intentionally not used inside this AD
objective. Prediction uses M6 `trajectory` and retains its native SciML solution,
algorithm and diagnostics. Predictions can fail outside the known ODE domain;
solver tolerances are not rigorous error bounds. The HNN learns a new energy on
the supplied state space; the symbolic reference Hamiltonian's domain is not a
certificate for that learned energy.

## Executable CPU evidence

From the repository root, after instantiating the optional environment:

```sh
julia +release --project=examples/inference examples/inference/neural_gate.jl
julia +release --project=examples/inference examples/inference/neural_showcase.jl
```

The gate also runs the bounded showcase, writing `artifacts/harmonic_hnn.png`,
`artifacts/nonlinear_ude.png` and `artifacts/neural_report.md` alongside the scripts.
Set `AML_NEURAL_OUTPUT` to redirect gate artifacts. Direct calls can use
`NeuralShowcase.run(output_dir="...")`.

The small examples intentionally use **strong polynomial architecture priors**:

- HNN: fixed elementwise-square activation and trainable scalar Dense output
  (three parameters, including an unidentifiable bias), 220 Adam iterations.
  Fit on 25 derivative states, evaluate 16 distinct held-out grid states and 16
  larger-amplitude extrapolation states. Rollout uses an independent initial
  condition and analytic harmonic solution. Report both learned and analytic
  energy drift on learned states, with energy values aligned at `(0,0)`.
- UDE: known `q′=p, p′=-q`, fixed cubic feature of `q`, and one trainable Dense
  correction coefficient. Fit only 25 trajectory observations over `t=0..3`,
  160 Adam iterations. Evaluate a separate initial condition over `t=0..6`,
  amplitude/time extrapolation over `t=0..9`, and missing-force error on 42
  independent states. The reference coefficient `-0.2` is used in data generation
  and post-training evaluation only, never in the training objective.

These are genuine Lux/ForwardDiff/Optimization/SciML executions, but effectively
low-dimensional neural-basis identification problems, **not demonstrations of
unconstrained neural function discovery**. Low extrapolation error here is aided
by the architecture containing the true functional family; it implies no global
correctness for arbitrary learned networks. Training and evaluation reference
ODEs also share a solver family, with tighter reference tolerances.

Tests cover scalar output, state dimensions, canonical sign and non-interleaved
four-dimensional ordering, additive constants, nested parameter gradients,
trajectory AD, separate correction inspection, native result/state retention,
bounded history, fit and held-out errors and saved artifacts.

Nonlinear pendulum HNN remains optional and is not implemented. LNN is deferred:
learning a Lagrangian requires controlled velocity-Hessian invertibility and
conditioning plus verified higher-order derivative solves; the scalar-Hamiltonian
route avoids making unsupported regularity or inverse-mass claims.
