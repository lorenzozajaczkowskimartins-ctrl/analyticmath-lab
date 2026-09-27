module PINNPDETests
using Test, Random, AnalyticMathLab
import NeuralPDE, ModelingToolkit, OptimizationOptimisers, ADTypes
using ModelingToolkit: @parameters, @variables, @named, Differential, PDESystem
const A=AnalyticMathLab
@testset "M9A Poisson PDE independent reference" begin
    @parameters x
    @variables u(..)
    @named poisson=PDESystem([-(Differential(x)^2)(u(x)) ~ 2.],
        [u(0.) ~ 0.,u(1.) ~ 0.],[x ∈ (0.,1.)],[x],[u(x)])
    p=A.pinn_problem(poisson;network=A.pinn_network(1,1;hidden=[8,8]),
        strategy=NeuralPDE.GridTraining(0.1),rng=Xoshiro(17),adtype=ADTypes.AutoZygote())
    r=A.train(p,OptimizationOptimisers.Adam(0.01);maxiters=800,history=true,log_every=100)
    @test p.system===poisson
    @test length(p.loss_components)==3
    @test getproperty.(p.loss_components,:kind)==[:pde,:bc,:bc]
    points=[0.03,0.17,0.33,0.57,0.79,0.93]
    values=A.predict(r,reshape(points,1,:))
    @test size(values)==(1,6)
    @test all(isfinite,values)
    error=maximum(abs,vec(values).-points.*(1 .-points))
    @test error<0.12
    println("M9A Poisson independent max error = ",error)
    @test isfinite(r.losses.value.objective)
    @test length(r.losses.value.components)==3
    @test all(e->e.components===nothing,r.history.entries)
    @test r.termination.requested_maxiters==800
    @test r.evidence.status==:unknown
end
end
