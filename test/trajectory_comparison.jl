module TrajectoryComparisonTests
using Test, AnalyticMathLab, Unitful
const A=AnalyticMathLab
@testset "M8C stored scalar comparison" begin
    @test isdefined(A,:ComparisonInput)
    if isdefined(A,:ComparisonInput)
        sa=ObservableSeries([1.,2.,3.]u"J";name=:total_energy,interval=1u"s",provenance=(run=:A,))
        sb=ObservableSeries([0.002,0.003,0.004]u"kJ";name=:total_energy,interval=2u"s",provenance=(run=:B,))
        a=ComparisonInput(statistical_summary(sa);series=sa,label="A")
        b=ComparisonInput(statistical_summary(sb);series=sb,label="B")
        c=compare(a,b)
        @test c isa ObservableComparison
        @test c.compatibility.status==:compatible
        @test c.difference.value≈1u"J"
        @test c.uncertainty.value===nothing
        @test c.a===a && c.b===b
        @test c.a.series.provenance.run==:A
        @test c.quantity==:mean
        @test compare(ComparisonInput(a.result),b).compatibility.status==:unknown
        lengthseries=ObservableSeries([1.,2.,3.]u"m";name=:total_energy)
        bad=compare(a,ComparisonInput(statistical_summary(lengthseries);series=lengthseries))
        @test bad.compatibility.status==:incompatible
        @test bad.difference.value===nothing
        kinetic=ObservableSeries(sa.values;name=:kinetic_energy)
        @test compare(a,ComparisonInput(statistical_summary(kinetic);series=kinetic)).compatibility.status==:incompatible
        s=ObservableSeries([1.,2.,3.];name=:temperature)
        x=ComparisonInput(statistical_summary(s);series=s)
        @test compare(x,x).compatibility.status==:unknown
        @test compare(x,x;unitless=true).difference.value==0
        @test compare(x,x;quantity=:std,unitless=true).uncertainty.value===nothing
    end
end
@testset "M8C correlation, windows and explicit independence" begin
    sa=ObservableSeries([1.,4.,2.,3.,7.,5.,2.,4.]u"J";name=:total_energy,interval=1u"s")
    sb=ObservableSeries(sa.values .+ 2u"J";name=:total_energy,interval=1u"s")
    ra=correlated_mean(sa;window=1,maxlag=3); rb=correlated_mean(sb;window=1,maxlag=3)
    a=ComparisonInput(ra;series=sa); b=ComparisonInput(rb;series=sb)
    c=compare(a,b)
    @test c.difference.value≈2u"J"
    @test c.uncertainty.status==:unknown
    ci=compare(a,b;independence=:independent)
    @test ci.uncertainty.value≈sqrt(ra.value.standard_error^2+rb.value.standard_error^2)
    @test ci.assumptions.independence==:independent
    @test compare(a,a;independence=:independent).uncertainty.value===nothing
    @test_throws ArgumentError compare(a,b;independence=:guess)
    ac=ra.value.correlation; bc=rb.value.correlation
    ca=ComparisonInput(ac;series=sa); cb=ComparisonInput(bc;series=sb)
    @test compare(ca,cb).difference.value≈zeros(4)
    @test compare(ca,cb).metadata.a.grid===ac.lag_times
    short=ComparisonInput(autocorrelation(sb;maxlag=2);series=sb)
    @test compare(ca,short).compatibility.status==:incompatible
    @test compare(ca,short).difference.value===nothing
    unbiased=ComparisonInput(autocorrelation(sb;maxlag=3,normalization=:unbiased);series=sb)
    @test compare(ca,unbiased).compatibility.status==:incompatible
    si=ObservableSeries(sa.values;name=sa.name,index_time=true)
    @test compare(ca,ComparisonInput(autocorrelation(si;maxlag=3);series=si)).compatibility.status==:incompatible
    tau1=ComparisonInput(integrated_autocorrelation_time(ac;window=1);series=sa,parent=ac)
    tau2=ComparisonInput(integrated_autocorrelation_time(bc;window=2);series=sb,parent=bc)
    @test compare(tau1,tau2).compatibility.status==:incompatible
    @test compare(tau1,tau1).difference.value==0
    @test compare(tau1,tau1;quantity=:physical_tau).difference.value==0u"s"
    @test compare(a,b;quantity=:effective_samples).difference.value==0
    bd=ComparisonInput(block_average(sa;block_sizes=[1,2]);series=sa)
    be=ComparisonInput(block_average(sb;block_sizes=[1,4]);series=sb)
    @test compare(bd,be).compatibility.status==:incompatible
    @test compare(bd,bd).difference.value==[0u"J",0u"J"]
    @test compare(bd,bd).a.result.discarded==[0,0]
    bare=compare(ac,bc)
    @test bare.compatibility.status==:unknown
    @test bare.difference.value===nothing
end
end
