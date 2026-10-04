#= Dense full-mode breakpoint: default safe; AML_SCALE_LEVEL=1 adds n=1200.
All n>=3000 full solves are refused under default 512 MiB workspace estimate.
No full Hessian is built to demonstrate an unsafe size. See CSV/TOML metadata.
Run: julia --project=. examples/scaling/when_dense_dies.jl
=#
using AnalyticMathLab, LinearAlgebra
if !isdefined(@__MODULE__,:ScaleHarness)
    include("harness.jl")
end
using .ScaleHarness
function when_dense_dies_main(;budget=budget_from_env())
    rows=NamedTuple[]
    sizes=budget.level==0 ? (40,150,600,3000,6000,10000,15000,30000) : (40,150,600,1200,3000,6000,10000,15000,30000)
    for n in sizes
        payload=dense_bytes(n,n); estimate=24payload
        println("n=$n one dense Float64 Hessian payload=$payload full-mode estimate=$estimate")
        if estimate<=budget.max_memory
            measure!(rows,budget,"structured_M_K_construction",n,32big(n),
                ()->(SymTridiagonal(fill(2.,n),fill(-1.,n-1)),Diagonal(ones(n)));
                check=x->begin @assert x[1][1,1]==2.; 0. end,
                output_count=x->3n-1,algorithm="O(n) structured explicit K, diagonal M")
            measure!(rows,budget,"dense_H_materialization",n,2payload,
                ()->Matrix(SymTridiagonal(fill(2.,n),fill(-1.,n-1)));
                check=x->begin @assert tr(x)==2n; 0. end,
                output_count=length,algorithm="explicit dense Hessian; n² outputs")
        end
        measure!(rows,budget,"full_modes",n,estimate,
            ()->normal_modes(SymTridiagonal(fill(2.,n),fill(-1.,n-1)),Diagonal(ones(n));max_memory_bytes=budget.max_memory);
            check=r->begin
                oracle=[4sin(j*pi/(2(n+1)))^2 for j in 1:n]
                err=maximum(abs.(r.eigenvalues-oracle)); @assert err<1e-10
                K=SymTridiagonal(fill(2.,n),fill(-1.,n-1))
                @assert norm(K*r.mode_vectors-r.mode_vectors*Diagonal(r.eigenvalues))<1e-8
                err
            end,output_count=r->length(r.eigenvalues),algorithm="full dense mass-weighted LAPACK; 24 payload workspace estimate")
        report("when_dense_dies",rows,budget)
    end
    rows
end
abspath(PROGRAM_FILE)==(@__FILE__) && when_dense_dies_main()
