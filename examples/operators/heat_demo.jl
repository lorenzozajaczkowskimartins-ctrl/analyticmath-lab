# Run from repository root:
# JULIA_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 julia +release --project=examples/operators examples/operators/heat_demo.jl
# Integration gate trains both routes and writes the same artifacts: run it INSTEAD
# of this demo when assertions are desired, not concurrently or as a duplicate job.
include("heat_showcase.jl")

if isempty(ARGS)
    HeatShowcase.run_showcase()
elseif ARGS == ["--reuse"]
    # Reuse fitted parameters for real held-out inference without optimization.
    # Reports/plots from the training run remain intact. No Serialization dependency.
    for d in (HeatShowcase.HeatFamily.parametric_dataset(), HeatShowcase.HeatFamily.operator_dataset())
        path = joinpath(HeatShowcase.OUTPUT, string(d.kind) * "_parameters.txt")
        isfile(path) || error("Missing $path; run the demo or integration gate once first")
        m = HeatShowcase.load_model(path, d)
        for split in HeatShowcase.SPLITS
            samples = filter(s -> s.split == split, d.samples)
            isempty(samples) && continue
            predictions = vcat((HeatShowcase.A.predict(m, s.input, s.coordinates) for s in samples)...)
            reference = vcat((s.values for s in samples)...)
            errors = HeatShowcase.A.field_errors(predictions, reference)
            println(d.kind, " / ", split, ": sampled relative L2=", errors.relative_sampled_l2,
                "; sampled RMS reference error=", errors.summary.rms)
        end
    end
else
    error("Usage: heat_demo.jl [--reuse]")
end
