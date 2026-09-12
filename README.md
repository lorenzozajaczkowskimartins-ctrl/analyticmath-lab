# AnalyticMathLab.jl

AnalyticMathLab.jl is a Julia library for automated mathematical analysis,
numerical verification, method comparison, and scientific visualization.
It is **experimental, educational, research-oriented, and under active
development**. Version 0.1.0 is a small first milestone, not a general-purpose
computer algebra system. The API may change.

The mathematical result is the source of truth:

```text
expression → analyze → FunctionAnalysis → evaluate / compare_derivatives / show / plot
```

## Run locally

Use Julia 1.12 and the existing repository environment; no global installation
or registry registration is required. From the repository root:

```sh
julia --project=. -e 'using Pkg; Pkg.instantiate()'
julia --project=.
```

The checked-in `Manifest.toml` records the tested environment. `Project.toml`
defines package identity and compatibility. The clone directory can remain
`analyticmath-lab`; the Julia module/package name is `AnalyticMathLab`.

## Current API

```julia
using AnalyticMathLab
using Symbolics

@variables x
f = x^3 - 6x^2 + 9x + 1
report = analyze(f, x)

report.expression
report.variable
report.first_derivative
report.second_derivative
evaluate(report, 2.0)
evaluate(report, 2.0; order=1)
evaluate.(Ref(report), [0.0, 1.0, 2.0])

comparison = compare_derivatives(report, 2.0)
comparison.values             # symbolic, automatic, central
comparison.absolute_errors    # discrepancies from the symbolic reference
```

`FunctionAnalysis <: AbstractAnalysis` stores symbolic results and concrete
numerical callables generated once by Symbolics. `evaluate` supports derivative
orders 0, 1, and 2. Numerical evaluation preserves the input's arithmetic where
the underlying operations support it, including rational and BigFloat inputs.
`analyze` neither prints nor creates figures or files.

`DerivativeComparison <: AbstractAnalysis` is a separate reusable result, not a
mutation of the original report. It compares Symbolics' evaluated derivative,
ForwardDiff, and FiniteDiff central differences with FiniteDiff's default step.
The reference is not a rigorous numerical oracle: the reported absolute errors
are discrepancies, not certified error bounds. Smoothness near the point is a
caller assumption; comparisons at corners or domain boundaries are not reliable.

## Bounded critical-point analysis

```julia
report = analyze(f, x; interval=(0.0, 4.0), residual_tolerance=1e-8)
report.critical_points.points
report.critical_points.status
show(stdout, MIME"text/plain"(), report)
```

An interval explicitly requests a **Float64 heuristic stationary-point search**
using `Roots.find_zeros`. Candidates store position, function value, absolute
first-derivative residual, second derivative, and classification. Residuals must
meet the absolute tolerance. Classification uses the second-derivative test:
positive/negative curvature gives a minimum/maximum *candidate*, and curvature
within `sqrt(eps(Float64))` of zero remains `:undetermined`. Interval endpoints
are labeled `:boundary_candidate` when detected as stationary candidates, not
interior extrema. Nonstationary endpoints are not added; this is not a search
for all constrained extrema.

Statuses distinguish `:not_requested`, `:heuristic`, and `:nonisolated` (an
identically zero derivative wherever the expression is defined). An empty list
does not mean a constant function has no stationary points, or certify that a
heuristic search found everything. The result records search bounds, method,
tolerance, and rejected-candidate count. No search window is silently guessed.

The result structs are immutable, but the `points` vector is mutable. Library
operations leave it unchanged; treat it as read-only or copy it before editing.

Supply a smooth real function on the requested interval. Search and derivative
comparison reject sampled nonfinite values. Plain `evaluate` preserves the
generated callable's behavior, including NaNMath's NaN for negative real `log`
inputs; exceptions raised by the callable propagate. In particular,
there is no automatic domain analysis, exhaustive root isolation, corner detection,
or proof of differentiability. Unbound symbolic parameters and multivariate
expressions are rejected. Scalar Symbolics expressions and real constants are
supported; string parsing and arbitrary Julia-function analysis are not.

## Makie visualization

```julia
using CairoMakie                  # choose a backend explicitly
fig = plot(report; xmin=0, xmax=4, samples=501)
save("analysis.png", fig)         # saving is an explicit caller action
```

`plot` extends Makie's function for `FunctionAnalysis` and returns a `Makie.Figure`.
It draws the function and already-known stationary candidates within the plot
window, without rerunning analysis. The report contains no Makie/backend state.
CairoMakie is included for headless/static rendering; the plotting code itself
uses only Makie and does not activate a backend or open a window.

Uniform sampling is intended for simple functions. Sampled domain errors and
nonfinite values become gaps; unsampled discontinuities can still be connected.
This is not a domain-aware/asymptote-aware plotter. The default plot window is
`[-5, 5]` and is only a view, never an implicit mathematical domain.

An executable notebook-style example is in `notebooks/function_analysis.jl`:

```sh
julia --project=. notebooks/function_analysis.jl
```

## Architecture and dependencies

- `src/AnalyticMathLab.jl`: module, imports, and public API.
- `src/analysis.jl`: small parametric result types and display methods.
- `src/symbolic.jl`: Symbolics orchestration and input validation.
- `src/numerical.jl`: evaluation, Roots search, ForwardDiff/FiniteDiff comparison.
- `src/visualization.jl`: backend-independent Makie view.
- `test/runtests.jl`: mathematical contracts and headless CairoMakie rendering.

Direct dependencies are Symbolics, Roots, ForwardDiff, FiniteDiff, Makie, and
CairoMakie. Test is test-only. No numerical solvers or finite-difference formulas
are reimplemented. Other analysis types can later add methods to `analyze`;
future features are not represented by empty modules or `Any`-filled fields.

## Tests

```sh
julia --project=. -e 'using Pkg; Pkg.test()'
```

Tests cover symbolic identities, numerical evaluation, search semantics and
residuals, method agreement, invalid inputs, presentation independence, and PNG
rendering without a GUI. Initial dependency precompilation can take several minutes.

## Scope and migration

The Python implementation is preserved by local tag `python-v0.1` and branch
`legacy-python`, both referencing original commit `6820e97`. Its source, tests,
CLI, report renderers, and packaging remain in Git history, not duplicated in
this Julia working tree. The conceptual foundations retained are typed results,
reused computations, explicit uncertainty, and presentation derived from data.

The former class-wrapper API, duplicated analysis helpers, broad exception
swallowing, placeholder module tree, Windows installer, and visual themes were
not ported. This is a Julia redesign, not Python feature parity.

Future milestones may add better stationary-point verification, configurable
method comparisons, and report-based visualization. Matrix/system analysis,
multivariable calculus, integration, ODE/PDE solvers, optimization, full report
exporters, automatic domains/asymptotes, and interactive GUIs are not implemented.

## License

MIT; see `LICENSE`, consistent with the original Python package's declaration.
