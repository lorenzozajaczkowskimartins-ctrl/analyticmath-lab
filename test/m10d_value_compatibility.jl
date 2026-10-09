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
    # The series retain honest distinct origins; the four-field leaves do not.
    @test A.scientific_origin(lazy_series) != A.scientific_origin(stored_series)
    @test A.scientific_origin(lazy_series).token == objectid(lazy_series)
    @test A.scientific_origin(stored_series).token == objectid(stored_series)
    @test A.scientific_origin(lazy) == (availability=:unknown,value=nothing)
    @test A.scientific_origin(stored) == (availability=:unknown,value=nothing)
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
    @test A.scientific_metadata(physical).units.availability == :unknown
    io=IOBuffer(); serialize(io,lazy); seekstart(io); recovered=deserialize(io)
    @test recovered.value == lazy.value
    # Serialization cannot recover source information absent from the leaf.
    @test A.scientific_origin(recovered) == A.scientific_origin(lazy)
    plain=PropertyResult(1.,:heuristic,:example,String[])
    typed=PropertyResult{Float64}(1.,:heuristic,:example,String[])
    @test typeof(typed) == typeof(plain) == PropertyResult{Float64}
    @test typed.value == plain.value
    @test A.scientific_origin(plain) == (availability=:unknown,value=nothing)
    @test fieldnames(typeof(plain)) == (:value,:status,:method,:notes)
    @test fieldtypes(typeof(plain)) == (Float64,Symbol,Symbol,Vector{String})
    @test PropertyResult{Float64}(1,:heuristic,:example,String[]).value === 1.0
    notes=["unchanged"]
    a=PropertyResult(1.,:heuristic,:example,notes)
    b=PropertyResult{Float64}(1.,:heuristic,:example,notes)
    c=PropertyResult(1.,:heuristic,:example,copy(notes))
    @test a === b
    @test a == b && isequal(a,b) && hash(a) == hash(b)
    @test a !== c && !(a == c) && !isequal(a,c)
    @test which(==,(typeof(a),typeof(b))).module === Base
    @test which(hash,(typeof(a),UInt)).module === Base
    @test a.notes === notes
    @test Tuple(getfield(a,i) for i in 1:fieldcount(typeof(a))) === (1.,:heuristic,:example,notes)
    @test !hasproperty(a,:metadata)
    @test A.scientific_metadata(a).provenance == (availability=:unknown,value=nothing)
    @test A.scientific_metadata(a).tolerances.availability == :unknown
    @test A.scientific_metadata(a).domain.availability == :unknown
    @test A.scientific_metadata(a).coordinates.availability == :unknown
    @test A.scientific_metadata(a).sampling.availability == :unknown
    @test only(A.scientific_metadata(a).claims) == (scope=:property,status=a.status,method=a.method,notes=a.notes)
end
end
