module TrajectoryTests
using Test, AnalyticMathLab
@testset "Numerical first-order problem interface" begin
    @test isdefined(AnalyticMathLab, :FirstOrderODE)
    @test isdefined(AnalyticMathLab, :trajectory)
    if isdefined(AnalyticMathLab, :FirstOrderODE)
        problem = FirstOrderODE((u,t) -> [-2t*u[1]], 1; labels=("y",))
        result = trajectory(problem, [1.0], (0.0,1.0); abstol=1e-10,reltol=1e-10,saveat=0.1)
        @test result.diagnostics.success
        @test result.solution.u[end][1] ≈ exp(-1) atol=1e-8
        @test result.diagnostics.final_time == 1.0
        @test result.diagnostics.accepted_steps > 0
        @test result.diagnostics.rejected_steps >= 0
        @test result.labels == ("y",)
        @test_throws DimensionMismatch trajectory(problem, [1.0,2.0], (0,1))
        @test_throws DomainError trajectory(problem, [Inf], (0,1))
        @test_throws ArgumentError trajectory(problem, [1.0], (0,0))
        @test_throws ArgumentError trajectory(problem, [1.0], (0,1);reltol=0)
        @test_throws ArgumentError FirstOrderODE((u,t)->u, 0)
        @test_throws DimensionMismatch FirstOrderODE((u,t)->u, 2;labels=("x",))
        @test_throws DimensionMismatch trajectory(FirstOrderODE((u,t)->[1,2],1),[1.0],(0,1))
        @test_throws DomainError trajectory(FirstOrderODE((u,t)->[NaN],1),[1.0],(0,1))
        restricted = FirstOrderODE((u,t)->[-1.0],1; domain=(u,t)->u[1]>0)
        @test_throws DomainError trajectory(restricted,[-1.0],(0,1))
        @test_throws DomainError trajectory(restricted,[0.2],(0,1))
    end
end
using Symbolics
@variables x v
@testset "Autonomous trajectories reuse checked field values" begin
    report = analyze(AutonomousSystem([v,-x],(x,v)))
    @test applicable(trajectory,report,[1,0],(0,1))
    if applicable(trajectory,report,[1,0],(0,1))
        path = trajectory(report,[1,0],(0,2pi);saveat=0.05,abstol=1e-10,reltol=1e-10)
        @test path.diagnostics.success
        @test path.solution.u[end] ≈ [1,0] atol=1e-7
        @test maximum(abs(sum(abs2,u)-1) for u in path.solution.u) < 1e-7
        damped = analyze(AutonomousSystem([v,-x-v],(x,v)))
        d = trajectory(damped,[1,0],(0,15))
        @test d.diagnostics.success
        @test sum(abs2,d.solution.u[end]) < 1e-5
        logistic = analyze(AutonomousSystem([x*(1-x)],(x,)))
        l = trajectory(logistic,0.25,(0,2))
        @test l.solution.u[end][1] ≈ 1/(1+3exp(-2)) atol=1e-6
        hole = analyze(AutonomousSystem(@real_function([x/x]),(x,)))
        @test_throws DomainError trajectory(hole,[0],(0,1))
        @test_throws DomainError trajectory(hole,[-1],(0,2);dt=1)
        unknown = analyze(AutonomousSystem([x],(x,);original_expression=[:(mystery(x))]))
        @test_throws DomainError trajectory(unknown,[1],(0,1))
        @test !hasproperty(FirstOrderODE((u,t)->[-2t*u[1]],1),:equilibria)
    end
end
end
