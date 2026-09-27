module PINNVisualizationTests
using Test, AnalyticMathLab
import Makie
@testset "M9A stored loss history view" begin
    h=PINNHistory(;stride=2,capacity=3)
    @test_throws ArgumentError lossplot(h)
    append!(h.entries,[(iteration=1,objective=1.0,components=nothing),
        (iteration=2,objective=0.4,components=nothing)])
    before=deepcopy(h.entries)
    @test lossplot(h) isa Makie.Figure
    @test h.entries==before
    h.truncated=true
    @test lossplot(h) isa Makie.Figure
    @test h.truncated
end
end
