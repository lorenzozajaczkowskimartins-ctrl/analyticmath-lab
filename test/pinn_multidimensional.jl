module PINNMultidimensionalTests
using Test, AnalyticMathLab
include(joinpath(@__DIR__,"..","examples","pinn","benchmarks.jl"))
const B=PINNBenchmarks
@testset "M9B multidimensional residual identities" begin
    for name in (:heat,:poisson2d,:coupled)
        @testset "$name" begin
            run=B.run(name;maxiters=2,hidden=[4],n=3)
            a=run.analysis; s=run.spec
            @test size(a.reference.value.prediction)==(s.outputs,9)
            @test length(a.residuals)==length(run.problem.backend_metadata.blocks)
            @test count(r->r.role==:pde,a.residuals)==s.pdes
            @test count(r->r.role==:ic,a.residuals)==length(s.ic)
            @test all(r->all(isfinite,r.values),a.residuals)
            @test all(r->r.summary.count==size(r.points.coordinates,2),a.residuals)
            @test all(r->r.sampling.outside_domain_count==0,a.residuals)
            @test all(r->r.sampling.snapshot_overlap_count==0,a.residuals)
            @test all(i->isequal(a.residuals[i].equation,run.problem.backend_metadata.blocks[i].eq),eachindex(a.residuals))
            @test a.collocation_metadata.strategy.semantics==:deterministic_grid
            @test a.collocation_metadata.strategy.coverage_claim==:none
            @test a.adaptive_loss_metadata.value===nothing
            @test a.evidence.status==:unknown
            @test pinnplot(a) isa AnalyticMathLab.Makie.Figure
            @test residualplot(a) isa AnalyticMathLab.Makie.Figure
            @test collocationplot(a) isa AnalyticMathLab.Makie.Figure
            @test errorplot(a;variable=s.outputs) isa AnalyticMathLab.Makie.Figure
            # Independent derivative check of each coupled equation, not a loss check.
            if name==:coupled
                X=a.residuals[1].points.coordinates; h=1e-3
                dx=zeros(size(X)); dx[1,:].=h
                dt=zeros(size(X)); dt[2,:].=h
                Y=predict(run.result,X)
                ut=(predict(run.result,X+dt)-predict(run.result,X-dt))/(2h)
                uxx=(predict(run.result,X+dx)-2Y+predict(run.result,X-dx))/h^2
                @test a.residuals[1].values≈vec(ut[1,:]-0.1uxx[1,:]-Y[2,:]) atol=1e-4
                @test a.residuals[2].values≈vec(ut[2,:]-0.1uxx[2,:]+Y[1,:]) atol=1e-4
            end
        end
    end
end
end
