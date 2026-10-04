"""Machine-local M9 data/analysis ladder. Level 1 actually executes one million queries.
Run: AML_SCALE_LEVEL=1 julia --project=. examples/scaling/million_query_analysis.jl
Use the documented external timeout; budgets cover estimated workload storage, not JIT RSS.
"""
module MillionQueryAnalysis
using AnalyticMathLab
include("harness.jl")
using .ScaleHarness
function main(;budget=budget_from_env())
    rows=NamedTuple[]
    sizes=([10_000],[10_000,100_000,1_000_000],[100_000,1_000_000,5_000_000],[1_000_000,10_000_000])[budget.level+1]
    for n in sizes
        estimate=dense_bytes(n,12)
        # Entire data allocation happens inside the preflight-guarded call.
        for summary_only in (false,true)
            measure!(rows,budget,summary_only ? "field_summary" : "field_full",n,estimate,
                ()->field_errors(fill(3.,n),fill(1.,n);summary_only);
                check=e->begin
                    @assert e.summary.rms==2. && e.relative_sampled_l2==2.
                    @assert e.summary.count==n
                    abs(e.summary.rms-2.)
                end,output_count=e->summary_only ? 1 : length(e.absolute),
                algorithm=summary_only ? "fused normalized reductions; no error arrays" : "retained absolute errors")
        end
        measure!(rows,budget,"sampled_summary",n,estimate,()->sampled_summary(fill(3.,n));
            check=s->begin @assert s.rms==3. && s.count==n; abs(s.rms-3.) end,
            output_count=s->1,algorithm="normalized mapped reductions")
        measure!(rows,budget,"scientific_data_scaling",n,estimate,()->begin
            q=reshape(collect(range(0.,1.;length=n)),1,:)
            s=ScientificSample(:train,[0.2],q,fill(3.,n);split=:training)
            d=ScientificDataset([s];kind=:surrogate,family=:constant,input_names=(:a,),coordinate_names=(:x,),
                domain=(inputs=[0. 1.],coordinates=[0. 1.]),reference=(kind=:manufactured,),units=:dimensionless,
                grid=(resampling=:none,),rng=(seed=:none,))
            scale=fit_scaling(d,:coordinates)
            (points=PINNPoints(q),dataset=d,scaled=transform(scale,q))
        end;check=x->begin
            @assert x.dataset.samples[1].values[1]==3.
            @assert first(x.scaled)==-1. && last(x.scaled)==1.
            @assert size(x.points.coordinates,2)==n
            0.
        end,output_count=x->length(x.scaled),algorithm="owned Float64 snapshots and affine normalization")
        report("million_query_analysis",rows,budget)
    end
    # AD collocation: 10k locally; summary-only intentionally re-evaluates deterministic AD.
    n=budget.level==0 ? 100 : 10_000
    for summary_only in (false,true)
        measure!(rows,budget,summary_only ? "heat_residual_summary" : "heat_residual_full",n,dense_bytes(n,16),
            ()->heat_residual(q->q[1]^2+q[2],PINNPoints(fill(0.3,2,n));alpha=0.2,summary_only);
            check=x->begin @assert isapprox(x.summary.rms,0.6;rtol=1e-12); abs(x.summary.rms-0.6) end,
            output_count=x->summary_only ? 1 : length(x.values),algorithm="ForwardDiff coordinate gradient/Hessian; sampled not continuum")
    end
    report("million_query_analysis",rows,budget)
    rows
end
abspath(PROGRAM_FILE)==(@__FILE__) && main()
end
