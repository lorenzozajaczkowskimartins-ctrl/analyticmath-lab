module SurrogateContractTests
using Test, AnalyticMathLab
const A=AnalyticMathLab
q=[0. 0.5 1.;0. 0.2 0.4]
ref=(kind=:analytical,source="test",error=:roundoff)
domain=(inputs=[0.05 0.2],coordinates=[0. 1.;0. 0.5])
sample(id,a,role;y=[0.,a,0.],coords=q)=ScientificSample(id,[a],coords,y;split=role)
make(ss;reference=ref)=ScientificDataset(ss;kind=:surrogate,family=:test,input_names=(:alpha,),coordinate_names=(:x,:t),domain,reference,units=:dimensionless,grid=(resampling=:none,),rng=(seed=1,))
d=make([sample(:a,0.05,:training),sample(:b,0.2,:training),sample(:c,0.1,:interpolation),sample(:e,0.3,:parameter_extrapolation)])
@testset "M9D split integrity" begin
    @test_throws ArgumentError make([sample(:a,0.05,:training),sample(:h,0.05,:interpolation)])
    @test_throws ArgumentError make([sample(:a,0.3,:training)])
    @test_throws ArgumentError make([sample(:a,0.05,:training),sample(:h,0.3,:interpolation)])
    @test_throws ArgumentError make([sample(:a,0.05,:training),sample(:h,0.1,:parameter_extrapolation)])
    @test_throws ArgumentError make([sample(:a,0.05,:training)];reference=(kind=:numerical,))
    nref=(kind=:numerical,solver=:SciMLBase,algorithm=:Tsit5,tolerances=(abstol=1e-10,reltol=1e-9),grid=q,tspan=(0.,0.4),parameters=(alpha=0.1,),error=:unknown)
    @test make([sample(:a,0.1,:training)];reference=nref).reference.error==:unknown
    @test classify_query(d,[0.1],[0.5;0.8;;]).coordinate==:outside
    @test_throws DimensionMismatch classify_query(d,[1.,2.],q)
end
@testset "M9D explicit train-only scaling" begin
    @test isdefined(A,:fit_scaling)
    if isdefined(A,:fit_scaling)
        z=fit_scaling(d,:inputs)
        @test z.fitted_ids==[:a,:b]
        @test z.offset≈[0.125]
        @test z.scale≈[0.075]
        @test inverse_transform(z,transform(z,[0.12]))≈[0.12]
        @test transform(z,[0.3])[1]>1
        changed=make([d.samples[1:2]...,sample(:c,0.1,:interpolation;y=fill(1e20,3)),sample(:e,0.3,:parameter_extrapolation;y=fill(-1e20,3))])
        @test fit_scaling(d,:outputs).scale==fit_scaling(changed,:outputs).scale
        @test fit_scaling(d,:outputs).offset==fit_scaling(changed,:outputs).offset
        @test_throws ArgumentError fit_scaling(d,:truth)
        @test_throws DimensionMismatch transform(z,[1.,2.])
    end
end
@testset "M9D sampled field metrics" begin
    @test isdefined(A,:field_errors)
    if isdefined(A,:field_errors)
        e=field_errors([1.,3.],[1.,1.])
        @test e.summary.rms≈sqrt(2.)
        @test e.summary.max_absolute==2
        @test e.summary.mean_absolute==1
        @test e.relative_sampled_l2≈sqrt(2.)
        @test field_errors(ones(2),zeros(2)).relative_sampled_l2===nothing
        @test_throws DimensionMismatch field_errors(ones(2),ones(3))
        @test_throws ArgumentError field_errors([NaN],[0.])
    end
end
end
