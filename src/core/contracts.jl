"""Supertype for reusable mathematical analysis results."""
abstract type AbstractAnalysis end

# Deliberate Float64 backend boundaries must not silently discard caller precision.
# Callers can explicitly round first with Float64(x) when that approximation is wanted.
function _checked_float64(x, argument; allow_infinite=false)
    x isa Real && !isnan(x) || throw(ArgumentError("$argument must be real and not NaN"))
    if !isfinite(x)
        allow_infinite && return Float64(x)
        throw(ArgumentError("$argument must be finite"))
    end
    y = try Float64(x) catch
        throw(ArgumentError("$argument must be representable in Float64"))
    end
    isfinite(y) && x == y || throw(ArgumentError(
        "$argument loses range or precision in Float64; explicitly round before this Float64-only path"))
    y
end

"""
    PropertyResult(value, status, method, notes; metadata=nothing)

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
Optional NamedTuple metadata describes the result without changing scientific
value equality/hashing. It must not silently retain a large source; statistical
summaries store only detached origin and bounded semantic context there.
"""
struct PropertyResult{T}
    value::T
    status::Symbol
    method::Symbol
    notes::Vector{String}
    metadata::Union{Nothing,NamedTuple}
end
PropertyResult(value,status::Symbol,method::Symbol,notes::Vector{String};metadata=nothing)=
    PropertyResult{typeof(value)}(value,status,method,notes,metadata)
PropertyResult{T}(value,status,method,notes) where {T}=
    PropertyResult{T}(value,status,method,notes,nothing)

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
