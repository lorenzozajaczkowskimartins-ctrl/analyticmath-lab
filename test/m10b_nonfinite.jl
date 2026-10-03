module M10BNonfiniteTests
using Test, AnalyticMathLab, Symbolics

@variables x y

@testset "M10B M1 legacy propagation versus checked experiments" begin
    identity_report = analyze(x,x)
    square = analyze(x^2,x)
    for a in (NaN, Inf, -Inf)
        @test isequal(evaluate(identity_report,a),a)
        @test_throws DomainError compare_derivatives(identity_report,a)
        @test_throws ArgumentError derivative_convergence(identity_report,a;samples=3)
    end
    for a in (0.0, -0.0, nextfloat(0.0), -nextfloat(0.0), floatmax(Float64))
        @test isequal(evaluate(identity_report,a),a)
    end
    # Raw scalar evaluation intentionally preserves IEEE underflow/overflow.
    @test evaluate(square,nextfloat(0.0)) == 0.0
    @test evaluate(square,floatmax(Float64)) == Inf
    @test_throws DomainError compare_derivatives(square,floatmax(Float64))
    @test_throws ArgumentError derivative_convergence(identity_report,floatmax(Float64);samples=3)
    @test_throws ArgumentError derivative_convergence(identity_report,0.0;
        hmin=1e307,hmax=1e308,samples=3)
    for a in (parse(BigFloat,"1e400"), -parse(BigFloat,"1e400"))
        @test isfinite(evaluate(identity_report,a))
        @test_throws ArgumentError derivative_convergence(identity_report,a;samples=3)
    end
    @test_throws ArgumentError derivative_convergence(identity_report,1.0;
        hmin=parse(BigFloat,"1e-400"),hmax=0.1,samples=3)
end

@testset "M10B M3–M5 domain edges and signed zero" begin
    root = analyze(@real_function(sqrt(x)),x)
    logarithm = analyze(@real_function(log(x)),x)
    reciprocal = analyze(@real_function(1/x),x)
    field_root = analyze(@real_function(sqrt(x)+y),(x,y))
    field_log = analyze(@real_function(log(x)+y),(x,y))
    field_reciprocal = analyze(@real_function([1/x,y]),(x,y))
    for z in (0.0,-0.0)
        @test domain_contains(root.real_analysis.domain,z) === true
        @test domain_contains(logarithm.real_analysis.domain,z) === false
        @test domain_contains(reciprocal.real_analysis.domain,z) === false
        @test evaluate(root,z) == 0
        @test domain_contains(field_root.domain,(z,1)) === true
        @test evaluate(field_root,(z,1)) == 1
        @test_throws DomainError gradient(field_root,(z,1))
        @test_throws DomainError hessian(field_root,(z,1))
        @test_throws DomainError evaluate(field_log,(z,1))
        @test_throws DomainError evaluate(field_reciprocal,(z,1))
        @test_throws DomainError jacobian(field_reciprocal,(z,1))
    end
    for a in (-nextfloat(0.0),-1.0)
        @test domain_contains(root.real_analysis.domain,a) === false
        @test_throws DomainError evaluate(field_root,(a,0))
    end
    tiny = nextfloat(0.0)
    @test domain_contains(logarithm.real_analysis.domain,tiny) === true
    @test isfinite(evaluate(field_log,(tiny,0)))
    @test domain_contains(field_reciprocal.domain,(tiny,0)) === true
    @test_throws DomainError evaluate(field_reciprocal,(tiny,0)) # value overflows
    for a in (NaN,Inf,-Inf)
        @test domain_contains(root.real_analysis.domain,a) === false
        @test domain_contains(field_root.domain,(a,0)) === false
        @test_throws DomainError evaluate(field_root,(a,0))
        @test_throws DomainError gradient(field_root,(a,0))
        @test_throws DomainError jacobian(field_reciprocal,(a,0))
    end
end

@testset "M10B M4–M5 finite inputs cannot silently return nonfinite results" begin
    scalar = analyze(x^2+y^2,(x,y))
    vector = analyze([x^2,y],(x,y))
    huge = floatmax(Float64)
    @test_throws DomainError evaluate(scalar,(huge,0))
    @test_throws DomainError gradient(scalar,(huge,0))
    @test_throws DomainError evaluate(vector,(huge,0))
    @test_throws DomainError jacobian(vector,(huge,0))
    linear = analyze(x+y,(x,y))
    for direction in ((NaN,1.0),(Inf,1.0),(0.0,-0.0))
        @test_throws DomainError directional_derivative(linear,(0,0),direction)
    end
    # Scaled floating directions must avoid overflow and underflow. Extreme
    # machine integers may be rejected explicitly rather than wrapped silently.
    @test directional_derivative(linear,(0,0),(huge,huge)) ≈ sqrt(2.0)
    @test directional_derivative(linear,(0,0),(nextfloat(0.0),0.0)) == 1
    @test directional_derivative(linear,(0,0),(-2,0)) == -1
    integer_direction = try
        directional_derivative(linear,(0,0),(typemin(Int),0))
    catch err
        err
    end
    @test integer_direction == -1 || integer_direction isa DomainError
    # The final dot product needs a finite-result guard, just like _mv_call.
    amplified = analyze(floatmax(Float64)*x+floatmax(Float64)*y,(x,y))
    @test_throws DomainError directional_derivative(amplified,(0,0),(1,1))
end

@testset "M10B M6 Float64 conversion is checked before the solver" begin
    zero_rhs = FirstOrderODE((u,t)->[0.0],1)
    for a in (NaN,Inf,-Inf,parse(BigFloat,"1e400"))
        @test_throws DomainError trajectory(zero_rhs,[a],(0,1);maxiters=1)
    end
    tiny=BigFloat("1e-400")
    @test_throws DomainError trajectory(zero_rhs,[tiny],(0,1);maxiters=1)
    @test_throws DomainError trajectory(FirstOrderODE((u,t)->[tiny],1),[0.],(0,1);maxiters=1)
    for a in (NaN,Inf,-Inf)
        @test_throws ArgumentError trajectory(zero_rhs,[1],(0,a);maxiters=1)
        @test_throws ArgumentError trajectory(zero_rhs,[1],(0,1);abstol=a,maxiters=1)
        @test_throws ArgumentError trajectory(zero_rhs,[1],(0,1);reltol=a,maxiters=1)
        @test_throws ArgumentError trajectory(zero_rhs,[1],(0,1);dt=a,maxiters=1)
    end
    for a in (parse(BigFloat,"1e400"),parse(BigFloat,"1e-400"))
        @test_throws ArgumentError trajectory(zero_rhs,[1],(0,1);abstol=a,maxiters=1)
        @test_throws ArgumentError trajectory(zero_rhs,[1],(0,1);saveat=a,maxiters=1)
        # RED: validating a before conversion does not validate Float64(a).
        @test_throws ArgumentError trajectory(zero_rhs,[1],(0,1);dt=a,maxiters=1)
    end
    @test_throws ArgumentError trajectory(zero_rhs,[1],
        (BigFloat(1),BigFloat(1)+BigFloat(2)^(-100));maxiters=1)
    for a in (NaN,Inf,-Inf,parse(BigFloat,"1e400"),1+0im)
        rhs = FirstOrderODE((u,t)->[a],1)
        @test_throws DomainError trajectory(rhs,[1],(0,1);maxiters=1)
    end
    @test_throws DomainError trajectory(zero_rhs,[1+0im],(0,1);maxiters=1)
end
end # module
