# Optional, sequential and deliberately outside base Pkg.test(). Always trains afresh.
using Test
include("heat_showcase.jl")
using .HeatShowcase
const A = HeatShowcase.A

function verify_runs(runs)
@testset "M9D analytical heat showcase" begin
    @test length(runs) == 2
    for run in runs
        r, a, d = run.result, run.analysis, run.result.dataset
        @test r.solution !== nothing || hasproperty(r.provenance, :checkpoint)
        @test r.objective.final < r.objective.initial
        @test isfinite(r.objective.final)
        # A fixed loose acceptance criterion, not used for optimizer selection/stopping.
        @test a.groups[:interpolation].errors.relative_sampled_l2 < 0.15
        @test Set(keys(a.groups)) == Set(s.split for s in d.samples)
        @test sum(g.sample_count for g in values(a.groups)) == length(d.samples)
        @test a.reference.kind == :analytical
        @test a.evidence.status == :unknown
        @test r.provenance.heldout_used_in_objective == false
        @test r.provenance.reference_used_in_objective == false
        @test length(a.physics) == length(d.samples)
        for e in a.physics
            @test all(isfinite, e.model.values)
            @test maximum(abs, e.reference.values) < 1e-10
            @test isempty(intersect(Tuple.(eachcol(e.model.points.coordinates)),
                Tuple.(eachcol(first(d.samples).coordinates))))
        end
        @test a.timing.context.reference_kind == :analytical_closed_form
        @test a.timing.context.query_count == length(first(filter(s -> s.split == :interpolation, d.samples)).values)
        @test length(a.timing.reference_seconds) == 11
        @test length(a.timing.inference_seconds) == 11
        @test isfile(run.report) && filesize(run.report) > 0
        @test all(p -> isfile(p) && filesize(p) > 0, run.figures)

        # Reload numeric parameters, not executable Julia or native optimizer internals.
        restored = HeatShowcase.load_model(run.checkpoint, d)
        s = first(filter(s -> s.split == :interpolation, d.samples))
        @test A.predict(restored, s.input, s.coordinates) ≈ A.predict(r, s.input, s.coordinates)

        m = HeatShowcase.make_model(d)
        p = HeatShowcase.ComponentArray{Float64}(m.parameters)
        before = A.training_data(m, d)
        poisoned = deepcopy(d)
        for s in poisoned.samples
            s.split == :training || (s.values .= 1e8)
        end
        after = A.training_data(m, poisoned)
        @test before.ids == [s.id for s in d.samples if s.split == :training]
        @test before.inputs == after.inputs
        @test before.targets == after.targets
        @test A.learning_objective(m, p, before) == A.learning_objective(m, p, after)
        for field in (:inputs, :coordinates, :outputs)
            z, zp = A.fit_scaling(d, field), A.fit_scaling(poisoned, field)
            @test z.fitted_ids == before.ids
            @test z.offset == zp.offset && z.scale == zp.scale
        end
        training = filter(s -> s.split == :training, d.samples)
        held = filter(s -> s.split != :training, d.samples)
        @test all(t.input != h.input for t in training for h in held)
        if d.kind == :operator
            @test m.architecture == :deeponet
            @test m.schema.sensors == d.sensors
            @test A.classify_query(m, s.input, s.coordinates).function_family == :unknown
            @test_throws ArgumentError A.predict(m, s.input, s.coordinates; sensors=d.sensors .+ 0.01)
        end
    end
end
end

if abspath(PROGRAM_FILE) == @__FILE__
    verify_runs(HeatShowcase.run_showcase(; plots=true))
end
