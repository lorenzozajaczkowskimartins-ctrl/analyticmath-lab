# Real core contract

`_real_analysis(expression, variable, first_derivative, second_derivative; interval=nothing, original=expression)` returns `RealFunctionStudy <: AbstractAnalysis`.

Fields: original_expression and simplified_expression (parametric storage); domain::RealDomain; roots, intercepts, sign, continuity, limits, monotonicity, extrema, concavity, inflections, asymptotes, symmetry (each PropertyResult).

`PropertyResult{T}`: value::T, status::Symbol (:established, :heuristic, or :unknown), method::Symbol, notes::Vector{String}. Unknown value is nothing. Never plot unknown as established absence. Vectors are result-owned and treated as read-only by library operations.
`RealInterval`: left::Real, right::Real, left_closed::Bool, right_closed::Bool. Finite endpoints Rational{BigInt}; unbounded endpoints -Inf / Inf (Float64 infinity only, never approximate finite roots).
`RealDomain`: components::Vector{RealInterval}, status::Symbol, method::Symbol, notes::Vector{String}.
`domain_contains(domain,x)` returns Bool for established domains, nothing if unknown.

Value schemas:
- roots: vector exact Real values (zero function uses a RealDomain for nonisolated zeros; periodic functions may use PeriodicPointSet).
- intercepts: (x=roots.value, y=exact value or nothing when 0 excluded).
- sign: vector (interval::RealInterval, sign::Int [-1,0,1]); zero points separately in roots.
- monotonicity: vector (interval, direction::Symbol [:increasing,:decreasing,:constant]).
- concavity: vector (interval, direction::Symbol [:convex,:concave,:affine]).
- extrema: vector (x, value, classification::Symbol [:minimum,:maximum]); local extrema, endpoints may included.
- inflections: vector (x,value); sign-change proof and original domain membership required.
- limits: vector (at::Real, side::Symbol [:left,:right,:both], kind::Symbol [:finite,:positive_infinity,:negative_infinity,:does_not_exist,:unknown], value [exact finite value or nothing]). Missing domain approach yields does_not_exist.
- continuity: (continuous_on_domain::Bool, discontinuities=vector (x,classification::Symbol [:removable,:pole,:boundary,:unknown])).
- asymptotes: (vertical=vector Real, horizontal=vector (side::Symbol [:negative_infinity,:positive_infinity],value), slant=vector (side,slope,intercept)).
- symmetry: :even, :odd, :both (zero), or :neither; original domain must be symmetric.

The package includes `real_analysis.jl` after AbstractAnalysis is defined; it includes `real_analysis_domain.jl`, `real_analysis_transforms.jl`, and `real_analysis_periodic.jl` itself. Public exports: PropertyResult, RealInterval, RealDomain, RealFunctionStudy, PeriodicPointSet, PeriodicIntervalSet, domain_contains. `analyze` stores the study at `report.real_analysis`; six-argument legacy FunctionAnalysis construction stores nothing instead.

Periodic schemas (sin(x) is completely established):
- PeriodicPointSet: parametric offset and period; means offset + k*period, k ∈ ℤ.
- PeriodicIntervalSet: parametric left, right, period, plus left_closed::Bool, right_closed::Bool; all integer translates. Sign/monotonicity/concavity rows use this instead of RealInterval. Extrema/inflection `x` uses PeriodicPointSet instead of a scalar.
- Exact periodic constants are Symbol(:π) or unevaluated Expr such as :(π/2). Never `eval` these; skip periodic decorations or explicitly interpret the tiny known arithmetic vocabulary for presentation.

Supported certificate class: exact integer/rational coefficients, arithmetic + - * / // and bounded integer powers (|exponent| ≤ 32 for algebra). Root completeness is established by rational-root factorization with an optional residual quadratic whose discriminant is negative, or a quadratic with rational square discriminant. Rational-root divisor enumeration is bounded (integer coefficients up to 10^8); exceeding it returns unknown. In particular x²-2 roots and 1/(x²-2) domain deliberately remain unknown in v1. A polynomial's continuity can still be established when its roots are unknown. No approximate root is ever labeled established.

Outer sqrt(rational) and log(rational) use exact chain-rule sign identities, exact original-domain inequalities, transformed limits, and rational-growth asymptotic identities. Original domains are walked recursively; unsupported composed inequalities return unknown rather than pretending to solve them. No samples are called proof without complete exact numerator/denominator roots first: exact rational cell representatives determine sign only after root completeness proves sign invariance on each cell. Derivative expressions passed by the parent are deliberately not trusted as certificates: rational derivatives are recomputed exactly.

`interval` does not restrict this global exact study. Unresolved roots can use a bounded Float64 fallback on established original-domain components, with status=:heuristic and method=:bounded_root_search. Empty searches never prove absence; numerical roots do not certify other properties. Parent numerical critical-point search keeps its existing smooth-interval contract. Limits list all finite original-domain component boundaries plus reachable infinities, not every ordinary interior point. Extrema are strict local extrema, including one-sided included sqrt-domain endpoints; constant plateaux have no strict extrema. A zero function has roots.value::RealDomain. Domain evidence empty components with status unknown must not be interpreted as an empty domain.

Finite transformed values may be unevaluated exact Expr such as log(2), sqrt(2); slant sqrt asymptote slopes/intercepts can also be Expr. For ordinary rational representatives they are Rational{BigInt}. Sine method=:analytic_identity; algebra method=:exact_algebra; unknown method=:unsupported.

Resource exhaustion uses status=:unknown and method=:resource_budget for the domain and properties. A shared per-study task-local budget bounds dense degree (64), projected coefficient bits (4096), cumulative work (200000), and original syntax nodes/depth (512/48). It applies across exact parsing, domain inference, derivative/parity intermediates and root calculations. No numerical fallback runs after budget exhaustion. This is an internal real-core budget, not a bound on caller expression construction or Symbolics derivative generation.

Standalone verification command: `julia --project=. test/real_analysis_core.jl`. The canonical `test/runtests.jl` includes core, capture, integration, and visualization tests. Display and plotting consume stored results without mathematical inference. Plotting skips periodic/unevaluated symbolic decorations rather than evaluating syntax.
