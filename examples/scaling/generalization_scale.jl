# Mandatory bounded GeneralizationAnalysis measurement, not a training showcase.
# Run with --project=examples/operators; no extreme or million-neural-query run.
module GeneralizationScale
using Test, AnalyticMathLab, Lux, NeuralOperators, Optimization, OptimizationOptimisers, ADTypes, Random
using ComponentArrays: ComponentArray
import Zygote
include("harness.jl")
using .ScaleHarness
function main()
    b=budget_from_env(); rows=NamedTuple[]
    @testset "M10C stored generalization scaling" begin
        for n in (100,10_000)
            q=vcat(reshape(collect(range(0.,1.;length=n)),1,:),zeros(1,n))
            s=ScientificSample(:train,[0.2],q,copy(q[1,:]);split=:training)
            d=ScientificDataset([s];kind=:surrogate,family=:controlled,input_names=(:a,),coordinate_names=(:x,:t),
                domain=(inputs=[0.1 0.3],coordinates=[0. 1.;0. 1.]),reference=(kind=:manufactured,),
                units=:dimensionless,grid=(resampling=:none,),rng=(seed=42,))
            m=learning_model(d,Lux.Dense(3=>1);rng=Xoshiro(42),normalization=:none,rng_provenance=(seed=42,))
            # One real tiny optimizer step produces an honest native result; it is
            # not counted as model accuracy/convergence evidence or timed analysis.
            r=AnalyticMathLab.train(m,d;initial_parameters=ComponentArray{Float64}(m.parameters),
                optimizer=OptimizationOptimisers.Adam(0.001),adtype=ADTypes.AutoZygote(),maxiters=1)
            check=a->begin
                @test a.training===r
                @test only(a.cases).reference===s.values
                @test only(a.cases).prediction ≈ AnalyticMathLab.predict(r,s.input,s.coordinates)
                @test a.groups[:training].errors.summary == only(a.cases).errors.summary
                @test a.groups[:training].per_coordinate_rms ≈ only(a.cases).errors.absolute
                @test a.evidence.status==:unknown
                abs(a.groups[:training].errors.summary.rms-only(a.cases).errors.summary.rms)
            end
            measure!(rows,b,"stored_generalization",n,256big(n),()->analyze(r);
                check,output_count=a->length(only(a.cases).prediction),
                algorithm="existing full-output contract: predictions/references, group copies and per-coordinate errors")
            report("generalization",rows,b)
        end
    end
end
abspath(PROGRAM_FILE)==(@__FILE__) && main()
end
