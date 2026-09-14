# Vector Field Analysis — Milestone 5

The supported object is a real map `F: R^n → R^m`, not a dynamical system.
Input and output dimensions are independently validated (1–32 each).

```julia
using AnalyticMathLab, Symbolics
@variables x y z
rotation = analyze([-y, x], (x,y))
evaluate(rotation, (1.0,2.0))       # [-2,1]
jacobian(rotation)                  # [0 -1; 1 0], formal symbolic matrix
jacobian(rotation, (1.0,2.0))       # stored numerical derivatives
linearization(rotation, (1,2))     # expression, base_point, value, coefficients
divergence(rotation).value         # 0
curl(rotation).value               # 2
rotation.field_zeros                # PropertyResult of field-zero candidates
rotation.conservative              # established false
potential(rotation)                # unknown (no potential constructed)
```

`analyze` accepts an `AbstractVector` or tuple of scalar real components and a
tuple/vector of independent Symbolics variables. Existing scalar dispatch is
unchanged. Strings, nested arrays, unbound parameters, empty components, repeated
variables, and invalid controls are rejected. No mode flag is needed.

## Stored result and numerical contracts

`VectorFieldAnalysis <: AbstractAnalysis` contains `components`,
`original_components`, `variables`, `input_dimension`, `output_dimension`,
`jacobian_expression`, a concrete `numerical` bundle of compiled component and
Jacobian-entry callables, `domain`, `component_domains`, `field_zeros`,
`divergence`, `curl`, `conservative`, and `potential`.

Each derivative is generated once with Symbolics, with `J[i,j] = ∂F_i/∂x_j`.
Evaluation uses the cached callables and returns fresh vectors/matrices; it does
not rerun symbolic analysis. Arithmetic follows the underlying generated scalar
operations, including Float32, Float64, rational, and BigFloat arithmetic where
supported. Ordinary machine-integer evaluation is not an arbitrary-precision
arithmetic guarantee. Domain constraints use the existing bounded BigInt checks.

Point dimension must be n; coordinates and results must be finite real values.
Known exclusions raise `DomainError`. As in scalar-field evaluation, unknown
membership is not automatically rejected by `evaluate`, but does not certify
validity. Numerical `jacobian` and `linearization` require known membership and
the sufficient componentwise open-smooth-neighborhood gate. This deliberately
rejects unresolved syntax, square-root boundaries, and absolute-value corners,
even when simplification erased the nonsmooth original expression.

`linearization` returns the m-vector `F(a) + J(a)(x-a)` with its m×n coefficient
matrix, base point, and field value. It carries no nonlinear stability claim.
`jacobian(report)` returns formal symbolic derivatives and does not certify
boundary differentiability. Symbolic arrays and evidence accessor results are
copied; stored report arrays and `Expr` objects remain mutable, read-only by
convention. Use qualified names, e.g. `AnalyticMathLab.jacobian`, if another
imported package offers a same-named generic.

## Original-domain intersection

Reuse the existing capture mechanism rather than a second wrapper/macro:

```julia
hole = analyze(@real_function([(x^2-1)/(x-1), y]), (x,y))
domain_contains(hole.domain, (1,0)) # false
```

Literal vectors (`[...]`, including scalar semicolon entries) and tuples can be
split into original component syntax. A captured container variable or unsupported
container expression cannot be safely decomposed: domain information stays
unknown rather than being reconstructed from simplified components. Plain
component input preserves only the expression trees that actually reach analyze.
Caller-supplied `original_expression=[original1, original2, ...]` must correspond
to the components; semantic equivalence is a caller trust contract.

Every component uses `MultivariateDomain`. Their intersection retains all known
restrictions; one unknown component cannot silently become unrestricted R^n.
Independent exclusions still reject points in partial domains. For example,
`[sqrt(1-x^2-y^2), log(x-y)]` imposes both `x^2+y^2 <= 1` and `x-y > 0`.
No general semialgebraic solver or arbitrary source evaluation is introduced.

## Divergence and curl evidence

Both accessors return `PropertyResult(value,status,method,notes)`, including
unsupported cases. For square maps divergence is the trace of the Jacobian.
For a 2D square field, `curl(report).value` is the scalar `∂Q/∂x - ∂P/∂y`.
For a 3D square field it is the three-vector
`[∂R/∂y-∂Q/∂z, ∂P/∂z-∂R/∂x, ∂Q/∂x-∂P/∂y]`.
Curl in other dimensions is unknown/unsupported. Rectangular maps have no
standard divergence, curl, or gradient-potential interpretation here.

Established symbolic operator results describe formal identities on the smooth
locus of the original domain; they do not establish smoothness everywhere or
extend the domain through holes. Numerical Jacobian calls retain the stronger
explicit smoothness gate.

## Field zeros, not stability

`field_zeros` is evidence about `F(x)=0`. Each internal `FieldZero` record stores
`point`, `value`, `residual_norm`, and `residual_threshold`. It has no stability
classification or eigenvalue-based theorem.

The existing exact system machinery handles nonsingular square affine systems
with exact rational coefficients and square coordinate-separable rational
polynomials whose roots are completely enumerated by the bounded exact engine.
All exact candidates must pass original membership, finite evaluation, residual
acceptance, and exact symbolic component substitution. Known excluded roots are
removed. An unverifiable candidate downgrades completeness to unknown.
Singular/nonisolated families and unsupported systems remain unknown, not empty
certified zero sets. Exact rectangular solving is not implemented.

Explicit `bounds=((a1,b1),...)` enables heuristic multistart Newton only when exact
solving is unsupported and the original domain is established. The scalar-field
solver loop is reused with F/J callbacks, not copied. Rectangular searches use
Julia's matrix-backslash step (least-squares/minimum-norm as applicable), followed
by verification of every component residual. Neither least-squares stationarity
nor solver termination alone qualifies as a zero.

Defaults: `grid=7`, `iterations=40`, `residual_tolerance=1e-8`,
`residual_rtol=0`, `residual_scale=1`. Grid range is 2–25, iterations 1–200,
and the Cartesian seed budget is 50,000. Bounds are finite increasing pairs.
Acceptance requires finite
`norm(F(point)) <= residual_tolerance + residual_rtol*residual_scale`.
The scale is caller-supplied; tolerance/scale must be positive finite, relative
tolerance nonnegative finite, and the effective threshold finite.

Search points stay within bounds. Candidate deduplication and Newton stopping
retain the existing scalar solver tolerances. A numerical result is always
heuristic, even if empty; no exhaustive enumeration, exact-zero proof,
root-position error bound, or dynamical conclusion follows. Exact studies remain
global even if bounds are supplied. Resource-budget exhaustion does not silently
launch a numerical fallback.

## Conservativity and potential reconstruction

Only exact rational-coefficient polynomial fields of total degree at most 8 are
currently eligible for potential construction. A conservative syntax gate also
requires an established original domain with supported open smooth syntax;
unsupported topology is never settled by observing zero curl.

Construction uses the polynomial radial formula
`φ(x) = ∫₀¹ sum(x_i F_i(t*x)) dt`, evaluated by finite exact Taylor coefficients,
not numerical quadrature. Every candidate is differentiated in every variable and
simplified against the corresponding component. Only exact zero differences
establish both the potential and `conservative.value === true`. The additive
constant is omitted. The polynomial extension restricts to the original domain;
no holes are filled. A nonzero polynomial mixed-partial obstruction on an
unrestricted domain can establish `conservative=false`. Restricted-domain
obstructions without a witness, nonpolynomial fields, or failed construction
remain unknown. This deliberately leaves some decidable cases unresolved.

The potential degree/syntax checks are conservative local limits, not a global
runtime sandbox. Symbolics construction, expansion, differentiation, compilation,
and affine elimination retain the architectural resource limitations documented
in `architecture.md`.

Mandatory topology regression:

```julia
punctured = analyze(@real_function([-y/(x^2+y^2), x/(x^2+y^2)]), (x,y))
curl(punctured).value              # 0 on the smooth punctured domain
punctured.conservative.status      # :unknown, NOT established true
potential(punctured).status        # :unknown
domain_contains(punctured.domain,(0,0)) # false
```

No single-valued potential is claimed on the punctured plane. Zero curl is never
a substitute for constructing and verifying a global potential.

## Rectangular maps and visualization

`analyze([x+y,x-y,x^2],(x,y))` has a 3×2 Jacobian, three-component evaluation and
linearization, and unknown/unsupported square-field operators. It is not plotted
as a 2D vector field by dropping its third component.

```julia
using CairoMakie                    # explicitly selected by the caller
fig = vectorplot(rotation; xrange=(-2,2),yrange=(-2,2),samples=15,arrowscale=0.12)
save("rotation.png",fig)
```

`vectorplot` and `plot` return a Makie Figure for R²→R² fields. Samples are 2–50
per axis, scales positive finite. Arrows are unnormalized; the explicit scale
preserves direction and relative magnitude. Sampling uses only stored field
callables. Unknown/invalid anchors are omitted before evaluation; membership is
checked at the actual rendered Float32 anchor to avoid rounding onto an exclusion.
Nonfinite/unrepresentable arrows are omitted. Arrow shafts are glyphs, not
trajectories or domain-contained paths. Rendering adds no mathematical evidence,
mutates no report data, and activates no backend.

Run `julia --project=. notebooks/vector_field_analysis.jl` for rotation, radial,
punctured-plane, and rectangular examples. It asserts the mathematical results
before loading CairoMakie and saves the three valid 2D arrow figures.

Streamlines, 3D arrows, automatic norm diagnostics, line/surface integrals,
ODEs, phase portraits, stability theory, integral theorems, forms, tensors, and
PDEs are outside this milestone. A possible Milestone 6 is explicitly scoped
line integrals and path-domain validation; no implementation is started here.
