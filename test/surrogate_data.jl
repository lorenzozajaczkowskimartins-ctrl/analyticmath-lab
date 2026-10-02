module SurrogateDataTests
using Test, AnalyticMathLab
const A=AnalyticMathLab
@testset "M9D scientific family structure" begin
    @test isdefined(A,:ScientificSample)
    @test isdefined(A,:ScientificDataset)
    if isdefined(A,:ScientificDataset)
        q=[0. 0.5 1.;0. 0.2 0.4]
        s=A.ScientificSample(:a,[0.1],q,[0.,0.8,0.];split=:training)
        h=A.ScientificSample(:b,[0.15],q,[0.,0.7,0.];split=:interpolation)
        ref=(kind=:analytical,source="sine heat",solver=nothing,tolerances=nothing,error=:roundoff)
        domain=(inputs=[0.05 0.2],coordinates=[0. 1.;0. 0.5])
        d=A.ScientificDataset([s,h];kind=:surrogate,family=:heat,input_names=(:alpha,),
            coordinate_names=(:x,:t),domain,reference=ref,units=:dimensionless,
            grid=(ordering=:columns,regular=false,boundaries=:included,resampling=:none),rng=(seed=4,))
        @test d.reference.kind==:analytical
        @test d.samples[1].id==:a
        @test d.coordinate_names==(:x,:t)
        @test A.classify_query(d,[0.3],q).parameter==:outside
        @test A.classify_query(d,[0.1],q).coordinate==:inside
        @test_throws ArgumentError A.ScientificDataset([s,s];kind=:surrogate,family=:heat,input_names=(:alpha,),coordinate_names=(:x,:t),domain,reference=ref,units=:dimensionless,grid=NamedTuple(),rng=(seed=4,))
        @test_throws DimensionMismatch A.ScientificSample(:bad,[0.1],q,[1.];split=:training)
    end
end
end
