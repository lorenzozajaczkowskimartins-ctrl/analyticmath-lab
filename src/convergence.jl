"""
    DerivativeConvergenceAnalysis <: AbstractAnalysis

Stored Float64 finite-difference experiment, independent of callables/backends.
`reference` is the evaluated symbolic first derivative, not an exact error oracle.
`relative_errors` contains `absolute_errors / abs(reference)` elementwise, or
`nothing` where the reference is zero or the ratio overflows Float64. Near-zero
references can make relative discrepancies ill-conditioned; no epsilon is added.
Steps run from largest to smallest. `best_step` selects the first sampled minimum
(ties favor the larger step), not an optimized or guaranteed optimal step.
Vectors are result-owned; library views do not mutate them. Treat them as read-only.
`order_indices` identifies the samples used for `observed_order`; empty means no
stable region was found. An observed order is empirical, never a theoretical label.
The eligible region ends at the first plateau, increase, or zero error. Select
the earliest three consecutive positive finite local log slopes whose deviations
from their mean are all at most 10% of that mean, extending while this remains
true. The returned order is the mean over that window (at least four samples).
Later decreasing regions are deliberately ignored, even if they look stable.
"""
struct DerivativeConvergenceAnalysis{E,V} <: AbstractAnalysis
    expression::E
    variable::V
    point::Float64
    method::Symbol
    reference::Float64
    steps::Vector{Float64}
    approximations::Vector{Float64}
    absolute_errors::Vector{Float64}
    relative_errors::Vector{Union{Nothing,Float64}}
    best_step::Float64
    minimum_error::Float64
    observed_order::Union{Nothing,Float64}
    order_indices::Vector{Int}
end

"""
    derivative_convergence(report::FunctionAnalysis, x;
        method=:central, hmin=1e-12, hmax=1e-1, samples=45)

Sweep logarithmically spaced, decreasing Float64 steps using `(f(x+h)-f(x))/h`
for `:forward`, or `(f(x+h)-f(x-h))/(2h)` for `:central`. All arithmetic and stored
numerical data are Float64, including conversion of other real input types.
The symbolic derivative is evaluated once; absolute discrepancies are not rigorous
error bounds. No symbolic analysis is repeated and the input report is unchanged.
The expression must be smooth on the sampled stencil; no domain or smoothness
proof is attempted. Invalid controls and unrepresentable stencil offsets raise
ArgumentError, as does an overflowing central denominator `2h`; nonfinite
evaluations and domain failures raise DomainError.
Only offsets used by the chosen formula are checked (`x+h` for forward, both
`x+h` and `x-h` for central).
"""
function derivative_convergence(report::FunctionAnalysis, x::Real;
                                method=:central, hmin::Real=1e-12,
                                hmax::Real=1e-1, samples::Integer=45)
    point = Float64(x)
    lo, hi = Float64(hmin), Float64(hmax)
    method in (:forward, :central) || throw(ArgumentError("method must be :forward or :central"))
    isfinite(point) || throw(ArgumentError("point must be finite in Float64"))
    isfinite(lo) && isfinite(hi) && 0 < lo < hi ||
        throw(ArgumentError("steps must satisfy finite 0 < hmin < hmax in Float64"))
    method == :central && !isfinite(2hi) &&
        throw(ArgumentError("central denominator 2h must be finite in Float64"))
    samples >= 3 || throw(ArgumentError("samples must be at least 3"))
    steps = exp10.(range(log10(hi), log10(lo); length=samples))
    steps[1], steps[end] = hi, lo
    all(diff(steps) .< 0) || throw(ArgumentError("steps must be distinct in Float64"))
    f = report.numerical.function_value
    base = Float64(_finite_real(f(point)))
    reference = Float64(_finite_real(report.numerical.first_derivative(point)))
    _finite_real(base)
    _finite_real(reference)
    approximations = Vector{Float64}(undef, length(steps))
    for (i, h) in pairs(steps)
        plus, minus = point + h, point - h
        isfinite(plus) && plus > point || throw(ArgumentError("x+h must be finite and distinguishable from x"))
        if method == :central
            isfinite(minus) && minus < point || throw(ArgumentError("x-h must be finite and distinguishable from x"))
        end
        upper = Float64(_finite_real(f(plus)))
        lower = method == :central ? Float64(_finite_real(f(minus))) : base
        _finite_real(upper)
        _finite_real(lower)
        approximation = method == :central ? (upper - lower) / (2h) : (upper - lower) / h
        approximations[i] = _finite_real(approximation)
    end
    errors = abs.(approximations .- reference)
    foreach(_finite_real, errors)
    relative_errors = Union{Nothing,Float64}[
        iszero(reference) || !isfinite(error / abs(reference)) ? nothing : error / abs(reference)
        for error in errors
    ]
    best = argmin(errors)
    order, indices = _convergence_order(steps, errors)
    return DerivativeConvergenceAnalysis(report.expression, report.variable, point,
        method, reference, steps, approximations, errors, relative_errors, steps[best], errors[best],
        order, indices)
end

"""
Select an empirical order without assuming a method's theoretical rate.
Only the initial strictly decreasing, positive-error prefix is eligible: stop
at the first plateau, increase, or zero (and never pass the first minimum).
Find the earliest window of three consecutive positive finite local log slopes
whose maximum deviation from their mean is at most 10% of that mean. Extend it
while that same criterion holds for the entire window; return its mean and sample
indices. Fewer than three stable slopes yields `nothing` and empty indices.
This deliberately conservative heuristic can miss a later asymptotic regime.
"""
function _convergence_order(steps::Vector{Float64}, errors::Vector{Float64})
    stop = 1
    while stop < length(errors) && 0 < errors[stop + 1] < errors[stop]
        stop += 1
    end
    slopes = [log(errors[i + 1] / errors[i]) / log(steps[i + 1] / steps[i]) for i in 1:(stop - 1)]
    for start in 1:(length(slopes) - 2)
        last = start + 2
        _stable_convergence_slopes(@view slopes[start:last]) || continue
        while last < length(slopes) && _stable_convergence_slopes(@view slopes[start:(last + 1)])
            last += 1
        end
        selected = @view slopes[start:last]
        return sum(selected) / length(selected), collect(start:(last + 1))
    end
    return nothing, Int[]
end

function _stable_convergence_slopes(slopes)
    all(s -> isfinite(s) && s > 0, slopes) || return false
    average = sum(slopes) / length(slopes)
    return all(s -> abs(s - average) <= 0.1average, slopes)
end

function Base.show(io::IO, result::DerivativeConvergenceAnalysis)
    print(io, "DerivativeConvergenceAnalysis(", result.method, ", x=", result.point,
          "; samples=", length(result.steps), ", minimum_error=", result.minimum_error, ")")
end

function Base.show(io::IO, ::MIME"text/plain", result::DerivativeConvergenceAnalysis)
    println(io, "AnalyticMathLab — Derivative Convergence (Float64)")
    println(io, "  f(", result.variable, ") = ", result.expression)
    println(io, "  Method: ", result.method, "; point: ", result.point)
    println(io, "  Symbolic reference (evaluated): ", result.reference)
    println(io, "  Sampled minimum absolute error: ", result.minimum_error,
            " at h=", result.best_step)
    print(io, "  Observed order: ", isnothing(result.observed_order) ? "unavailable" : result.observed_order,
          "; sample indices: ", result.order_indices)
end
