# Dynamical systems and first-order ODEs (Milestone 6)

## Structural analysis

```julia
using AnalyticMathLab, Symbolics
@variables x v
field = analyze([v, -x-v/2], (x,v))
report = analyze(AutonomousSystem(field))
@assert report.field === field
 equilibria(report) # PropertyResult of equilibrium records
 stability(report)  # local matrix, numerical spectrum, and stability evidence
 nullclines(report) # implicit component equations, restricted to report.domain
jacobian(report, (0,0))
linearization(report, (0,0))
```

`AutonomousSystem(F, variables; kwargs...)` also constructs the vector report;
keywords are forwarded to vector analysis. Only square fields are accepted.
`analyze(system; classification_atol=1e-10, classification_rtol=1e-8)` reuses the
stored field zeros and Jacobian. No differentiation or root search is repeated.
`evaluate`, `jacobian`, and `linearization` delegate to the vector report.

Equilibrium records retain point, field value, residual norm/threshold,
status/method, original-domain validity, and local analysis. Exact affine and
separable solving, bounded multistart Newton searches, and their limitations are
inherited from vector fields. A heuristic empty search is not proof of absence;
nonisolated families are not enumerated. Accessors return deep copies; treat the
report's own mutable arrays as read-only.

## Local stability, not global dynamics

A supported open smooth neighborhood of the original expression is required.
Local matrices substitute equilibria into the stored Jacobian. The displayed
Float64 eigenvalues are diagnostics, never exact sign certificates.

At established equilibria with rational matrices, exact diagonal signs or planar
trace/determinant tests establish local asymptotic stability, instability, or a
saddle. A positive eigenvalue proves instability even when another eigenvalue is
zero; nonhyperbolicity does not invalidate this one-sided theorem. Negative real
parts throughout establish local asymptotic stability, not global attraction.
Mixed positive and negative signs yield the label `:saddle` (possibly with center
directions in higher dimensions); this label does not certify hyperbolicity.

A planar purely imaginary spectrum establishes `:center` only for an affine
linear system on an established unrestricted domain. The same linearization for
a nonlinear system stays `:inconclusive` / `:unknown`, as do zero-eigenvalue cases
without a positive direction. No nonlinear center, Lyapunov function, basin of
attraction, periodic orbit, or bifurcation is inferred from a plot or spectrum.
There is no separate public hyperbolicity flag.

Other spectra use a real-part threshold
`classification_atol + classification_rtol * max(maximum(abs,eigenvalues),1)`.
Signs outside this band yield only `:heuristic` evidence; unresolved signs yield
unknown when they prevent a conclusion. Approximate equilibria retain the warning
that a small residual is neither a root-position nor stability guarantee.
Unrepresentable Jacobians/spectra return unknown, not fabricated signs.

Planar nullclines are implicit equations `F[i] ~ 0` paired with the original
domain. They do not certify regularity, topology, or a parametrization. Other
dimensions return unknown nullcline evidence.

## Numerical integration

```julia
path = trajectory(report, [1,0], (0,12); saveat=0.05)
problem = FirstOrderODE((u,t) -> [-2t*u[1]], 1; labels=("y",))
nonautonomous = trajectory(problem, 1.0, (0,2)) # y(t) = exp(-t^2)
path.solution(0.5) # native SciML dense interpolation
path.diagnostics
```

The backend is SciMLBase with OrdinaryDiffEqTsit5's adaptive `Tsit5()` by default,
not a handwritten integrator or the full DifferentialEquations umbrella package.
An installed compatible `algorithm` can be supplied explicitly. State, times,
and tolerances are converted to Float64. State is a vector even for scalar ODEs;
`f(u,t)` must return a real finite vector/tuple of the declared dimension (1–32).
Parameters may be captured in the callable. This is an out-of-place interface.
Backward integration is supported with distinct finite time endpoints.

Defaults are `abstol=1e-9`, `reltol=1e-7`, `maxiters=100000`; optional positive
`dt` is an initial step magnitude and `saveat` a positive saving interval measured
from the initial time in the integration direction (including backward solves).
The interval grid is passed as SciML `tstops`, **not** its incompatible dense-output
`saveat` option: the solver lands on requested times while saving every adaptive
step and the native dense interpolation history. Thus `saveat` can change the
adaptive step sequence and cost; it does not produce an exclusively uniform
output grid. The initial and final endpoints are saved on a completed solve even
when the final endpoint is off the interval grid. With `saveat=nothing`, no extra
stops are requested.

The interval must remain finite and positive after Float64 conversion. Grid times
must be distinct in Float64, and `abs(tend-tstart)/saveat` must be finite and at
most 1,000,000; invalid or excessive grids raise `ArgumentError` before constructing
the solver's stop queue. This grid budget is independent of `maxiters`. If the
solver stops early, only the reached portion is saved and completion remains
false; future requested grid times are not fabricated.

The result retains the native solution,
the `FirstOrderODE`, labels, return code, success/completion flags, final time,
algorithm type, tolerances, and accepted/rejected step counts. Inspect completion
and return code rather than assuming a returned result reached its target.
Tolerances and sampled comparisons are not rigorous global error bounds.

An optional `domain=(u,t)->true` is a caller-supplied numerical contract. Every RHS
call, including trial stages, requires membership exactly `true`; invalid or
unknown membership and nonfinite values raise `DomainError`. Autonomous paths
reuse the field's preserved original domain. Use `@real_function` before symbolic
cancellation to retain holes. This fail-fast policy does not locate a boundary,
return a partial path on domain exceptions, or certify the continuous interpolant
between sampled stages. No stiffness detection, event API, or rigorous enclosure
is provided in this milestone.

## Presentation and executable example

```julia
using CairoMakie # caller selects backend, after analysis/integration
save("phase.png", phaseplot(report; trajectories=[path], show_nullclines=true))
save("time.png", timeplot(path))
```

`phaseplot` is planar only and accepts trajectories originating from the identical
underlying field. It reuses unnormalized arrows with an explicit `arrowscale`,
stored equilibrium markers, optional sampled nullcline contours, and saved
trajectory states. Known-invalid or unresolved domain cells/segments are masked
conservatively, so some valid regions may also be omitted. `timeplot` uses saved
states without RHS calls or new solving; it does not certify domain validity
between those states. Neither view mutates results or activates a backend.

Run `julia --project=. notebooks/dynamical_systems.jl [output-directory]`.
The executable notebook covers rotation, damping, a saddle, logistic growth,
nonlinear nonhyperbolic uncertainty, nonautonomous decay, and a preserved hole.
It checks mathematics and trajectories before importing CairoMakie, then saves
phase/time figures to ignored `notebooks/output/` by default.
