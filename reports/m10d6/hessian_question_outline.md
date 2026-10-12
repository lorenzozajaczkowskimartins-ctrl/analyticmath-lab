# M10D.6A — Which 3000-dimensional Hessian route?

Evidence: SOURCE_INSPECTED at HEAD `377a3c45905d0e16dba1fc2adc9d8eb3dcff14ca`. No scientific workflow or tests were executed for this audit. This is a completed source-derived question outline, not a proposed new API.

## 1. Does scalar-field analyze support 3000 variables?

No. `analyze(expression::Real, variables::Union{Tuple,AbstractVector}; ...)` first calls `_mv_variables`, which requires **1 through 32 inclusive**. With 3000 variables it throws `ArgumentError("between 1 and 32 variables are supported")` before gradient/Hessian construction. Source: `src/multivariate_analysis.jl:35-47,283-303`. Existing test: `test/multivariate_regressions.jl:44-46` uses 33 variables; it does not execute a 3000-variable construction.

**Exactly 32 variables are accepted by this guard**, not rejected. With otherwise valid inputs, all symbolic gradient and dense Hessian entries and numerical derivative callables are built at lines 298-303. Domain/exact-solver budgets and bounded-grid product checks occur later (304-321), so they are not a preallocation memory guard for 32-variable analysis. No `max_memory_bytes`, `memory_budget`, sparse Hessian, Hessian-vector-product or derivative-only keyword is present on this public signature. The fixed variable limit is internal policy, not a user-set budget.

## 2. Is a supplied 3000 by 3000 matrix supported by normal_modes?

This is a different route: `normal_modes(K::AbstractMatrix,M::AbstractMatrix; max_memory_bytes=512*1024^2, ...)`. It accepts supplied stiffness/Hessian and mass matrices; it does not construct a Hessian from an expression. Shape is checked and `24*sizeof(Float64)*big(n)^2` is compared to the public byte budget **before coefficient traversal, metadata copies and dense conversion**. The default rejects n=3000. Exact arithmetic for storage is recorded in `refusals.json`.

The refusal is `ArgumentError("normal_modes full dense solve n=$n estimates $estimated_bytes bytes (including workspace), exceeding max_memory_bytes=$max_memory_bytes; use a structured/partial eigensolver when only a few modes are required, or explicitly raise the budget.")`. A caller can explicitly raise `max_memory_bytes`, but this authorizes a full dense Float64 solve, not a peak-RSS guarantee or a sparse solver. Caller input matrices, symbolic graphs and arbitrary metadata are not bounded by the estimate. Sources: `src/mechanics/normal_modes.jl:149-186,196-253`. Existing tests: `test/m10c_partial_modes.jl:4-17` includes n=3000 with an explicit 1024-byte budget and a coefficient-access trap at typemax(Int); it is not a default-budget 3000 solve test.

## 3. What if the input is an atomistic snapshot?

`normal_modes(snapshot; hessian=H, kwargs...)` needs a **caller-supplied** particle-major Cartesian Hessian, positions and positive masses. n = particles * dimension; 1000 particles in 3D is a 3000-coordinate matrix. Without H the result is structured unknown, not automatic differentiation. It does not certify equilibrium (`equilibrium_status=:not_verified`). The bridge validates/traverses H and creates scaled `kn` before forwarding to the matrix route; the matrix-route preflight therefore does **not** protect all adapter allocations. Source: `src/atomistic/modes.jl:16-50`.

`normal_modes(mechanics_report, equilibrium; kwargs...)` also builds a mechanical linearization before reaching the matrix route. Do not generalize the direct matrix preflight to all upstream symbolic/adapter work (`src/mechanics/normal_modes.jl:31-77,265-279`).

## 4. Is partial_chain a public alternative?

No. The existing `ControlledModes.partial_chain` is a maintained, controlled chain experiment in `examples/scaling/partial_modes.jl`, optionally included by `test/m10c_partial_modes.jl:20-48`; it is not an exported generic AML partial-Hessian API. A structured/partial external eigensolver can be an appropriate method, but its integration is caller work. Sparse inputs to public `normal_modes(K,M)` still take the full dense route. Do not recommend nonexistent `normal_modes(...; k=...)`, `hessian(...; sparse=true)` or a generic public memory-budget API.

## Wiki targets (proposed, not written)

- Scalar-fields / Supported dimensions and derivative construction.
- Normal-modes / Dense memory preflight and explicit byte control.
- Atomistic-analysis / Supplied Cartesian Hessian and unit scaling.
- Scaling / Maintainer-only controlled partial spectra.
- Errors-and-status / Resource refusal versus unknown scientific evidence.

## Remaining verification boundaries

No fresh test pass, allocation measurement, peak RSS, or large eigensolve is claimed. A bounded follow-up test could prove exact-32 acceptance and allocation ordering; the source order already establishes that the dimension check alone does not reject 32. Adapter-preflight behavior is a documentation caveat and candidate future hardening item, not a change made here.
