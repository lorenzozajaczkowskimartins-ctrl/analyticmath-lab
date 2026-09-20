module MechanicsVisualizationTests
using Test, AnalyticMathLab, Symbolics
import Makie, CairoMakie
@variables q p
@testset "Mechanics views reuse M6 and label numerical energy" begin
    @test isdefined(AnalyticMathLab,:energyplot)
    if isdefined(AnalyticMathLab,:energyplot)
        h = analyze(HamiltonianSystem((p^2+q^2)/2;coordinates=(q,),momenta=(p,)))
        d = dynamics(h)
        path = trajectory(d,[1,0],(0,7);saveat=0.1)
        before = deepcopy(path.solution.u)
        before_h = energy_function(h)
        fig = phaseplot(d;trajectories=[path],energy_levels=[0.5,1.0],samples=9)
        @test fig isa Makie.Figure
        axis = only(filter(c -> c isa Makie.Axis,fig.content))
        @test axis.xlabel[] == "q"
        @test axis.ylabel[] == "p"
        @test phaseplot(h;conversion=d,trajectories=[path]) isa Makie.Figure
        @test energyplot(d,path) isa Makie.Figure
        @test energyplot(h,path;conversion=d) isa Makie.Figure
        @test path.solution.u == before
        @test isequal(energy_function(h),before_h)
        other = analyze(HamiltonianSystem(p^2+q^2;coordinates=(q,),momenta=(p,)))
        @test_throws ArgumentError phaseplot(other;conversion=d)
        @test_throws ArgumentError energyplot(other,path;conversion=d)
        mktempdir() do dir
            for (name,view) in (("phase",fig),("energy",energyplot(d,path)))
                file = joinpath(dir,name*".png")
                CairoMakie.save(file,view)
                @test filesize(file)>1000
            end
        end
    end
end
end
