# Inverse heat PINN (optional CPU gate)

This is a thin integration of NeuralPDE 7.3's public parameter-estimation route, not a new inverse solver. Existing forward PINN defaults remain unchanged: `pinn_problem(...; param_estim=false)` is still the default.

## Public API and parameter provenance

Declare physical parameters in `ModelingToolkit.PDESystem`, give their initial guesses through `initial_conditions=Dict(alpha=>0.3)`, and pass `param_estim=true` to `pinn_problem`. AML forwards the Boolean to `NeuralPDE.PhysicsInformedNN`.

**Every declared PDESystem parameter is inferred when this flag is true.** This is not a selection mask. Partial fixed/trainable masks, positivity transformations, parameter bounds and uncertainty estimates are not added by this integration. To keep a coefficient fixed in an inverse problem, substitute its numerical value into the equations instead of declaring it among the physical parameters to estimate. With the flag false, declared parameters remain backend parameters rather than optimization unknowns.

`problem.provenance.physical_parameters` records the flag, declared and inferred symbolic parameters, all-or-none selection semantics, and the PDESystem initialization source. Full initial values remain in the retained system and optimization problem. Network initialization and physical-parameter initialization are distinct.

Retrieve a physical estimate by its symbol, never by slicing the optimizer vector:

```julia
result = AnalyticMathLab.train(problem, optimizer; maxiters=budget)
alpha_estimate = result.solution.original_sol[alpha]
# Equivalently, AML retains the native solution:
alpha_estimate == result.backend_solution[alpha]
```

No extra retrieval helper is needed. The public NeuralPDE additional-loss callback uses named trial solutions and network parameter vectors:

```julia
additional_loss = (phi, theta, p) ->
    sum(abs2, phi.u(Xfit, theta.u) .- yfit) / size(Xfit, 2)
```

`Xfit` is a coordinate matrix with one point per column; `p` holds the declared physical-parameter values. This observation loss does not directly penalize or reveal the true alpha to the optimizer. The analytical truth is used only to generate synthetic observations and evaluate errors.

These conventions follow the installed NeuralPDE 7.3 `docs/src/tutorials/param_estim.md` (parameter-estimation tutorial), including `original_sol[alpha]` retrieval.

## Benchmark and reproduction

From the repository root, with the optional environment installed:

```sh
julia +release --project=examples/pinn examples/pinn/inverse_heat_gate.jl
```

Append `construction` to run only the keyword/provenance contract checks. The gate is opt-in and is not included in base `Pkg.test()`.
Run heavy Julia gates serially. The current gate additionally checks the analytical
reference against PDE/BC/IC identities before construction/training. Parameter-free
forward problems retain empty physical-parameter provenance, including when the
backend represents the absence of parameters as `SciMLBase.NullParameters`.

The problem is `u_t = alpha*u_xx` on `[0,1] × [0,1]`, with homogeneous endpoint boundaries and initial condition `u(x,0)=sin(pi*x)`. Its consistent analytical reference is

```text
u(x,t) = sin(pi*x) exp(-alpha*pi^2*t), alpha_true = 0.1.
```

The initial alpha guess is 0.3. A stateless Float64 Lux network with hidden widths `[12,12]` uses Xoshiro seed 42, `GridTraining(0.1)`, AutoZygote, and NeuralPDE finite-difference PDE derivatives. Training has a fixed budget: 3000 Adam steps at 0.01, then 2000 fresh-optimizer continuation steps at 0.001. No test-set-based stopping or optimizer scheduling is used.

Nine noiseless fit observations use the Cartesian product of `x=(0.23,0.51,0.79)` and `t=(0.19,0.47,0.83)`. The separate 143-point offset grid is withheld from the fit and used for both reference error and independent PDE-residual evaluation. BC/IC residuals use 17 offset points per block. The gate checks disjoint fit/heldout coordinates and zero overlap with returned collocation snapshots; AML conservatively leaves complete sampling-history independence unestablished. These deterministic-grid runs use no resampling callback.

Existing AML `analyze` evaluates all four residual blocks and the analytical reference without adapter changes. An independent central-finite-difference calculation checks that the diagnostic PDE residual uses the **inferred alpha**, not the initial guess. Symbolic physical unknowns survive optimization continuation and diagnostics without private vector offsets.

## Observed bounded run

A completed run with Julia 1.12.7, NeuralPDE 7.3.0, Lux 1.31.4, ModelingToolkit 11.45.1, Optimization 5.9.1 and SymbolicIndexingInterface 0.3.55 produced:

| Quantity | Observed value |
|---|---:|
| Estimated alpha | 0.1001376352637773 |
| Relative alpha error (fraction) | 0.0013763526377728874 |
| Training objective | 6.154274778026821e-6 |
| Fit-observation RMS error | 0.00023291956955758485 |
| Heldout solution RMS error | 0.00039498544505731965 |
| Heldout solution maximum absolute error | 0.001320045446671178 |
| Independent PDE residual RMS | 0.011189868130813872 |
| Independent PDE residual maximum absolute value | 0.08727105211294421 |
| Left BC residual RMS | 0.0006197853085965828 |
| Right BC residual RMS | 0.00026078512481291064 |
| IC residual RMS | 0.0009166152201961581 |

The two construction testsets passed 2 and 5 assertions; the bounded inverse testset passed 11 assertions. Acceptance limits were declared in the gate before the run: relative alpha error below 0.15, fit and heldout solution RMS below 0.05, and PDE residual RMS below 0.1. They are illustrative regression thresholds, not a certification standard.

Both optimizer stages exhausted their specified budgets and returned `ReturnCode.Default`, with `backend_success=false`. **Passing the sampled accuracy checks does not turn this into optimizer-reported convergence.** The complete run log was retained at `/home/lorenzozm/.hermes/cache/scratch/aml-m9c-inverse-gate.log`; keyword/provenance RED and GREEN logs share the `aml-m9c-` prefix. Those scratch logs are local execution evidence, not repository artifacts, and may be pruned. Julia also emitted precompilation/cache-version notices; there were no gate test failures.

## Limitations

This is a single-seed, noiseless, well-specified synthetic inverse problem. It establishes neither general identifiability nor robustness to noise, poor observation placement, alternative initial guesses, different architectures or multiple inferred coefficients. Alpha is unconstrained during optimization; a positive returned estimate is tested, not enforced. There is no posterior, confidence interval, global PDE error bound or extrapolation claim. Finite-difference derivative error is not estimated. The off-grid PDE residual is materially larger than the training objective; retain both rather than equating low objective with physical accuracy. AML's global-correctness evidence remains `:unknown`.
