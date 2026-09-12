using Test
using AnalyticMathLab
using Symbolics
import Makie

@testset "Convergence order and diagnostics" begin
    @variables order_x
    for (method, expected) in ((:forward, 1.0), (:central, 2.0))
        result = derivative_convergence(analyze(sin(order_x), order_x), 0.4;
                                        method, hmin=1e-3, hmax=1e-1, samples=9)
        @test result.observed_order !== nothing
        if result.observed_order !== nothing
            @test result.observed_order ≈ expected atol=0.08
            @test length(result.order_indices) >= 4
            @test all(diff(result.order_indices) .== 1)
            i = result.order_indices
            slopes = diff(log.(result.absolute_errors[i])) ./ diff(log.(result.steps[i]))
            @test result.observed_order ≈ sum(slopes)/length(slopes)
        end
        @test occursin("Derivative Convergence", sprint(show, MIME"text/plain"(), result))
        @test occursin(string(method), sprint(show, result))
        @test !occursin("RuntimeGeneratedFunction", sprint(show, MIME"text/plain"(), result))
    end
    report = analyze(sin(order_x), order_x)
    @test length(derivative_convergence(report, 0.4).steps) == 45
    @test (@inferred derivative_convergence(report, 0.4f0)).point isa Float64
    @test (@inferred derivative_convergence(report, 2//5)).point isa Float64
    @test (@inferred derivative_convergence(report, big"0.4")).point isa Float64
    few = derivative_convergence(report, 0.4; samples=3)
    @test few.observed_order === nothing
    @test isempty(few.order_indices)
    exact = derivative_convergence(analyze(5, order_x), 0.0)
    @test all(iszero, exact.absolute_errors)
    @test exact.observed_order === nothing
    @test isempty(exact.order_indices)
    @test exact.best_step == first(exact.steps)
    for method in (:backward, :bad, "central", nothing)
        @test_throws ArgumentError derivative_convergence(report, 0.4; method)
    end
    for point in (Inf, -Inf, NaN, big"1e400")
        @test_throws ArgumentError derivative_convergence(report, point)
    end
    for hmin in (0, -1, Inf, NaN, 0.1, 1, big"1e-400")
        @test_throws ArgumentError derivative_convergence(report, 0.4; hmin)
    end
    for hmax in (0, -1, Inf, NaN, 1e-13)
        @test_throws ArgumentError derivative_convergence(report, 0.4; hmax)
    end
    for samples in (-1, 0, 1, 2)
        @test_throws ArgumentError derivative_convergence(report, 0.4; samples)
    end
    for method in (:forward, :central)
        @test_throws ArgumentError derivative_convergence(report, 1.0; method, hmin=1e-20)
    end
    @test_throws ArgumentError derivative_convergence(report, 0.0; hmin=1.0, hmax=nextfloat(1.0), samples=8)
    @test_throws DomainError derivative_convergence(analyze(log(order_x), order_x), -1.0)
    @test_throws DomainError derivative_convergence(analyze(log(order_x), order_x), 0.01; hmax=0.1)
    @test_throws DomainError derivative_convergence(analyze(sqrt(order_x), order_x), 0.0)
    @test_throws DomainError derivative_convergence(analyze(exp(order_x), order_x), 1000.0)
    forward_log = derivative_convergence(analyze(log(order_x), order_x), 0.01;
                                         method=:forward, hmax=0.1)
    @test all(isfinite, forward_log.approximations)
end

@variables convergence_x

@testset "Relative discrepancies with explicit unavailable values" begin
    for expression in (sin(convergence_x), -sin(convergence_x))
        result = derivative_convergence(analyze(expression, convergence_x), 0.4)
        @test hasproperty(result, :relative_errors)
        if hasproperty(result, :relative_errors)
            @test result.relative_errors == result.absolute_errors ./ abs(result.reference)
        end
    end
    for expression in (5, convergence_x^2)
        result = derivative_convergence(analyze(expression, convergence_x), 0.0)
        @test hasproperty(result, :relative_errors)
        if hasproperty(result, :relative_errors)
            @test all(isnothing, result.relative_errors)
        end
    end
    tiny = derivative_convergence(analyze(1e-310convergence_x + convergence_x^3,
                                         convergence_x), 0.0)
    @test hasproperty(tiny, :relative_errors)
    if hasproperty(tiny, :relative_errors)
        @test all(isfinite, tiny.relative_errors)
    end
    overflow = derivative_convergence(analyze(1e-310convergence_x + 100convergence_x^3,
                                             convergence_x), 0.0)
    @test hasproperty(overflow, :relative_errors)
    if hasproperty(overflow, :relative_errors)
        @test first(overflow.relative_errors) === nothing
        @test last(overflow.relative_errors) isa Float64
    end
end

@testset "Central denominator must be representable" begin
    report = analyze(convergence_x / 1e308, convergence_x)
    @test_throws ArgumentError derivative_convergence(report, 0.0;
        hmin=1e307, hmax=1e308, samples=5)
    forward = derivative_convergence(report, 0.0; method=:forward,
        hmin=1e307, hmax=1e308, samples=5)
    @test all(isfinite, forward.approximations)
end

@testset "Order selection excludes cancellation and unstable slopes" begin
    hs = exp10.(-collect(0.0:7.0))
    for errors in ([1.0, 0.5, 0.01, 0.009, 0.00001, 0.000009, 1e-8, 9e-9],
                   [1.0, 2, 0.1, 0.01, 0.001, 0.0001, 0.00001, 0.000001],
                   ones(8), zeros(8))
        order, indices = AnalyticMathLab._convergence_order(hs, errors)
        @test order === nothing
        @test isempty(indices)
    end
    errors = [1.0, 0.01, 0.0001, 1e-6, 1e-4, 1e-6, 1e-8, 1e-10]
    order, indices = AnalyticMathLab._convergence_order(hs, errors)
    @test order ≈ 2
    @test indices == [1, 2, 3, 4]
    zero_tail = [1.0, 0.01, 0.0001, 1e-6, 0, 0, 0, 0]
    @test AnalyticMathLab._convergence_order(hs, zero_tail)[2] == [1, 2, 3, 4]
end

@testset "Convergence controlled steps, without a backend" begin
    @test ismissing(Makie.current_backend())
    @test all(m -> nameof(m) != :CairoMakie, values(Base.loaded_modules))
    @test isdefined(AnalyticMathLab, :derivative_convergence)
    if isdefined(AnalyticMathLab, :derivative_convergence)
        report = analyze(sin(convergence_x), convergence_x)
        numerical = report.numerical
        points = copy(report.critical_points.points)
        central = @inferred derivative_convergence(report, 0.4; hmin=1e-3, hmax=1e-1, samples=9)
        forward = @inferred derivative_convergence(report, 0.4; method=:forward, hmin=1e-3, hmax=1e-1, samples=9)
        @test central isa AbstractAnalysis
        @test central isa DerivativeConvergenceAnalysis
        @test isequal(central.expression, report.expression)
        @test isequal(central.variable, report.variable)
        @test central.point === 0.4
        @test central.method == :central
        @test forward.method == :forward
        @test central.reference == cos(0.4)
        @test length(central.steps) == 9
        @test first(central.steps) ≈ 1e-1
        @test last(central.steps) ≈ 1e-3
        @test all(diff(central.steps) .< 0)
        @test all(isapprox.(diff(log10.(central.steps)), -0.25))
        @test central.approximations == [(sin(0.4+h)-sin(0.4-h))/(2h) for h in central.steps]
        @test forward.approximations == [(sin(0.4+h)-sin(0.4))/h for h in forward.steps]
        @test central.absolute_errors == abs.(central.approximations .- central.reference)
        @test all(central.absolute_errors .< forward.absolute_errors)
        @test central.best_step == central.steps[argmin(central.absolute_errors)]
        @test central.minimum_error == minimum(central.absolute_errors)
        @test report.numerical === numerical
        @test report.critical_points.points == points
        @test !hasproperty(central, :numerical)
        @test !hasproperty(central, :report)
        @test ismissing(Makie.current_backend())
        @test all(m -> nameof(m) != :CairoMakie, values(Base.loaded_modules))
    end
end

import CairoMakie

@testset "Stored reference evaluated once; presentation never evaluates" begin
    source = analyze(sin(convergence_x), convergence_x)
    function_calls, derivative_calls = Ref(0), Ref(0)
    numerical = (
        function_value=t -> (function_calls[] += 1; source.numerical.function_value(t)),
        first_derivative=t -> (derivative_calls[] += 1; source.numerical.first_derivative(t)),
        second_derivative=source.numerical.second_derivative,
    )
    report = FunctionAnalysis(source.expression, source.variable, source.first_derivative,
        source.second_derivative, numerical, source.critical_points)
    for method in (:forward, :central)
        function_calls[] = derivative_calls[] = 0
        result = derivative_convergence(report, 0.4; method, samples=9)
        @test derivative_calls[] == 1
        @test function_calls[] == (method == :central ? 19 : 10)
        @test result.reference == evaluate(source, 0.4; order=1)
        calls = (function_calls[], derivative_calls[])
        @test plot(result) isa Makie.Figure
        sprint(show, MIME"text/plain"(), result)
        @test (function_calls[], derivative_calls[]) == calls
    end
end

@testset "Stored convergence log-log view" begin
    @variables plot_x
    for result in (derivative_convergence(analyze(sin(plot_x), plot_x), 0.4),
                   derivative_convergence(analyze(5, plot_x), 0.0),
                   derivative_convergence(analyze(plot_x^2, plot_x), 0.0; method=:central))
        before = (copy(result.steps), copy(result.approximations), copy(result.absolute_errors), copy(result.relative_errors), copy(result.order_indices))
        backend = Makie.current_backend()
        figure = plot(result)
        @test figure isa Makie.Figure
        @test Makie.current_backend() === backend
        axis = only(filter(item -> item isa Makie.Axis, figure.content))
        @test axis.xscale[] === log10
        @test axis.yscale[] === log10
        @test occursin("minimum", lowercase(axis.subtitle[]))
        if all(iszero, result.absolute_errors)
            @test occursin("zero", lowercase(axis.subtitle[]))
            @test !any(p -> p isa Makie.Lines, axis.scene.plots)
        else
            line = only(filter(p -> p isa Makie.Lines, axis.scene.plots))
            @test length(line[1][]) == count(>(0), result.absolute_errors)
            @test all(p -> p[2] > 0, line[1][])
        end
        @test before == (result.steps, result.approximations, result.absolute_errors, result.relative_errors, result.order_indices)
        mktempdir() do directory
            path = joinpath(directory, "convergence.png")
            CairoMakie.save(path, figure)
            @test filesize(path) > 1000
            @test open(io -> read(io, 8), path) == UInt8[0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]
        end
    end
end
