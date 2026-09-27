# Explicit opt-in CPU gates, sequential. Not included by Pkg.test().
# julia +release --project=examples/pinn examples/pinn/benchmark_gate.jl standard
# julia +release --project=examples/pinn examples/pinn/benchmark_gate.jl burgers
# julia +release --project=examples/pinn examples/pinn/benchmark_gate.jl navier-stokes
using Test, AnalyticMathLab
include("benchmarks.jl")
const B=PINNBenchmarks
length(ARGS)==1 || error("choose standard, burgers or navier-stokes")
mode=only(ARGS)
mode in ("standard","burgers","navier-stokes") || error("unknown gate")
using CairoMakie
CairoMakie.activate!()
out=joinpath(@__DIR__,"..","..","notebooks","output")
mkpath(out)
let
if mode=="standard"
    for name in (:poisson2d,:coupled)
        run=B.run(name;maxiters=1500,n=15)
        B.report(run)
        a=run.analysis
        @testset "M9B $name integration" begin
            @test all(s->isfinite(s.rms),a.reference.value.summary)
            @test maximum(s.max_absolute for s in a.reference.value.summary)<0.35
            @test all(r->all(isfinite,r.values),a.residuals)
            @test a.evidence.status==:unknown
            @test length(a.reference.value.summary)==run.spec.outputs
        end
        save(joinpath(out,"m9b_$(name)_panel.png"),pinnplot(a))
    end
    # Same physical problem, network, seed, evaluation points and iteration budget.
    # Initialization RNG is reused by seed, not a promise of comparable sample sets.
    for strategy in (B.NeuralPDE.GridTraining(0.25),B.NeuralPDE.StochasticTraining(16))
        run=B.run(:heat;strategy,maxiters=200,n=9)
        println("STRATEGY COMPARISON ",run.analysis.collocation_metadata.strategy.semantics)
        B.report(run)
        @test all(r->all(isfinite,r.values),run.analysis.residuals)
        @test run.analysis.collocation_metadata.strategy.coverage_claim==:none
    end
elseif mode=="burgers"
    run=B.run(:burgers;maxiters=500,n=15)
    B.report(run)
    @testset "M9B optional Burgers demonstrator" begin
        @test all(r->all(isfinite,r.values),run.analysis.residuals)
        @test isfinite(run.analysis.reference.value.summary[1].rms)
        @test run.analysis.evidence.status==:unknown
    end
    save(joinpath(out,"m9b_burgers_panel.png"),pinnplot(run.analysis))
else
    run=B.run(:navier_stokes;maxiters=2,strategy=B.NeuralPDE.GridTraining(0.5),hidden=[4],n=3)
    B.report(run)
    a=run.analysis
    @testset "M9B bounded Navier-Stokes stress" begin
        @test run.spec.labels==[:x_momentum,:y_momentum,:incompressibility]
        @test size(a.reference.value.prediction)==(3,27)
        @test getproperty.(run.problem.network_mapping,:output)==[1,2,3]
        @test length(a.residuals)==14
        @test count(r->r.role==:pde,a.residuals)==3
        @test count(r->r.role==:ic,a.residuals)==2
        @test all(r->all(isfinite,r.values),a.residuals)
        @test a.evidence.status==:unknown
        @test run.result.termination.requested_maxiters==2
        @test all(ismissing,a.reference.value.relative_error[2:3,:])
        # Independent pointwise finite-difference check of incompressibility.
        X=a.residuals[3].points.coordinates; h=1e-4
        dx=zeros(size(X)); dx[1,:].=h
        dy=zeros(size(X)); dy[2,:].=h
        du=(predict(run.result,X+dx)-predict(run.result,X-dx))/(2h)
        dv=(predict(run.result,X+dy)-predict(run.result,X-dy))/(2h)
        @test a.residuals[3].values≈vec(du[1,:]+dv[2,:]) atol=1e-5
        no_reference=analyze(run.result;residual_points=Dict(i=>a.residuals[i].points for i in 1:3))
        @test no_reference.reference.value===nothing
        @test all(r->r.evidence.status==:heuristic,no_reference.residuals[1:3])
    end
    fig=Figure(size=(1100,850))
    for i in 1:3
        ax=Axis(fig[i,1];xlabel="Supplied 3D sample index (not spatial distance)",
            ylabel="Signed residual",title=string(run.spec.labels[i]))
        scatter!(ax,eachindex(a.residuals[i].values),a.residuals[i].values)
    end
    Label(fig[4,1],"Two optimizer steps: structural stress only, not validated CFD or global correctness.")
    save(joinpath(out,"m9b_navier_stokes_residuals.png"),fig)
    save(joinpath(out,"m9b_navier_stokes_components.png"),losscomponentsplot(a))
end
println("GATE COMPLETE: ",mode)
end
