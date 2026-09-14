module VectorZeroTests
using Test, AnalyticMathLab, Symbolics
@variables x y
@testset "Field zeros have residual evidence, not stability" begin
    r = analyze([-y,x],(x,y))
    @test r.field_zeros.status == :established
    if r.field_zeros.status == :established
        p = only(r.field_zeros.value)
        @test p.point == [0,0]
        @test p.residual_norm == 0
        @test !hasproperty(p,:classification)
        @test !hasproperty(p,:eigenvalues)
        e = analyze(@real_function([x^2/x,y]),(x,y))
        @test e.field_zeros.status == :established
        @test isempty(e.field_zeros.value)
        s = analyze([x^2-1,y^2-1],(x,y))
        @test s.field_zeros.status == :established
        @test length(s.field_zeros.value) == 4
        u = analyze([sin(x),y],(x,y))
        @test u.field_zeros.status == :unknown
        h = analyze([sin(x),y],(x,y);bounds=((-1,1),(-1,1)),grid=3,
            residual_tolerance=1e-9,residual_rtol=1e-8,residual_scale=2)
        @test h.field_zeros.status == :heuristic
        @test !isempty(h.field_zeros.value)
        @test all(p -> p.residual_norm <= p.residual_threshold == 1e-9+2e-8,h.field_zeros.value)
        @test all(p -> maximum(abs,p.point) < 1e-6,h.field_zeros.value)
        q = analyze([sin(x),y,x+y],(x,y);bounds=((-1,1),(-1,1)),grid=3)
        @test q.field_zeros.status == :heuristic
        @test !isempty(q.field_zeros.value)
        @test all(p -> p.residual_norm <= p.residual_threshold,q.field_zeros.value)
        @test_throws ArgumentError analyze([x,y],(x,y);residual_tolerance=0)
        @test_throws ArgumentError analyze([x,y],(x,y);bounds=((1,0),(-1,1)))
        @test_throws ArgumentError analyze([x,y],(x,y);grid=100)
        @test_throws ArgumentError analyze([x,y],(x,y);iterations=0)
        @test_throws ArgumentError analyze([x,y],(x,y);residual_scale=Inf)
    end
end
end
