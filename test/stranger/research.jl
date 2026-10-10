using AnalyticMathLab
using Test, Serialization, Unitful, LinearAlgebra, SparseArrays
@testset "Stranger research stored streaming and persistence" begin
    # A range is a lazy AbstractVector; no private streaming helper is required.
    values=range(1.,10000.;length=10000)
    series=ObservableSeries(values;index_time=true,name=:signal)
    result=statistical_summary(series)
    @test series.values===values
    @test result.value.count==10000
    @test result.value.mean≈5000.5
    @test result.value.variance≈10000*10001/12
    @test result.value.standard_error===nothing
    @test statistical_summary(ObservableSeries(collect(values))).value==result.value
    @test Base.summarysize(result)<4096
    physical=statistical_summary(ObservableSeries([1.,2.,3.].*u"m"))
    @test physical.value.variance≈1u"m^2"
    for T in (Float32,Float64,BigFloat)
        @test statistical_summary(ObservableSeries(T[1,2,3])).value.mean≈T(2)
    end
    @test statistical_summary(ObservableSeries([1,2,3])).value.mean isa Float64
    @test statistical_summary(ObservableSeries([1+im,2+im])).status==:unknown
    for object in (result,physical,AnalyticMathLab.scientific_origin(series))
        io=IOBuffer(); serialize(io,object); seekstart(io); restored=deserialize(io)
        if object isa PropertyResult
            @test restored.value==object.value
            @test restored.status==object.status
        else
            @test restored==object
        end
    end
    # Sparse storage is accepted but the existing eigensolver is dense Float64.
    modes=normal_modes(sparse([2 -1;-1 2]),Diagonal([1,1]))
    @test modes.frequencies≈[1.,sqrt(3.)]
    @test eltype(modes.mode_vectors)==Float64
    @test eltype(normal_modes(BigFloat[2 -1;-1 2],Diagonal(big.([1,1]))).mode_vectors)==Float64
    @test normal_modes(ComplexF64[2 im;-im 2],Diagonal([1.,1.])).evidence.status==:unknown
    @test_throws DimensionMismatch normal_modes(ones(2,3),ones(2,2))
end
println("STRANGER_PASS research")
