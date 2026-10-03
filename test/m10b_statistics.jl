module M10BStatisticsTests
using Test, AnalyticMathLab, Unitful
const A = AnalyticMathLab

# Standalone numeric audit: include directly, without modifying the root runner.
# No simulation, random fixtures, exact-statistics claim, or IID inference.
# Float32 arithmetic may promote (e.g. division by Int); require no narrowing,
# not identical output types. BigFloat references describe the *stored inputs*,
# not ideal decimal observations before input rounding.
function reference_moments(xs)
    setprecision(BigFloat, 512) do
        ys = BigFloat.(xs)
        m = sum(ys) / length(ys)
        (mean=m, variance=sum((y-m)^2 for y in ys)/(length(ys)-1))
    end
end

function typed_statistics(T)
    tol = 64eps(T)
    xs = T[1,2,3,4]
    s = ObservableSeries(xs; interval=T(2), name=:energy)
    r = statistical_summary(s)
    @test r.status == :heuristic
    @test r.value.mean ≈ T(5)/2 rtol=tol
    @test r.value.variance ≈ T(5)/3 rtol=tol
    @test r.value.standard_error === nothing
    @test precision(r.value.mean) >= precision(T)
    @test precision(r.value.variance) >= precision(T)
    run = running_statistics(s).value
    @test run.variances[1] === nothing
    @test run.means ≈ T[1,1.5,2,2.5] rtol=tol
    for k in 2:length(xs)
        ref = reference_moments(xs[1:k])
        @test run.means[k] ≈ ref.mean rtol=tol
        @test run.variances[k] ≈ ref.variance rtol=tol
    end
    ac = autocorrelation(s; maxlag=3)
    au = autocorrelation(s; maxlag=3, normalization=:unbiased)
    @test ac.evidence.status == :heuristic
    @test ac.counts == [4,3,2,1]
    @test collect(ac.lag_times) == T[0,2,4,6]
    @test ac.autocovariance ≈ T[5/4,5/16,-3/8,-9/16] rtol=tol
    @test ac.autocorrelation ≈ T[1,1/4,-3/10,-9/20] rtol=max(tol,eps(Float64))
    @test au.autocovariance ≈ [T(5)/4,T(5)/12,-T(3)/4,-T(9)/4] rtol=tol
    tau = integrated_autocorrelation_time(ac)
    @test tau.value.tau == T(3)/4
    @test tau.value.physical_tau == T(3)/2
    cm = correlated_mean(s; maxlag=3)
    @test cm.value.effective_samples ≈ T(8)/3 rtol=max(tol,eps(Float64))
    @test cm.value.standard_error ≈ sqrt(T(5)/8) rtol=max(tol,eps(Float64))
    @test 1 <= cm.value.effective_samples <= length(xs)
    clamped = integrated_autocorrelation_time(ac; window=3)
    @test clamped.value.tau == 0.5
    @test clamped.value.clamped
    @test integrated_autocorrelation_time(autocorrelation(s;maxlag=1)).status == :unknown
    @test integrated_autocorrelation_time(ac;window=0).value.tau == 0.5
    @test_throws ArgumentError integrated_autocorrelation_time(ac;window=4)
    b = block_average(ObservableSeries(T[1,2,3,4,99]);block_sizes=[2,3,8])
    @test b.block_counts == [2,1,0]
    @test b.discarded == [1,2,5]
    @test b.block_means[1] == T[1.5,3.5]
    @test b.variances == [T(2),nothing,nothing]
    @test b.standard_errors == [T(1),nothing,nothing]

    @testset "large offset: Welford vs 512-bit centered and naive" begin
        offset = T(2)^(precision(T)÷2+2)
        x = offset .+ T[-2,-1,1,2]
        ref = reference_moments(x)
        out = statistical_summary(ObservableSeries(x))
        naive = (sum(y*y for y in x)-sum(x)^2/length(x))/(length(x)-1)
        @test out.value !== nothing
        if out.value !== nothing
            # Welford is stable, not exact: subtraction and running means round.
            @test out.value.mean ≈ ref.mean rtol=tol
            @test out.value.variance ≈ ref.variance rtol=16sqrt(eps(T))
            @test abs(BigFloat(out.value.variance)-ref.variance) < abs(BigFloat(naive)-ref.variance)
        end
        reversed = statistical_summary(ObservableSeries(reverse(x)))
        @test reversed.value.variance ≈ ref.variance rtol=16sqrt(eps(T))
    end

    @testset "near-equal stored means retain representable B-A" begin
        a0 = T(1)
        b0 = nextfloat(a0)
        left = ObservableSeries([a0];name=:energy)
        right = ObservableSeries([b0];name=:energy)
        a = ComparisonInput(statistical_summary(left);series=left)
        b = ComparisonInput(statistical_summary(right);series=right)
        c = compare(a,b;unitless=true)
        @test c.compatibility.status == :compatible
        @test c.difference.value == eps(a0)
        @test compare(b,a;unitless=true).difference.value == -eps(a0)
        @test compare(a,b).difference.value === nothing
    end

    @testset "units preserve scale and precision" begin
        su = ObservableSeries(xs .* u"J";interval=T(2)*u"s",name=:energy)
        sm = statistical_summary(su).value
        @test sm.mean ≈ (T(5)/2)*u"J" rtol=tol
        @test sm.variance ≈ (T(5)/3)*u"J^2" rtol=tol
        @test precision(ustrip(sm.mean)) >= precision(T)
        acu = autocorrelation(su;maxlag=3)
        @test acu.autocovariance ≈ ac.autocovariance .* u"J^2" rtol=tol
        @test acu.autocorrelation ≈ ac.autocorrelation rtol=tol
        @test integrated_autocorrelation_time(acu).value.physical_tau == (T(3)/2)*u"s"
        @test correlated_mean(su;maxlag=3).value.standard_error ≈ cm.value.standard_error*u"J" rtol=tol
        bu = block_average(su;block_sizes=[2])
        @test only(bu.variances) ≈ T(2)*u"J^2" rtol=tol
        @test only(bu.standard_errors) ≈ T(1)*u"J" rtol=tol
        scaled = ObservableSeries((xs .+ T(2)).*T(1000).*u"mJ";name=:energy)
        c = compare(ComparisonInput(statistical_summary(su);series=su),
            ComparisonInput(statistical_summary(scaled);series=scaled))
        @test c.compatibility.status == :compatible
        @test c.difference.value ≈ T(2)*u"J" rtol=tol
    end
end

@testset "M10B M8B/C numeric robustness" begin
    for T in (Float32,Float64)
        @testset "$T" begin
            typed_statistics(T)
        end
    end
    for bits in (128,256)
        setprecision(BigFloat,bits) do
            @testset "BigFloat $bits" begin
                typed_statistics(BigFloat)
            end
        end
    end

    @testset "empty, singleton, constant, missing and nonfinite" begin
        for x in (Float64[],[missing],[1.,missing,3.,4.],[1.,NaN,3.,4.],
                  [1.,Inf,3.,4.],[1.,-Inf,3.,4.],[1+im,2+im,3+im,4+im])
            s = ObservableSeries(x;index_time=true)
            @test statistical_summary(s).status == :unknown
            @test running_statistics(s).status == :unknown
            @test autocorrelation(s).evidence.status == :unknown
            @test correlated_mean(s).status == :unknown
            @test block_average(s;block_sizes=[1,2]).evidence.status == :unknown
        end
        for T in (Float32,Float64,BigFloat)
            one = ObservableSeries(T[2];index_time=true)
            r = statistical_summary(one).value
            @test r.mean == T(2)
            @test r.variance === r.std === r.standard_error === nothing
            @test autocorrelation(one).evidence.status == :unknown
            @test correlated_mean(one).status == :unknown
            s = ObservableSeries(fill(T(2),4);index_time=true)
            @test statistical_summary(s).value.variance == 0
            @test running_statistics(s).value.variances[2:end] == zeros(3)
            ac = autocorrelation(s;maxlag=3)
            @test ac.autocovariance == zeros(4)
            @test ac.autocorrelation === nothing
            @test integrated_autocorrelation_time(ac).status == :unknown
            @test correlated_mean(s).status == :unknown
            @test only(block_average(s;block_sizes=[2]).standard_errors) == 0
        end
        @test_throws ArgumentError ObservableSeries([1.,missing];missing_policy=:drop)
    end

    @testset "subnormal and extreme finite observations" begin
        for T in (Float32,Float64)
            tiny = nextfloat(zero(T))
            r = statistical_summary(ObservableSeries(T[tiny,2tiny])).value
            @test isfinite(r.mean)
            @test tiny <= r.mean <= 2tiny
            @test r.variance >= 0 # The exact variance is below representable range.
            x = sqrt(tiny)*T(2)
            xs = T[-x,x,-x,x]
            out = statistical_summary(ObservableSeries(xs)).value
            ref = reference_moments(xs)
            @test out.variance > 0
            @test out.variance ≈ ref.variance rtol=0.25
            # Huge constants have a finite mean and exactly zero variance even
            # though x*x overflows; zero initialization must not reject them.
            huge = floatmax(T)/T(2)
            constant = statistical_summary(ObservableSeries(fill(huge,4)))
            @test constant.value !== nothing
            if constant.value !== nothing
                @test constant.value.mean == huge
                @test iszero(constant.value.variance)
            end
            # True variance outside the working range may honestly be unknown;
            # never publish Inf/NaN as heuristic moments.
            overflow = statistical_summary(ObservableSeries(T[-huge,huge]))
            @test overflow.status == :unknown ||
                (isfinite(overflow.value.mean) && isfinite(overflow.value.variance))
            # RED reproducer: m2 overflows although final sample variance fits.
            # statistics.jl:_ts_moments needs scaled accumulation or an explicit
            # wider fallback, not merely a post-hoc nonfinite guard.
            amplitude = sqrt(floatmax(T))/T(2)
            xs = repeat(T[-amplitude,amplitude],4)
            finitevar = statistical_summary(ObservableSeries(xs))
            ref = reference_moments(xs)
            @test finitevar.value !== nothing
            if finitevar.value !== nothing
                @test finitevar.value.variance ≈ ref.variance rtol=64eps(T)
            end
            running=running_statistics(ObservableSeries(xs))
            @test running.value !== nothing
            if running.value !== nothing
                @test last(running.value.variances) ≈ ref.variance rtol=64eps(T)
            end
        end
    end

    @testset "saved-time tolerance, representable neighbors and duplicates" begin
        for T in (Float32,Float64,BigFloat)
            t0 = T(1)
            step = eps(t0)
            times = [t0,t0+step,t0+2step,t0+3step]
            info = sampling_info(4;times)
            @test info.regularity == :regular
            @test info.interval == step
            @test_throws ArgumentError sampling_info(3;times=[t0,t0+step,t0+step])
            @test_throws ArgumentError sampling_info(3;times=[t0,t0+step,t0])
            @test sampling_info(0;times=T[]).regularity == :insufficient
            @test sampling_info(1;times=T[1]).regularity == :insufficient
        end
        @test sampling_info(3;times=[0.,1.,2.0+1e-9]).regularity == :regular
        @test sampling_info(3;times=[0.,1.,2.0+1e-7]).regularity == :irregular
        @test sampling_info(3;times=[0.,1e-200,3e-200]).regularity == :irregular
        @test sampling_info(3;times=[0.,1000.,2000.]u"ms",interval=1u"s").regularity == :regular
        @test_throws ArgumentError sampling_info(2;times=[0.,Inf])
        @test_throws ArgumentError sampling_info(2;interval=0.)
        @test_throws ArgumentError sampling_info(3;times=[0.,1.,2.],interval=2.)
        s = ObservableSeries([1.,2.,3.,4.];times=[0.,1.,2.,4.])
        @test autocorrelation(s).evidence.status == :unknown
        @test correlated_mean(s).status == :unknown
        frame(i) = AtomisticSnapshot([[Float64(i),0.]])
        trajectory = AtomisticTrajectoryView(4,frame;times=[0.,1.,2.,3.]u"s")
        @test sampling_info(trajectory).interval == 1u"s"
    end

    @testset "stored B-A and overflow/underflow-safe independent SE" begin
        # Stored-result fixtures intentionally isolate compare from upstream
        # variance overflow. Compare consumes supplied estimates, not samples.
        for T in (Float32,Float64), unit in (1,u"J")
            sa = ObservableSeries(T[1,2,3,4].*unit;name=:energy,index_time=true)
            sb = ObservableSeries(T[3,4,5,6].*unit;name=:energy,index_time=true)
            ra = correlated_mean(sa;maxlag=3)
            rb = correlated_mean(sb;maxlag=3)
            for se in (floatmax(T)/T(4),floatmin(T))
                ar = A.PropertyResult(merge(ra.value,(standard_error=se*unit,)),
                    ra.status,ra.method,ra.notes)
                br = A.PropertyResult(merge(rb.value,(standard_error=se*unit,)),
                    rb.status,rb.method,rb.notes)
                a,b = ComparisonInput(ar;series=sa),ComparisonInput(br;series=sb)
                c = compare(a,b;unitless=true,independence=:independent)
                @test c.compatibility.status == :compatible
                @test c.difference.value ≈ T(2)*unit
                # RED: sqrt(se_a^2+se_b^2) spuriously overflows/underflows.
                # comparison.jl:303: hypot after conversion to reference units.
                @test c.uncertainty.status == :heuristic
                @test c.uncertainty.value !== nothing
                if c.uncertainty.value !== nothing
                    @test c.uncertainty.value ≈ hypot(se,se)*unit rtol=64eps(T) atol=zero(se)*unit
                    @test c.uncertainty.value > zero(se)*unit
                end
                @test compare(a,b;unitless=true).uncertainty.status == :unknown
                @test compare(a,a;unitless=true,independence=:independent).uncertainty.status == :unknown
            end
            # True B-A overflow is a refusal, not a finite saturated answer.
            h = floatmax(T)*unit
            left = ObservableSeries([-h];name=:energy)
            right = ObservableSeries([h];name=:energy)
            c = compare(ComparisonInput(statistical_summary(left);series=left),
                ComparisonInput(statistical_summary(right);series=right);unitless=true)
            @test c.compatibility.status == :compatible
            @test c.difference.status == :unknown
            @test c.difference.value === nothing
        end
    end
end
end # module
