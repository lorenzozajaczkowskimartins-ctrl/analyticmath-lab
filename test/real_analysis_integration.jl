using Test, AnalyticMathLab, Symbolics
import Makie
@variables integration_x

@testset "Real study public integration" begin
    report = analyze(integration_x^2, integration_x)
    @test hasproperty(report, :real_analysis)
    if hasproperty(report, :real_analysis)
        @test report.real_analysis isa RealFunctionStudy
        @test report.real_analysis.roots.value == [0//1]
        @test report.real_analysis.intercepts.value.y == 0
        @test report.real_analysis.continuity.value.continuous_on_domain
        @test all(isconcretetype, fieldtypes(typeof(report)))
        captured = analyze(@real_function((integration_x^2-1)/(integration_x-1)), integration_x)
        @test domain_contains(captured.real_analysis.domain, 1) === false
        @test captured.real_analysis.roots.value == [-1//1]
        @test isempty(captured.real_analysis.asymptotes.value.vertical)
        @test captured.real_analysis.symmetry.value == :neither
        erased = analyze(@real_function(integration_x/integration_x), integration_x)
        @test domain_contains(erased.real_analysis.domain, 0) === false
        @test erased.real_analysis.intercepts.value.y === nothing
        @test evaluate(erased, 2) == 1
        legacy = FunctionAnalysis(report.expression, report.variable, report.first_derivative,
            report.second_derivative, report.numerical, report.critical_points)
        @test legacy.real_analysis === nothing
        @test evaluate(legacy, 2) == 4
        text = sprint(show, MIME"text/plain"(), captured)
        @test occursin("Real Function Study", text)
        @test occursin("established", text)
        @test occursin("removable", text)
        @test occursin("exact_algebra", text)
        bounded = analyze(integration_x^2-2, integration_x; interval=(-2,2))
        @test bounded.real_analysis.roots.status == :heuristic
        @test bounded.real_analysis.roots.method == :bounded_root_search
        @test bounded.real_analysis.roots.value ≈ [-sqrt(2),sqrt(2)]
        @test bounded.real_analysis.sign.status == :unknown
        @test bounded.critical_points.status == :heuristic
    end
end
