module M10DValueCompatibilityTests
using Test, AnalyticMathLab, Unitful, Serialization
const A=AnalyticMathLab
include(joinpath(@__DIR__,"..","examples","scaling","streaming_helpers.jl"))
@testset "M10D3 scientific value equality excludes origin identity" begin
    v=StreamingScale.AlternatingSamples(1000)
    stored_series=ObservableSeries(collect(v)); lazy_series=ObservableSeries(v)
    stored=statistical_summary(stored_series); lazy=statistical_summary(lazy_series)
    @test lazy.value == stored.value
    @test keys(lazy.value) == (:count,:mean,:variance,:std,:minimum,:maximum,:standard_error)
    @test hash(lazy.value) == hash(stored.value)
    @test !hasproperty(lazy.value,:origin)
    @test !hasproperty(lazy.value,:semantic_context)
    @test lazy isa PropertyResult
    @test A.scientific_origin(lazy) != A.scientific_origin(stored)
    @test only(A.scientific_origin(lazy).parents).token == objectid(lazy_series)
    @test only(A.scientific_origin(stored).parents).token == objectid(stored_series)
    @test A.scientific_metadata(lazy).units == A.scientific_metadata(stored).units
    @test A.scientific_metadata(lazy).approximation == A.scientific_metadata(stored).approximation
    @test A.scientific_metadata(lazy).provenance == A.scientific_origin(lazy)
    @test Base.summarysize(lazy) < 4096
    small=statistical_summary(ObservableSeries(collect(1.:8.)))
    big=statistical_summary(ObservableSeries(collect(1.:4096.)))
    @test Base.summarysize(small) == Base.summarysize(big)
    physical=statistical_summary(ObservableSeries([1.,2.,3.].*u"m"))
    @test physical.value.mean == 2u"m"
    @test physical.value.variance == 1u"m^2"
    @test A.scientific_metadata(physical).units.value == "m"
    io=IOBuffer(); serialize(io,lazy); seekstart(io); recovered=deserialize(io)
    @test recovered.value == lazy.value
    # Immediate source descriptor survives serialization; result token is process-local.
    @test A.scientific_origin(recovered).parents == A.scientific_origin(lazy).parents
    plain=PropertyResult(1.,:heuristic,:example,String[])
    typed=PropertyResult{Float64}(1.,:heuristic,:example,String[])
    @test typeof(typed) == typeof(plain) == PropertyResult{Float64}
    @test typed.value == plain.value
    @test isempty(A.scientific_origin(plain).parents)
end
end
