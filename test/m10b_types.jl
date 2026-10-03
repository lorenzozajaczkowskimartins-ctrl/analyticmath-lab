module M10BTypesTests
using Test, AnalyticMathLab, Symbolics

@variables x y

@testset "M10B M1 generic algebraic evaluation and promotion" begin
    polynomial = analyze(x^3 + 2x + 1, x)
    for T in (Float32, Float64)
        a = T(0.5)
        @test evaluate(polynomial, a) === a^3 + 2a + 1
        @test evaluate(polynomial, a; order=1) === 3a^2 + 2
        @test evaluate(polynomial, a; order=2) === 6a
    end
    # Generated literal constants follow Julia promotion, not the input type.
    promoted = analyze(x + 0.5, x)
    @test evaluate(promoted, Float32(1)) === 1.5
    constant = analyze(Symbolics.Num(3), x)
    @test evaluate(constant, Float32(1)) == 3
    @test evaluate(constant, Float32(1); order=1) == 0
    for a in (2, BigInt(2), 2//3, BigInt(2)//BigInt(3))
        expected = a^3 + 2a + 1
        actual = evaluate(polynomial, a)
        @test actual == expected
        @test actual isa Union{Integer,Rational}
        @test evaluate(polynomial, a; order=1) == 3a^2 + 2
        @test evaluate(polynomial, a; order=2) == 6a
    end
    # Complex is meaningful for algebraic scalar callables, not real-field APIs.
    z = ComplexF64(0.5, 0.75)
    @test evaluate(polynomial, z) == z^3 + 2z + 1
    @test evaluate(polynomial, z; order=1) == 3z^2 + 2
    @test evaluate(polynomial, z; order=2) == 6z
    @test_throws MethodError compare_derivatives(polynomial, z)
end

@testset "M10B true BigFloat precision, not widened Float64" begin
    square = analyze(x^2, x)
    for bits in (128, 256)
        setprecision(BigFloat, bits) do
            # Both increments disappear in Float64; at 256 bits the second also
            # distinguishes genuine 256-bit arithmetic from a 128-bit detour.
            delta = BigFloat(2)^(-bits + 20)
            a = one(BigFloat) + delta
            expected = one(BigFloat) + 2delta + delta^2
            actual = evaluate(square, a)
            @test actual isa BigFloat
            @test precision(actual) == bits
            @test actual != BigFloat(Float64(actual))
            @test actual == expected
            @test evaluate(square, a; order=1) == 2a
            @test evaluate(square, a; order=1) != BigFloat(Float64(2a))
        end
    end
end

@testset "M10B M2 type-dependent FiniteDiff central steps" begin
    cubic = analyze(x^3, x)
    function check_comparison(a)
        T = typeof(a)
        c = compare_derivatives(cubic, a)
        # FiniteDiff's default is cbrt(eps(T))*max(abs(a),1), NOT
        # a Float64 step reused for Float32/BigFloat. Independent cubic stencil.
        h = cbrt(eps(T)) * max(abs(a), one(a))
        stencil = ((a+h)^3 - (a-h)^3)/(2h)
        allowance = 32eps(T)/h + 4h^2
        @test c.point === a
        @test c.values.symbolic == 3a^2
        @test c.values.automatic == 3a^2
        @test c.values.central ≈ stencil rtol=8eps(T) atol=8eps(T)
        @test abs(c.values.central - 3a^2) <= allowance
        @test c.absolute_errors.central == abs(c.values.central-c.values.symbolic)
    end
    for T in (Float32, Float64)
        check_comparison(T(0.5))
    end
    for bits in (128, 256)
        setprecision(BigFloat, bits) do
            check_comparison(BigFloat(0.5))
        end
    end
    # Real integer/rational points are deliberately floated for AD and FD.
    @test compare_derivatives(cubic, 1).point === 1.0
    @test compare_derivatives(cubic, 1//2).point === 0.5
end

@testset "M10B M4–M5 real containers and exact polynomial values" begin
    scalar = analyze(x^2 + 3y^2, (x,y))
    vector = analyze([x*y, x^2+y], (x,y))
    points = ([2,3], Float32[2,3], Float64[2,3], BigFloat[2,3],
              [2//3,3//4], [BigInt(2)//3,BigInt(3)//4])
    for p in points
        a,b = p
        @test evaluate(scalar,p) == a^2+3b^2
        @test gradient(scalar,p) == [2a,6b]
        @test hessian(scalar,p) == [2 0; 0 6]
        @test evaluate(vector,p) == [a*b,a^2+b]
        @test jacobian(vector,p) == [b a; 2a 1]
        @test domain_contains(scalar.domain,p) === true
        if a isa Rational
            @test evaluate(scalar,p) isa Rational
            @test all(v -> v isa Rational,evaluate(vector,p))
        end
    end
    storage = [99,2,3,88]
    p = @view storage[2:3]
    @test evaluate(scalar,p) == 31
    @test jacobian(vector,p) == [3 2;4 1]
    @test storage == [99,2,3,88]
    for r in (scalar,vector)
        @test domain_contains(r.domain,(1+0im,2+0im)) === false
        @test_throws DomainError evaluate(r,(1+0im,2+0im))
    end
    @test_throws DomainError gradient(scalar,(1+0im,2+0im))
    @test_throws DomainError jacobian(vector,(1+0im,2+0im))
end

@testset "M10B intentional Float64 experiment and ODE boundaries" begin
    cubic = analyze(x^3,x)
    for a in (Float32(1), BigFloat(1), 1//1)
        c = derivative_convergence(cubic,a;hmin=1//1000,hmax=1//10,samples=3)
        @test c.point === 1.0
        @test c.reference === 3.0
        @test eltype(c.steps) === Float64
        @test eltype(c.approximations) === Float64
    end
    # One tiny solve per representative boundary, not a backend/type cross-product.
    decay = FirstOrderODE((u,t)->[-u[1]],1)
    for initial in (Float32[1], BigFloat[1], @view([9,1,9][2:2]))
        path = trajectory(decay,initial,(BigFloat(0),BigFloat(0.1)))
        @test path.diagnostics.success && path.diagnostics.completed
        @test eltype(path.solution.u[1]) === Float64
        @test eltype(path.solution.t) === Float64
        @test path.solution(0.05)[1] ≈ exp(-0.05) atol=1e-7
    end
end
end # module
