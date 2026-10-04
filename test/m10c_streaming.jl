module M10CStreamingTests
using Test, AnalyticMathLab
const helper=joinpath(@__DIR__,"..","examples","scaling","streaming_helpers.jl")
@testset "M10C bounded lazy streaming" begin
    @test isfile(helper)
    if isfile(helper)
        include(helper)
        S=StreamingScale
        v=S.AlternatingSamples(1000)
        stored=statistical_summary(ObservableSeries(collect(v))).value
        lazy=statistical_summary(ObservableSeries(v)).value
        @test lazy==stored
        r=S.stream_summary(1000;chunk_size=31,max_seconds=30.,progress=false)
        @test r.status=="completed"
        @test r.consumed==1000
        @test r.moments.mean==stored.mean
        @test r.moments.variance==stored.variance
        @test r.moments.standard_error===nothing
        @test Base.summarysize(v)<100
        @test Base.summarysize(S.AlternatingSamples(10^10))==Base.summarysize(v)
        @test_throws ArgumentError S.stream_summary(10;chunk_size=0)
        @test_throws ArgumentError S.stream_summary(10;max_seconds=NaN)
        @test_throws ArgumentError S.stream_summary(10^10;max_seconds=0.01)
        withenv("AML_EXTREME"=>"1") do
            stopped=S.stream_summary(10^10;chunk_size=7,max_seconds=eps(),progress=false)
            @test stopped.status=="timed_out_safely"
            @test stopped.consumed<10^10
            @test stopped.requested==10^10
        end
        S.stream_summary(1000;progress=false)
        @test (@allocated S.stream_summary(100_000;progress=false))<100_000
    end
end
end
