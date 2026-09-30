module InferenceSensitivityTests
using Test, AnalyticMathLab, LinearAlgebra
@testset "Local sensitivity and conditioning, not global identifiability" begin
    factory=p->FirstOrderODE((u,t)->[u[2],-p[2]/p[1]*u[1]],2;labels=("q","v"))
    times=collect(range(0.,2.;length=17))
    obs=ObservationSet(times,reshape(cos.(2times),1,:);variables=(:q,))
    spec=InferenceParameters((:m,:k),[1.,4.];inferred=(:m,:k))
    p=ParameterInferenceProblem(factory,spec,obs;u0=[1.,0.],tspan=(0.,2.))
    s=local_sensitivity(p,[1.,4.]).value
    # Only k/m is identifiable from this trajectory; scaling both is invisible.
    @test s.rank == 1
    @test isinf(s.condition)
    @test s.jacobian[:,1] ≈ -4s.jacobian[:,2] atol=1e-7
    @test s.column_cosines[1,2] ≈ -1 atol=1e-10
    @test inference_predict(p,[2.,8.]) ≈ obs.values atol=1e-7
    @test s.singular_values ≈ svdvals(s.jacobian)
    @test s.right_vectors' * s.right_vectors ≈ I
    weighted=ObservationSet(times,obs.values;variables=(:q,),weights=reshape(collect(1.:17.),1,:))
    wp=ParameterInferenceProblem(factory,spec,weighted;u0=[1.,0.],tspan=(0.,2.))
    w=local_sensitivity(wp,[1.,4.]).value
    @test w.weighted_jacobian ≈ sqrt.(vec(weighted.weights)).*s.jacobian
    @test w.singular_values ≈ svdvals(w.weighted_jacobian)
    # Economical factors in an underdetermined observation map do not contain
    # the entire nullspace. Rank is compared with parameter count, not min(m,n).
    short=ObservationSet([0.5],reshape([cos(1.)],1,1);variables=(:q,))
    sp=ParameterInferenceProblem(factory,spec,short;u0=[1.,0.],tspan=(0.,2.))
    ss=local_sensitivity(sp,[1.,4.]).value
    @test size(ss.right_vectors)==(2,1)
    @test length(ss.singular_values)==1
    @test ss.rank==1 && isinf(ss.condition)
    zeroobs=ObservationSet([0.],ones(1,1);variables=(:q,))
    zp=ParameterInferenceProblem(factory,spec,zeroobs;u0=[1.,0.],tspan=(0.,2.))
    zs=local_sensitivity(zp,[1.,4.]).value
    @test zs.rank==0 && isinf(zs.condition)
    @test all(isnan,zs.column_cosines)
    @test_throws ArgumentError local_sensitivity(p,[1.,4.];rank_rtol=-1)
end
end
