using Test
using AnalyticMathLab
using Symbolics
import Makie

@variables x

@testset "Analysis does not activate a backend" begin
    @test ismissing(Makie.current_backend())
    analyze(x^2, x)
    @test ismissing(Makie.current_backend())
    @test all(m -> nameof(m) != :CairoMakie, values(Base.loaded_modules))
end

@testset "Symbolic report" begin
    @test isdefined(AnalyticMathLab, :analyze)
    if isdefined(AnalyticMathLab, :analyze)
        f = x^3 - 6x^2 + 9x + 1
        report = analyze(f, x)
        @test report isa FunctionAnalysis
        @test isequal(report.expression, f)
        @test isequal(report.variable, x)
        @test iszero(Symbolics.simplify(report.first_derivative - (3x^2 - 12x + 9)))
        @test iszero(Symbolics.simplify(report.second_derivative - (6x - 12)))
    end
end

@testset "Reusable numerical evaluation" begin
    report = analyze(x^3 - 6x^2 + 9x + 1, x)
    @test isdefined(AnalyticMathLab, :evaluate)
    if isdefined(AnalyticMathLab, :evaluate)
        for t in (-2, 0.0, 1//2, 2.0, big"2.5")
            @test evaluate(report, t) ≈ t^3 - 6t^2 + 9t + 1
        end
        @test evaluate(report, 2.0; order=1) ≈ -3
        @test evaluate(report, 2.0; order=2) ≈ 0
        @test_throws ArgumentError evaluate(report, 2.0; order=3)
        @test evaluate(analyze(5, x), 2.0) == 5
        @test evaluate(analyze(5, x), 2.0; order=1) == 0
        @test evaluate(analyze(sin(x), x), 0.4) ≈ sin(0.4)
        @test evaluate(analyze(sin(x), x), 0.4; order=1) ≈ cos(0.4)
    end
end

@testset "Univariate input contract" begin
    @variables y
    @test_throws ArgumentError analyze(x + y, x)
    @test_throws ArgumentError analyze(x, x + 1)
    @test_throws ArgumentError analyze(x, Symbolics.Num(1))
end

@testset "Numerical inference and report reuse" begin
    report = analyze(x^3 - 6x^2 + 9x + 1, x; interval=(0, 4))
    numerical = report.numerical
    points = copy(report.critical_points.points)
    @test all(isconcretetype, fieldtypes(typeof(report)))
    for t in (2, 0.3f0, 0.3, 1//2, big"0.3")
        @test (@inferred evaluate(report, t)) isa typeof(t)
        @test (@inferred evaluate(report, t; order=1)) ≈ 3t^2 - 12t + 9
        @test (@inferred evaluate(report, t; order=2)) ≈ 6t - 12
    end
    @test (@inferred compare_derivatives(report, 0.3)) isa DerivativeComparison
    @test evaluate.(Ref(report), [0.0, 1.0, 2.0]) ≈ [1, 5, 3]
    sprint(show, MIME"text/plain"(), report)
    @test report.numerical === numerical
    @test report.critical_points.points == points
    @test analyze(x^2, x; interval=(-1, 1)).critical_points.points !== report.critical_points.points
    @test isnan(evaluate(analyze(log(x), x), -1.0))
    for tolerance in (0, -1, Inf, NaN)
        @test_throws ArgumentError analyze(x^2, x; residual_tolerance=tolerance)
    end
end

@testset "Bounded stationary-point search" begin
    @test hasproperty(analyze(x^2, x), :critical_points)
    if hasproperty(analyze(x^2, x), :critical_points)
        @test analyze(x^2, x).critical_points.status == :not_requested
        report = analyze(x^3 - 6x^2 + 9x + 1, x; interval=(0, 4))
        result = report.critical_points
        @test result.status == :heuristic
        @test result.interval == (0.0, 4.0)
        @test result.method == :roots_find_zeros
        @test getproperty.(result.points, :x) ≈ [1, 3]
        @test getproperty.(result.points, :value) ≈ [5, 1]
        @test getproperty.(result.points, :classification) == [:maximum_candidate, :minimum_candidate]
        @test all(p -> p.residual <= result.residual_tolerance, result.points)
        @test isempty(analyze(x, x; interval=(-2, 2)).critical_points.points)
        @test analyze(5, x; interval=(-2, 2)).critical_points.status == :nonisolated
        flat = analyze(x^4, x; interval=(-1, 1)).critical_points.points
        @test length(flat) == 1
        @test only(flat).classification == :undetermined
        boundary = analyze(x^2, x; interval=(0, 1)).critical_points.points
        @test length(boundary) == 1
        @test only(boundary).x == 0
        @test only(boundary).classification == :boundary_candidate
        for interval in ((2, 1), (0, 0), (-Inf, 1), (NaN, 1))
            @test_throws ArgumentError analyze(x^2, x; interval)
        end
        @test_throws ArgumentError analyze(x^2, x; interval=(-1, 1), residual_tolerance=-1)
        @test_throws DomainError analyze(log(x), x; interval=(-2, -1))
    end
end

@testset "Stationary search diagnostics" begin
    result = analyze(x^2, x; interval=(-1, 1), residual_rtol=1e-6,
                     residual_scale=2.0).critical_points
    @test result.residual_relative_tolerance == 1e-6
    @test result.residual_scale == 2.0
    @test result.effective_residual_tolerance ≈ 1e-8 + 2e-6
    @test isempty(result.rejections)
    @test result.rejected_candidates == length(result.rejections)
    rejected_report = analyze(sin(x), x; interval=(1, 2), residual_tolerance=1e-20)
    rejected = rejected_report.critical_points
    @test rejected.status == :heuristic
    @test isempty(rejected.points)
    @test rejected.rejected_candidates == length(rejected.rejections) == 1
    rejection = only(rejected.rejections)
    @test rejection.x ≈ pi / 2
    @test rejection.residual > rejection.threshold
    @test rejection.threshold == 1e-20
    @test rejection.reason == :residual_exceeded
    equal_threshold = analyze(sin(x), x; interval=(1, 2),
        residual_tolerance=rejection.residual).critical_points
    @test length(equal_threshold.points) == 1
    @test only(equal_threshold.points).residual == equal_threshold.effective_residual_tolerance
    small_scale = analyze(sin(x), x; interval=(1, 2), residual_tolerance=1e-20,
        residual_rtol=rejection.residual, residual_scale=0.5).critical_points
    large_scale = analyze(sin(x), x; interval=(1, 2), residual_tolerance=1e-20,
        residual_rtol=rejection.residual, residual_scale=2).critical_points
    @test small_scale.rejected_candidates == 1
    @test length(large_scale.points) == 1
    scaled = analyze(sin(x), x; interval=(1, 2), residual_tolerance=1e-20,
                     residual_rtol=1e-15, residual_scale=1).critical_points
    @test length(scaled.points) == 1
    @test only(scaled.points).classification == :maximum_candidate
    @test isempty(scaled.rejections)
    @test scaled.rejected_candidates == 0
    empty_report = analyze(x, x; interval=(-1, 1))
    @test isempty(empty_report.critical_points.points)
    @test isempty(empty_report.critical_points.rejections)
    @test empty_report.critical_points.status == :heuristic
    @test occursin("accepted=0, rejected=1", sprint(show, MIME"text/plain"(), rejected_report))
    @test occursin("accepted=0, rejected=0", sprint(show, MIME"text/plain"(), empty_report))
    @test occursin("roots_find_zeros", sprint(show, MIME"text/plain"(), rejected_report))
    @test occursin("Residual threshold", sprint(show, MIME"text/plain"(), rejected_report))
    for rtol in (-1, NaN, Inf)
        @test_throws ArgumentError analyze(x^2, x; residual_rtol=rtol)
    end
    for scale in (0, -1, NaN, Inf)
        @test_throws ArgumentError analyze(x^2, x; residual_scale=scale)
    end
    @test_throws ArgumentError analyze(x^2, x; residual_rtol=1e308, residual_scale=1e308)
    for expression in (x^2, 5)
        cp = analyze(expression, x).critical_points
        @test cp.status == :not_requested
        @test cp.method == :none
        @test cp.interval === nothing
        @test isempty(cp.rejections)
    end
    cp = analyze(5, x; interval=(-1, 1)).critical_points
    @test cp.status == :nonisolated
    @test cp.method == :symbolic_identity
    @test isempty(cp.rejections)
end

@testset "Legacy critical-point constructors" begin
    points = CriticalPoint{Float64}[]
    for make in (CriticalPointAnalysis, CriticalPointAnalysis{Nothing})
        cp = make(points, nothing, :not_requested, :none, 1e-8, 0)
        @test cp.points === points
        @test isempty(cp.rejections)
        @test cp.effective_residual_tolerance == 1e-8
        @test cp.residual_relative_tolerance == 0
    end
    cp = CriticalPointAnalysis(points, (0.0, 1.0), :heuristic, :roots_find_zeros, 1e-8, 2)
    @test cp.rejected_candidates == 2
    @test cp.rejections === nothing
end

@testset "Derivative method comparison" begin
    @test isdefined(AnalyticMathLab, :compare_derivatives)
    if isdefined(AnalyticMathLab, :compare_derivatives)
        report = analyze(x^3 - 6x^2 + 9x + 1, x)
        comparison = compare_derivatives(report, 2.0)
        @test comparison isa DerivativeComparison
        @test comparison.point == 2.0
        @test comparison.reference_method == :symbolic
        @test comparison.values.symbolic ≈ -3
        @test comparison.values.automatic ≈ -3
        @test comparison.values.central ≈ -3 atol=1e-7
        @test comparison.absolute_errors.automatic <= 1e-12
        @test comparison.absolute_errors.central <= 1e-7
        for expression in (sin(x), exp(x), 5, x^2)
            c = compare_derivatives(analyze(expression, x), 0.3)
            @test c.values.automatic ≈ c.values.symbolic atol=1e-12
            @test c.values.central ≈ c.values.symbolic atol=1e-7
        end
        @test_throws DomainError compare_derivatives(report, Inf)
        @test_throws DomainError compare_derivatives(analyze(log(x), x), -1.0)
    end
end

@testset "Display is a view of structured data" begin
    report = analyze(x^2, x; interval=(-1, 1))
    before = evaluate(report, 2.0)
    text = sprint(show, MIME"text/plain"(), report)
    @test occursin("Function Analysis", text)
    @test occursin("First derivative", text)
    @test occursin("Second derivative", text)
    @test occursin("heuristic", text)
    @test occursin("minimum_candidate", text)
    @test !occursin("RuntimeGeneratedFunction", text)
    @test evaluate(report, 2.0) == before
    @test !isempty(sprint(show, report))
    mktemp() do _, io
        redirect_stdout(io) do
            analyze(x^2, x)
        end
        flush(io)
        @test filesize(io) == 0
    end
end

include("architecture.jl")
include("vector_fields.jl")
include("vector_calculus.jl")
include("vector_zeros.jl")
include("vector_regressions.jl")
include("dynamical_systems.jl")
include("trajectories.jl")
include("dynamical_regressions.jl")
include("mechanics.jl")
include("mechanics_dynamics.jl")
include("mechanics_readiness.jl")
include("normal_modes.jl")
include("mode_contracts.jl")
include("source_capture.jl")
include("real_analysis_core.jl")
include("real_analysis_integration.jl")
include("real_analysis_visualization.jl")

# Multivariate analysis and its backend-independence checks run before CairoMakie.
include("multivariate_analysis.jl")
include("multivariate_visualization.jl")
include("multivariate_regressions.jl")

# Run convergence's backend-independence checks before it imports CairoMakie.
include("convergence.jl")
include("vector_visualization.jl")
include("dynamical_visualization.jl")
include("mechanics_visualization.jl")
include("normal_modes_visualization.jl")

import CairoMakie

@testset "Makie view" begin
    @test isdefined(AnalyticMathLab, :plot)
    if isdefined(AnalyticMathLab, :plot)
        report = analyze(x^3 - 6x^2 + 9x + 1, x; interval=(0, 4))
        before = copy(report.critical_points.points)
        fig = plot(report; xmin=0, xmax=4, samples=101)
        @test fig isa Makie.Figure
        axis = only(filter(item -> item isa Makie.Axis, fig.content))
        @test count(p -> p isa Makie.Lines, axis.scene.plots) == 1
        @test count(p -> p isa Makie.Scatter, axis.scene.plots) == 1
        @test report.critical_points.points == before
        @test_throws ArgumentError plot(report; xmin=2, xmax=1)
        @test_throws ArgumentError plot(report; samples=1)
        @test plot(analyze(5, x); xmin=-1, xmax=1) isa Makie.Figure
        @test plot(analyze(log(x), x); xmin=-1, xmax=2) isa Makie.Figure
        mktempdir() do dir
            path = joinpath(dir, "analysis.png")
            CairoMakie.save(path, fig)
            @test filesize(path) > 1000
            @test open(io -> read(io, 8), path) == UInt8[0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]
        end
    end
end
