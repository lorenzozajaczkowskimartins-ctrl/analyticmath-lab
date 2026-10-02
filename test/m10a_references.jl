module M10AReferenceTests
using Test, Symbolics, AnalyticMathLab
const helper = joinpath(@__DIR__, "..", "examples", "validation", "reference_checks.jl")
@testset "M10A sampled reference gate before use" begin
    @test isfile(helper)
    if isfile(helper)
        include(helper)
        @variables x t u(..) v(..)
        Dx = Differential(x); Dt = Differential(t)
        points = [[0.17, 0.13], [0.43, 0.29], [0.79, 0.61]]
        eqs = [Dt(u(x,t)) ~ 0.1Dx(Dx(u(x,t)))]
        bcs = [u(0,t) ~ 0, u(1,t) ~ 0, u(x,0) ~ sin(pi*x)]
        reference = q -> [sin(pi*q[1])*exp(-0.1pi^2*q[2])]
        check(ref; equations=eqs, conditions=bcs) = ReferenceChecks.check_reference(
            ref, [x,t], [u(x,t)], equations, conditions, points; atol=1e-11, rtol=1e-11)
        evidence = check(reference)
        @test evidence.status == :heuristic
        @test evidence.method == :sampled_reference_substitution
        @test evidence.value.equation_count == 1
        @test evidence.value.condition_count == 3
        @test evidence.value.sample_count == 3
        @test evidence.value.maximum_residual < 1e-11
        # Exercise each boundary/initial identity independently, not just a count.
        for condition in bcs
            @test check(reference;conditions=[condition]).status == :heuristic
        end
        # Constant shift preserves the PDE but fails the declared homogeneous BCs.
        @test_throws ArgumentError check(q -> [reference(q)[1]+1.];conditions=bcs[1:2])
        @test_throws ArgumentError check(q -> [v(q[1],q[2])])
        @test_throws ArgumentError check(q -> [sin(pi*q[1])*exp(-0.1*q[2])])
        # PDE-consistent but IC-inconsistent references must also be refused.
        @test_throws ArgumentError check(q -> [2sin(pi*q[1])*exp(-0.1pi^2*q[2])])
        @test_throws ArgumentError check(reference; equations=[Dt(u(x,t)) ~ -0.1Dx(Dx(u(x,t)))])
        @test_throws ArgumentError check(reference; conditions=[u(x,0) ~ sin(x)])
        @test_throws DimensionMismatch check(q -> [reference(q)..., 0.])
        @test_throws ArgumentError ReferenceChecks.check_reference(reference,[x,t],[u(x,t)],eqs,bcs,Vector{Float64}[];atol=1e-11,rtol=1e-11)
        # The gate itself executes before a consumer, not a caught failure after use.
        used = Ref(false)
        consume(ref) = (check(ref); used[] = true)
        @test_throws ArgumentError consume(q -> [sin(x)*exp(-q[2])])
        @test !used[]
    end
end
end
