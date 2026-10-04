include("harness.jl")
using .ScaleHarness
function main()
    b=budget_from_env(); rows=NamedTuple[]
    for n in (15_000,30_000)
        measure!(rows,b,"dense_hessian_payload",n,dense_bytes(n,n),()->error("unsafe kernel must not execute");
            algorithm="Float64 dense payload estimate, excludes solver workspace")
        @assert last(rows).status=="refused_by_guardrail"
    end
    report("guardrails",rows,b)
end
abspath(PROGRAM_FILE)==(@__FILE__) && main()
