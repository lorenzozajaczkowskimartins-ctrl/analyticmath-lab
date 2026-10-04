# Safe: julia +release --project=. examples/scaling/million_sample_statistics.jl
using AnalyticMathLab
include("harness.jl")
include("streaming_helpers.jl")
using .ScaleHarness, .StreamingScale
function main()
    b=budget_from_env(); rows=NamedTuple[]
    ladder=b.level==0 ? (1000,10_000) : b.level==1 ? (100_000,1_000_000) : (100_000,1_000_000,10_000_000)
    for n in ladder
        samples=StreamingScale.AlternatingSamples(n)
        check=r->begin
            @assert r.status=="completed" && r.consumed==n
            @assert abs(r.moments.mean)<1e-12
            err=abs(r.moments.variance-n/(n-1))
            @assert err<1e-10
            err
        end
        measure!(rows,b,"lazy_moments",n,4096,
            ()->StreamingScale.stream_summary(n;progress=false,max_seconds=b.max_seconds);
            check,output_count=r->r.consumed,algorithm="M10B Welford, O(1) auxiliary storage")
        measure!(rows,b,"stored_moments",n,dense_bytes(n)+4096,
            ()->statistical_summary(ObservableSeries(collect(samples)));
            check=r->begin
                @assert abs(r.value.variance-n/(n-1))<1e-10
                abs(r.value.mean)
            end,output_count=r->r.value.count,algorithm="same Welford; explicit input materialization")
        report("statistics",rows,b)
    end
    # Full running/block outputs and full-sample centered ACF are intentionally
    # measured on bounded prefixes, not advertised as O(1) output contracts.
    n=10_000; s=ObservableSeries(StreamingScale.AlternatingSamples(n);index_time=true)
    for (name,f,estimate) in (("running_prefix",()->running_statistics(s),64big(n)),
            ("block_prefix",()->block_average(s;block_sizes=[10,100]),32big(n)),
            ("acf_prefix",()->autocorrelation(s;maxlag=16),32big(n)))
        measure!(rows,b,name,n,estimate,f;algorithm="bounded prefix; retained output, not extreme-stream estimator")
    end
    report("statistics",rows,b)
end
abspath(PROGRAM_FILE)==(@__FILE__) && main()
