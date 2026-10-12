# Scalar analysis: one function, three derivative estimates

[Learning path](index.md) · Next: [multivariate calculus](multivariate.md)

Prerequisites: derivatives and local extrema; basic Julia. Difficulty: introductory.
Dependencies: AnalyticMathLab and Symbolics in the checkout project.
Executable: [calculus.jl](scripts/calculus.jl). Run from the repository root:

```sh
julia +1.12.7 --project=. docs/tutorials/scripts/calculus.jl
```

## Problem and mathematical formulation

How do we distinguish a mathematical derivative from a numerical approximation?
Study the dimensionless polynomial on the whole real line,

$$f(x)=x^3-6x^2+9x+1.$$

It is smooth everywhere. Direct differentiation and factorization give

$$f'(x)=3x^2-12x+9=3(x-1)(x-3),\qquad f''(x)=6x-12.$$

Thus the only stationary points are $x=1$ and $x=3$. Their curvatures are
negative and positive respectively, so they are a strict local maximum and
minimum, with values 5 and 1. Neither is a global extremum on $\mathbb R$:
the cubic is unbounded above and below. The supplied interval $(0,4)$ is a
bounded search region, not a declaration that the function exists only there.

## Implementation

`analyze` stores symbolic derivatives and compiled numerical callables.
`evaluate(...; order=1)` evaluates the stored derivative rather than differentiating
again. `report.critical_points.points` contains numerical candidates, not a
complete symbolic solution certificate. This script separately establishes the
roots from the factored expression and checks that the search recovers them.
The complete block is byte-identical to the linked script and needs no hidden REPL state.

```julia
using AnalyticMathLab, Symbolics

@variables x
f = x^3 - 6x^2 + 9x + 1
report = analyze(f, x; interval=(0, 4))
zero_identity(e) = iszero(Symbolics.simplify(Symbolics.expand(e)))
@assert zero_identity(report.first_derivative - 3*(x-1)*(x-3))
@assert zero_identity(report.second_derivative - (6x-12))
@assert evaluate(report, 2.0) == 3.0
@assert evaluate(report, 2.0; order=1) == -3.0
points = sort(report.critical_points.points; by=p -> p.x)
@assert length(points) == 2
@assert maximum(abs.([p.x for p in points] - [1.0, 3.0])) <= 1e-10
@assert [p.classification for p in points] == [:maximum_candidate, :minimum_candidate]
@assert maximum(abs.([p.value for p in points] - [5.0, 1.0])) <= 1e-10

comparison = compare_derivatives(report, 2.0)
@assert abs(comparison.values.symbolic + 3) <= 1e-12
@assert abs(comparison.values.automatic + 3) <= 1e-12
@assert abs(comparison.values.central + 3) <= 1e-7
# A caller-chosen stencil, distinct from FiniteDiff's default step.
h = 1/8
central = (evaluate(report, 2+h) - evaluate(report, 2-h))/(2h)
@assert abs(central - (-3 + h^2)) <= 1e-12
println((value=evaluate(report, 2.0), stationary=[p.x for p in points],
    classifications=[p.classification for p in points], derivative_values=comparison.values,
    discrepancies=comparison.absolute_errors, explicit_h=h, stencil=central))
println("CALCULUS_OK")
```

## Verification and result interpretation

EXACT_IDENTITY: symbolic differences verify the explicitly derived derivatives.
The factorization, not numerical search, justifies exhaustiveness in this example.
ANALYTICAL_REFERENCE: $f(2)=3$ and $f'(2)=-3$; stationary values are 5 and 1.
EXAMPLE_EXECUTED: positions `[1.0, 2.999999999999999]` were recovered within
$10^{-10}$, with `:maximum_candidate` and `:minimum_candidate` labels.

NUMERICAL_COMPARISON at $x=2$: symbolic and automatic derivatives were both
`-3.0`; FiniteDiff central differentiation returned `-2.9999999998139817`, a
discrepancy of about $1.86\times10^{-10}$. Assertions compare against the
independently differentiated polynomial, using $10^{-12}$ for symbolic/AD and
$10^{-7}$ for this finite-difference run. These are example acceptance tolerances,
not universal guarantees.

For a caller-selected centered stencil,

$$D_h f(x)=\frac{f(x+h)-f(x-h)}{2h},$$

Taylor expansion cancels even terms, giving
$D_h f(x)=f'(x)+h^2 f'''(x)/6+O(h^4)$ for sufficiently smooth functions.
For this cubic $f'''=6$ and all higher derivatives vanish: in exact arithmetic
$D_h f(2)=-3+h^2$. The binary step $h=1/8$ produced `-2.984375`, checked
within $10^{-12}$. This teaching stencil is not a new AML algorithm and is not
FiniteDiff's internally selected default step.

Truncation improves as $h$ shrinks, but subtracting nearby floating-point values
and dividing by $h$ amplifies roundoff. Smaller is not always better.
`comparison.absolute_errors` measures differences from evaluated symbolic
arithmetic, not certified true-error bounds. AD differentiates implemented
arithmetic, not arbitrary nonsmooth mathematics.

## Domains and next steps

For rational or logarithmic functions, preserve original syntax with
`@real_function` before symbolic cancellation erases exclusions. Numerical
univariate `evaluate` does not automatically enforce original-domain membership.
A small derivative residual is not a root-position bound; an empty heuristic
search does not prove absence of stationary points.

Continue to [ordered multivariate derivatives](multivariate.md). The existing
[function notebook](../../notebooks/function_analysis.jl) and
[convergence notebook](../../notebooks/derivative_convergence.jl) add plotting
and step-size experiments; they are not new execution gates of this tutorial.
[Execution record](../../reports/m10d6/tutorial_implementation_report.md).
