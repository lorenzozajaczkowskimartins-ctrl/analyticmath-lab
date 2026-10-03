module M10BDiagnosticsTests
using Test, AnalyticMathLab
@testset "M10B AML-side diagnostics" begin

@testset "M10B generic sampled metrics retain real precision and range" begin
    for T in (Float32,Float64)
        s=sampled_summary(T[3,4])
        @test s.rms isa T
        @test s.mean_absolute isa T
        @test s.max_absolute isa T
        @test s.sampled_l2 isa T
        @test s.rms ≈ sqrt(T(25)/2)
        @test s.sampled_l2 ≈ T(5)
        tiny=nextfloat(zero(T))
        @test sampled_summary(fill(tiny,4)).mean_absolute == tiny
        @test sampled_summary(fill(tiny,4)).rms == tiny
        @test sampled_summary(T[0,-0.0]).rms == zero(T)
        for invalid in (T(NaN),T(Inf),T(-Inf))
            @test sampled_summary(T[1,invalid]).rms === nothing
        end
    end
    for bits in (128,256)
        setprecision(BigFloat,bits) do
            for x in (BigFloat("1e400"),BigFloat("1e1000"),BigFloat("1e-400"),BigFloat("1e-1000"))
                s=sampled_summary([x,-x])
                @test s.rms isa BigFloat
                @test s.rms == x
                @test s.mean_absolute == x
                @test s.sampled_l2 ≈ sqrt(BigFloat(2))*x
                @test precision(s.rms) == bits
            end
        end
    end
    @test sampled_summary(Float64[]).rms === nothing
    @test sampled_summary([1+im]).rms === nothing
    @test sampled_summary([3//1,4//1]).sampled_l2 ≈ 5.
    @test sampled_summary([floatmax(Float64),floatmax(Float64)]).sampled_l2 === nothing
    @test sampled_summary(view([3.,4.,9.],1:2)).sampled_l2 ≈ 5.
    @test sampled_summary(1:1).rms == 1.
end

@testset "M10B explicit Float64 data boundaries" begin
    for x in (BigFloat("1e1000"),BigFloat("1e-1000"),BigFloat(1)+eps(BigFloat))
        @test_throws ArgumentError PINNPoints(reshape([x],1,1))
        @test_throws ArgumentError ObservationSet([0.],reshape([x],1,1);variables=(:u,))
        @test_throws ArgumentError InferenceParameters((:p,),[x];inferred=(:p,))
        @test_throws ArgumentError ScientificSample(:s,[x],zeros(1,1),[1.];split=:training)
        @test_throws ArgumentError AffineScaling([x],[1.],[:s],:inputs)
    end
    @test eltype(PINNPoints(reshape(Float32[0.25],1,1)).coordinates)==Float64
    @test PINNPoints(reshape([big"0.25"],1,1)).coordinates==reshape([0.25],1,1)
    for x in (NaN,Inf,-Inf)
        @test_throws ArgumentError PINNPoints(reshape([x],1,1))
        @test_throws ArgumentError ObservationSet([0.],reshape([x],1,1);variables=(:u,))
        @test_throws ArgumentError InferenceParameters((:p,),[x];inferred=(:p,))
        @test_throws ArgumentError ScientificSample(:s,[1.],zeros(1,1),[x];split=:training)
    end
    @test_throws ArgumentError ObservationSet([1.,1.],ones(1,2);variables=(:u,))
    @test ObservationSet([1.,nextfloat(1.)],ones(1,2);variables=(:u,)).times==[1.,nextfloat(1.)]
    @test_throws ArgumentError ObservationSet([0.],ones(1,1);variables=(:u,),weights=reshape([BigFloat("1e-1000")],1,1))
    @test_throws ArgumentError InferenceParameters((:p,),[1.];inferred=(:p,),bounds=([0.],[BigFloat("1e1000")]))
    @test InferenceParameters((:p,),[1.];inferred=(:p,),bounds=([-Inf],[Inf])).bounds==([-Inf],[Inf])
end

@testset "M10B scaling and error arithmetic" begin
    for s in (0.,-1.,NaN,Inf)
        @test_throws ArgumentError AffineScaling([0.],[s],[:s],:inputs)
    end
    @test_throws DimensionMismatch AffineScaling([0.,1.],[1.],[:s],:inputs)
    z=AffineScaling([0.],[1.],[:s],:inputs)
    for T in (Float32,Float64,BigFloat)
        x=T[0.25 0.75]
        @test inverse_transform(z,transform(z,x))==x
    end
    extreme=AffineScaling([-1e308],[1e308],[:s],:inputs)
    @test only(transform(extreme,reshape([1e308],1,1))) ≈ 2.
    @test only(inverse_transform(extreme,reshape([2.],1,1))) ≈ 1e308
    @test_throws ArgumentError transform(z,reshape([NaN],1,1))
    @test_throws ArgumentError inverse_transform(z,reshape([Inf],1,1))
    s=ScientificSample(:s,[1.],zeros(1,1),[1.];split=:training)
    d=ScientificDataset([s];kind=:surrogate,family=:constant,input_names=(:a,),coordinate_names=(:x,),
        domain=(inputs=[1. 1.],coordinates=[0. 0.]),reference=(kind=:analytical,),units=:dimensionless,grid=(resampling=:none,),rng=(seed=1,))
    @test fit_scaling(d,:inputs).scale == [1.]
    @test only(transform(fit_scaling(d,:inputs),reshape([1.],1,1)))==0.
    for T in (Float32,Float64,BigFloat)
        e=field_errors(T[2,4],T[1,2])
        @test e.summary.rms isa T
        @test isfinite(e.relative_sampled_l2)
    end
    @test field_errors([1.],[0.]).relative_sampled_l2 === nothing
    @test field_errors([1e300],[1e-300];relative_floor=0.).relative_sampled_l2 === nothing
    @test_throws ArgumentError field_errors([NaN],[1.])
    @test_throws ArgumentError field_errors([1+im],[1+0im])
end
end
end
