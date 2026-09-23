module TrajectoryStatisticsTests
using Test, AnalyticMathLab, Unitful
const AML=AnalyticMathLab
@testset "Sampling metadata" begin
    @test isdefined(AML,:sampling_info)
    if isdefined(AML,:sampling_info)
        t=[0.,0.5,1.]
        s=AML.sampling_info(3;times=t,provenance=(stride=5,))
        @test s.times === t
        @test s.interval==0.5
        @test s.regularity==:regular
        @test s.provenance.stride==5
        @test AML.sampling_info(3).regularity==:unknown
        @test AML.sampling_info(3).times===nothing
        @test AML.sampling_info(0).regularity==:insufficient
        @test AML.sampling_info(1;times=[4.]).regularity==:insufficient
        @test AML.sampling_info(3;interval=2.).times isa AbstractRange
        @test collect(AML.sampling_info(3;index_time=true).times)==[0,1,2]
        @test AML.sampling_info(3;times=[0.,1.,2.1]).regularity==:irregular
        @test AML.sampling_info(3;times=[0.,1e-12,3e-12]).regularity==:irregular
        @test AML.sampling_info(3;times=[0.,1.,2.0 + 1e-9]).regularity==:regular
        @test_throws DimensionMismatch AML.sampling_info(3;times=[0.,1.])
        @test_throws ArgumentError AML.sampling_info(2;times=[0.,NaN])
        @test_throws ArgumentError AML.sampling_info(2;times=[0.,0.])
        @test_throws ArgumentError AML.sampling_info(2;interval=-1)
        @test_throws ArgumentError AML.sampling_info(3;times=t,interval=1.)
        @test_throws ArgumentError AML.sampling_info(3;interval=1.,index_time=true)
        calls=Ref(0)
        v=AML.AtomisticTrajectoryView(3,i->(calls[]+=1);times=t,provenance=(stride=5,))
        @test AML.sampling_info(v).times===t
        @test AML.sampling_info(v).provenance.stride==5
        @test calls[]==0
        @test AML.sampling_info(3;interval=2u"ps").units=="ps"
    end
end
struct CountedValues <: AbstractVector{Float64}
    data::Vector{Float64}
    calls::Base.RefValue{Int}
end
Base.size(v::CountedValues)=size(v.data)
Base.getindex(v::CountedValues,i::Int)=(v.calls[]+=1;v.data[i])
@testset "Borrowed scalar moments and running statistics" begin
    @test isdefined(AML,:ObservableSeries)
    if isdefined(AML,:ObservableSeries)
        values=CountedValues([1.,2.,3.,4.],Ref(0))
        s=AML.ObservableSeries(values)
        @test s.values===values
        @test values.calls[]<=1
        @test s.sampling.times===nothing
        r=AML.statistical_summary(s)
        @test r.value.count==4
        @test r.value.mean==2.5
        @test r.value.variance≈5/3
        @test r.value.std≈sqrt(5/3)
        @test r.value.minimum==1
        @test r.value.maximum==4
        @test r.value.standard_error===nothing
        @test values.calls[]<=5
        run=AML.running_statistics(s).value
        @test run.means≈[1.,1.5,2.,2.5]
        @test run.variances[1]===nothing
        @test run.variances[2:end]≈[0.5,1.,5/3]
        large=AML.statistical_summary(AML.ObservableSeries(1e12 .+ [1.,2.,3.,4.])).value
        @test large.variance≈5/3
        unit=AML.statistical_summary(AML.ObservableSeries([1.,2.,3.]u"eV")).value
        @test unit.mean==2u"eV"
        @test unit.variance≈1u"eV^2"
        @test unit.std≈1u"eV"
        for bad in (Float64[],[NaN],[Inf],[1.,missing],[1+im])
            @test AML.statistical_summary(AML.ObservableSeries(bad)).status==:unknown
            @test AML.running_statistics(AML.ObservableSeries(bad)).status==:unknown
        end
        @test AML.statistical_summary(AML.ObservableSeries([2.])).value.variance===nothing
        @test AML.statistical_summary(AML.ObservableSeries(fill(3.,5))).value.variance==0
        @test_throws ArgumentError AML.ObservableSeries([1.];missing_policy=:drop)
    end
end
@testset "Bounded direct covariance" begin
    @test isdefined(AML,:autocorrelation)
    if isdefined(AML,:autocorrelation)
        x=[1.,4.,2.,3.,7.,5.]; mu=sum(x)/length(x)
        for normalization in (:biased,:unbiased)
            ac=AML.autocorrelation(AML.ObservableSeries(x;interval=2u"ps");maxlag=3,normalization)
            reference=[sum((x[i]-mu)*(x[i+k]-mu) for i in 1:length(x)-k)/(normalization==:biased ? length(x) : length(x)-k) for k in 0:3]
            @test ac.autocovariance≈reference
            @test ac.autocorrelation≈reference/reference[1]
            @test ac.counts==[6,5,4,3]
            @test ac.lags==0:3
            @test collect(ac.lag_times)==[0,2,4,6]u"ps"
            @test ac.normalization==normalization
            @test ac.method==:direct_bounded
        end
        ac=AML.autocorrelation(AML.ObservableSeries(x.*u"eV";index_time=true))
        @test ac.autocovariance[1]≈sum((x.-mu).^2)/length(x)*u"eV^2"
        @test ac.autocorrelation[1]≈1
        @test length(AML.autocorrelation(AML.ObservableSeries(collect(1.:1000.);interval=1)).lags)==129
        for s in (AML.ObservableSeries(x),AML.ObservableSeries(x;times=[0.,1.,2.,3.,4.,6.]),
                AML.ObservableSeries([NaN,2.];interval=1),AML.ObservableSeries([1.,missing];interval=1),
                AML.ObservableSeries(Float64[]),AML.ObservableSeries([1.];interval=1))
            ac=AML.autocorrelation(s)
            @test ac isa AML.AutocorrelationAnalysis
            @test ac.evidence.status==:unknown
            @test ac.autocorrelation===nothing
        end
        constant=AML.autocorrelation(AML.ObservableSeries(fill(4.,5);interval=1))
        @test all(iszero,constant.autocovariance)
        @test constant.autocorrelation===nothing
        @test constant.evidence.status==:unknown
        @test_throws ArgumentError AML.autocorrelation(AML.ObservableSeries(x;interval=1);maxlag=6)
        @test_throws ArgumentError AML.autocorrelation(AML.ObservableSeries(x;interval=1);normalization=:invalid)
        counted=CountedValues(x,Ref(0)); s=AML.ObservableSeries(counted;interval=1)
        AML.autocorrelation(s)
        @test counted.calls[]<=length(x)+1
    end
end
end
