module M10DSemanticsReviewTests
using Test, AnalyticMathLab, Serialization
const A=AnalyticMathLab
@testset "M10D3 bounded review counterexamples" begin
    s=ObservableSeries([1.,2.])
    origin=merge(A.scientific_origin(s),(unexpected_source=collect(1.:4096.),))
    path=trajectory(FirstOrderODE((u,t)->[1.],1),[0.],(0.,1.))
    # Exercise the existing extensible diagnostics slot, not a leaf side channel.
    with_origin(origin)=TrajectoryResult(path.solution,path.problem,path.labels,
        merge(path.diagnostics,(origin=origin,)))
    p=with_origin(origin)
    detached=A.scientific_origin(p)
    @test Base.summarysize(detached) < 4096
    @test !hasproperty(only(detached.parents),:unexpected_source)
    @test hasproperty(detached,:kind)
    malformed=with_origin((unrelated=:metadata,))
    @test isempty(A.scientific_origin(malformed).parents)
    selected=observable_series(path;component=1)
    @test :numerical_integration in A.scientific_metadata(selected).approximation
    summary=statistical_summary(selected)
    @test summary.status == :heuristic
    @test isempty(A.scientific_metadata(summary).approximation)
    @test A.scientific_metadata(summary).tolerances.availability == :unknown
    io=IOBuffer(); serialize(io,detached); seekstart(io)
    @test deserialize(io) == detached
    @test Base.summarysize(detached) == Base.summarysize(deepcopy(detached))
    for _ in 1:12
        p=with_origin(detached)
        detached=A.scientific_origin(p)
    end
    levels=0; leaf=detached
    while true
        levels+=1
        isempty(leaf.parents) && break
        leaf=only(leaf.parents)
    end
    @test levels == 8
    @test leaf.truncated
    @test A._sm_numeric_tolerances((maxiters=1,abstol=2e-9,reltol=3e-7,callback=identity)) == (abstol=2e-9,reltol=3e-7)
    @test A._sm_numeric_tolerances((maxiters=1,callback=identity)) === nothing
end
end
