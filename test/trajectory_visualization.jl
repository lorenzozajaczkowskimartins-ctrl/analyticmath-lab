module TrajectoryVisualizationTests
using Test, AnalyticMathLab, Unitful
import Makie
const A=AnalyticMathLab
@testset "Trajectory result-only statistical views" begin
    @test isdefined(A,:timeseriesplot)
    if isdefined(A,:timeseriesplot)
        s=A.ObservableSeries([1.,3.,2.,4.,1.,2.,3.,1.].*u"eV";interval=2u"ps")
        before=copy(s.values)
        @test A.timeseriesplot(s) isa Makie.Figure
        @test A.autocorrelationplot(A.autocorrelation(s)) isa Makie.Figure
        @test A.blockplot(A.block_average(s;block_sizes=[1,2,4])) isa Makie.Figure
        t=AtomisticTrajectoryView(4,i->AtomisticSnapshot([[1.0*i,0.]];velocities=[[1.,0.]],masses=[1.],potential_energy=1.);
            times=[0.,1.,2.,3.],provenance=(fixed_particles=:caller_asserted,))
        m=A.mean_squared_displacement(t)
        @test A.msdplot(m) isa Makie.Figure
        @test A.msdplot(m;fit=A.diffusion_estimate(m;fit_window=(1.,3.))) isa Makie.Figure
        @test A.vacfplot(A.velocity_autocorrelation(t;normalize=true)) isa Makie.Figure
        @test A.energyplot(A.analyze(t;observables=(:total_energy,))) isa Makie.Figure
        @test s.values==before
        @test_throws ArgumentError A.timeseriesplot(A.ObservableSeries([1.,2.]))
        @test_throws ArgumentError A.autocorrelationplot(A.autocorrelation(A.ObservableSeries(ones(3);interval=1)))
    end
end
end
