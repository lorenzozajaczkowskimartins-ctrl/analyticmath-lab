module DynamicalVisualizationTests
using Test, AnalyticMathLab, Symbolics
import Makie, CairoMakie
@variables x v
@testset "Dynamical views consume stored reports and solutions" begin
    @test isdefined(AnalyticMathLab,:phaseplot)
    @test isdefined(AnalyticMathLab,:timeplot)
    if isdefined(AnalyticMathLab,:phaseplot) && isdefined(AnalyticMathLab,:AutonomousSystem)
        report = analyze(AutonomousSystem([v,-x],(x,v)))
        path = trajectory(report,[1,0],(0,7);saveat=0.05)
        before = sprint(show,MIME"text/plain"(),report)
        values = deepcopy(path.solution.u)
        fig = phaseplot(report;trajectories=[path],show_nullclines=true,samples=9,arrowscale=0.1)
        @test fig isa Makie.Figure
        @test timeplot(path) isa Makie.Figure
        @test sprint(show,MIME"text/plain"(),report) == before
        @test path.solution.u == values
        @test_throws ArgumentError phaseplot(analyze(AutonomousSystem([x],(x,))))
        @test_throws ArgumentError phaseplot(report;trajectories=[trajectory(FirstOrderODE((u,t)->[-u[1]],1),[1],(0,1))])
        # Time views must not reevaluate even a stateful numerical RHS.
        calls = Ref(0)
        counted = FirstOrderODE((u,t) -> (calls[] += 1; [-u[1]]),1)
        counted_path = trajectory(counted,1.0,(0,1))
        before_calls = calls[]
        @test timeplot(counted_path) isa Makie.Figure
        @test calls[] == before_calls
        # Valid endpoints do not authorize a segment through a preserved hole.
        punctured = analyze(@real_function([x/x,v]),(x,v))
        @test domain_contains(punctured.domain,(-1,0)) === true
        @test domain_contains(punctured.domain,(1,0)) === true
        @test !AnalyticMathLab._ds_segment_allowed(punctured,[-1,0],[1,0])
        @test AnalyticMathLab._ds_segment_allowed(punctured,[1,0],[2,0])
        mktempdir() do dir
            for (name,view) in (("phase",fig),("time",timeplot(path)))
                target = joinpath(dir,name*".png")
                CairoMakie.save(target,view)
                @test filesize(target)>1000
            end
        end
    end
end
end
