module M10BShowcases
using Test, AnalyticMathLab, Symbolics, LinearAlgebra
@variables x
@testset "M10B required numerical demonstrations" begin
    shifted=analyze(1+x,x)
    cancellation=map((128,256)) do bits
        setprecision(BigFloat,bits) do
            delta=BigFloat(2)^(-160)
            recovered=evaluate(shifted,delta)-1
            println("A cancellation bits=",bits," recovered=",recovered," exact increment=",delta)
            recovered
        end
    end
    @test iszero(cancellation[1])
    @test cancellation[2]==BigFloat(2)^(-160)
    large=BigFloat("1e400")
    summary=sampled_summary([large,-large])
    @test summary.rms===large || summary.rms==large
    @test summary.rms isa BigFloat && isfinite(summary.rms)
    println("B generic RMS beyond Float64: ",summary.rms," type=",typeof(summary.rms))

    square=analyze(x^2,x)
    delta=2.0^-13
    oracle=2BigFloat(delta)+BigFloat(delta)^2
    errors=map((Float32,Float64)) do T
        value=evaluate(square,T(1)+T(delta))-T(1)
        error=abs(BigFloat(value)-oracle)
        @test isfinite(value) && value>0
        println("C cancellation type=",T," value=",value," absolute error=",error)
        error
    end
    @test errors[1]>errors[2]

    values=2.0^28 .+ [-2.,-1.,1.,2.]
    reference=setprecision(BigFloat,512) do
        v=BigFloat.(values); mean=sum(v)/length(v)
        sum((v.-mean).^2)/(length(v)-1)
    end
    variance=statistical_summary(ObservableSeries(values)).value.variance
    naive=(sum(abs2,values)-sum(values)^2/length(values))/(length(values)-1)
    @test abs(BigFloat(variance)-reference)<abs(BigFloat(naive)-reference)
    println("D offset variance AML=",variance," reference=",reference," naive=",naive)
    for T in (Float32,Float64,BigFloat,Rational{Int})
        mass=Diagonal(T[1,1//1000000])
        modes=normal_modes(Matrix{T}(I,2,2),mass)
        @test modes.evidence.status==:heuristic
        @test modes.eigenvalues ≈ [1.,1e6] rtol=8eps(Float32)
        println("E mass type=",T," eigenvalues=",modes.eigenvalues," backend=",modes.metadata.arithmetic)
    end
    @test normal_modes(Matrix{Float64}(I,2,2),Diagonal([1.,eps(Float64)/4])).evidence.status==:unknown
end
end
