module TrajectoryComparisonEdgeTests
using Test, AnalyticMathLab, Unitful
const A=AnalyticMathLab
@testset "M8C fail-closed units, shapes and context" begin
    s=ObservableSeries([1.,4.,2.,3.,7.,5.,2.,4.]u"J";name=:total_energy,interval=1u"s")
    a=ComparisonInput(statistical_summary(s);series=s)
    unknown=ObservableSeries([1.,2.,3.];name=s.name)
    @test compare(a,ComparisonInput(statistical_summary(unknown);series=unknown)).compatibility.status==:unknown
    ac=autocorrelation(s;maxlag=3)
    l=ObservableSeries([1.,4.,2.,3.,7.,5.,2.,4.]u"m";name=s.name,interval=1u"s")
    @test compare(ComparisonInput(ac;series=s),ComparisonInput(autocorrelation(l;maxlag=3);series=l)).compatibility.status==:incompatible
    malformed=A.AutocorrelationAnalysis(ac.sampling,ac.lags,ac.lag_times,ac.autocovariance,ac.autocorrelation[1:2],ac.counts,ac.normalization,ac.method,ac.evidence)
    @test compare(ComparisonInput(ac;series=s),ComparisonInput(malformed;series=s)).difference.value===nothing
    @test compare(ComparisonInput(ac;series=s),ComparisonInput(malformed;series=s)).compatibility.status==:incompatible
    si=ObservableSeries(s.values;name=s.name,index_time=true)
    ai=autocorrelation(si;maxlag=3)
    ti=ComparisonInput(integrated_autocorrelation_time(ai;window=1);series=si,parent=ai)
    @test compare(ti,ti;quantity=:physical_tau,unitless=true).difference.value===nothing
    @test compare(ti,ti).difference.value==0
    @test compare(a,a;quantity=:count).difference.value==0
    su=ObservableSeries(s.values;name=s.name,interval=1.)
    au=ComparisonInput(autocorrelation(su;maxlag=3);series=su)
    @test compare(au,au).compatibility.status==:unknown
    @test compare(au,au;unitless_time=true).compatibility.status==:compatible
    badtime=ObservableSeries(s.values;name=s.name,interval=1u"m")
    at=ComparisonInput(autocorrelation(badtime;maxlag=3);series=badtime)
    @test compare(at,at).compatibility.status==:incompatible
    c=compare(a,ComparisonInput(statistical_summary(ObservableSeries(s.values .+ 1u"J";name=s.name));series=s))
    @test c.metadata.conversion.target==u"J"
    # Metadata consistency is checked without rereading source values.
    contradictory=ComparisonInput(ac;series=si)
    @test compare(contradictory,contradictory).compatibility.status==:incompatible
    x=ObservableSeries([1.,2.]u"K";name=:temperature,provenance=(temperature_convention=:definition_A,))
    y=ObservableSeries([1.,2.]u"K";name=:temperature,provenance=(temperature_convention=:definition_B,))
    @test compare(ComparisonInput(statistical_summary(x);series=x),ComparisonInput(statistical_summary(y);series=y)).compatibility.status==:incompatible
    missing=ComparisonInput(PropertyResult(nothing,:unknown,:unavailable,["No data"]);series=s)
    @test compare(a,missing).compatibility.status==:unknown
    @test compare(a,missing).difference.value===nothing
end
@testset "M8C review regressions: derived identity and dimensions" begin
    energy=ObservableSeries(collect(1.:8.)u"J";name=:total_energy,interval=1u"s")
    lengthdata=ObservableSeries(collect(1.:8.)u"m";name=:total_energy,interval=1u"s")
    ea=ComparisonInput(energy_diagnostics(energy);series=energy)
    eb=ComparisonInput(energy_diagnostics(lengthdata);series=lengthdata)
    relative=compare(ea,eb;quantity=:maximum_relative)
    @test relative.compatibility.status==:incompatible
    @test relative.difference.value===nothing
    ba=ComparisonInput(block_average(energy;block_sizes=[1,2]);series=energy)
    bb=ComparisonInput(block_average(lengthdata;block_sizes=[1,2]);series=lengthdata)
    for quantity in (:block_counts,:discarded)
        @test compare(ba,bb;quantity).compatibility.status==:incompatible
        @test compare(ba,bb;quantity).difference.value===nothing
        @test compare(ba,ba;quantity).difference.value==[0,0]
    end
    ta=ComparisonInput(transient_analysis(energy);series=energy)
    tb=ComparisonInput(transient_analysis(lengthdata);series=lengthdata)
    for quantity in (:suggested_start,:suggested_time)
        @test compare(ta,tb;quantity).compatibility.status==:incompatible
        @test compare(ta,tb;quantity).difference.value===nothing
        @test compare(ta,ta;quantity).difference.value!==nothing
    end
    unnamed=ObservableSeries(energy.values;interval=1u"s")
    tr=ComparisonInput(transient_analysis(unnamed);series=unnamed)
    @test compare(tr,tr).compatibility.status==:unknown
    @test compare(tr,tr).difference.value===nothing
end
end
