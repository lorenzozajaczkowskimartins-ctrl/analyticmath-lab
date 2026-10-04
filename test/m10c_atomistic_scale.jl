module M10CAtomisticScaleTests
using Test, AnalyticMathLab
@testset "M10C explicit pair-output preflight" begin
    plain=AtomisticSnapshot([(0.,0.,0.),(3.,4.,0.)])
    distance()=AnalyticMathLab._at_distance(plain,plain.positions[1],plain.positions[2])
    @test distance()==5.
    distance()
    @test (@allocated distance())<128
    calls=Ref(0)
    s=AtomisticSnapshot([(0.,0.),(3.,4.),(6.,8.)];distance=(a,b)->(calls[]+=1;hypot(b[1]-a[1],b[2]-a[2])))
    @test hasmethod(pair_distances,Tuple{typeof(s)},(:max_bytes,))
    if hasmethod(pair_distances,Tuple{typeof(s)},(:max_bytes,))
        refused=pair_distances(s;max_bytes=1)
        @test refused.status==:unknown
        @test calls[]==0
        @test occursin("3",join(refused.notes))
        @test occursin("bytes",join(refused.notes))
        full=pair_distances(s;max_bytes=4096).value
        @test full.distances==[5.,10.,5.]
        @test_throws ArgumentError pair_distances(s;max_bytes=-1)
        @test pair_distances(s;max_pairs=2).status==:unknown
    end
end
end
