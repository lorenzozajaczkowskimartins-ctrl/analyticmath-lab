using Test, Lux, Optimization, OptimizationOptimisers, Random
using AnalyticMathLab
using AnalyticMathLab: ForwardDiff, Symbolics
const AML = AnalyticMathLab
Symbolics.@variables nq np
const MECHANICS = analyze(HamiltonianSystem((nq^2+np^2)/2;coordinates=(nq,),momenta=(np,)))
const HNET = Lux.Chain(Lux.WrappedFunction(x->x.^2),Lux.Dense(2=>1))
const HSTATE = Lux.testmode(last(Lux.setup(Random.Xoshiro(44),HNET)))
hparams(v)=(layer_1=NamedTuple(),layer_2=(weight=reshape(v[1:2],1,2),bias=v[3:3]))
const HMODEL = AML.HamiltonianNN(MECHANICS,HNET,hparams([0.5,0.5,3.]),HSTATE)
Symbolics.@variables nq2 np2
const MECHANICS4=analyze(HamiltonianSystem((nq^2+2nq2^2+3np^2+4np2^2)/2;coordinates=(nq,nq2),momenta=(np,np2)))
@testset "Canonical neural Hamiltonian" begin
    @test applicable(AML.learned_vector_field,HMODEL,[2.,3.],0.)
    if applicable(AML.learned_vector_field,HMODEL,[2.,3.],0.)
        @test AML.learned_vector_field(HMODEL,[2.,3.],0.) ≈ [3.,-2.]
        shifted=AML.HamiltonianNN(MECHANICS,HNET,hparams([0.5,0.5,19.]),HSTATE)
        @test AML.learned_vector_field(shifted,[2.,3.],0.) ≈ [3.,-2.]
        @test AML.aligned_energy(shifted,[2.,3.];reference=zeros(2)) ≈ 6.5
        net4=Lux.Chain(Lux.WrappedFunction(x->x.^2),Lux.Dense(4=>1))
        state4=Lux.testmode(last(Lux.setup(Random.Xoshiro(3),net4)))
        model4=AML.HamiltonianNN(MECHANICS4,net4,(layer_1=NamedTuple(),layer_2=(weight=reshape([0.5,1.,1.5,2.],1,4),bias=[0.])),state4)
        @test AML.learned_vector_field(model4,[1.,2.,3.,4.]) ≈ [9.,16.,-1.,-4.]
        @test_throws DimensionMismatch AML.learned_energy(HMODEL,[1.])
        bad=AML.HamiltonianNN(MECHANICS,Lux.WrappedFunction(identity),NamedTuple(),NamedTuple())
        @test_throws DimensionMismatch AML.learned_energy(bad,[1.,2.])
        x=[-1. 0. 1. 0.5;0.2 1. -0.4 0.7]
        d=AML.DerivativeData(x,[x[2,:]';-x[1,:]'])
        @test AML.dynamics_objective(HMODEL,d) < 1e-20
        @test ForwardDiff.gradient(v->AML.dynamics_objective(AML.HamiltonianNN(MECHANICS,HNET,hparams(v),HSTATE),d),[0.3,0.7,0.])[1] < 0
    end
end
const UNET = Lux.Chain(Lux.WrappedFunction(x->[x[1]^3]),Lux.Dense(1=>1;use_bias=false))
const USTATE = Lux.testmode(last(Lux.setup(Random.Xoshiro(45),UNET)))
uparams(v)=(layer_1=NamedTuple(),layer_2=(weight=reshape(v,1,1),))
const KNOWN = FirstOrderODE((u,t)->[u[2],-u[1]],2)
const UMODEL = AML.UDEProblem(KNOWN,UNET,uparams([-0.2]),USTATE;correction_indices=(2,))
@testset "Native optimization and trajectory UDE" begin
    @test applicable(AML.learned_correction,UMODEL,[2.,3.],0.)
    if applicable(AML.learned_correction,UMODEL,[2.,3.],0.)
        @test AML.learned_correction(UMODEL,[2.,3.],0.) ≈ [0.,-1.6]
        @test AML.learned_vector_field(UMODEL,[2.,3.],0.) ≈ [3.,-3.6]
        tupleknown=FirstOrderODE((u,t)->(u[2],-u[1]),2)
        tuplemodel=AML.UDEProblem(tupleknown,UNET,uparams([-0.2]),USTATE;correction_indices=(2,))
        @test AML.learned_vector_field(tuplemodel,[2.,3.],0.) ≈ [3.,-3.6]
        x=[-1. 0. 1. 0.5;0.2 1. -0.4 0.7]
        d=AML.DerivativeData(x,[x[2,:]';-x[1,:]'])
        fit=AML.train(HMODEL,d;initial_parameters=[0.3,0.7,3.],reconstruct=hparams,
            optimizer=OptimizationOptimisers.Adam(0.03),maxiters=100,history_limit=12)
        @test fit.solution !== nothing
        @test length(fit.history)<=12
        @test fit.provenance.global_correctness === :unknown
        @test fit.provenance.training_data === d
        @test fit.provenance.initial_parameters == [0.3,0.7,3.]
        @test fit.provenance.evidence.status === :unknown
        @test !isempty(fit.provenance.limitations)
        @test AML.dynamics_objective(fit.model,d)<1e-5
        @test fit.model.state === HSTATE
        @test AML.predict(fit,[1.,0.],(0.,1.)).diagnostics.success
        tr=trajectory(FirstOrderODE((u,t)->[u[2],-u[1]-0.2u[1]^3],2),[1.,0.],(0.,1.))
        times=collect(range(0.,1.;length=9))
        obs=AML.TrajectoryData(times,hcat(tr.solution.(times)...))
        @test AML.dynamics_objective(UMODEL,obs)<1e-12
        @test ForwardDiff.gradient(v->AML.dynamics_objective(AML.UDEProblem(KNOWN,UNET,uparams(v),USTATE;correction_indices=(2,)),obs),[-0.1])[1]>0
        uf=AML.train(UMODEL,obs;initial_parameters=[-0.05],reconstruct=uparams,
            optimizer=OptimizationOptimisers.Adam(0.02),maxiters=90)
        @test AML.dynamics_objective(uf.model,obs)<1e-6
        @test abs(AML.learned_correction(uf.model,[0.7,0.2],0.)[2]+0.2*0.7^3)<0.002
        @test uf.model.known === KNOWN
        @test uf.provenance.solver.algorithm isa AML.OrdinaryDiffEqTsit5.Tsit5
        @test uf.provenance.solver.abstol == 1e-9
        @test_throws ArgumentError AML.train(HMODEL,d;initial_parameters=[0.3,0.7,3.],reconstruct=hparams,optimizer=OptimizationOptimisers.Adam(),maxiters=0)
    end
end
if get(ENV,"AML_NEURAL_SKIP_SHOWCASE","false") != "true"
@testset "Executable CPU showcases" begin
    path=joinpath(@__DIR__,"neural_showcase.jl")
    @test isfile(path)
    if isfile(path)
        include(path)
        result=NeuralShowcase.run(;output_dir=get(ENV,"AML_NEURAL_OUTPUT",joinpath(@__DIR__,"artifacts")))
        @test result.metrics.hnn_fit_mse < 1e-5
        @test result.metrics.hnn_heldout_mse < 1e-4
        @test result.metrics.hnn_rollout_rmse < 0.02
        @test result.metrics.ude_fit_rmse < 0.01
        @test result.metrics.ude_heldout_rmse < 0.03
        @test result.metrics.ude_correction_rmse < 0.01
        @test all(isfile,result.figures)
        @test isfile(result.report)
    end
end
end
