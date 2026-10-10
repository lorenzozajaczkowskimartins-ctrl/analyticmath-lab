using AnalyticMathLab
using Test, Serialization
@testset "Stranger explicit scientific dataset" begin
    sample=ScientificSample(:training_run,Float32[1],reshape(Float32[0,1],1,:),Float32[1,2];split=:training)
    dataset=ScientificDataset([sample];kind=:surrogate,family=:affine,
        input_names=(:amplitude,),coordinate_names=(:t,),
        domain=(inputs=[0. 2.],coordinates=[0. 1.]),
        reference=(kind=:analytical,formula="a+t",error=:floating_roundoff),
        units=(inputs=("dimensionless",),coordinates=("dimensionless",),output="dimensionless"),
        grid=(sampling=:explicit,resampling=:none),rng=(kind=:deterministic,))
    @test eltype(sample.values)==Float64
    @test dataset.reference.kind==:analytical
    @test classify_query(dataset,[1.],sample.coordinates).guarantee==:none
    scaling=fit_scaling(dataset,:outputs)
    # Scaling rows are output components; columns are query samples.
    outputs=reshape(sample.values,1,:)
    @test inverse_transform(scaling,AnalyticMathLab.transform(scaling,outputs))≈outputs
    @test_throws DimensionMismatch AnalyticMathLab.transform(scaling,sample.values)
    @test_throws DimensionMismatch ScientificSample(:bad,[1.],zeros(1,3),[1.,2.];split=:training)
    @test_throws ArgumentError ScientificSample(:bad,[1.],zeros(1,1),[1.];split=:guessed)
    @test_throws ArgumentError ScientificSample(:bad,[1+im],zeros(1,1),[1.];split=:training)
    @test_throws ArgumentError learning_model(dataset,nothing)
    io=IOBuffer(); serialize(io,dataset); seekstart(io); restored=deserialize(io)
    @test restored.samples[1].values==sample.values
    @test restored.units==dataset.units
    @test restored.reference==dataset.reference
end
println("STRANGER_PASS dataset")
