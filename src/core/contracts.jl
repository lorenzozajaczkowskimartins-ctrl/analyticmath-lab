"""Supertype for reusable mathematical analysis results."""
abstract type AbstractAnalysis end

"""
    PropertyResult(value, status, method, notes)

A structured mathematical claim with evidence separate from its algorithm.
`:established` means established within the stated supported class/assumptions;
`:heuristic` means numerical evidence without completeness or certification;
`:unknown` means no conclusion (possibly retaining verified partial candidates).
An empty value establishes absence only when the status and claim warrant it.
`method` records how the result was obtained, not how certain it is.

Constructors and Symbol-valued statuses remain permissive for compatibility.
Domain `:partial` and legacy search `:not_requested`/`:nonisolated` have specialized
contracts; they are not additional confidence levels. Notes and value vectors
are result-owned mutable data: consumers must not mutate them.
"""
struct PropertyResult{T}
    value::T
    status::Symbol
    method::Symbol
    notes::Vector{String}
end

# Numerical experiments validate results without imposing real-study semantics.
function _finite_real(value)
    value isa Real && isfinite(value) ||
        throw(DomainError(value, "expected a finite real numerical value"))
    return value
end

# Shared acceptance convention, not a root-position error bound. Keep the
# caller-supplied derivative scale independent of observations and classifications.
function _residual_controls(tolerance, rtol, scale)
    tol = Float64(tolerance)
    isfinite(tol) && tol > 0 || throw(ArgumentError("residual_tolerance must be finite and positive"))
    relative, derivative_scale = Float64(rtol), Float64(scale)
    isfinite(relative) && relative >= 0 ||
        throw(ArgumentError("residual_rtol must be finite and nonnegative"))
    isfinite(derivative_scale) && derivative_scale > 0 ||
        throw(ArgumentError("residual_scale must be finite and positive"))
    threshold = tol + relative * derivative_scale
    isfinite(threshold) || throw(ArgumentError("effective residual tolerance must be finite"))
    return (tolerance=tol, relative=relative, scale=derivative_scale, threshold=threshold)
end
