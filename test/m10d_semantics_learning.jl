# Bounded optional gate in examples/operators: one affine network, one step.
module M10DSemanticsLearningTests
using Test, AnalyticMathLab, Lux, NeuralOperators, Optimization, OptimizationOptimisers
using ComponentArrays, ADTypes, Zygote, Random
const A=AnalyticMathLab
@testset "M10D3 numerical reference through learning and generalization" begin
    path=trajectory(FirstOrderODE((u,t)->[2.],1),[1.],(0.,1.))
    schema=(family=:linear,id=:run,input=[2.],input_names=(:speed,),coordinate_names=(:t,),
        domain=(inputs=[1. 3.],coordinates=[0. 1.]),selection=(component=1,),split=:training,
        reference=(kind=:numerical,description="linear ODE",error=:unknown),
        units=(inputs=("unknown",),coordinates=("unknown",),output="unknown"),
        grid=(sampling=:stored,resampling=:none),rng=(kind=:deterministic,))
    d=ScientificDataset(path;schema,source_retention=:descriptor)
    m=learning_model(d,Lux.Dense(2=>1);rng=Xoshiro(13),normalization=:train_minmax,rng_provenance=(seed=13,))
    result=A.train(m,d;initial_parameters=ComponentArray{Float64}(m.parameters),
        optimizer=OptimizationOptimisers.Adam(0.01),adtype=ADTypes.AutoZygote(),maxiters=1)
    a=analyze(result;relative_floor=2e-11)
    @test applicable(A.scientific_metadata,m)
    @test applicable(A.scientific_metadata,result)
    @test applicable(A.scientific_metadata,a)
    if applicable(A.scientific_metadata,m) && applicable(A.scientific_metadata,result) && applicable(A.scientific_metadata,a)
        mm=A.scientific_metadata(m); rm=A.scientific_metadata(result); am=A.scientific_metadata(a)
        @test mm.reference.value.kind == :numerical
        @test rm.reference.value.kind == :numerical
        @test am.reference.value.kind == :numerical
        @test am.reference.value.error == :unknown
        @test only(rm.claims).status == only(am.claims).status == :unknown
        @test a.reference === d.reference
        @test mm.units.value == am.units.value == d.units
        @test mm.coordinates.value.query == (:t,)
        @test am.domain.value.bounds == d.domain
        @test mm.backend.value.packages == (:Lux,:NeuralOperators,:Optimization)
        @test mm.method != mm.backend.value
        @test :surrogate in am.approximation
        @test :sampled_errors_only in am.approximation
        @test am.tolerances.value.relative_floor == 2e-11
        @test am.tolerances.value.reference == (abstol=1e-9,reltol=1e-7)
        @test mm.rng.value == (seed=13,)
        origin=A.scientific_origin(a)
        @test only(origin.parents).token == objectid(result)
        @test only(only(origin.parents).parents).token == objectid(d)
        @test only(only(only(origin.parents).parents).parents).token == objectid(path)
        @test only(A.scientific_origin(m).parents).token == objectid(d)
        @test Base.summarysize(origin) < 4096
        @test classify_query(result.model,[2.],reshape([0.,1.],1,:)).guarantee == :none
    end
end
end
