# All pairs are quadratic even when an aggregate retains only O(N) output.
using AnalyticMathLab
include("harness.jl")
using .ScaleHarness
function main()
    b=budget_from_env();rows=NamedTuple[]
    ladder=b.level==0 ? (100,500) : (100,500,1000)
    for n in ladder
        s=AtomisticSnapshot([(Float64(i),0.,0.) for i in 1:n])
        pairs=big(n)*(n-1)÷2
        measure!(rows,b,"explicit_pairs",n,64pairs+64big(n),()->pair_distances(s;max_bytes=b.max_memory);
            algorithm="all unordered pairs; O(N²) work/output",
            output_count=r->length(r.value.distances),check=r->begin
                @assert r.value!==nothing && length(r.value.distances)==pairs
                @assert r.value.minimum==1. && r.value.maximum==n-1
                0.
            end)
        measure!(rows,b,"coordination",n,256big(n),()->coordination(s;cutoff=1.);
            algorithm="all-pair traversal; O(N) retained output, O(N²) work",
            output_count=r->length(r.value.counts),check=r->begin
                @assert r.value.counts==vcat(1,fill(2,n-2),1)
                0.
            end)
        report("atomistic",rows,b)
    end
    # Large geometry is built safely; its quadratic pair OUTPUT is never built.
    for n in (10_000,100_000)
        s=AtomisticSnapshot([(Float64(i),0.,0.) for i in 1:n])
        r=pair_distances(s;max_bytes=b.max_memory)
        @assert r.status==:unknown && occursin("refused",join(r.notes))
        println(join(r.notes))
        pairs=big(n)*(n-1)÷2
        measure!(rows,b,"explicit_pairs",n,64pairs+64big(n),()->error("must refuse before call");
            algorithm="estimated only; explicit output refused")
        report("atomistic",rows,b)
    end
end
abspath(PROGRAM_FILE)==(@__FILE__) && main()
