using AnalyticMathLab
using Test, Unitful
@testset "Stranger atomistic data without an MD backend" begin
    positions=[(0.,0.,0.),(1.,0.,0.)]
    snapshot=AtomisticSnapshot(positions;masses=[1.,1.],boundary=(kind=:open,))
    @test snapshot.positions===positions
    @test pair_distances(snapshot).value.minimum==1.
    @test snapshot.velocities===nothing
    @test occursin("unknown",pair_distances(snapshot).value.units)
    owned=AtomisticSnapshot(positions;copy_data=true)
    @test owned.positions!==positions
    physical=AtomisticSnapshot([(0u"m",0u"m"),(100u"cm",0u"cm")])
    @test pair_distances(physical).value.minimum≈1u"m"
    @test pair_distances(AtomisticSnapshot([(NaN,0.)])).status==:unknown
    @test pair_distances(AtomisticSnapshot([(0.,),(1.,2.)])).status==:unknown
    @test pair_distances(AtomisticSnapshot(positions;boundary=(kind=:unsupported,))).status==:unknown
    @test_throws ArgumentError AtomisticSnapshot(positions;dimension=-1)
    @test_throws DimensionMismatch AtomisticTrajectoryView(2,i->snapshot;times=[0.])
    view=AtomisticTrajectoryView(3,i->snapshot;times=[0.,1.,2.])
    series=ObservableSeries([pair_distances(view[i]).value.minimum for i in 1:length(view)];
        times=view.times,name=:distance)
    @test statistical_summary(series).value.mean==1.
end
println("STRANGER_PASS atomistic")
