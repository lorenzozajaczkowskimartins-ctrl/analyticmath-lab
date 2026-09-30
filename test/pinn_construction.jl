module PINNConstructionTests
using Test, Random, AnalyticMathLab
import Lux, NeuralPDE, ModelingToolkit, Optimization, ADTypes
using ModelingToolkit: @parameters, @variables, @named, Differential, PDESystem
const A=AnalyticMathLab
@parameters t
@variables u(..)
@named ode = PDESystem([Differential(t)(u(t)) ~ -u(t)], [u(0.) ~ 1.],
    [t ∈ (0.,1.)], [t], [u(t)])
@testset "M9A real backend construction" begin
    @test Base.get_extension(A,:AnalyticMathLabPINNExt)!==nothing
    @test isdefined(A,:pinn_network)
    if isdefined(A,:pinn_network)
        network=A.pinn_network(1,1;hidden=[8])
        @test network isa Lux.AbstractLuxLayer
        ps,st=Lux.setup(Xoshiro(1),network)
        @test size(first(Lux.apply(network,zeros(Float32,1,2),ps,st)))==(1,2)
        @test_throws ArgumentError A.pinn_network(0,1)
        @test_throws ArgumentError A.pinn_network(1,1;hidden=[0])
        p=A.pinn_problem(ode;network,strategy=NeuralPDE.GridTraining(0.1),rng=Xoshiro(42),adtype=ADTypes.AutoZygote())
        @test p isa A.PINNProblem
        @test !p.provenance.physical_parameters.param_estim
        @test isempty(p.provenance.physical_parameters.declared)
        @test isempty(p.provenance.physical_parameters.inferred)
        @test p.system===ode
        @test isequal(p.independent_variables,[t])
        @test isequal(p.dependent_variables,[u(t)])
        @test only(p.networks)===network
        @test p.discretization isa NeuralPDE.PhysicsInformedNN
        @test p.optimization_problem isa Optimization.OptimizationProblem
        @test p.symbolic_discretization===p.optimization_problem.f.sys
        @test p.backend_metadata===NeuralPDE.pinn_metadata(p.optimization_problem)
        @test length(p.loss_components)==2
        @test getproperty.(p.loss_components,:kind)==[:pde,:bc]
        @test all(s->Lux.statelength(s)==0,p.initial_states)
        @test p.evidence.status==:established
        info=A.pinn_inspect(p)
        @test info.system===ode
        @test info.optimization_problem===p.optimization_problem
        @test length(info.boundary_conditions)==1
        @test info.network_mapping[1].input_indices==[1]
        p2=A.pinn_problem(ode;network,strategy=NeuralPDE.GridTraining(0.1),rng=Xoshiro(42),adtype=ADTypes.AutoZygote())
        @test p.optimization_problem.u0==p2.optimization_problem.u0
        @test_throws DimensionMismatch A.pinn_problem(ode;network=A.pinn_network(1,2),strategy=NeuralPDE.GridTraining(0.1),rng=Xoshiro(2),adtype=ADTypes.AutoZygote())
        @test_throws ArgumentError A.pinn_problem(ode;network=Lux.Chain(Lux.Dense(1=>2),Lux.BatchNorm(2),Lux.Dense(2=>1)),strategy=NeuralPDE.GridTraining(0.1),rng=Xoshiro(2),adtype=ADTypes.AutoZygote())
        @test_throws ArgumentError A.pinn_problem(nothing;network,strategy=NeuralPDE.GridTraining(0.1),rng=Xoshiro(2),adtype=ADTypes.AutoZygote())
    end
end
end
