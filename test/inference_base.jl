module InferenceBaseTests
using Test, AnalyticMathLab
@testset "M9C base isolation" begin
    @test Base.get_extension(AnalyticMathLab,:AnalyticMathLabInferenceExt) === nothing
    @test Base.get_extension(AnalyticMathLab,:AnalyticMathLabDynamicsExt) === nothing
    @test ismissing(AnalyticMathLab.Makie.current_backend())
    @test all(m->!(nameof(m) in (:Lux,:Optimization,:NeuralPDE,:Molly,:CUDA,:AMDGPU,:Metal,:Reactant)),values(Base.loaded_modules))
end
@testset "Physical observation contract" begin
    @test isdefined(AnalyticMathLab,:ObservationSet)
    if isdefined(AnalyticMathLab,:ObservationSet)
        o=ObservationSet([0.,0.3,1.], [1. 2. 3.];variables=(:q,),kind=:synthetic,role=:fit)
        @test o.variables == ("q",)
        @test o.weights === nothing
        @test o.units === nothing
        @test o.times == [0.,0.3,1.]
        @test_throws DimensionMismatch ObservationSet([0.,1.],ones(2,2);variables=(:q,))
        @test_throws ArgumentError ObservationSet([0.,0.],ones(1,2);variables=(:q,))
        @test_throws ArgumentError ObservationSet([0.,1.],ones(1,2);variables=(:q,),weights=[1. -1.])
    end
@testset "M6 parameterized forward composition" begin
    @test isdefined(AnalyticMathLab,:ParameterInferenceProblem)
    if isdefined(AnalyticMathLab,:ParameterInferenceProblem)
        factory=p->FirstOrderODE((u,t)->[u[2],-p[2]/p[1]*u[1]],2;labels=("q","v"))
        spec=InferenceParameters((:m,:k),[1.,3.];inferred=(:k,),provenance=(source=:test,))
        times=[0.,0.2,0.7,1.]
        obs=ObservationSet(times,reshape(cos.(2 .* times),1,:);variables=(:q,),kind=:synthetic)
        p=ParameterInferenceProblem(factory,spec,obs;u0=[1.,0.],tspan=(0.,1.))
        @test p.model isa FirstOrderODE
        @test p.parameters.inferred == ("k",)
        @test p.reference === nothing
        @test p.indices == [1]
        @test inference_predict(p,[4.]) ≈ obs.values atol=1e-7
        @test inference_objective(p,[4.]) < 1e-12
        @test p.native_problem.p == [1.,3.]
        @test_throws ArgumentError infer_parameters(p,nothing;maxiters=1)
        reversed=InferenceParameters((:m,:k),[1.,3.];inferred=(:k,:m),bounds=([0.,0.],[10.,10.]))
        reordered=ObservationSet(times,[(-2sin.(2times))';cos.(2times)'];variables=("v","q"))
        rp=ParameterInferenceProblem(factory,reversed,reordered;u0=[1.,0.],tspan=(0.,1.))
        @test rp.parameters.indices == [2,1]
        @test rp.indices == [2,1]
        @test inference_predict(rp,[4.,1.]) ≈ reordered.values atol=1e-7
        @test rp.parameters.bounds == ([0.,0.],[10.,10.])
        s=local_sensitivity(p,[4.];rank_rtol=1e-8)
        @test s.value.rank == 1
        @test s.status == :heuristic
        @test s.value.jacobian[:,1] ≈ -times.*sin.(2 .* times)./4 atol=1e-6
        @test_throws ArgumentError InferenceParameters((:m,:k),[1.,3.];inferred=(:bad,))
        @test_throws ArgumentError InferenceParameters((:k,),[3.];inferred=(:k,),bounds=([4.],[5.]))
        @test_throws ArgumentError ParameterInferenceProblem(factory,spec,obs;u0=[1.,0.],tspan=(0.,1.),heldout=obs)
    end
end
end
end
