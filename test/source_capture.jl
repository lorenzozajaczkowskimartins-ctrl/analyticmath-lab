using Test
using Symbolics
using AnalyticMathLab

@testset "Original expression capture before symbolic cancellation" begin
    @test isdefined(AnalyticMathLab, :RealExpression)
    @test isdefined(AnalyticMathLab, Symbol("@real_function"))
    if isdefined(AnalyticMathLab, Symbol("@real_function"))
        # eval is confined to test syntax so this file loads before the macro exists.
        @eval begin
            @variables capture_x
            captured = @real_function capture_x / capture_x
            @test captured isa RealExpression
            @test captured.expression == 1
            @test captured.original == :(capture_x / capture_x)
            @test (@real_function sqrt(capture_x^2)).original == :(sqrt(capture_x^2))
            @test (@real_function 5).original == 5
        end
    end
end
