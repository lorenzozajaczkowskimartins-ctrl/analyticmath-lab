module TrajectoryComparisonTransportTests
using Test, AnalyticMathLab, Unitful
const A=AnalyticMathLab
function path(;clock=1u"s",scale=1.0,periodic=false)
    AtomisticTrajectoryView(6,i->AtomisticSnapshot([[scale*(i-1),0.]]u"m";
        velocities=[[scale,0.]]u"m/s",species=[:A],
        boundary=periodic ? (kind=:orthorhombic,lengths=[20.,20.]u"m") : (kind=:open,));
        times=clock===nothing ? nothing : (0:5).*clock,provenance=(fixed_particles=:caller_asserted,))
end
@testset "M8C transport metadata gates" begin
    pa=path(); pb=path(scale=2.)
    ma=mean_squared_displacement(pa); mb=mean_squared_displacement(pb)
    a=ComparisonInput(ma;selection=:population_A,label="A")
    b=ComparisonInput(mb;selection=:population_A,label="B")
    c=compare(a,b)
    @test c.compatibility.status==:compatible
    @test c.difference.value==mb.values.value-ma.values.value
    @test c.metadata.a.grid===ma.times
    @test compare(ma,mb).compatibility.status==:unknown
    @test compare(a,ComparisonInput(mb;selection=:other)).compatibility.status==:incompatible
    mu=mean_squared_displacement(pa;coordinates=:unwrapped)
    @test compare(a,ComparisonInput(mu;selection=:population_A)).compatibility.status==:incompatible
    wrapped=mean_squared_displacement(path(periodic=true);coordinates=:wrapped)
    @test compare(a,ComparisonInput(wrapped;selection=:population_A)).difference.value===nothing
    mi=mean_squared_displacement(path(clock=nothing);time_options=(index_time=true,))
    @test compare(a,ComparisonInput(mi;selection=:population_A)).compatibility.status==:incompatible
    mc=mean_squared_displacement(path(clock=1000u"ms"))
    @test compare(a,ComparisonInput(mc;selection=:population_A)).compatibility.status==:compatible
    shifted=mean_squared_displacement(path(clock=2u"s"))
    @test compare(a,ComparisonInput(shifted;selection=:population_A)).difference.value===nothing
    da=diffusion_estimate(ma;fit_window=(1u"s",5u"s"))
    db=diffusion_estimate(mb;fit_window=(1u"s",5u"s"))
    fa=ComparisonInput(da;parent=ma,selection=:population_A)
    fb=ComparisonInput(db;parent=mb,selection=:population_A)
    @test compare(fa,fb).difference.value≈db.value.diffusion-da.value.diffusion
    @test compare(da,db).compatibility.status==:unknown
    dc=diffusion_estimate(mb;fit_window=(2u"s",5u"s"))
    @test compare(fa,ComparisonInput(dc;parent=mb,selection=:population_A)).compatibility.status==:incompatible
    di=diffusion_estimate(mi;fit_window=(1,5))
    @test compare(fa,ComparisonInput(di;parent=mi,selection=:population_A)).compatibility.status==:incompatible
    va=velocity_autocorrelation(pa;normalize=true,maxlag=3)
    vb=velocity_autocorrelation(pb;normalize=true,maxlag=3)
    xa=ComparisonInput(va;selection=:population_A); xb=ComparisonInput(vb;selection=:population_A)
    @test compare(xa,xb).difference.value==fill(3u"m^2/s^2",4)
    @test compare(xa,xb;quantity=:normalized).difference.value==zeros(4)
    @test compare(xa,xb;quantity=(:normalized,:raw)).compatibility.status==:incompatible
    @test compare(va,vb).difference.value===nothing
end
@testset "M8C deviations and transients remain descriptive" begin
    for name in (:total_energy,:kinetic_energy,:potential_energy)
        sa=ObservableSeries([1.,2.,3.,4.,5.,6.,7.,8.]u"J";name,interval=1u"s",provenance=(ensemble=:NVE,))
        sb=ObservableSeries(2 .* sa.values;name,interval=1u"s",provenance=(ensemble=:NVE,))
        a=ComparisonInput(energy_diagnostics(sa);series=sa)
        b=ComparisonInput(energy_diagnostics(sb);series=sb)
        @test compare(a,b).difference.value==7u"J"
        @test compare(a,b).a.result.value.conservation_expected== (name==:total_energy)
        @test compare(a,b).b.result.value.conservation_expected== (name==:total_energy)
        @test compare(a,b;quantity=:linear_slope).difference.value≈1u"J/s"
        ta=ComparisonInput(transient_analysis(sa);series=sa)
        tb=ComparisonInput(transient_analysis(sb);series=sb)
        @test compare(ta,tb).difference.value==4u"J"
        @test compare(ta,ComparisonInput(transient_analysis(sb;threshold=2.);series=sb)).compatibility.status==:incompatible
    end
    s=ObservableSeries([[i*1.,0.]u"kg*m/s" for i in 1:8];name=:total_momentum,interval=1u"s")
    p=ComparisonInput(momentum_diagnostics(s);series=s)
    @test compare(p,p).difference.value==0u"kg*m/s"
    @test p.result.value.conservation_expected===false
    s3=ObservableSeries([[i*1.,0.,0.]u"kg*m/s" for i in 1:8];name=:total_momentum,interval=1u"s")
    @test compare(p,ComparisonInput(momentum_diagnostics(s3);series=s3)).compatibility.status==:incompatible
end
end
