# Differential equations: checking an adaptive trajectory

[Learning path](index.md) · Previous: [normal modes](normal-modes.md) ·
Next: [trajectories and statistics](trajectories.md)

Prerequisites: first-order ODEs, initial conditions, vectors. Difficulty: intermediate.
Direct dependency: AnalyticMathLab. SciMLBase and OrdinaryDiffEqTsit5 are declared
package dependencies used by AML internally, not undeclared global packages.
Executable: [odes.jl](scripts/odes.jl). From the repository root:

```sh
julia +1.12.7 --project=. docs/tutorials/scripts/odes.jl
```

## Problem, formulation and analytical reference

For the dimensionless unit-frequency oscillator, $\ddot q=-q$. Introduce
$v=\dot q$ and state $u=(q,v)^T$:

$$\dot u=\begin{pmatrix}v\\-q\end{pmatrix},\quad
u(0)=\begin{pmatrix}1\\0\end{pmatrix},\quad 0\le t\le2.$$

The independent reference is $q(t)=\cos t$, $v(t)=-\sin t$. Differentiating
these expressions verifies the ODE and initial conditions. The smooth linear
right-hand side supplies existence/uniqueness for this problem; solver success
alone would not establish that mathematical fact.

`FirstOrderODE` expects an out-of-place `f(u,t)` returning one finite real component
per declared state. A state is a vector even for one-dimensional problems.
Labels `(q,v)` convey order; they do not infer masses, particle identity or units.
The default domain predicate permits this unrestricted model.

## Implementation

The script encapsulates the model in `HarmonicTutorial` so the following statistics
lesson can reuse the same actual trajectory without duplicating the ODE.
The native solver is adaptive Tsit5. The specified absolute and relative tolerances
control its local numerical decisions, not a certified global error bound.

```julia
module HarmonicTutorial
using AnalyticMathLab

# Dimensionless unit-frequency oscillator; ordered state (q,v).
problem = FirstOrderODE((u, t) -> [u[2], -u[1]], 2; labels=("q", "v"))
path = trajectory(problem, [1.0, 0.0], (0.0, 2.0);
    abstol=1e-10, reltol=1e-10, saveat=0.125, dt=0.125)
@assert path.diagnostics.success && path.diagnostics.completed
@assert path.labels == ("q", "v")
times = path.solution.t
states = hcat(path.solution.u...)
@assert size(states) == (2, length(times))
@assert first(times) == 0.0 && last(times) == 2.0
@assert all(diff(times) .> 0)
requested = collect(0.0:0.125:2.0)
@assert all(t -> t in times, requested)
reference = hcat(([cos(t), -sin(t)] for t in times)...)
state_error = maximum(abs, states - reference)
@assert state_error <= 1e-8
# A separate query uses the retained native interpolant, not stored-only extraction.
query = 0.37
interpolation_error = maximum(abs, path.solution(query) - [cos(query), -sin(query)])
@assert interpolation_error <= 1e-8
println((saved_samples=length(times), requested_stops=length(requested),
    accepted=path.diagnostics.accepted_steps, rejected=path.diagnostics.rejected_steps,
    max_saved_state_error=state_error, interpolation_query=query,
    interpolation_error=interpolation_error, labels=path.labels))
println("ODES_OK")
end
```

## Saved observations versus internal steps

SOURCE_INSPECTED: AML's `saveat=0.125` is an interval of forced accepted stops,
implemented through SciML `tstops`. It retains every accepted adaptive step and
native dense interpolation history; it is not SciML's generic output-only
`saveat` keyword. `dt` chooses the initial step magnitude, not a fixed-step method.
Only AML's actual accepted wrapper keywords are used above.

EXAMPLE_EXECUTED: the run saved 84 observations, with 83 accepted steps and
2 rejected trials, while the requested interval grid has only 17 times. Every
requested time occurred in the saved history, and all saved times increased.
Rejected trials are not a new row in the observed series. This concrete example
shows why requested times and stored samples must not be conflated.

NUMERICAL_COMPARISON uses the entrywise maximum at actual saved times,

$$e_{\rm saved}=\max_{i,j}|u_i(t_j)-u_i^{\rm ref}(t_j)|.$$

Observed $e_{\rm saved}=1.75648\times10^{-12}$, checked at $10^{-8}$.
The separate native interpolant query at $t=0.37$ had maximum component discrepancy
$8.17790\times10^{-13}$, also checked at $10^{-8}$. These metrics concern a finite
sample and one interpolated query, not every continuous time or every initial state.
Both completion and solver-success flags were checked, along with state shape
`(2,length(times))` and coordinate labels.

## Limitations and next steps

`saveat` is not a global memory-retention control. Long integrations can retain
large adaptive history even with sparse requested observations. Integration uses
checked Float64 boundaries; this workflow is not arbitrary-precision solving.
A solver return does not establish accuracy without a reference or other justified
evidence. A domain predicate is checked at RHS stages, not certified over the
entire dense interpolant; it is not a boundary-location algorithm.

The next [statistics lesson](trajectories.md) consumes stored observations without
interpolation. Its unweighted means are not continuous-time averages, especially
on this adaptive grid. For autonomous symbolic fields and other examples see the
existing [dynamics guide](../dynamical_systems.md).
[Execution record](../../reports/m10d6/tutorial_implementation_report.md).
