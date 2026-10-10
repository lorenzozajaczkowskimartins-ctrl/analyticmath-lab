# Standalone public workflow: julia --project=. test/stranger/student.jl
using AnalyticMathLab
using Test, Symbolics
@testset "Stranger student scalar and multivariate analysis" begin
    @variables x y
    report=analyze(x^2+2x,x)
    @test evaluate(report,3)==15
    @test evaluate(report,3;order=1)==8
    for T in (Int,Float32,Float64,BigFloat)
        value=evaluate(report,T(3))
        @test value==15
        @test value isa T
    end
    @test evaluate(report,1+im)==2+4im
    field=analyze(x^2+3y^2,(x,y))
    @test gradient(field,[1.,2.])==[2.,12.]
    @test hessian(field,[1.,2.])==[2. 0.;0. 6.]
    @test_throws DimensionMismatch gradient(field,[1.])
    @test_throws ArgumentError analyze(x+y,x)
    result=PropertyResult(2.,:heuristic,:user_measurement,["Caller claim, not certified."])
    @test result.value==2.
    @test fieldnames(typeof(result))==(:value,:status,:method,:notes)
end
println("STRANGER_PASS student")
