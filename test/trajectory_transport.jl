module TrajectoryTransportTests
using Test, AnalyticMathLab, Unitful
const AML=AnalyticMathLab
function path(;wrapped=false,velocities=true,unitful=false)
    ts=collect(0.:3.)
    frame(i)=AtomisticSnapshot([[wrapped ? mod(9.0+i-1,10.) : 9.0+i-1,0.],[2(i-1),0.]].*(unitful ? u"nm" : 1);
        velocities=velocities ? [[1.,0.],[2.,0.]].*(unitful ? u"nm/ps" : 1) : nothing,
        masses=[1.,1.],species=[:A,:B],boundary=wrapped ? (kind=:orthorhombic,lengths=[10.,10.]) : (kind=:open,))
    AtomisticTrajectoryView(4,frame;times=ts.*(unitful ? u"ps" : 1),provenance=(fixed_particles=:caller_asserted,))
end
@testset "Single-origin displacement and explicit diffusion interval" begin
    p=path()
    m=AML.mean_squared_displacement(p)
    @test m.values.value ≈ [0.,2.5,10.,22.5]
    @test m.origin_count==1
    @test m.particle_count==2
    @test m.dimensions==2
    @test AML.mean_squared_displacement(p;species=:A).values.value ≈ [0.,1.,4.,9.]
    @test AML.mean_squared_displacement(path(wrapped=true)).values.status==:unknown
    @test AML.mean_squared_displacement(p;coordinates=:unwrapped).values.value==m.values.value
    @test AML.mean_squared_displacement(p;species=:Z).values.status==:unknown
    stationary=AtomisticTrajectoryView(3,i->AtomisticSnapshot([[1.,2.]]);times=[0.,1.,2.],provenance=(fixed_particles=:caller_asserted,))
    @test AML.mean_squared_displacement(stationary).values.value==[0.,0.,0.]
    u=AML.mean_squared_displacement(path(unitful=true))
    @test u.values.value ≈ [0.,2.5,10.,22.5].*u"nm^2"
    @test u.times==[0.,1.,2.,3.].*u"ps"
    @test AML.diffusion_estimate(m).status==:unknown
    linear=AtomisticTrajectoryView(5,i->AtomisticSnapshot([[i==1 ? 0. : sqrt(8*(i-1)+3),0.]]);
        times=collect(0.:4.),provenance=(fixed_particles=:caller_asserted,))
    fit=AML.diffusion_estimate(AML.mean_squared_displacement(linear);fit_window=(1.,4.))
    @test fit.value.diffusion ≈ 2.
    @test fit.value.intercept ≈ 3.
    @test fit.status==:heuristic
    @test fit.value.points==4
    @test AML.diffusion_estimate(m;fit_window=(1.,1.)).status==:unknown
    @test AML.diffusion_estimate(m;fit_window=(5.,7.)).status==:unknown
    @test AML.diffusion_estimate(m;fit_window=(0.,1.)).status==:unknown
    continuous=AtomisticTrajectoryView(4,i->AtomisticSnapshot([[9.0+i-1,0.]];
        boundary=(kind=:orthorhombic,lengths=[10.,10.]));times=collect(0.:3.),provenance=(fixed_particles=:caller_asserted,))
    @test AML.mean_squared_displacement(continuous).values.status==:unknown
    @test AML.mean_squared_displacement(continuous;coordinates=:unwrapped).values.value≈[0.,1.,4.,9.]
    linear_units=AtomisticTrajectoryView(5,i->AtomisticSnapshot([[i==1 ? 0. : sqrt(8*(i-1)+3),0.]].*u"nm");
        times=collect(0.:4.).*u"ps",provenance=(fixed_particles=:caller_asserted,))
    @test AML.diffusion_estimate(AML.mean_squared_displacement(linear_units);fit_window=(1u"ps",4u"ps")).value.diffusion≈2u"nm^2/ps"
    @test AML.diffusion_estimate(m;fit_window=(3.,1.)).status==:unknown
    @test AML.mean_squared_displacement(AtomisticTrajectoryView(4,p.getframe)).values.status==:unknown
end
@testset "VACF measured velocities, origins and normalization" begin
    p=path()
    v=AML.velocity_autocorrelation(p;maxlag=3,normalize=true)
    @test v.raw.value ≈ fill(2.5,4)
    @test v.normalized.value ≈ ones(4)
    @test v.origin_counts==[4,3,2,1]
    @test AML.velocity_autocorrelation(p;species=:B,maxlag=1).raw.value==[4.,4.]
    @test AML.velocity_autocorrelation(path(velocities=false)).raw.status==:unknown
    changing=AtomisticTrajectoryView(3,i->AtomisticSnapshot([[0.,0.]];velocities=[[(-1.)^(i-1),0.]]);
        times=[0.,1.,2.],provenance=(fixed_particles=:caller_asserted,))
    @test AML.velocity_autocorrelation(changing;maxlag=2).raw.value ≈ [1.,-1.,1.]
    orthogonal=AtomisticTrajectoryView(2,i->AtomisticSnapshot([[0.,0.]];velocities=[i==1 ? [1.,0.] : [0.,1.]]);
        times=[0.,1.],provenance=(fixed_particles=:caller_asserted,))
    @test AML.velocity_autocorrelation(orthogonal;maxlag=1).raw.value ≈ [1.,0.]
    unknown=AtomisticTrajectoryView(4,p.getframe)
    @test AML.velocity_autocorrelation(unknown).raw.status==:unknown
    irregular=AtomisticTrajectoryView(4,p.getframe;times=[0.,1.,2.,4.],provenance=p.provenance)
    @test AML.velocity_autocorrelation(irregular).raw.status==:unknown
    @test AML.velocity_autocorrelation(path(unitful=true);maxlag=1).raw.value ≈ [2.5,2.5].*u"nm^2/ps^2"
end
end
