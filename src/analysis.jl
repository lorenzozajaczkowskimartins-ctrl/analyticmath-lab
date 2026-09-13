
"""
    FunctionAnalysis <: AbstractAnalysis

Analysis of a scalar expression in one independent variable. Symbolic results
are stored as mathematical objects, independently of their presentation.
Use [`analyze`](@ref) to construct a report.
"""
struct FunctionAnalysis{E,V,D1,D2,N,C,R} <: AbstractAnalysis
    expression::E
    variable::V
    first_derivative::D1
    second_derivative::D2
    numerical::N
    critical_points::C
    real_analysis::R
end

# Preserve the public six-argument constructor for numerical-only reports.
FunctionAnalysis(e, v, d1, d2, n, c) = FunctionAnalysis(e, v, d1, d2, n, c, nothing)

"""A numerical stationary-point candidate with its derivative residual and curvature."""
struct CriticalPoint{T<:Real}
    x::T
    value::T
    residual::T
    second_derivative::T
    classification::Symbol
end

"""
    CriticalPointAnalysis

Bounded stationary-point search data. `status` is `:not_requested`, `:heuristic`,
or `:nonisolated` (identically zero derivative wherever the expression is defined).
An empty heuristic result is not proof of absence. `rejected_candidates` counts
solver candidates rejected by the derivative-residual check. `rejections` stores
their positions, residuals, thresholds, and reasons (`:residual_exceeded`).
Acceptance means `abs(f′(x)) <= effective_residual_tolerance`, where the threshold
is `residual_tolerance + residual_relative_tolerance * residual_scale`.
The scale is caller-supplied in derivative units, not inferred from samples.
The default relative tolerance is zero, preserving absolute-only acceptance.

`points` and `rejections` are report-owned vectors of immutable records. Library
operations do not mutate them; treat them as read-only and copy before editing.
The legacy six-argument constructors retain absolute-only semantics. For legacy
reports with a nonzero rejection count, `rejections === nothing` denotes missing
historical details; no candidate records are invented. Results from `analyze`
always contain a rejection vector whose length agrees with the count.
"""
struct CriticalPointAnalysis{I}
    points::Vector{CriticalPoint{Float64}}
    interval::I
    status::Symbol
    method::Symbol
    residual_tolerance::Float64
    rejected_candidates::Int
    residual_relative_tolerance::Float64
    residual_scale::Float64
    effective_residual_tolerance::Float64
    rejections::Union{Nothing,Vector{NamedTuple{(:x, :residual, :threshold, :reason),
                                               Tuple{Float64,Float64,Float64,Symbol}}}}
end

function CriticalPointAnalysis{I}(points, interval, status, method, tolerance,
                                  rejected) where {I}
    rejections = rejected == 0 ? NamedTuple{(:x, :residual, :threshold, :reason),
        Tuple{Float64,Float64,Float64,Symbol}}[] : nothing
    return CriticalPointAnalysis{I}(points, interval, status, method, tolerance,
                                    rejected, 0.0, 1.0, tolerance, rejections)
end

function CriticalPointAnalysis(points, interval::I, status, method, tolerance,
                               rejected) where {I}
    return CriticalPointAnalysis{I}(points, interval, status, method, tolerance, rejected)
end

"""
    DerivativeComparison

Numerical derivative values from symbolic evaluation, ForwardDiff, and FiniteDiff
central differences. `absolute_errors` are discrepancies from the evaluated
symbolic reference, not rigorous error bounds or independent symbolic proofs.
"""
struct DerivativeComparison{T,V,E} <: AbstractAnalysis
    point::T
    reference_method::Symbol
    values::V
    absolute_errors::E
end

function Base.show(io::IO, report::FunctionAnalysis)
    print(io, "FunctionAnalysis(", report.expression, ", ", report.variable,
          "; critical_points=", report.critical_points.status, ")")
end

function Base.show(io::IO, ::MIME"text/plain", report::FunctionAnalysis)
    println(io, "AnalyticMathLab — Function Analysis")
    println(io, "  f(", report.variable, ") = ", report.expression)
    println(io, "  First derivative:  ", report.first_derivative)
    println(io, "  Second derivative: ", report.second_derivative)
    result = report.critical_points
    print(io, "  Critical points: ", result.status)
    if !isnothing(result.interval)
        print(io, " on ", result.interval)
    end
    if result.status == :heuristic
        print(io, " (stationary candidates only; not exhaustive)")
    elseif result.status == :nonisolated
        print(io, " (zero derivative wherever defined)")
    end
    print(io, "\n  Search method: ", result.method)
    if result.status == :heuristic
        print(io, "\n  Solver candidates: accepted=", length(result.points),
              ", rejected=", result.rejected_candidates)
        print(io, "\n  Residual threshold: ", result.effective_residual_tolerance,
              " (absolute=", result.residual_tolerance,
              ", relative=", result.residual_relative_tolerance,
              ", scale=", result.residual_scale, ")")
    end
    for point in result.points
        print(io, "\n    x=", point.x, ", f(x)=", point.value, ", ",
              point.classification, ", |f′(x)|=", point.residual)
    end
    if report.real_analysis !== nothing
        println(io)
        show(io, MIME"text/plain"(), report.real_analysis)
    end
end
