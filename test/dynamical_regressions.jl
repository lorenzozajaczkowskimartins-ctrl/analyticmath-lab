module DynamicalRegressionTests
using Test, AnalyticMathLab, Symbolics
import Makie, SciMLBase, OrdinaryDiffEqTsit5, LinearAlgebra
@variables x y
@testset "Dynamical display and numerical contracts" begin
    r = analyze(AutonomousSystem([y,-x],(x,y)))
    text = sprint(show,MIME"text/plain"(),r)
    @test occursin("eigenvalues",text)
    @test occursin("exact_linear_system",text)
    @test occursin("x′",text)
    @test length(sprint(show,r)) < 200
    path = @test_logs trajectory(FirstOrderODE((u,t)->[-u[1]],1),[1],(0,1);saveat=0.2)
    @test hasproperty(path.diagnostics,:completed)
    @test path.solution.dense
    @test path.solution(0.35)[1] ≈ exp(-0.35) atol=1e-6
    @test all(t -> t in path.solution.t, 0.0:0.2:1.0)
    @test length(path.solution.t) > length(0.0:0.2:1.0)
    @test ismissing(Makie.current_backend())
    @test all(m -> nameof(m) ∉ (:CairoMakie,:GLMakie),values(Base.loaded_modules))
    ambiguities = Test.detect_ambiguities(AnalyticMathLab,Symbolics,Makie,LinearAlgebra,SciMLBase,OrdinaryDiffEqTsit5;recursive=false)
    @test isempty(filter(pair -> any(m -> m.module === AnalyticMathLab,pair),ambiguities))
end
@testset "Dense save interval in both directions" begin
    decay = FirstOrderODE((u,t)->[-u[1]],1)
    for (span, initial, query) in (((0.0,1.0),1.0,0.35), ((1.0,0.0),exp(-1),0.65))
        path = @test_logs trajectory(decay,initial,span;saveat=0.3)
        grid = span[1]:copysign(0.3,span[2]-span[1]):span[2]
        @test all(t -> t in path.solution.t,grid)
        @test first(path.solution.t) == span[1]
        @test last(path.solution.t) == span[2] # final endpoint off the interval grid
        @test path.diagnostics.success && path.diagnostics.completed
        @test path.solution.dense
        @test path.solution(query)[1] ≈ exp(-query) atol=1e-6
        @test all(>(0), diff(path.solution.t) .* sign(span[2]-span[1]))
    end
end
@testset "Bounded representable save interval" begin
    constant = FirstOrderODE((u,t)->[0.0],1)
    @test_throws ArgumentError trajectory(constant,1.0,(0,1);saveat=big"1e400")
    @test_throws ArgumentError trajectory(constant,1.0,(0,1);saveat=big"1e-400")
    @test_throws ArgumentError trajectory(constant,1.0,(0,1);saveat=1/1_000_001,maxiters=1)
    @test_throws ArgumentError trajectory(constant,1.0,(1e16,1e16+10);saveat=0.5,maxiters=1)
end
@testset "Save interval preserves partial-solution diagnostics" begin
    decay = FirstOrderODE((u,t)->[-u[1]],1)
    for span in ((0.0,1.0),(1.0,0.0))
        path = @test_logs (:warn,r"Interrupted. Larger maxiters is needed") trajectory(
            decay,exp(-span[1]),span;saveat=0.2,dt=0.01,maxiters=1)
        @test !path.diagnostics.success
        @test !path.diagnostics.completed
        @test path.diagnostics.retcode == SciMLBase.ReturnCode.MaxIters
        @test path.diagnostics.final_time == last(path.solution.t)
        @test min(span...) < path.diagnostics.final_time < max(span...)
        @test path.diagnostics.accepted_steps == path.solution.stats.naccept > 0
        @test path.diagnostics.rejected_steps == path.solution.stats.nreject
        @test path.solution.dense
        query = (span[1]+path.diagnostics.final_time)/2
        @test path.solution(query)[1] ≈ exp(-query) atol=1e-6
    end
end
@testset "Nonlinear imaginary spectrum through the public API" begin
    r = analyze(AutonomousSystem([-y+x^3,x],(x,y);bounds=((-0.5,0.5),(-0.5,0.5)),grid=3))
    @test r.equilibria.status == :heuristic
    @test !isempty(r.equilibria.value)
    @test all(e -> e.local_analysis.stability.value == :inconclusive,r.equilibria.value)
    @test all(e -> e.local_analysis.stability.status == :unknown,r.equilibria.value)
    @test all(e -> e.local_analysis.stability.value != :center,r.equilibria.value)
end
end
