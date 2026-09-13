# Architecture and API contracts (Milestone 4.5)

Milestone 4.5 reorganizes the Milestones 1–4 implementation, without adding a
mathematical domain or changing public exports, result layouts, or constructors.
There is one public module, `AnalyticMathLab`. Internal source paths and `_ra_*` /
`_mv_*` helpers are not public APIs. No vector-field implementation is present.

## Dependency direction and source ownership

All package includes are explicit in `src/AnalyticMathLab.jl`, in this order:

1. `src/core/contracts.jl`: `AbstractAnalysis`, `PropertyResult`, finite-real
   validation, and shared absolute/relative residual controls.
2. `src/core/expressions.jl`: `RealExpression`, `@real_function`, and AST/operator
   normalization. Historical `_ra_ast`/`_mv_ast` and `_ra_op`/`_mv_op` names alias
   the same normalization functions; they do not merge the domain vocabularies.
3. `src/core/exact_algebra.jl`: bounded rational-polynomial arithmetic, parsing,
   factorization, syntax preflight, and resource accounting. Historical `_ra_*`
   names remain internal for minimal refactoring churn.
4. `src/analysis.jl`: univariate result containers and display;
   `src/real_analysis.jl`, `src/real_analysis_domain.jl`,
   `src/real_analysis_transforms.jl`, `src/real_analysis_periodic.jl`, and
   `src/real_analysis_display.jl`: specialized real-domain inference and evidence.
5. `src/multivariate_domain.jl`: original-syntax restrictions and membership;
   `src/multivariate_analysis.jl`: scalar-field reports, derivatives, smoothness
   gates, stationary solving, classification, and display.
6. `src/numerical.jl`: legacy evaluation, stationary search, derivative comparison;
   `src/symbolic.jl`: univariate Symbolics orchestration;
   `src/convergence.jl`: controlled finite-difference experiments and display.
7. `src/visualization/real.jl`, `src/visualization/plots.jl`, and
   `src/visualization/scalar_fields.jl`: Makie consumers of stored reports.

The shared core depends on neither study type nor numerical experiment nor
presentation. Multivariate restrictions can load with the core and Symbolics,
without loading `RealFunctionStudy`, scalar solvers, or Makie. Scalar stationary
solving reuses the core rational engine, not the univariate study pipeline.
Convergence consumes `FunctionAnalysis` and finite-value validation, not real
function certificates. Domain walkers remain specialized: interval unions in
one variable and syntax constraints in multiple variables have different
semantics and should not be forced under a generic abstract domain.

Includes are centralized, but runtime function calls may refer to functions
introduced by later includes. Importing the public module loads all prerequisites;
individual subsystem files are not standalone public entry points. The isolated
core fixture in `test/architecture.jl` explicitly lists its prerequisites.

## Public dispatch and compatibility

- `analyze(expression::Real, variable::Symbolics.Num)` returns `FunctionAnalysis`.
  Symbolics scalar numbers are included in `Real`. A `RealExpression` wrapper
  forwards the preserved syntax through the corresponding scalar method.
- `analyze(expression::Real, variables::Union{Tuple,AbstractVector})` selects
  `ScalarFieldAnalysis`, including a one-element variable collection. Variables
  are validated and retained in order. A collection of variables does not make
  the expression vector-valued. Vector expressions have no `analyze` method.
- `evaluate`, `gradient`, `hessian`, `directional_derivative`, and `linearization`
  dispatch on the stored report type. Symbolic gradient/Hessian access returns
  copies; numerical access reuses compiled callables.
- `plot`, `surface`, and `contour` extend the imported Makie functions, rather
  than creating competing generics. `gradient` and `hessian` are package-owned;
  qualify them as `AnalyticMathLab.gradient` / `AnalyticMathLab.hessian` when
  another imported package exports the same names. No broad fallback methods
  are added to third-party types.
- Existing result field layouts and permissive constructors remain intact,
  including six-argument `FunctionAnalysis` and `CriticalPointAnalysis`
  compatibility constructors. No status enum or new mandatory fields are added.

`test/architecture.jl` checks the complete export set, Makie binding identity,
scalar dispatch, inference on representative numerical paths, and ambiguities
across AnalyticMathLab, Symbolics, Makie, and LinearAlgebra. Only ambiguity pairs
with a method owned by AnalyticMathLab are failures; this is not a claim that all
third-party methods or every possible future package combination are unambiguous.

## Evidence, validation, and original domains

`PropertyResult(value, status, method, notes)` separates evidence from algorithm.
`:established` means established within the supported class and assumptions;
`:heuristic` does not certify completeness; `:unknown` gives no complete
conclusion, even when verified partial candidates are retained. An empty value
is not proof of absence unless the status and claim warrant it. Domain `:partial`
and legacy search `:not_requested` / `:nonisolated` retain specialized meanings.
Constructor acceptance of Symbol-valued statuses is unchanged.

Both stationary pipelines share the control validation for
`residual_tolerance + residual_rtol * residual_scale`: positive finite absolute
tolerance and scale, nonnegative finite relative tolerance, and finite effective
threshold. This is a residual acceptance test, not a root-position bound. Solver
algorithms, classification thresholds, and completeness claims stay specialized.

Capture original syntax before Symbolics cancels restrictions, using
`@real_function`. A plain Symbolics expression cannot reveal restrictions already
erased by construction. Caller-supplied `original_expression` must describe the
same mathematical expression and variable names; equivalence is trusted, not
proved. AST normalization never executes captured code. Restriction evaluation
uses a limited operation vocabulary, not Julia `eval`.

Original exclusions survive simplification. Partial multivariate domains reject
independently known exclusions even if another restriction cannot be resolved;
otherwise membership returns `nothing`, not `true`. Numerical scalar-field
derivatives, directional derivatives, and linearization require the existing
sufficient open-smooth-neighborhood gate. Formal symbolic derivatives do not
establish smoothness. Scalar-field evaluation rejects known exclusions and
nonfinite values, but unresolved membership is not proof of validity.

For compatibility, univariate `evaluate` still exposes the generated callable's
behavior (including cancellations and NaNMath results), and legacy stationary
search assumes smoothness across the supplied interval. Neither silently becomes
a checked-domain API. Check the stored real domain separately when needed.

## Resource and inference boundaries

The shared dense rational engine limits degree to 64, projected coefficient size
to 4096 bits, and scoped cumulative work to 200,000 units. Syntax preflight caps
512 nodes and depth 48; supported integer powers have magnitude at most 32.
Bounds precede expensive dense arithmetic; a dedicated budget exception becomes
explicit unknown/resource-budget evidence where handled by the study pipeline.
Exact integer/rational restriction arithmetic uses BigInt to prevent machine
wraparound. These are conservative implementation limits, not mathematical limits.

This is not a global computation sandbox. Symbolics expression construction,
derivative generation/compilation, exact affine-system elimination, and general
library routines are not all governed by the polynomial work counter. Scalar
search separately caps variables, seed counts, and Newton iterations as documented
in the README. Keep these limits scoped honestly rather than promising bounded
execution for arbitrary symbolic input.

Concrete compiled callables and parametric report fields preserve inference on
hot numerical paths. Symbolic orchestration, heterogeneous evidence, captured
syntax, and domain reasoning remain dynamic. `RealInterval` retains abstract
real endpoints for compatibility; real membership can show a wider inferred
union than the actual supported membership contract. Do not change public field
layouts or mathematical semantics just to eliminate inference coloring.

## Presentation and backend isolation

Analysis neither renders, prints, saves, nor activates a backend. The package
imports Makie, but does not import CairoMakie or GLMakie; callers choose a backend.
CairoMakie remains a project dependency for existing headless examples/tests.
Result objects contain no backend state. Plots reuse stored inference and
callables: curve/grid sampling is presentation, not new mathematical evidence.
Convergence plots use stored discrepancies without reevaluating the function.
Original-domain gaps and conservative scalar-field cell masks remain intact.

Structs are immutable but stored vectors and captured `Expr` objects are mutable.
Treat report-owned data as read-only or deep-copy it before editing. Display and
plotting must not mutate analyses. No generic immutability wrapper is introduced.

## Future extension boundary — design only

A future vector-field milestone would need an explicitly vector-valued input
method and a distinct result type, rather than widening the current scalar
`expression::Real` methods. It should compose shared contracts, capture original
syntax per component, preserve component restrictions and their intersection,
and define numerical/domain/evidence contracts before implementing operators.
Vector dimension and independent-variable dimension must be validated separately.
New views should consume that result, with their own narrow dispatch, and load
last without backend activation. Existing scalar methods and exports must keep
working; check cross-package ambiguities again before adding public names.

No `VectorFieldAnalysis`, vector operators, placeholder modules, traits, or
speculative public constructors are implemented or promised by Milestone 4.5.

## Verification and historical preservation

From the repository root:

```sh
julia --project=. -e "using Pkg; Pkg.test()"
julia --project=. -e "using AnalyticMathLab"
julia --project=. notebooks/function_analysis.jl
julia --project=. notebooks/derivative_convergence.jl
julia --project=. notebooks/real_function_analysis.jl
julia --project=. notebooks/multivariable_analysis.jl
```

The canonical runner includes architecture, source capture, real-core/integration,
scalar-field, domain-regression, convergence, and rendering tests. Backend-absence
checks execute before rendering imports. Architecture documentation paths and
centralized include ownership are also regression-tested. Generated outputs go
under ignored `notebooks/output/`, not into the source tree or public API.

The Python implementation remains at tag `python-v0.1` and branch `legacy-python`,
both rooted at `6820e97`. This milestone does not modify those refs or introduce
Python source copies. Work is committed locally; publishing and Milestone 5 are
outside this milestone.
