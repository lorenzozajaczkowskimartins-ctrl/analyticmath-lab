module AtomisticVisualizationTests
using Test, AnalyticMathLab, Unitful
import Makie
const AML=AnalyticMathLab
@testset "Atomistic snapshot and lazy frame views" begin
    @test isdefined(AML,:mdplot)
    if isdefined(AML,:mdplot)
        s=AtomisticSnapshot([[0.,0.],[1.,0.],[1.,1.]];masses=ones(3),species=[:A,:B,:A],
            velocities=[[1.,0.],[0.,1.],[1.,1.]],boundary=(kind=:orthorhombic,lengths=[3.,3.]))
        before=deepcopy(s.positions)
        fig=AML.mdplot(s;selected_particle=2,color=:species)
        @test fig isa Makie.Figure
        @test s.positions==before
        @test count(a->a isa Makie.Axis,fig.content)==1
        @test AML.mdplot(s;color=:speed) isa Makie.Figure
        @test AML.mdplot(s;color=:index) isa Makie.Figure
        @test AML.mdplot(mdcheck(s)) isa Makie.Figure
        calls=Int[]
        t=AtomisticTrajectoryView(5,i->(push!(calls,i);s))
        @test AML.mdplot(t;frame=3) isa Makie.Figure
        @test calls==[3]
        @test_throws BoundsError AML.mdplot(s;selected_particle=4)
        @test_throws ArgumentError AML.mdplot(s;color=:atomic_radius)
        su=AtomisticSnapshot([[0.,0.,0.],[10.,0.,0.]].*u"Å";boundary=(kind=:orthorhombic,lengths=[2.,2.,2.].*u"nm"))
        @test AML.mdplot(su) isa Makie.Figure
        @test_throws ArgumentError AML.mdplot(AtomisticSnapshot([[NaN,0.]]))
        rdf=AML.radial_distribution(s;edges=[0.,0.5,1.5])
        @test AML.plot(rdf) isa Makie.Figure
    end
end
end
