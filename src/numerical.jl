"""
    evaluate(report::FunctionAnalysis, x::Number; order=0)

Evaluate the stored numerical callable for the expression (`order=0`), first
or second derivative. No symbolic differentiation is repeated. Broadcasting
`evaluate.(Ref(report), xs)` evaluates a collection of points. Domain errors
from the underlying mathematical functions propagate to the caller. Generated
callables may use NaNMath and return NaN instead (for example, log at a negative
real input); evaluation preserves these values rather than inferring a domain.
"""
function evaluate(report::FunctionAnalysis, x::Number; order::Integer=0)
    order == 0 && return report.numerical.function_value(x)
    order == 1 && return report.numerical.first_derivative(x)
    order == 2 && return report.numerical.second_derivative(x)
    throw(ArgumentError("order must be 0, 1, or 2"))
end


function _interval_bounds(interval::Tuple{Real,Real})
    a, b = Float64.(interval)
    isfinite(a) && isfinite(b) && a < b ||
        throw(ArgumentError("interval endpoints must be finite and strictly increasing"))
    return a, b
end

function _critical_points(numerical, first, interval, tolerance, rtol=0, scale=1)
    controls = _residual_controls(tolerance, rtol, scale)
    tol, relative, derivative_scale, threshold = controls
    points = CriticalPoint{Float64}[]
    rejections = NamedTuple{(:x, :residual, :threshold, :reason),
                           Tuple{Float64,Float64,Float64,Symbol}}[]
    isnothing(interval) && return CriticalPointAnalysis(points, nothing, :not_requested,
        :none, tol, 0, relative, derivative_scale, threshold, rejections)
    a, b = _interval_bounds(interval)
    _finite_real(numerical.function_value(a))
    _finite_real(numerical.function_value(b))
    if iszero(Symbolics.simplify(first))
        return CriticalPointAnalysis(points, (a, b), :nonisolated, :symbolic_identity,
            tol, 0, relative, derivative_scale, threshold, rejections)
    end
    derivative(t) = _finite_real(numerical.first_derivative(t))
    candidates = Roots.find_zeros(derivative, a, b)
    rejected = 0
    for t in candidates
        residual = abs(derivative(t))
        if residual > threshold
            rejected += 1
            push!(rejections, (x=Float64(t), residual=Float64(residual),
                               threshold=threshold, reason=:residual_exceeded))
            continue
        end
        value = _finite_real(numerical.function_value(t))
        curvature = _finite_real(numerical.second_derivative(t))
        classification = if t == a || t == b
            :boundary_candidate
        elseif abs(curvature) <= sqrt(eps(Float64))
            :undetermined
        elseif curvature > 0
            :minimum_candidate
        else
            :maximum_candidate
        end
        push!(points, CriticalPoint(Float64(t), Float64(value), Float64(residual),
                                    Float64(curvature), classification))
    end
    return CriticalPointAnalysis(points, (a, b), :heuristic, :roots_find_zeros,
        tol, rejected, relative, derivative_scale, threshold, rejections)
end

"""
    compare_derivatives(report::FunctionAnalysis, x::Real)

Compare the first derivative evaluated symbolically with automatic differentiation
and FiniteDiff central differences at a finite real point. FiniteDiff chooses its
default step size. The function must be smooth and defined in a neighborhood of
`x`; no automatic domain or differentiability proof is attempted. This returns
new structured data without modifying the report. Absolute discrepancies use
the symbolic derivative as a reference, which is not guaranteed exact numerically.
"""
function compare_derivatives(report::FunctionAnalysis, x::Real)
    point = float(_finite_real(x))
    f = report.numerical.function_value
    _finite_real(f(point))
    symbolic = _finite_real(report.numerical.first_derivative(point))
    automatic = _finite_real(ForwardDiff.derivative(f, point))
    central = _finite_real(FiniteDiff.finite_difference_derivative(f, point, Val(:central)))
    values = (; symbolic, automatic, central)
    errors = (automatic=abs(automatic - symbolic), central=abs(central - symbolic))
    return DerivativeComparison(point, :symbolic, values, errors)
end
