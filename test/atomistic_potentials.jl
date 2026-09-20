using Test
using Symbolics
using AnalyticMathLab

@testset "Scalar radial potential contract" begin
    @test isdefined(AnalyticMathLab, :analyze_potential)
    if isdefined(AnalyticMathLab, :analyze_potential)
        @variables r a
        p = AnalyticMathLab.analyze_potential((r-2)^2, r; interval=(0.5, 4),
            provenance=(source=:test,), units=(length=:nm, energy=:kJ), cutoff=3)
        @test p isa AnalyticMathLab.AbstractAnalysis
        @test p.function_analysis isa AnalyticMathLab.FunctionAnalysis
        @test AnalyticMathLab.evaluate(p, 3) ≈ 1
        @test p.numerical.force(3) ≈ -2
        @test AnalyticMathLab.domain_contains(p.radial_domain, -1) === false
        @test AnalyticMathLab.domain_contains(p.radial_domain, 0) === false
        @test AnalyticMathLab.domain_contains(p.radial_domain, 2) === true
        @test p.equilibria.status == :established
        @test only(p.equilibria.value).x == 2
        @test p.cutoff.radius == 3
        @test p.cutoff.modification == :none
        @test p.units.length == :nm
        @test p.provenance.source == :test
        @test_throws DomainError AnalyticMathLab.evaluate(p, 0)
        @test_throws ArgumentError AnalyticMathLab.analyze_potential(a/r, r)
        @test_throws ArgumentError AnalyticMathLab.analyze_potential(1/r, r; interval=(-1, 2))
        @test_throws ArgumentError AnalyticMathLab.analyze_potential(1/r, r; cutoff=-1)
        hole = AnalyticMathLab.analyze_potential(@real_function((r-1)/(r-1)), r)
        @test AnalyticMathLab.domain_contains(hole.radial_domain, 1) === false
        @test_throws DomainError AnalyticMathLab.evaluate(hole, 1)
        @test_throws ArgumentError AnalyticMathLab.analyze_potential(@real_function((r-1)/(r-1)), r; interval=(0.5,2))
    end
end

@testset "Lennard-Jones derived certificate" begin
    @test isdefined(AnalyticMathLab, :lennard_jones_analysis)
    if isdefined(AnalyticMathLab, :lennard_jones_analysis)
        p = AnalyticMathLab.lennard_jones_analysis(; epsilon=2.0, sigma=1.5, interval=(1.2,4.5))
        rmin = 2^(1/6)*1.5
        @test AnalyticMathLab.evaluate(p, 1.5) ≈ 0 atol=1e-12
        @test AnalyticMathLab.evaluate(p, rmin) ≈ -2 atol=1e-12 # radius is a Float64 approximation
        @test p.numerical.force(rmin) ≈ 0 atol=1e-10
        @test p.numerical.force(1.4) > 0
        @test p.numerical.force(2.0) < 0
        h=1e-5
        @test p.numerical.force(2.0) ≈ -(evaluate(p,2.0+h)-evaluate(p,2.0-h))/(2h) rtol=1e-8
        @test evaluate(p,0.1) > 0
        @test abs(evaluate(p,150.)) < abs(evaluate(p,15.))
        @test evaluate(p,150.) < 0
        @test abs(p.numerical.force(150.)) < abs(p.numerical.force(15.))
        @test_throws DomainError evaluate(p,-1.)
        @test_throws DomainError evaluate(p,0.)
        @test_throws DomainError evaluate(p,Inf)
        @test p.equilibria.status == :established
        @test p.evidence.minimum.method == :scaled_sixth_power_identity
        @test all(values(p.evidence.minimum.value.identities))
        point = only(p.equilibria.value)
        @test point.x ≈ rmin
        @test point.value == -2
        @test point.curvature ≈ 72*2/rmin^2
        @test point.classification == :minimum
        @test AnalyticMathLab.domain_contains(p.radial_domain, rmin) === true
        @test AnalyticMathLab.domain_contains(p.radial_domain, 0) === false
        @test !isempty(p.limitations)
        for bad in (0, -1, Inf, NaN)
            @test_throws ArgumentError AnalyticMathLab.lennard_jones_analysis(; epsilon=bad)
            @test_throws ArgumentError AnalyticMathLab.lennard_jones_analysis(; sigma=bad)
        end
    end
end
