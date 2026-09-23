module TrajectoryUncertaintyTests
using Test, AnalyticMathLab, Unitful
const A=AnalyticMathLab
@testset "Correlation window and effective information" begin
    @test isdefined(A,:correlated_mean)
    if isdefined(A,:correlated_mean)
        s=A.ObservableSeries([1.,4.,2.,3.,7.,5.];interval=2u"ps")
        ac=A.autocorrelation(s;maxlag=3)
        tau=A.integrated_autocorrelation_time(ac;window=1)
        @test tau.value.raw_tau≈0.5+ac.autocorrelation[2]
        @test tau.value.tau>=0.5
        @test tau.value.physical_tau==tau.value.tau*2u"ps"
        r=A.correlated_mean(s;window=1,maxlag=3)
        @test r.status==:heuristic
        @test r.value.effective_samples≈6/(2r.value.tau_int)
        @test r.value.standard_error≈r.value.std/sqrt(r.value.effective_samples)
        @test r.value.method==:windowed_autocorrelation
        @test A.correlated_mean(A.ObservableSeries([1.,2.,3.])).status==:unknown
        @test A.correlated_mean(A.ObservableSeries(ones(8);interval=1)).status==:unknown
        @test_throws ArgumentError A.integrated_autocorrelation_time(ac;window=4)
        # Controlled positive-correlation sequence: no automatic tail truncation found.
        strong=A.ObservableSeries(collect(1.:1000.);interval=1)
        @test A.correlated_mean(strong;maxlag=10).status==:unknown
        @test A.correlated_mean(strong;maxlag=10,window=10).value.effective_samples<100
        # Alternating, IID-like zero positive-lag window: cap information at N.
        alternating=A.ObservableSeries(repeat([-1.,1.],32);index_time=true)
        @test A.correlated_mean(alternating).value.effective_samples==64
        @test A.correlated_mean(alternating;window=1).value.tau_int>=0.5
        @test A.correlated_mean(A.ObservableSeries([1.,3.,2.,4.].*u"eV";interval=1);window=0).value.standard_error isa Unitful.AbstractQuantity
        # Analytic AR(1) rho(k)=q^k, explicitly truncated at K (not a stochastic threshold).
        q=0.5; K=10; sampling=A.sampling_info(100;interval=1)
        controlled=A.AutocorrelationAnalysis(sampling,0:K,0:K,nothing,q.^(0:K),100 .- (0:K),:biased,:analytic_fixture,
            PropertyResult(nothing,:heuristic,:fixture,String[]))
        @test A.integrated_autocorrelation_time(controlled;window=K).value.tau≈0.5+q*(1-q^K)/(1-q)
    end
end
@testset "Block sizes and conservative transient evidence" begin
    @test isdefined(A,:block_average)
    if isdefined(A,:block_average)
        s=A.ObservableSeries(collect(1.:9.);interval=1)
        b=A.block_average(s;block_sizes=[1,2,4])
        @test b isa A.BlockAnalysis
        @test b.block_counts==[9,4,2]
        @test b.discarded==[0,1,1]
        @test b.block_means[2]==[1.5,3.5,5.5,7.5]
        @test b.standard_errors[2]≈sqrt((20/3)/4)
        @test b.evidence.status==:heuristic
        @test A.block_average(s;block_sizes=[9]).standard_errors[1]===nothing
        @test_throws ArgumentError A.block_average(s;block_sizes=[0])
        @test A.block_average(A.ObservableSeries([NaN]);block_sizes=[1]).evidence.status==:unknown
        step=A.ObservableSeries(vcat(fill(10.,20),fill(0.,20));interval=1)
        tr=A.transient_analysis(step)
        @test tr.status==:heuristic
        @test tr.value.apparent_transient
        @test tr.value.suggested_start==21
        @test tr.value.applied==false
        @test tr.value.equilibrium_proven==false
        @test A.transient_analysis(A.ObservableSeries(ones(40);interval=1)).value.suggested_start===nothing
        @test A.transient_analysis(A.ObservableSeries([1.,2.])).status==:unknown
    end
end
end
