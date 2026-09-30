# Optional serial CPU gate; not included by base Pkg.test().
using Test, AnalyticMathLab, Random
import NeuralPDE, ModelingToolkit, ADTypes, SymbolicIndexingInterface
import OptimizationOptimisers
using ModelingToolkit: @parameters, @variables, @named, Differential, PDESystem

function inverse_fixture(;param_estim=true,observations=false)
    @parameters x t alpha
    @variables u(..)
    Dx=Differential(x); Dt=Differential(t)
    @named sys=PDESystem([Dt(u(x,t)) ~ alpha*Dx(Dx(u(x,t)))],
        [u(0.,t) ~ 0.,u(1.,t) ~ 0.,u(x,0.) ~ sin(pi*x)],
        [x ∈ (0.,1.),t ∈ (0.,1.)],[x,t],[u(x,t)],[alpha];
        initial_conditions=Dict(alpha=>0.3))
    truth=0.1
    exact=z->[sin(pi*z[1])*exp(-truth*pi^2*z[2])]
    @testset "Inverse heat reference consistency before training" begin
        @test only(exact([0.,0.4])) == 0.
        @test abs(only(exact([1.,0.4]))) < 1e-15
        @test only(exact([0.37,0.])) ≈ sin(pi*0.37)
        z=[0.37,0.41]
        f=y->only(exact(y))
        g=AnalyticMathLab.ForwardDiff.gradient(f,z)
        h=AnalyticMathLab.ForwardDiff.hessian(f,z)
        @test g[2] ≈ truth*h[1,1] atol=1e-12
    end
    Xfit=reduce(hcat,([a,b] for a in (0.23,0.51,0.79) for b in (0.19,0.47,0.83)))
    yfit=reduce(hcat,exact.(eachcol(Xfit)))
    # Documented NeuralPDE 7.3 NamedTuple trial-solution callback.
    observation_loss=(phi,theta,p)->sum(abs2,phi.u(Xfit,theta.u).-yfit)/size(Xfit,2)
    problem=pinn_problem(sys;network=pinn_network(2,1;hidden=[12,12]),
        strategy=NeuralPDE.GridTraining(0.1),rng=Xoshiro(42),
        adtype=ADTypes.AutoZygote(),param_estim,
        additional_loss=observations ? observation_loss : nothing,
        provenance=(benchmark=:inverse_heat,seed=42,observation_count=observations ? 9 : 0))
    (;problem,alpha,truth,exact,Xfit,yfit)
end

@testset "inverse physical parameter forwarding" begin
    f=inverse_fixture()
    @test SymbolicIndexingInterface.is_variable(f.problem.optimization_problem,f.alpha)
    @test f.problem.optimization_problem[f.alpha] == 0.3
end

@testset "physical parameter provenance" begin
    f=inverse_fixture()
    @test f.problem.provenance.physical_parameters.param_estim === true
    @test isequal(f.problem.provenance.physical_parameters.declared,[f.alpha])
    @test isequal(f.problem.provenance.physical_parameters.inferred,[f.alpha])
    fixed=inverse_fixture(;param_estim=false)
    @test !SymbolicIndexingInterface.is_variable(fixed.problem.optimization_problem,fixed.alpha)
    @test isempty(fixed.problem.provenance.physical_parameters.inferred)
end

# Run with `construction` for only the lightweight contract checks.
if isempty(ARGS)
    @testset "bounded inverse heat with withheld diagnostics" begin
        f=inverse_fixture(;observations=true)
        first_stage=AnalyticMathLab.train(f.problem,OptimizationOptimisers.Adam(0.01);
            maxiters=3000,history=true,record_components=true,log_every=100)
        r=AnalyticMathLab.train(first_stage,OptimizationOptimisers.Adam(0.001);
            maxiters=2000,history=true,record_components=true,log_every=100)
        estimate=r.solution.original_sol[f.alpha]
        @test estimate == r.backend_solution[f.alpha]
        Xheld=reduce(hcat,([a,b] for a in range(0.037,0.957;length=13)
            for b in range(0.041,0.953;length=11)))
        @test isempty(intersect(Set(Tuple.(eachcol(f.Xfit))),Set(Tuple.(eachcol(Xheld)))))
        points=Dict(i=>PINNPoints(i==1 ? Xheld : reshape(collect(range(0.037,0.957;length=17)),1,:);
            generation=:offset_grid,provenance=(purpose=:withheld_diagnostics,))
            for i in eachindex(f.problem.backend_metadata.blocks))
        a=analyze(r;residual_points=points,condition_roles=Dict(4=>:ic),
            reference_points=points[1],reference=f.exact,
            reference_provenance=(kind=:analytical,alpha=f.truth,evaluation_points_used_for_fit=false))
        fit_rms=sqrt(sum(abs2,predict(r,f.Xfit).-f.yfit)/length(f.yfit))
        alpha_error=abs(estimate-f.truth)/f.truth
        println("INVERSE HEAT alpha_true=",f.truth," alpha_initial=0.3 alpha_estimate=",estimate,
            " relative_parameter_error=",alpha_error)
        println("objective=",a.loss_diagnostics.objective," evaluated_objective=",a.loss_diagnostics.evaluated_objective,
            " fit_rms=",fit_rms," heldout_rms=",only(a.reference.value.summary).rms,
            " heldout_max=",only(a.reference.value.summary).max_absolute)
        println("stage1_termination=",first_stage.termination," stage2_termination=",r.termination)
        for block in a.residuals
            println("block=",block.index," role=",block.role," rms=",block.summary.rms,
                " max=",block.summary.max_absolute," snapshot_overlap=",block.sampling.snapshot_overlap_count)
        end
        println("packages=",f.problem.provenance.packages)
        println("global_correctness=",a.evidence.status,"; finite-difference derivatives; noiseless single-seed benchmark")
        @test isfinite(estimate) && estimate>0
        @test alpha_error<0.15
        @test fit_rms<0.05
        @test only(a.reference.value.summary).rms<0.05
        @test a.residuals[1].summary.rms<0.1
        @test all(b->all(isfinite,b.values),a.residuals)
        @test all(b->b.sampling.snapshot_overlap_count==0,a.residuals)
        @test a.evidence.status==:unknown
        # Check diagnostics use inferred alpha, not the 0.3 initial guess.
        h=1e-4; dx=zeros(size(Xheld)); dx[1,:].=h
        dt=zeros(size(Xheld)); dt[2,:].=h
        ut=(predict(r,Xheld+dt)-predict(r,Xheld-dt))/(2h)
        uxx=(predict(r,Xheld+dx)-2predict(r,Xheld)+predict(r,Xheld-dx))/h^2
        @test a.residuals[1].values ≈ vec(ut-estimate*uxx) atol=2e-4
    end
elseif ARGS != ["construction"]
    error("usage: inverse_heat_gate.jl [construction]")
end
