module VectorCalculusTests
using Test, AnalyticMathLab, Symbolics
@variables x y z
zeroexpr(e) = iszero(Symbolics.simplify(e; expand=true))
@testset "Vector calculus and verified potentials" begin
    r = analyze([-y,x],(x,y))
    @test r.divergence.status == :established
    if r.divergence.status == :established
        @test divergence(r).value == 0
        @test curl(r).value == 2
        @test r.conservative.status == :established
        @test r.conservative.value === false
        @test potential(r).status == :unknown
        for F in ([2x,2y], [2x+y,x+2y], [4x^3,6y^2])
            q = analyze(F,(x,y))
            @test q.conservative.status == :established
            @test q.conservative.value === true
            @test potential(q).status == :established
            for i in 1:2
                @test zeroexpr(Symbolics.expand_derivatives(Differential(q.variables[i])(potential(q).value))-F[i])
            end
        end
        p = analyze([-y/(x^2+y^2),x/(x^2+y^2)],(x,y))
        @test zeroexpr(curl(p).value)
        @test p.conservative.status == :unknown
        @test potential(p).status == :unknown
        @test domain_contains(p.domain,(0,0)) === false
        t = analyze([y,z,x],(x,y,z))
        @test divergence(t).value == 0
        @test curl(t).value == [-1,-1,-1]
        q = analyze([x+y,x-y,x^2],(x,y))
        @test divergence(q).status == :unknown
        @test curl(q).status == :unknown
        @test q.conservative.status == :unknown
        @test potential(q).status == :unknown
        @test curl(analyze([x],(x,))).status == :unknown
        a = analyze([2x+y+1,x-3y],(x,y))
        l = linearization(a,(1,2))
        @test size(l.coefficients) == (2,2)
        @test all(zeroexpr.(l.expression .- collect(a.components)))
        lr = linearization(q,(1,2))
        @test length(lr.expression) == 3
        @test size(lr.coefficients) == (3,2)
    end
end
end
