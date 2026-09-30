using Test, AnalyticMathLab
import Unitful
using Unitful: @u_str
@testset "Frozen M8 pair-distance observations" begin
    @test isdefined(AnalyticMathLab,:distance_observations)
    if isdefined(AnalyticMathLab,:distance_observations)
        xyz=[[[9.8,0.],[0.2,0.]],[[0.1,0.],[0.5,0.]]]
        times=[0.,0.3]
        view=AtomisticTrajectoryView(2,i->AtomisticSnapshot(xyz[i];time=times[i],
            boundary=(kind=:orthorhombic,lengths=[10.,10.]),provenance=(wrapped=true,));times)
        s=distance_observations(view,(1,2))
        @test s.values ≈ [0.4,0.4]
        @test s.sampling.times == times
        @test s.provenance.source === view
        @test s.provenance.pair == (1,2)
        @test s.provenance.frames == [1,2]
        @test s.provenance.geometry == [:minimum_image,:minimum_image]
        @test s.units == "unknown (unitless values)"
        xyz[1][1][1]=5.; times[1]=-2.
        @test s.values ≈ [0.4,0.4]
        @test s.sampling.times == [0.,0.3]
        obs=ObservationSet(s;kind=:numerical)
        s.values[1]=99.; s.sampling.times[1]=-1.
        @test obs.values ≈ reshape([0.4,0.4],1,:)
        @test obs.times == [0.,0.3]
        @test obs.provenance.source_series === s
        unknown=AtomisticTrajectoryView(2,i->AtomisticSnapshot([[0.],[1.]]))
        @test distance_observations(unknown,(1,2)).sampling.times === nothing
        @test_throws ArgumentError ObservationSet(distance_observations(unknown,(1,2)))
        @test_throws ArgumentError ObservationSet(ObservableSeries([1.,2.];index_time=true))
        unitview=AtomisticTrajectoryView(2,i->AtomisticSnapshot([[0.]u"nm",[Float64(i)]u"nm"];
            time=(i-1)*2u"ps"))
        us=distance_observations(unitview,(1,2))
        @test us.values == [1u"nm",2u"nm"]
        @test_throws ArgumentError ObservationSet(us)
        @test_throws ArgumentError ObservationSet(us;time_scale=1u"nm",length_scale=1u"nm")
        uo=ObservationSet(us;time_scale=2u"ps",length_scale=1u"nm")
        @test uo.times == [0.,1.]
        @test uo.values == [1. 2.]
        @test uo.units.length_scale == 1u"nm"
        @test uo.provenance.source_series === us
        conflicting=AtomisticTrajectoryView(2,i->AtomisticSnapshot([[0.],[1.]];time=i);times=[0.,1.])
        @test_throws ArgumentError distance_observations(conflicting,(1,2))
        unsupported=AtomisticTrajectoryView(2,i->AtomisticSnapshot([[0.],[1.]];boundary=(kind=:unsupported,)))
        @test_throws ArgumentError distance_observations(unsupported,(1,2))
        backend=AtomisticTrajectoryView(2,i->AtomisticSnapshot([[0.],[1.]];time=i,distance=(a,b)->0.7))
        @test distance_observations(backend,(1,2)).values == [0.7,0.7]
        @test_throws ArgumentError distance_observations(backend,(1,1))
        @test_throws ArgumentError distance_observations(backend,(1,3))
        @test_throws ArgumentError distance_observations(backend,(1,2);frames=[2,1])
    end
end
