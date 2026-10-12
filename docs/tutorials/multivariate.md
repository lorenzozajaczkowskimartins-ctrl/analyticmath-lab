# Multivariate calculus: gradients, curvature and a minimum

[Learning path](index.md) · Previous: [scalar analysis](calculus.md) ·
Next: [vector calculus](vector-calculus.md)

Prerequisites: partial derivatives and small matrices. Difficulty: intermediate.
Dependencies: AnalyticMathLab and Symbolics in the checkout project.
Executable: [multivariate.jl](scripts/multivariate.jl). From the repository root:

```sh
julia +1.12.7 --project=. docs/tutorials/scripts/multivariate.jl
```

## Problem and assumptions

Study the dimensionless smooth scalar field

$$f(x,y)=x^2+xy+2y^2,\qquad (x,y)\in\mathbb R^2.$$

The tuple `(x,y)` fixes the meaning of points, derivative vectors and matrices.
`(1,2)` means $x=1,y=2$, not an unordered collection. Direct differentiation gives

$$\nabla f=\begin{pmatrix}2x+y\\x+4y\end{pmatrix},\qquad
H=\begin{pmatrix}2&1\\1&4\end{pmatrix}.$$

For displacement $d$, the first-order change is $\nabla f\cdot d$;
the gradient points toward fastest increase under the Euclidean metric.
The Hessian describes how the gradient changes. Taylor's expansion reads

$$f(a+d)=f(a)+\nabla f(a)^T d+\tfrac12 d^T H(a)d+o(\|d\|^2).$$

Here the remainder vanishes identically. Solving the two linear stationarity
equations gives only $(0,0)$. Sylvester's criterion establishes positive
definiteness: the leading principal minors are 2 and 7. Independently,

$$f(x,y)=(x+y/2)^2+\tfrac74 y^2.$$

This is strictly positive away from the origin. Here the local Hessian argument
extends to a unique global minimum because the whole function is this quadratic.
A positive Hessian at one point of a nonlinear field does not imply global convexity.

## Implementation

A variable tuple selects `ScalarFieldAnalysis`, even for a one-element tuple.
`gradient(field)` and `hessian(field)` return formal expressions; point overloads
evaluate cached derivatives. Stationary discovery is a separate `PropertyResult`:
inspect its status/method and each candidate's local classification evidence.

```julia
using AnalyticMathLab, Symbolics

@variables x y
field = analyze(x^2 + x*y + 2y^2, (x, y))
zero_identity(e) = iszero(Symbolics.simplify(Symbolics.expand(e)))
@assert field.variables == (x, y)
@assert all(zero_identity, gradient(field) - [2x+y, x+4y])
@assert all(zero_identity, hessian(field) - [2 1; 1 4])
@assert gradient(field, (1, 2)) == [4, 9]
@assert hessian(field, (1, 2)) == [2 1; 1 4]
@assert evaluate(field, (1, 2)) == 11
@assert domain_contains(field.domain, (0, 0)) === true
@assert field.stationary_points.status == :established
point = only(field.stationary_points.value)
@assert collect(point.point) == [0, 0]
@assert point.classification == :minimum_candidate
@assert point.classification_evidence.status == :established
# At this quadratic's origin the second-order expansion is the whole function.
@assert zero_identity(field.expression - ((x+y/2)^2 + 7y^2/4))
println((gradient_at_1_2=gradient(field, (1, 2)), hessian=hessian(field, (1, 2)),
    stationary=point.point, classification=point.classification,
    search_status=field.stationary_points.status, method=field.stationary_points.method))
println("MULTIVARIATE_OK")
```

## Verification and observed results

EXACT_IDENTITY: componentwise symbolic differences check the gradient, Hessian
and completed-square identity. ANALYTICAL_REFERENCE: at $(1,2)$ the gradient is
`[4,9]`, value 11 and Hessian the matrix above. These small, exactly representable
integer evaluations are checked independently of AML's candidate solver.

EXAMPLE_EXECUTED: the stored point was `Rational{BigInt}[0,0]`, discovery status
`:established`, method `:exact_linear_system`, and classification
`:minimum_candidate` with established symbolic definiteness evidence. This is
AML's actual vocabulary; the interpretation follows from the independent
positive-definiteness argument, not a renamed label.

No approximate root search is needed for this exact linear gradient. Other
expressions may use bounded heuristic search or return unknown completeness.
A zero Hessian eigenvalue makes the second-order test inconclusive; it does not
establish a flat family of minima.

## Domain and computational limitations

`domain_contains(field.domain,(0,0))` was checked true. Polynomial smoothness
on $\mathbb R^2$ follows independently from the model. For expressions with
exclusions, membership alone may not establish an open smooth neighborhood
suitable for derivative classification; preserve original syntax when it matters.

SOURCE_INSPECTED: public symbolic scalar-field analysis accepts 1 through 32
ordered variables; exactly 32 passes the dimension guard. This is not a general
large-scale symbolic Hessian capability. Symbolic construction can still be
expensive; no high-dimensional construction is run here.

Proceed to [vector-valued maps](vector-calculus.md) and
[potential energy in mechanics](mechanics.md). The existing
[multivariable notebook](../../notebooks/multivariable_analysis.jl) explores saddles
and domain exclusions, separately from this page's execution evidence.
[Execution record](../../reports/m10d6/tutorial_implementation_report.md).
