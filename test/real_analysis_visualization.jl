using Test, AnalyticMathLab, Symbolics
import Makie
@variables plot_x
@testset "Stored real study plotting" begin
    hole = analyze(@real_function(plot_x^3/plot_x), plot_x; interval=(-1,1))
    @test !isempty(hole.critical_points.points) # Keep legacy diagnostics.
    @test AnalyticMathLab._real_plot_points(hole, -1.0, 1.0) == (Float64[], Float64[])
    # Every finite feature shares the membership gate, not only legacy points.
    stored = hole.real_analysis
    fabricated = (domain=stored.domain,
        roots=PropertyResult([0,1//2],:established,:exact_algebra,String[]),
        extrema=PropertyResult([(x=0,value=0)],:established,:exact_algebra,String[]),
        inflections=stored.inflections)
    fixture = (critical_points=hole.critical_points, real_analysis=fabricated)
    @test AnalyticMathLab._real_plot_points(fixture,-1.0,1.0) == ([0.5],[0.0])
    unknown_domain = RealDomain(RealInterval[],:unknown,:unsupported,String[])
    unknown_fixture = merge(fixture,(real_analysis=merge(fabricated,(domain=unknown_domain,)),))
    @test 0.0 in first(AnalyticMathLab._real_plot_points(unknown_fixture,-1.0,1.0))
    gap = analyze(sqrt((plot_x^2-1)*(plot_x^2-4)), plot_x)
    gx, gy = AnalyticMathLab._real_plot_curve(gap, -3.0, 3.0, 2)
    for (left, right) in ((-2,-1),(1,2))
        @test any(i -> left <= gx[i] <= right && isnan(gy[i]), eachindex(gx))
    end
    backend = Makie.current_backend()
    report = analyze(@real_function((plot_x^2-1)/(plot_x-1)), plot_x)
    before = sprint(show, MIME"text/plain"(), report)
    @test isdefined(AnalyticMathLab, :_real_plot_curve)
    if isdefined(AnalyticMathLab, :_real_plot_curve)
        xs, ys = AnalyticMathLab._real_plot_curve(report, -2.0, 3.0, 10)
        @test any(isnan, ys)
        @test all(i -> !(xs[i] < 1 < xs[i+1]) || isnan(ys[i]) || isnan(ys[i+1]), 1:length(xs)-1)
        figure = plot(report; xmin=-2, xmax=3, samples=10)
        @test figure isa Makie.Figure
        @test isequal(backend, Makie.current_backend())
        @test before == sprint(show, MIME"text/plain"(), report)
        for e in (1/plot_x, sqrt(plot_x-2), log(plot_x-1))
            r = analyze(e, plot_x)
            xx, yy = AnalyticMathLab._real_plot_curve(r, -3.0, 4.0, 12)
            @test all(i -> !isfinite(yy[i]) || domain_contains(r.real_analysis.domain, xx[i]) === true, eachindex(xx))
            @test plot(r; xmin=-3, xmax=4, samples=12) isa Makie.Figure
        end
        # A plotting call samples only the function, never stored derivatives.
        counter = Ref(0)
        numerical = (function_value=t -> (counter[] += 1; t+1),
            first_derivative=t -> error("plot differentiated"),
            second_derivative=t -> error("plot differentiated"))
        counted = FunctionAnalysis(report.expression, report.variable, report.first_derivative,
            report.second_derivative, numerical, report.critical_points, report.real_analysis)
        @test plot(counted; xmin=-2, xmax=3, samples=10) isa Makie.Figure
        @test 0 < counter[] <= 12
    end
end
