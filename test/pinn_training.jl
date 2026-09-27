module PINNTrainingTests
using Test, Random, AnalyticMathLab
import Lux, NeuralPDE, ModelingToolkit, Optimization, OptimizationOptimisers, ADTypes
using ModelingToolkit: @parameters, @variables, @named, Differential, PDESystem
const A=AnalyticMathLab
@parameters t
@variables u(..)
@named ode = PDESystem([Differential(t)(u(t)) ~ -u(t)],[u(0.) ~ 1.],
    [t ∈ (0.,1.)],[t],[u(t)])
@testset "M9A ODE training, history and independent predictions" begin
    p=A.pinn_problem(ode;network=A.pinn_network(1,1;hidden=[8]),
        strategy=NeuralPDE.GridTraining(0.1),rng=Xoshiro(42),adtype=ADTypes.AutoZygote())
    u0=copy(p.optimization_problem.u0)
    result=A.train(p,OptimizationOptimisers.Adam(0.02);maxiters=500,
        history=true,log_every=25,history_capacity=8,record_components=true)
    @test result isa A.PINNTrainingResult
    @test result.problem===p
    @test result.backend_solution===result.solution.original_sol
    @test result.parameters===result.backend_solution.u
    @test result.optimization_problem isa Optimization.OptimizationProblem
    @test p.optimization_problem.u0==u0
    @test result.termination.retcode===result.backend_solution.retcode
    @test result.evidence.status==:unknown
    @test result.losses.status==:heuristic
    @test result.losses.value.objective==result.backend_solution.objective
    @test isfinite(result.losses.value.evaluated_objective)
    @test length(result.losses.value.components)==2
    @test length(result.history.entries)==8
    @test result.history.truncated
    @test all(e->isfinite(e.objective),result.history.entries)
    @test all(e->length(e.components)==2,result.history.entries)
    @test all(e->keys(e)==(:iteration,:objective,:components),result.history.entries)
    @test all(s->Lux.statelength(s)==0,result.states)
    # These points are independent of the 0.1-spaced collocation grid.
    points=[0.07,0.23,0.37,0.61,0.73,0.97]
    predictions=A.predict(result,reshape(points,1,:))
    @test size(predictions)==(1,length(points))
    @test all(isfinite,predictions)
    error=maximum(abs,vec(predictions).-exp.(-points))
    @test error<0.12
    println("M9A ODE independent max error = ",error)
    @test length(A.predict(result,0.37))==1
    @test A.predict(result,[0.37])≈A.predict(result,0.37)
    @test A.predict(result,0.37)[1]≈result.solution(0.37;dv=u(t))
    direct,_=Lux.apply(only(p.networks),reshape(points,1,:),only(result.network_parameters),only(result.states))
    @test predictions≈direct
    @test_throws DimensionMismatch A.predict(result,[0.2,0.3])
    @test_throws DimensionMismatch A.predict(result,zeros(2,3))
    @test_throws ArgumentError A.predict(result,[NaN])
    @test_throws ArgumentError A.train(p,OptimizationOptimisers.Adam();maxiters=0)
    @test_throws ArgumentError A.train(p,OptimizationOptimisers.Adam();maxiters=2,log_every=0)
    @test A.pinn_inspect(result).backend_solution===result.backend_solution
    @test A.pinn_inspect(result).construction.system===ode
    before=copy(result.parameters)
    continued=A.train(result,OptimizationOptimisers.Adam(0.005);maxiters=2)
    @test continued.problem===p
    @test continued.history===nothing
    @test continued.optimization_problem.u0==before
    @test result.parameters==before
    @test all(isfinite,A.predict(continued,0.5))
end
end
