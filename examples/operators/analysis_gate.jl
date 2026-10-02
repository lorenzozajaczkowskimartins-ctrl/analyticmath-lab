using Test, AnalyticMathLab, Lux, NeuralOperators, Optimization, OptimizationOptimisers, ComponentArrays, ADTypes, Zygote, Random
const A=AnalyticMathLab
include("heat_family.jl")
@testset "M9D structured generalization analysis" begin
    @test isdefined(A,:GeneralizationAnalysis)
    if isdefined(A,:GeneralizationAnalysis)
        d=HeatFamily.parametric_dataset()
        m=learning_model(d,Lux.Dense(3=>1);rng=Xoshiro(8),normalization=:none,rng_provenance=(seed=8,))
        r=A.train(m,d;initial_parameters=ComponentArray{Float64}(m.parameters),optimizer=OptimizationOptimisers.Adam(0.01),adtype=ADTypes.AutoZygote(),maxiters=1)
        a=analyze(r)
        @test a.training===r
        @test length(a.cases)==length(d.samples)
        @test Set(keys(a.groups))==Set((:training,:interpolation,:parameter_extrapolation,:coordinate_extrapolation))
        @test a.reference.kind==:analytical
        @test a.physics===nothing
        @test a.evidence.status==:unknown
        @test a.groups[:interpolation].sample_count==6
        @test length(a.groups[:interpolation].per_coordinate_rms)==273
        @test a.groups[:coordinate_extrapolation].sample_count==1
        @test a.cases[1].classification.parameter==:inside
        @test a.cases[end].classification.coordinate==:outside
        points=PINNPoints([0.173 0.473;0.117 0.337];generation=:independent_grid)
        residual=heat_residual(q->only(A.predict(r,[0.12],reshape(q,2,1))),points;alpha=0.12)
        @test all(isfinite,residual.values)
        @test analyze(r;physics=(interpolation=residual,)).physics.interpolation===residual
    end
end
