# Fast optional extension boundary/result gate; run separately from base Pkg.test().
using Test, AnalyticMathLab
import Optimization, OptimizationOptimisers
const AML=AnalyticMathLab
@testset "Optimization-only activation" begin
    @test Base.get_extension(AML,:AnalyticMathLabInferenceExt)!==nothing
    @test Base.get_extension(AML,:AnalyticMathLabDynamicsExt)===nothing
    @test Base.get_extension(AML,:AnalyticMathLabPINNExt)===nothing
    @test all(m->!(nameof(m) in (:Lux,:NeuralPDE,:ModelingToolkit,:Molly,:CUDA,:AMDGPU,:Metal,:Reactant,:CairoMakie,:GLMakie)),values(Base.loaded_modules))
    @test ismissing(AML.Makie.current_backend())
end
import Lux
@testset "Independent learned-dynamics activation" begin
    ext=Base.get_extension(AML,:AnalyticMathLabDynamicsExt)
    @test ext!==nothing
    @test Base.get_extension(AML,:AnalyticMathLabPINNExt)===nothing
    @test all(m->!(nameof(m) in (:NeuralPDE,:ModelingToolkit,:Molly,:CUDA,:AMDGPU,:Metal,:Reactant,:CairoMakie,:GLMakie)),values(Base.loaded_modules))
    ambiguities=Test.detect_ambiguities(AML,ext,Base.get_extension(AML,:AnalyticMathLabInferenceExt),Lux,Optimization;recursive=false)
    @test isempty(filter(pair->any(m->m.module in (AML,ext,Base.get_extension(AML,:AnalyticMathLabInferenceExt)),pair),ambiguities))
end
@testset "Missing truth, bounded history and stored plotting" begin
    calls=Ref(0)
    factory=p->begin
        calls[]+=1
        FirstOrderODE((u,t)->[-p[1]*u[1]],1;labels=("y",))
    end
    obs=ObservationSet([0.,0.5,1.],reshape(exp.(-[0.,0.5,1.]),1,:);variables=("y",),kind=:user_supplied)
    spec=InferenceParameters((:rate,),[0.8];inferred=(:rate,))
    problem=ParameterInferenceProblem(factory,spec,obs;u0=[1.],tspan=(0.,1.))
    result=infer_parameters(problem,OptimizationOptimisers.Adam(0.01);maxiters=3,history_stride=1,history_capacity=1)
    @test result.reference_comparison===nothing
    @test result.heldout===nothing
    @test result.problem.observations===obs
    @test result.problem.parameters===spec
    @test result.evidence.status===:unknown
    @test result.termination.requested_maxiters==3
    @test length(result.history.entries)==1 && result.history.truncated
    @test !isempty(result.limitations)
    before=calls[]
    prediction=copy(result.prediction)
    figure=parameterfitplot(result)
    @test figure isa AML.Makie.Figure
    @test calls[]==before
    @test result.prediction==prediction
    @test ismissing(AML.Makie.current_backend())
end
