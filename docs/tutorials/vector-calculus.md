# Vector calculus: rotation, divergence and potentials

[Learning path](index.md) · Previous: [multivariate calculus](multivariate.md) ·
Next: [mechanics](mechanics.md)

Prerequisites: partial derivatives and line integrals. Difficulty: intermediate.
Dependencies: AnalyticMathLab and Symbolics; no rendering backend required.
Executable: [vector_calculus.jl](scripts/vector_calculus.jl). From the repository root:

```sh
julia +1.12.7 --project=. docs/tutorials/scripts/vector_calculus.jl
```

## Problem and coordinate conventions

A vector field assigns a vector to each point. Take the dimensionless planar map
$F(x,y)=(-y,x)$ on all of $\mathbb R^2$. Components are ordered $(F_x,F_y)$;
variables are ordered $(x,y)$. The Jacobian has component rows and variable columns:

$$J_{ij}=\frac{\partial F_i}{\partial x_j},\qquad
J=\begin{pmatrix}0&-1\\1&0\end{pmatrix}.$$

For this linear map, the Jacobian describes the whole field, not only a local
approximation. Divergence is its trace,
$\nabla\cdot F=\partial_x F_x+\partial_y F_y=0$.
This is local flux balance, not absence of flow. AML's square planar curl is

$$\operatorname{curl}_{2D}F=\partial_x F_y-\partial_y F_x=2,$$

corresponding to the out-of-plane component of a three-dimensional embedding,
not a two-component vector. Nonzero curl rules out a smooth potential $F=\nabla\phi$
here, since mixed second partial derivatives of such a potential would agree.
In contrast $G=(2x,2y)$ is the gradient of $\phi=x^2+y^2$ on $\mathbb R^2$.

## Implementation

`analyze` accepts ordered scalar components and independent variables.
`evaluate` returns a fresh vector; `jacobian` a matrix. `divergence`, `curl` and
`potential` return four-field `PropertyResult` objects (`value`, `status`,
`method`, `notes`), not bare numbers.

```julia
using AnalyticMathLab, Symbolics

@variables x y
rotation = analyze([-y, x], (x, y))
@assert rotation.variables == (x, y)
@assert evaluate(rotation, (1, 2)) == [-2, 1]
@assert jacobian(rotation) == [0 -1; 1 0]
@assert jacobian(rotation, (1, 2)) == [0 -1; 1 0]
@assert divergence(rotation).status == :established
@assert divergence(rotation).value == 0
@assert curl(rotation).status == :established
@assert curl(rotation).value == 2
@assert rotation.conservative.value === false
@assert potential(rotation).status == :unknown

radial = analyze([2x, 2y], (x, y))
@assert curl(radial).value == 0
@assert radial.conservative.value === true
phi = potential(radial)
@assert phi.status == :established
@assert iszero(Symbolics.simplify(Symbolics.expand(phi.value - x^2 - y^2)))
println((rotation_value=evaluate(rotation, (1, 2)), jacobian=jacobian(rotation),
    divergence=divergence(rotation).value, planar_curl=curl(rotation).value,
    rotation_potential_status=potential(rotation).status, radial_potential=phi.value))
println("VECTOR_CALCULUS_OK")
```

## Verification and interpretation

EXACT_IDENTITY / ANALYTICAL_REFERENCE: differentiating the linear components
gives the displayed Jacobian, divergence 0 and curl 2.
EXAMPLE_EXECUTED: formal and point-evaluated Jacobians matched exactly;
at $(1,2)$ the field was `[-2,1]`. Divergence and curl were established.
The rotation's conservative value was false and potential status unknown.
These are distinct claims: no potential was constructed, rather than a potential
with value zero. The radial field's established potential simplified to $x^2+y^2$.

An analytical circulation check gives further meaning: on the unit circle
$r(\theta)=(\cos\theta,\sin\theta)$, $F(r)=r'$ and $F(r)\cdot r'=1$,
so $\oint F\cdot dr=2\pi$. This is a mathematical derivation, not an executed
line-integral computation or an advertised AML line-integral API.

## Local identities versus global conclusions

Zero curl alone is not a global potential certificate on an arbitrary domain.
For example $(-y/(x^2+y^2),x/(x^2+y^2))$ is curl-free on the punctured plane
but has nonzero circulation around the excluded origin. A global potential needs
additional domain/topology assumptions. Our radial example has an explicitly
constructed polynomial potential, stronger evidence than sampled zero curl.

SOURCE_INSPECTED: rectangular Jacobians are supported for maps
$\mathbb R^n\to\mathbb R^m$; divergence/curl have narrower conventions.
This page executes only planar square fields. Mathematics requires no CairoMakie
backend or optional rendering.

Continue to [potential energy and forces](mechanics.md). See the existing
[vector-field guide](../vector_fields.md) and
[notebook](../../notebooks/vector_field_analysis.jl) for topology and rectangular
examples, not new runtime evidence of this page.
[Execution record](../../reports/m10d6/tutorial_implementation_report.md).
