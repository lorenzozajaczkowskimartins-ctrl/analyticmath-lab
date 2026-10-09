# Optional; julia --project=examples/operators test/m10d_flagship_learning.jl
module M10DFlagshipLearningTests
using Test, AnalyticMathLab
const file = joinpath(@__DIR__,"..","examples","integration","one_system_learning.jl")
@testset "M10D4 bounded oscillator learning and generalization" begin
    @test isfile(file)
    if isfile(file)
        include(file)
        L = OneSystemLearning
        r = Base.invokelatest(L.run_learning)
        W = L.OneSystemManyMethods
        s, d, fit, a = r.core.system, r.dataset, r.fit, r.analysis
        @test d.family == r.core.dataset.family
        @test d.family.parameters == s.parameters
        @test d.reference.kind == :numerical
        @test d.reference.error == :unknown
        @test d.input_names == (:symmetric_amplitude,)
        @test d.coordinate_names == (:t,)
        @test d.units == r.core.dataset.units
        @test fit.dataset === d
        @test a.training === fit
        @test a.reference === d.reference
        @test a.evidence.status == fit.evidence.status == :unknown
        @test Set(keys(a.groups)) == Set((:training,:interpolation,:parameter_extrapolation))
        @test fit.provenance.training_ids == [:canonical,:lower,:upper]
        @test r.batch.ids == [:canonical,:lower,:upper]
        @test length(r.batch.targets) == 3length(s.times)
        @test r.model.schema.input_names == d.input_names
        @test r.model.schema.coordinate_names == d.coordinate_names
        @test r.model.schema.units == d.units
        @test r.model.provenance.resampling == :none
        training = filter(x->x.split==:training,d.samples)
        expected_inputs = hcat((vcat(repeat(AnalyticMathLab.transform(r.model.normalization.inputs,
            reshape(x.input,:,1)),1,length(x.values)),
            AnalyticMathLab.transform(r.model.normalization.coordinates,x.coordinates)) for x in training)...)
        @test r.batch.inputs == expected_inputs
        @test inverse_transform(r.model.normalization.outputs,r.batch.targets) ≈
            reshape(vcat((x.values for x in training)...),1,:)
        @test fit.provenance.maxiters == 1
        @test !fit.provenance.heldout_used_in_objective
        @test isfinite(r.initial_loss) && isfinite(fit.objective.final)
        @test r.model.provenance.rng.seed == 41
        @test !isempty(fit.history)
        for (sample,case,source) in zip(d.samples,a.cases,r.sources)
            @test case.id == sample.id
            @test case.split == sample.split
            @test sample.values == only(source.samples).values
            @test sample.coordinates == reshape(s.times,1,:)
            @test sample.input == [r.cases[sample.id].amplitude]
            @test sample.split == r.cases[sample.id].split
            @test sample.values ≈ [W.exact_state(s,t;amplitude=sample.input[1])[1] for t in s.times] atol=2e-8
            @test case.reference == sample.values
            @test case.coordinates == sample.coordinates
            @test case.classification.parameter == (sample.split==:parameter_extrapolation ? :outside : :inside)
            @test case.classification.coordinate == :inside
            @test case.classification.guarantee == :none
            @test case.errors.summary.rms ≈ sqrt(sum((case.prediction.-case.reference).^2)/length(case.reference))
            @test all(isfinite,case.prediction)
            @test case.errors.summary.rms < 2.0 # bounded pipeline, not a fit-accuracy claim
        end
        @test all(c.compatibility == :explicit_same_quantity_and_conventions for c in r.comparisons)
        @test all(c.agreement for c in r.comparisons)
        origin = AnalyticMathLab.scientific_origin(a)
        @test only(origin.parents).token == objectid(fit)
        @test only(only(origin.parents).parents).token == objectid(d)
        @test length(W.origin_trace(a)) <= 8
        @test Base.summarysize(origin) < 4096
        @test d.provenance.origin.token == objectid(r.core.dataset)
        @test all(x.reference.kind == :numerical for x in r.sources)
        @test all(x.provenance.source_retention == :descriptor for x in r.sources)
        @test AnalyticMathLab.scientific_metadata(a).reference.value.kind == :numerical
        for model_file in (file, joinpath(dirname(file),"one_system_many_methods.jl"))
            code=read(model_file,String)
            @test !occursin(r"(?:AML|AnalyticMathLab)\._",code)
            @test !occursin("Base.include",code)
            @test !occursin(r"include\(.*(?:src/|test/)",code)
        end
        println("LEARNING_ERRORS ",r.errors)
        println("LEARNING_TRACE ",W.origin_trace(a))
    end
end
end
