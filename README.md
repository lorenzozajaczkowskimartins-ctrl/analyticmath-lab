# AnalyticMathLab.jl

AnalyticMathLab.jl is a Julia library for automated mathematical analysis,
numerical verification, method comparison, and scientific visualization.
It is **experimental, educational, research-oriented, and under active
development**. Milestones 1–3 provide function analysis, numerical derivative
convergence experiments, and evidence-aware univariate real-function studies,
not a general-purpose computer algebra system.
The package version remains 0.1.0; the API may change.

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

## Real function analysis (Milestone 3)

```julia
captured = @real_function (x^2 - 1)/(x - 1)
report = analyze(captured, x)
study = report.real_analysis
study.domain                  # (-Inf, 1) ∪ (1, Inf), exact rational endpoints
domain_contains(study.domain, 1) # false
study.roots.value              # [-1//1], never the excluded root 1
study.continuity.value         # removable hole, not a pole
study.limits.value             # finite two-sided limit 2 at the hole
study.asymptotes.value         # slant y = x + 1, no vertical asymptote
show(stdout, MIME"text/plain"(), study)
```

`analyze(f, x)` still returns `FunctionAnalysis`, preserving the derivative,
numerical-evaluation, stationary-diagnostic, and convergence APIs. Its additional
`real_analysis::RealFunctionStudy` stores domain, roots, intercepts, sign,
continuity, limits, monotonicity, extrema, concavity, inflections, asymptotes,
and symmetry. Legacy six-argument report construction remains supported and
sets `real_analysis = nothing`.

Each property is a `PropertyResult(value, status, method, notes)`. Evidence status
is separate from method: `:established` with `:exact_algebra` or
`:analytic_identity` is not the same as numerical evidence. Unsupported deductions
use `:unknown`, not an empty list claiming absence. Inspect statuses before values.
The real study is global; an explicit numerical search interval is not its domain.

When exact roots are unresolved, `interval=(a,b)` permits a bounded Float64
fallback on established original-domain components. These roots have
`status=:heuristic`, `method=:bounded_root_search`, and diagnostics explicitly
denying completeness, including for empty searches. Candidates are filtered by
original-domain membership, finite values, and an absolute residual threshold
`sqrt(eps(Float64))`; this is not a root-position bound. Heuristic roots do not
establish global sign, extrema, or other exact properties.

Original syntax is essential. Symbolics can cancel `x/x` to `1` during expression
construction, before `analyze` is called. Use `@real_function x/x` to retain the
exclusion at zero. Ordinary Symbolics input preserves only the expression tree
that reaches the analyzer; already-erased restrictions cannot be recovered.
The optional `original_expression` keyword accepts caller-supplied original syntax;
the caller must ensure it represents the same expression. Captured syntax is
walked, never evaluated by domain inference. Use the same variable name as the
Symbolics variable; unresolved local constants/names produce unknown information.

`RealDomain.components` is a union of `RealInterval` values with left/right
endpoints and independent closedness flags. Exact finite boundaries use
`Rational{BigInt}`; infinities are distinguished unbounded endpoints. Membership
returns `nothing` for unknown domains. Empty components mean the empty set only
when domain status is established. Recursive restrictions include denominator
nonzero, square-root radicand nonnegative, and logarithm argument positive.
Unsupported composed inequalities remain unknown.

The certified class includes integer/rational polynomial and rational arithmetic,
outer square roots/logarithms of supported rational functions, and `sin(x)` via
exact periodic identities. Rational-root factorization and exact quadratic
discriminants establish completeness only for the supported factorization class.
Irrational algebraic roots such as those of `x^2-2` are not represented exactly
in this milestone; affected global properties remain unknown. Integer powers and
factor searches have explicit resource bounds; this is not a theorem prover.
A shared conservative algebraic budget caps dense degree at 64, projected
coefficient size at 4096 bits, and cumulative work at 200,000 units. Original
syntax is capped at 512 nodes/depth 48. These bounds also cover derivative and
parity intermediates. Exhaustion returns an unknown study with
`method=:resource_budget`, without launching a numerical fallback. This budget
covers the real-analysis core, not Symbolics expression construction or the
legacy derivative/callable generation performed by `analyze`.

Sign cells are certified only after complete boundary/root enumeration; exact
rational representatives then establish the sign on each cell. Monotonicity uses
first-derivative signs; strict local extrema require sign changes (included
one-sided square-root endpoints are also considered). Concavity directions are
`:convex` (up), `:concave` (down), and `:affine`. Inflections require a concavity
change at a point in the original domain: `x^4` has none at zero, and a pole is
never an inflection. Zero sets can be an entire `RealDomain`; sine roots and
features use `PeriodicPointSet`/`PeriodicIntervalSet` with integer translates.

Limits store `at`, `side` (`:left`, `:right`, `:both`), `kind`, and exact finite
`value`. Kinds distinguish finite values, both infinities, nonexistent limits,
and unknown. Stored queries cover domain-component boundaries and reachable
infinities, not arbitrary interior points. A side with no domain approach has
no limit. Continuity distinguishes removable holes, poles, and other boundaries;
general piecewise/jump classification is unsupported rather than guessed.
Vertical asymptotes require divergent one-sided limits; horizontal and slant
asymptotes use exact growth/limit identities. Parity requires both a symbolic
identity and symmetry of the original domain.

Stored vectors and captured `Expr` objects are mutable even though result structs
are immutable. Treat them as read-only or deep-copy before modification; library
views do not mutate them. Exact transformed values may be unevaluated syntax such
as `log(2)`; they are data, not instructions to execute.

For compatibility, `evaluate` retains the generated callable's behavior, including
NaNMath results and symbolic cancellations; it is not a checked real-domain
evaluator. Check `domain_contains(report.real_analysis.domain, x)` when needed.
The legacy bounded stationary search still assumes a smooth function throughout
its interval; the global study does not make that numerical search domain-safe.

Run `julia --project=. notebooks/real_function_analysis.jl` to print studies and
render the preserved removable-hole and rational-pole examples. Analysis is
completed before the example loads CairoMakie.

## Derivative convergence and error analysis (Milestone 2)

```julia
report = analyze(sin(x), x)
central = derivative_convergence(report, 0.4;
    method=:central, hmin=1e-12, hmax=1e-1, samples=45)
forward = derivative_convergence(report, 0.4; method=:forward)
central.steps                  # decreasing logarithmic h grid, inclusive bounds
central.approximations
central.reference              # stored symbolic first derivative evaluated once
central.absolute_errors
central.relative_errors        # per-sample Float64 or nothing
central.best_step
central.minimum_error
central.observed_order         # Float64 or nothing
central.order_indices          # samples actually used for the estimate
show(stdout, MIME"text/plain"(), central)

using CairoMakie               # caller chooses the rendering backend
save("convergence.png", plot(central))
```

`DerivativeConvergenceAnalysis <: AbstractAnalysis` is structured data containing
the expression, variable, evaluation point, method, reference, and sampled results.
It retains neither the source report nor numerical callables or backend state.
The source report is not modified. Its vectors are mutable: treat them as read-only
or copy before editing; modifying them can invalidate stored summary fields.

The experiment deliberately uses explicit formulas to control h:

- Forward: `(f(x+h) - f(x)) / h`.
- Central: `(f(x+h) - f(x-h)) / (2h)`.

Inputs and numerical values are converted to Float64. Defaults are central
differences with 45 logarithmically spaced steps from `hmax=1e-1` down to
`hmin=1e-12`. Require finite `0 < hmin < hmax`, at least three distinct samples,
a finite point, and distinguishable finite stencil offsets. Central differences
also require finite `2h`. Invalid controls raise `ArgumentError`; nonfinite
evaluations, arithmetic results, and domain failures raise `DomainError`.
Only the chosen method's stencil is used; forward differences do not evaluate
`x-h`. No domain clipping, automatic h selection, or smoothness proof occurs.

Absolute error means `abs(approximation - reference)`, a discrepancy from the
evaluated symbolic derivative, not a certified error bound. Relative discrepancies
divide by `abs(reference)`; each entry is `nothing` when the reference is zero or
the ratio overflows Float64. Near-zero references can make relative errors
ill-conditioned; there is no artificial epsilon denominator.
`best_step` and `minimum_error` describe only the sampled grid. Ties select the
larger h, not a claimed global optimum. Zero discrepancy does not prove exactness.

For smooth functions, truncation-dominated forward and central differences often
show orders near one and two, respectively. Small h can instead amplify roundoff
and subtraction cancellation. The package neither forces those orders nor
separates truncation and floating-point contributions into certified components.

Observed order is an explicitly heuristic estimate from absolute errors:

1. Restrict to the initial positive, strictly decreasing error prefix, ending at
   the first plateau, increase, or zero. Never search later decreasing regions.
2. Compute local slopes `log(E[i+1]/E[i]) / log(h[i+1]/h[i])`.
3. Find the earliest three consecutive positive finite slopes whose deviations
   from their mean are at most 10% of that mean; extend while this remains true.
4. Store the mean and its sample indices. Without four suitable samples, return
   `nothing` with empty indices. No theoretical order enters the calculation.

This avoids fitting across an observed roundoff upturn, but cannot certify a
truncation regime. It can miss a later asymptotic region or be fooled by a smooth
numerical artifact. Inspect the curve and selected indices, not just the order.

`plot(central)` returns a Makie Figure using stored h and absolute error only,
with log-log axes and an annotation of the sampled minimum. A positive minimum
gets a marker. Zero errors are omitted and counted in the subtitle, never replaced
by epsilon; all-zero results have an empty, annotated log-log axis. The plot does
not evaluate the function, recompute convergence, mutate data, or activate a backend.

Run the notebook-style example (constructs both analyses before loading CairoMakie):

```sh
julia --project=. notebooks/derivative_convergence.jl
```

It saves separate forward and central PNGs in `notebooks/output/`, or in the
optional output-directory argument. Generated images are ignored by Git.

## Bounded critical-point analysis

```julia
report = analyze(f, x; interval=(0.0, 4.0), residual_tolerance=1e-8)
report.critical_points.points
report.critical_points.status
show(stdout, MIME"text/plain"(), report)
```

An interval explicitly requests a **Float64 heuristic stationary-point search**
using `Roots.find_zeros`. Candidates store position, function value, absolute
first-derivative residual, second derivative, and classification. By default,
residuals must meet the absolute tolerance. Classification uses the second-derivative test:
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

Optional `residual_rtol=0` and `residual_scale=1` keywords allow an explicitly
scaled check: `abs(f′(candidate)) <= residual_tolerance + residual_rtol * residual_scale`.
The scale is a caller-chosen positive finite value in derivative units, not a
sampled estimate. Relative tolerance must be finite and nonnegative; absolute
tolerance remains finite and positive. The effective threshold must be finite.
Defaults retain Milestone 1 acceptance. This check is not a root-position error
bound and does not change the second-derivative classification threshold.

`critical_points.rejections` records each rejected solver candidate's `x`,
`residual`, `threshold`, and `reason` (`:residual_exceeded`). For results from
`analyze`, the count agrees with `rejected_candidates`. Legacy six-argument
`CriticalPointAnalysis` constructors remain supported; if they supply a nonzero
rejection count, `rejections === nothing` denotes unavailable historical details.
Text display reports the method, interval, threshold,
and accepted/rejected counts, distinguishing an empty solver search from a
search whose candidates failed verification. Both still have `:heuristic`
status; neither certifies absence. Domain failures still propagate, rather than
being counted as rejected roots.

The result structs are immutable, but their `points` and `rejections` vectors
are mutable. Library operations leave them unchanged; treat them as read-only
or copy them before editing.

Supply a smooth real function on the requested interval. Search and derivative
comparison reject sampled nonfinite values. Plain `evaluate` preserves the
generated callable's behavior, including NaNMath's NaN for negative real `log`
inputs; exceptions raised by the callable propagate. In particular,
the numerical APIs do not automatically enforce the stored real domain or prove
differentiability. Unbound symbolic parameters and multivariate
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

Stored established domain boundaries insert explicit curve gaps, even if the
uniform grid misses a hole or pole. Stored finite roots, extrema, inflections,
removable holes, and vertical/horizontal/slant asymptotes decorate the plot.
Periodic and unevaluated symbolic decorations are currently skipped; they remain
available in the report. Unknown domains retain sampled-error/nonfinite gaps only,
so unknown unsampled discontinuities can still be connected. No mathematical
inference occurs in plotting. The default `[-5, 5]` window is only a view.

An executable notebook-style example is in `notebooks/function_analysis.jl`:

```sh
julia --project=. notebooks/function_analysis.jl
```

## Architecture and dependencies

- `src/AnalyticMathLab.jl`: module, imports, and public API.
- `src/analysis.jl`: small parametric result types and display methods.
- `src/symbolic.jl`: Symbolics orchestration and input validation.
- `src/numerical.jl`: evaluation, Roots search, ForwardDiff/FiniteDiff comparison.
- `src/convergence.jl`: controlled finite differences, error data, empirical order, display.
- `src/visualization.jl`: backend-independent Makie view.
- `src/source_capture.jl`: syntax preservation before symbolic cancellation.
- `src/real_analysis*.jl`: exact core, domains, transforms, periodic identities,
  evidence display, and stored-result plotting helpers.
- `test/runtests.jl`: mathematical contracts and headless CairoMakie rendering.
- `test/convergence.jl`: convergence contracts and rendering; included by `runtests.jl`.

Direct dependencies are Symbolics, Roots, ForwardDiff, FiniteDiff, Makie, and
CairoMakie. Test is test-only. Roots and general derivative comparison retain
their library implementations; the h sweep deliberately uses explicit differences.
Other analysis types can later add methods to `analyze`;
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

Milestone 3 implements a conservative univariate real-function study with explicit
domains and evidence-aware results for the supported classes above. Milestone 4
adds scalar-field calculus as documented below. General matrix/system analysis,
integration, ODE/PDE solvers, constrained optimization, full report
exporters, general-purpose domain inference, and interactive GUIs are not implemented.

## License

MIT; see `LICENSE`, consistent with the original Python package's declaration.
## Multivariate scalar fields (Milestone 4)

AnalyticMathLab also analyzes scalar fields `f: ℝⁿ → ℝ`, with plotting focused on
two variables:

```julia
@variables x y
report = analyze(x^2 + 2y^2 - x*y, (x, y))
gradient(report)                    # stored symbolic vector
hessian(report, (1.0, 2.0))        # reusable numerical callable
directional_derivative(report, (1, 2), (3, 4)) # direction is normalized
linearization(report, (1, 2))      # expression, base point, value, coefficients
levelset(report, 3)                 # a Symbolics equation
```

Stationary-point completeness is certified only for nonsingular affine-gradient
systems (quadratic fields) and separable rational polynomials whose univariate
derivative roots are completely handled by the existing exact root engine. Other
expressions return `:unknown` unless finite `bounds` are supplied. Bounded searches
use a validated, finite multistart Newton grid and are always `:heuristic`; empty
results do not establish absence. Every accepted candidate stores its finite
gradient-residual norm and threshold. Hessian classification uses scale-aware
absolute/relative eigenvalue tolerances. Exact diagonal and two-dimensional
definiteness tests are marked `:established`; other eigenvalue classifications
remain numerical evidence. Near-zero curvature is `:inconclusive`.

`@real_function` preserves original denominator, square-root, logarithm, and
negative-integer-power restrictions. `domain_contains` returns `true`, `false`, or
`nothing` when the safe syntax walker cannot establish membership. Variable
exponents and unsupported calls deliberately make the domain partial/unknown.
Checked evaluation rejects known exclusions and all nonfinite inputs/results; an
unknown domain does not assert that a point is valid.

For two-variable reports, `surface`, `contour`, `gradientplot`, and `plot` return a
`Makie.Figure`. Pass explicit finite `xrange`, `yrange`, and bounded `samples` for
the view. Gradient arrows are unnormalized and reuse stored gradient callables;
`arrowscale` applies an explicit positive display scale without changing relative magnitudes.
`surface`/`plot(...; tangent_at=point)` adds the stored-linearization tangent plane;
critical markers consume stored stationary analysis. No backend is activated and
nothing is displayed or saved by the library. Load CairoMakie or another backend
in application code. Sampling masks known-invalid vertices and conservatively
masks cells whose interval enclosure cannot exclude a forbidden restriction value.
This also catches even-multiplicity poles and holes inside a cell, rather than
relying only on vertex sign changes. Unsupported interval operations can blank
entire regions; arbitrary unknown-domain boundaries are not certified.

`ScalarFieldAnalysis` stores the expression, original syntax, ordered variables,
symbolic gradient/Hessian, compiled callables, `MultivariateDomain`, and a
`PropertyResult` of `StationaryPoint` records. `MultivariateRestriction` is the
internal syntax/relation record. `analyze(f, x)` remains the univariate API;
tuple/vector variable collections select the scalar-field methods. `LinearAlgebra`
is the additional standard-library dependency.

Directional derivatives normalize the direction and, like linearization, require
a supported open smooth neighborhood of the original domain. They reject corners
and domain boundaries instead of applying a formal gradient there. Numerical
gradient/Hessian APIs use the same sufficient smoothness gate; symbolic forms
remain formal derivatives. Integer/rational domain checks use bounded BigInt arithmetic
to avoid machine-integer overflow. Partial domains still reject independently
known exclusions; otherwise membership is `nothing`.

Limits: at most 32 variables; integer powers through magnitude 32 in domain
syntax; the shared exact algebra budgets still apply. Exact stationary solving
does not enumerate nonisolated families. General searches require explicit finite
bounds, at most 50,000 seeds, and at most 200 Newton iterations per seed; no global
completeness or root-position error bound is implied. Degenerate Hessians remain
`:inconclusive`; constrained/boundary extrema are not solved. `levelset` returns
an equation which must be intersected with `report.domain`, not a parametrization
or topological description. Plot vertices/arrows require known membership;
unknown membership is masked rather than drawn as a valid point.

Run `julia --project=. notebooks/multivariable_analysis.jl` for the quadratic,
saddle, quartic, and excluded-circle examples and their saved Makie figures.
All multivariate tests are included in `test/runtests.jl`; backend-independence
checks run before CairoMakie is imported.
