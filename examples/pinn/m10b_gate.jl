# A real discretized one-layer PINN at initial parameters; no training result is claimed.
module M10BPINNNumericGate
using Test, Random, AnalyticMathLab
import Lux, NeuralPDE, ModelingToolkit, Optimization, ADTypes, SymbolicIndexingInterface
using ModelingToolkit: @parameters, @variables, @named, Differential, PDESystem
const A=AnalyticMathLab
@parameters t
@variables u(..)
@named ode=PDESystem([Differential(t)(u(t)) ~ -u(t)],[u(0.) ~ 1.],[t ∈ (0.,1.)],[t],[u(t)])
p=A.pinn_problem(ode;network=A.pinn_network(1,1;hidden=Int[]),strategy=NeuralPDE.GridTraining(0.5),rng=Xoshiro(1021),adtype=ADTypes.AutoForwardDiff())
unknown=A.PropertyResult(nothing,:unknown,:untrained_numeric_fixture,["No training performed."])
function fixture(parameters=p.initial_parameters)
    A.PINNTrainingResult(p,p.optimization_problem,nothing,p.optimization_problem,copy(p.optimization_problem.u0),
        parameters,deepcopy(p.initial_states),A.PINNHistory(),unknown,nothing,nothing,
        (kind=:untrained_numeric_fixture,),unknown,["Initial-state test fixture, not optimizer output."])
end
@testset "M10B PINN native prediction and diagnostic numeric gate" begin
    r=fixture(); ext=Base.get_extension(A,:AnalyticMathLabPINNExt)
    @test all(isfinite,A.predict(r,[0.25]))
    for bad in (BigFloat("1e400"),BigFloat("1e-400"),BigFloat(1)+eps(BigFloat))
        @test_throws ArgumentError A.predict(r,[bad])
    end
    for bad in (NaN,Inf,-Inf)
        ps=deepcopy(p.initial_parameters)
        ps[1].layer_1.bias .= bad
        @test_throws DomainError A.predict(fixture(ps),[0.25])
    end
    ps=deepcopy(p.initial_parameters)
    ps[1].layer_1.weight .= 0.
    ps[1].layer_1.bias .= 1e300
    huge=fixture(ps)
    @test only(A.predict(huge,[0.25]))==1e300
    points=A.PINNPoints(reshape([0.25,0.75],1,:))
    comparison=ext._reference_analysis(huge,points,x->[1e-300],(kind=:numeric_fixture,),0.)
    @test comparison.value.summary[1].rms==1e300
    @test all(ismissing,comparison.value.relative_error)
    bigreference=ext._reference_analysis(r,points,x->[BigFloat("1e400")],(kind=:numeric_fixture,),0.)
    @test bigreference.value.summary[1].rms isa BigFloat
    @test isfinite(bigreference.value.summary[1].rms)
    # Public backend signed residual evaluated at initial optimization state.
    block=first(p.backend_metadata.blocks)
    residual=ext._sample_residual(r,block,points)
    @test length(residual)==2 && all(isfinite,residual)
    @test sampled_summary(residual).finite_count==2
    @test ismissing(A.Makie.current_backend())
end
end
