module PINNEdgeTests
using Test, Random, AnalyticMathLab
import Lux, NeuralPDE, ModelingToolkit, OptimizationOptimisers, ADTypes
using ModelingToolkit: @parameters, @variables, @named, Differential, PDESystem
const A=AnalyticMathLab
@testset "M9A ordering and explicit network layouts" begin
    @parameters x t
    @variables u(..) v(..)
    @named sys=PDESystem([u(t,x) ~ t+x,v(x,t) ~ x-t],
        [u(0.,0.) ~ 0.,v(0.,0.) ~ 0.],[x ∈ (0.,1.),t ∈ (0.,1.)],[x,t],[u(t,x),v(x,t)])
    nets=[A.pinn_network(2,1;hidden=[3]),A.pinn_network(2,1;hidden=[3])]
    options=(strategy=NeuralPDE.GridTraining(0.5),adtype=ADTypes.AutoZygote())
    @test_throws ArgumentError A.pinn_problem(sys;network=nets,rng=Xoshiro(1),options...)
    @test_throws ArgumentError A.pinn_problem(sys;network=A.pinn_network(2,2),network_layout=:shared,rng=Xoshiro(1),options...)
    @test_throws DimensionMismatch A.pinn_problem(sys;network=nets[1:1],network_layout=:separate,rng=Xoshiro(1),options...)
    p=A.pinn_problem(sys;network=nets,network_layout=:separate,rng=Xoshiro(1),options...)
    @test getproperty.(p.network_mapping,:input_indices)==[[2,1],[1,2]]
    r=A.train(p,OptimizationOptimisers.Adam();maxiters=1)
    X=[0.2 0.7;0.4 0.9]
    y=A.predict(r,X)
    @test size(y)==(2,2)
    @test y[1,:]≈[r.solution(X[2,i],X[1,i];dv=u(t,x)) for i in 1:2]
    @test y[2,:]≈[r.solution(X[1,i],X[2,i];dv=v(x,t)) for i in 1:2]
    @test A.predict(r,(0.2,0.4))≈y[:,1]
    @test_throws DimensionMismatch A.predict(r,0.2)
    @named sharedsys=PDESystem([u(x) ~ x,v(x) ~ 2x],[u(0.) ~ 0.,v(0.) ~ 0.],
        [x ∈ (0.,1.)],[x],[u(x),v(x)])
    p2=A.pinn_problem(sharedsys;network=A.pinn_network(1,2;hidden=[3]),network_layout=:shared,rng=Xoshiro(3),options...)
    @test getproperty.(p2.network_mapping,:output)==[1,2]
    r2=A.train(p2,OptimizationOptimisers.Adam();maxiters=1)
    @test length(r2.network_parameters)==1
    @test A.predict(r2,0.3)≈[r2.solution(0.3;dv=u(x)),r2.solution(0.3;dv=v(x))]
end
@testset "M9A additional costs, callback and non-Dense model" begin
    @parameters t
    @variables u(..)
    @named ode=PDESystem([Differential(t)(u(t)) ~ -u(t)],[u(0.) ~ 1.],
        [t ∈ (0.,1.)],[t],[u(t)])
    net=Lux.SkipConnection(Lux.Chain(Lux.Dense(1=>3,tanh),Lux.Dense(3=>1)),+)
    extra=(phi,θ,p)->sum(abs2,phi.u(zeros(1,1),θ.u))
    p=A.pinn_problem(ode;network=net,strategy=NeuralPDE.GridTraining(0.2),rng=Xoshiro(11),
        adtype=ADTypes.AutoZygote(),additional_loss=extra,optimization_options=(weights=[1.,2.,3.],))
    @test only(p.networks)===net
    @test getproperty.(p.loss_components,:kind)==[:pde,:bc,:additional]
    calls=Ref(0)
    r=A.train(p,OptimizationOptimisers.Adam();maxiters=10,history=true,log_every=1,
        record_components=true,callback=(state,loss)->(calls[]+=1;state.iter>=2))
    @test calls[]==2
    @test r.termination.iterations==2
    @test length(r.history.entries)==2
    @test !r.history.truncated
    @test r.losses.value.evaluated_objective≈sum([1.,2.,3.].*r.losses.value.components)
    @test A.predict(r,0.3)[1]≈r.solution(0.3;dv=u(t))
    @test ismissing(A.Makie.current_backend())
    @test all(m->!(nameof(m) in (:CUDA,:AMDGPU,:Metal,:Reactant,:Molly)),values(Base.loaded_modules))
end
end
