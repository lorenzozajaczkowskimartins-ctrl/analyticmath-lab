"""Internal, machine-local measurement helpers; not an AML public API.

Memory estimates are preflight contracts supplied by each workload, not RSS caps.
The time budget is checked between calls; non-cooperative kernels must also run
under the documented external process timeout. Never use this to attempt an OOM.
"""
module ScaleHarness
using LinearAlgebra, TOML, SHA
export StressBudget, dense_bytes, measure!, report, budget_from_env

struct StressBudget
    max_memory::BigInt
    max_seconds::Float64
    threads::Int
    level::Int
    function StressBudget(;max_memory=512*1024^2,max_seconds=120.,threads=1,level=0)
        max_memory isa Integer && max_memory>0 || throw(ArgumentError("positive integer byte budget required"))
        max_seconds isa Real && isfinite(max_seconds) && max_seconds>0 || throw(ArgumentError("finite positive seconds required"))
        seconds=Float64(max_seconds)
        isfinite(seconds) && seconds>0 || throw(ArgumentError("seconds must be representable"))
        threads isa Integer && threads>0 || throw(ArgumentError("positive thread ceiling required"))
        level isa Integer && level in 0:3 || throw(ArgumentError("level must be 0:3"))
        level==3 && get(ENV,"AML_EXTREME","0")!="1" && throw(ArgumentError("level 3 requires AML_EXTREME=1"))
        new(big(max_memory),seconds,Int(threads),Int(level))
    end
end
function dense_bytes(dims...;element_bytes=8)
    all(d->d isa Integer && d>=0,dims) || throw(ArgumentError("nonnegative integer dimensions required"))
    element_bytes isa Integer && element_bytes>0 || throw(ArgumentError("positive element width required"))
    prod(big.(dims);init=big(element_bytes))
end
budget_from_env()=StressBudget(max_memory=parse(BigInt,get(ENV,"AML_MAX_BYTES","536870912")),
    max_seconds=parse(Float64,get(ENV,"AML_MAX_SECONDS","120")),
    threads=parse(Int,get(ENV,"AML_MAX_THREADS","1")),level=parse(Int,get(ENV,"AML_SCALE_LEVEL","0")))

function measure!(rows,b::StressBudget,name,n,estimate,f;check=x->0.,output_count=x->0,
        algorithm="",repeats=2)
    estimate isa Integer && estimate>=0 || throw(ArgumentError("nonnegative byte estimate required"))
    repeats isa Integer && repeats>0 || throw(ArgumentError("positive repeats required"))
    Threads.nthreads()<=b.threads && BLAS.get_num_threads()<=b.threads ||
        throw(ArgumentError("Julia/BLAS thread count exceeds configured ceiling"))
    base=(name=String(name),n=n,estimated_bytes=big(estimate),algorithm=String(algorithm))
    emptyrow=(elapsed_seconds=0.,allocated_bytes=0,result_bytes=0,output_count=0,
        correctness_metric=0.,warmup_seconds=0.,repeats_completed=0,rss_highwater_bytes=Sys.maxrss())
    if estimate>b.max_memory
        push!(rows,merge(base,emptyrow,(status="refused_by_guardrail",)))
        return last(rows)
    end
    started=time_ns(); warm=@timed f(); metric=check(warm.value)
    count=output_count(warm.value); storage=Base.summarysize(warm.value)
    warmtime=warm.time; warm=nothing
    elapsed=0.; allocated=0; completed=0
    for _ in 1:repeats
        (time_ns()-started)/1e9>=b.max_seconds && break
        run=@timed f()
        metric=check(run.value); count=output_count(run.value)
        storage=Base.summarysize(run.value)
        elapsed+=run.time; allocated+=run.bytes; completed+=1
        run=nothing
    end
    overdue=(time_ns()-started)/1e9>=b.max_seconds
    status=overdue || completed<repeats ? "timed_out_safely" : "completed"
    push!(rows,merge(base,(elapsed_seconds=completed==0 ? 0. : elapsed/completed,
        allocated_bytes=completed==0 ? 0 : allocated÷completed,result_bytes=storage,
        output_count=count,correctness_metric=metric,warmup_seconds=warmtime,
        repeats_completed=completed,rss_highwater_bytes=Sys.maxrss(),status=status)))
    last(rows)
end

_csv(x)="\""*replace(string(x),'"'=>"\"\"")*"\""
function report(name,rows,b::StressBudget;directory=joinpath(@__DIR__,"..","..","output","scaling"))
    mkpath(directory)
    csv=joinpath(directory,name*".csv")
    # Atomic replacement retains the previous complete checkpoint on interruption.
    open(csv*".tmp","w") do io
        if !isempty(rows)
            columns=keys(first(rows)); println(io,join(string.(columns),","))
            for row in rows
                keys(row)==columns || throw(ArgumentError("measurement row schemas differ"))
                println(io,join((_csv(getproperty(row,k)) for k in columns),","))
            end
        end
    end
    mv(csv*".tmp",csv;force=true)
    root=normpath(joinpath(@__DIR__,"..",".."))
    hashes=Dict{String,String}()
    for folder in ("src","ext","examples/scaling"), (dir,_,files) in walkdir(joinpath(root,folder)), file in files
        endswith(file,".jl") || endswith(file,".toml") || continue
        p=joinpath(dir,file); hashes[relpath(p,root)]=bytes2hex(sha256(read(p)))
    end
    for file in ("Project.toml","Manifest.toml")
        hashes[file]=bytes2hex(sha256(read(joinpath(root,file))))
    end
    metadata=Dict("julia_version"=>string(VERSION),"julia_threads"=>Threads.nthreads(),
        "blas_threads"=>BLAS.get_num_threads(),"cpu"=>Sys.cpu_info()[1].model,
        "numeric_type_default"=>"Float64; workload must identify exceptions",
        "max_estimated_bytes"=>string(b.max_memory),"max_seconds"=>b.max_seconds,
        "level"=>b.level,"rss_highwater_bytes"=>Sys.maxrss(),
        "rss_scope"=>"process lifetime high-water RSS, NOT workload allocation or isolated peak",
        "time_policy"=>"cooperative between calls; external process timeout required for hard deadline",
        "source_sha256"=>hashes)
    path=joinpath(directory,name*".toml")
    open(io->TOML.print(io,metadata),path*".tmp","w")
    mv(path*".tmp",path;force=true)
    println("report: ",csv)
    csv
end
end
