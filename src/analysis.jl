"""Supertype for reusable mathematical analysis results."""
abstract type AbstractAnalysis end

"""
    FunctionAnalysis <: AbstractAnalysis

Analysis of a scalar expression in one independent variable. Symbolic results
are stored as mathematical objects, independently of their presentation.
Use [`analyze`](@ref) to construct a report.
"""
struct FunctionAnalysis{E,V,D1,D2,N,C} <: AbstractAnalysis
    expression::E
    variable::V
    first_derivative::D1
    second_derivative::D2
    numerical::N
    critical_points::C
end

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
solver candidates rejected by the absolute derivative-residual check.

`points` is a report-owned vector of immutable candidates. Library operations
do not mutate it; callers should treat it as read-only and copy it before editing.
"""
struct CriticalPointAnalysis{I}
    points::Vector{CriticalPoint{Float64}}
    interval::I
    status::Symbol
    method::Symbol
    residual_tolerance::Float64
    rejected_candidates::Int
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
    for point in result.points
        print(io, "\n    x=", point.x, ", f(x)=", point.value, ", ",
              point.classification, ", |f′(x)|=", point.residual)
    end
end
