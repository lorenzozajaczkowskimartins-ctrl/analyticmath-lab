# Manual only: AML_EXTREME=1 julia +release --project=. examples/scaling/extreme_streaming_statistics.jl --samples=10000000000 --chunk-size=1000000 --max-seconds=120
using TOML
include("streaming_helpers.jl")
function main(args=ARGS)
    options=Dict("samples"=>"1000000","chunk-size"=>"100000","max-seconds"=>"30")
    for arg in args
        startswith(arg,"--") && occursin('=',arg) || error("expected --key=value")
        k,v=split(arg[3:end],'=';limit=2)
        haskey(options,k) || error("unknown option: $k")
        options[k]=v
    end
    n=parse(Int,options["samples"]); chunk=parse(Int,options["chunk-size"])
    seconds=parse(Float64,options["max-seconds"])
    println((requested=n,estimated_state_bytes=4096,work="O(requested), not a runtime estimate",max_seconds=seconds))
    # Warm only a small separate stream; do not silently run the extreme twice.
    StreamingScale.stream_summary(1000;progress=false)
    r=@timed StreamingScale.stream_summary(n;chunk_size=chunk,max_seconds=seconds)
    v=r.value
    summary=Dict("requested"=>n,"consumed"=>v.consumed,"status"=>v.status,
        "elapsed_seconds"=>r.time,"allocated_bytes"=>r.bytes,"result_bytes"=>Base.summarysize(v),
        "rss_highwater_bytes"=>Sys.maxrss(),"julia_version"=>string(VERSION),
        "julia_threads"=>Threads.nthreads(),"cpu"=>Sys.cpu_info()[1].model,
        "chunk_size"=>chunk,"max_seconds"=>seconds,"estimated_state_bytes"=>4096,
        "samples_per_second"=>v.samples_per_second,
        "standard_error"=>"unknown; no independence assumption")
    if v.moments!==nothing
        summary["mean"]=v.moments.mean
        summary["sample_variance"]=something(v.moments.variance,"unavailable")
        @assert v.moments.count==v.consumed
        @assert abs(v.moments.mean)<2/max(1,v.consumed)
        v.consumed>1 && @assert abs(v.moments.variance-v.consumed/(v.consumed-1))<1e-6
    end
    dir=joinpath(@__DIR__,"../../output/scaling");mkpath(dir)
    path=joinpath(dir,"extreme_stream.toml")
    open(io->TOML.print(io,summary),path,"w")
    println(summary)
end
abspath(PROGRAM_FILE)==(@__FILE__) && main()
