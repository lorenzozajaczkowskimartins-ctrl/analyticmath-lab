"""Reusable M9D heat experiments. Training and all evidence remain separate.

Defaults are fixed before evaluation: Float64 CPU, full-batch Adam(0.005),
3000 iterations per model, seeds 911/912. No held-out stopping or tuning.
`run_showcase` trains sequentially. `load_model` reuses numeric checkpoints for
inference without retraining; optimizer objects/history are intentionally not serialized.
"""
module HeatShowcase
using AnalyticMathLab, Lux, NeuralOperators, Optimization, OptimizationOptimisers
using ComponentArrays: ComponentArray
using ADTypes, Zygote, Random, CairoMakie
const A = AnalyticMathLab
include("heat_family.jl")
const OUTPUT = normpath(joinpath(@__DIR__, "../../notebooks/output/m9d_heat"))
const SPLITS = (:training, :interpolation, :parameter_extrapolation,
    :amplitude_extrapolation, :frequency_extrapolation, :coordinate_extrapolation)
const CHECKPOINT_VERSION = "M9D_HEAT_PARAMETERS_V1"
seed(d) = d.kind == :surrogate ? 911 : 912

function make_model(d)
    network = if d.kind == :surrogate
        Lux.Chain(Lux.Dense(3 => 24, tanh), Lux.Dense(24 => 24, tanh), Lux.Dense(24 => 1))
    else
        NeuralOperators.DeepONet(Lux.Dense(9 => 12),
            Lux.Chain(Lux.Dense(2 => 24, tanh), Lux.Dense(24 => 24, tanh), Lux.Dense(24 => 12)))
    end
    A.learning_model(d, network; rng=Xoshiro(seed(d)), normalization=:train_minmax,
        rng_provenance=(seed=seed(d), type=:Xoshiro, policy=:fixed_before_evaluation))
end

"""Plain Float64 parameter checkpoint: no extra dependency and no eval on load.

Tied to this architecture version and the installed Lux/NeuralOperators versions.
Recreates preprocessing from the unchanged training dataset. Does not claim to
restore an optimizer or provide resumable optimizer state.
"""
function save_model(path, r)
    m = r.model
    open(path, "w") do io
        println(io, CHECKPOINT_VERSION)
        println(io, m.schema.kind)
        println(io, string(pkgversion(Lux), " ", pkgversion(NeuralOperators)))
        println(io, seed(r.dataset))
        p = ComponentArray{Float64}(m.parameters)
        println(io, length(p))
        for v in p
            println(io, repr(v))
        end
    end
    path
end

function load_model(path, d)
    rows = readlines(path)
    length(rows) >= 5 || error("incomplete checkpoint")
    rows[1] == CHECKPOINT_VERSION || error("checkpoint architecture version mismatch")
    rows[2] == string(d.kind) || error("checkpoint dataset kind mismatch")
    rows[3] == string(pkgversion(Lux), " ", pkgversion(NeuralOperators)) || error("checkpoint package version mismatch")
    parse(Int, rows[4]) == seed(d) || error("checkpoint seed mismatch")
    m = make_model(d)
    p = ComponentArray{Float64}(m.parameters)
    n = parse(Int, rows[5])
    n == length(p) && length(rows) == n + 5 || error("checkpoint parameter count mismatch")
    vals = parse.(Float64, rows[6:end])
    all(isfinite, vals) || error("nonfinite checkpoint parameters")
    p .= vals
    A.ScientificModel(m.architecture, m.network, p, m.state, m.schema,
        m.normalization, merge(m.provenance, (checkpoint=abspath(path), optimizer_state=:not_saved)))
end

function physics_evidence(r)
    # Off-grid Cartesian points: independent of training/evaluation targets.
    # Later-time cases get their own out-of-domain residual points.
    map(r.dataset.samples) do s
        ts = s.split == :coordinate_extrapolation ? [0.673, 0.743, 0.823] : [0.037, 0.183, 0.417]
        q = HeatFamily.grid([0.113, 0.337, 0.619, 0.887], ts)
        pts = A.PINNPoints(q; generation=:independent_grid,
            provenance=(purpose=:post_training_residual, used_in_training=false, split=s.split))
        alpha = r.dataset.kind == :surrogate ? only(s.input) : r.dataset.provenance.alpha
        coefficients = r.dataset.kind == :surrogate ? [1.] : s.descriptor
        predicted = p -> only(A.predict(r, s.input, reshape(p, 2, 1)))
        reference = p -> HeatFamily.heat_solution(coefficients, alpha, p)
        (id=s.id, split=s.split,
            model=A.heat_residual(predicted, pts; alpha),
            reference=A.heat_residual(reference, pts; alpha))
    end
end

function timing_evidence(r)
    # Exactly the same held-out case/grid/output vector for both complete calls.
    # Sensor preparation is excluded from both; coefficients already known to reference.
    s = first(filter(s -> s.split == :interpolation, r.dataset.samples))
    alpha = r.dataset.kind == :surrogate ? only(s.input) : r.dataset.provenance.alpha
    coefficients = r.dataset.kind == :surrogate ? [1.] : s.descriptor
    reference = () -> [HeatFamily.heat_solution(coefficients, alpha, q) for q in eachcol(s.coordinates)]
    inference = () -> A.predict(r, s.input, s.coordinates)
    A.benchmark_queries(reference, inference; training_seconds=r.timing.optimization_seconds,
        repetitions=11, context=(case_id=s.id, split=s.split, query_count=length(s.values),
            reference_kind=:analytical_closed_form, same_coordinates=true, output=:allocated_scalar_vector,
            inference_scope=:normalization_network_denormalization, reference_scope=:finite_sine_series,
            sensor_preparation=:excluded_from_both, pde_numerical_solver=:none,
            training_scope=:optimization_only_compilation_may_be_included))
end

function write_report(path, r, a)
    open(path, "w") do io
        println(io, "# M9D ", r.dataset.kind, " — sampled heat-family evidence\n")
        println(io, "Reference: ", repr(a.reference), "\n")
        println(io, "Fixed CPU Float64 training: ", repr(r.provenance), "\n")
        println(io, "Architecture and package provenance: ", repr(r.model.provenance), "\n")
        println(io, "Objective (scaled training MSE, not reference error or PDE residual): ", repr(r.objective), "\n")
        println(io, "| Split | Functions/parameters | Sampled relative L2 | Sampled RMS error |\n|---|---:|---:|---:|")
        for split in SPLITS
            haskey(a.groups, split) || continue
            g = a.groups[split]
            println(io, "| ", split, " | ", g.sample_count, " | ", g.errors.relative_sampled_l2, " | ", g.errors.summary.rms, " |")
        end
        println(io, "\n## Per-case reference errors (physical dimensionless u; unweighted query samples)")
        for c in a.cases
            println(io, "- ", c.id, " / ", c.split, ": relative sampled L2=", c.errors.relative_sampled_l2,
                ", RMS=", c.errors.summary.rms, "; classification=", repr(c.classification))
        end
        println(io, "\n## Independent ForwardDiff residual: u_t - alpha*u_xx")
        println(io, "12 off-grid points per case; no reference values in model residual; no residual threshold claimed.")
        for e in a.physics
            println(io, "- ", e.id, " / ", e.split, ": model sampled residual RMS=", e.model.summary.rms,
                "; analytical-reference residual RMS=", e.reference.summary.rms,
                "; points=", repr(e.model.points.coordinates))
        end
        println(io, "\n## Descriptive analytical-reference vs inference timing\n", repr(a.timing))
        println(io, "\nThis is closed-form Fourier evaluation, NOT a numerical PDE solver benchmark. No ranking or speedup claim.")
        println(io, "Training != interpolation != parameter/function/coordinate extrapolation. All shifts are retained, not ranked.")
        println(io, "Sampled norms are not continuum norms. Reference error and differential residual are separate evidence.")
        println(io, "No discretization invariance, global accuracy, uncertainty calibration, or stability established.")
        println(io, "Checkpoint contains numeric parameters only; native optimizer/state history not serialized. Reuse requires unchanged heat_family.jl and compatible packages.")
    end
    path
end

function save_figures(prefix, r, a)
    paths = String[]
    splits = [s for s in SPLITS if haskey(a.groups, s)]
    labels = replace.(string.(splits), "_" => "\n")
    f = Figure(size=(1100, 650))
    ax = Axis(f[1, 1]; title="$(r.dataset.kind): reference error by explicit split (not ranking)",
        ylabel="Unweighted sampled relative L2 vs analytical Fourier truth",
        xticks=(collect(eachindex(splits)), labels), xticklabelsize=12)
    scatter!(ax, collect(eachindex(splits)), [a.groups[s].errors.relative_sampled_l2 for s in splits]; markersize=14)
    Label(f[2, 1], "Training targets and held-out splits are distinct. Finite samples only; no continuum/generalization guarantee.")
    push!(paths, prefix * "_reference_errors.png"); save(last(paths), f)

    f = Figure(size=(1100, 650))
    ax = Axis(f[1, 1]; title="Independent ForwardDiff heat residual — separate from reference error",
        xlabel="Case index (dataset order, not spatial coordinate)", ylabel="Sampled RMS of u_t - alpha*u_xx")
    for split in splits
        ix = findall(e -> e.split == split, a.physics)
        scatter!(ax, ix, [a.physics[i].model.summary.rms for i in ix]; label=string(split))
    end
    Legend(f[1, 2], ax)
    Label(f[2, 1:2], "12 independent off-grid points per case; differentiated learned field; no global PDE correctness claim.")
    push!(paths, prefix * "_physics_residual.png"); save(last(paths), f)

    # One held-out field: genuine x/t axes, separate colorbars and evidence panels.
    c = first(filter(c -> c.split == :interpolation, a.cases))
    xs, ts = unique(vec(c.coordinates[1, :])), unique(vec(c.coordinates[2, :]))
    f = Figure(size=(1400, 470))
    fields = (c.reference, c.prediction, c.errors.absolute)
    titles = ("Analytical Fourier reference", "Learned inference", "Absolute reference error |prediction - truth|")
    limits = extrema(vcat(c.reference, c.prediction))
    for j in 1:3
        panel = GridLayout(); f[1, j] = panel
        ax = Axis(panel[1, 1]; title=titles[j], xlabel="x (dimensionless)", ylabel="t (dimensionless)")
        z = reshape(fields[j], length(xs), length(ts))
        hm = j == 3 ? heatmap!(ax, xs, ts, z; colormap=:magma) : heatmap!(ax, xs, ts, z; colorrange=limits)
        Colorbar(panel[1, 2], hm; label=j == 3 ? "|error|" : "u")
    end
    Label(f[2, 1:3], "$(r.dataset.kind), interpolation case $(c.id); sampled grid only. PDE residual is shown separately.")
    push!(paths, prefix * "_interpolation_field.png"); save(last(paths), f)

    f = Figure(size=(1050, 530))
    ax = Axis(f[1, 1]; title="Descriptive local timing: identical allocated query-vector scope",
        xlabel="Alternating warmed repetition", ylabel="Elapsed seconds (not a speedup score)")
    scatter!(ax, 1:11, a.timing.reference_seconds; label="Analytical finite Fourier evaluation")
    scatter!(ax, 1:11, a.timing.inference_seconds; label="Inference including affine scaling")
    Legend(f[1, 2], ax)
    Label(f[2, 1:2], "Optimization-only cost: $(a.timing.training_seconds) s (may include compilation).\nNot a numerical PDE solver comparison; hardware-local observations only.")
    push!(paths, prefix * "_timing.png"); save(last(paths), f)
    paths
end

"""Train each route once, sequentially. Return native results and separate evidence.

`maxiters` is a bounded training budget, not an accuracy promise. The optional
integration gate owns the fixed interpolation assertion. Extrapolation has no
pass/fail accuracy threshold. Output overwrites only this example's generated files.
"""
function run_showcase(; output=OUTPUT, maxiters=3000, plots=true,
        datasets=(HeatFamily.parametric_dataset(), HeatFamily.operator_dataset()))
    1 <= maxiters <= 10000 || throw(ArgumentError("showcase budget must be in 1:10000"))
    mkpath(output)
    runs = NamedTuple[]
    for d in datasets
        m = make_model(d)
        r = A.train(m, d; initial_parameters=ComponentArray{Float64}(m.parameters),
            optimizer=OptimizationOptimisers.Adam(0.005), adtype=ADTypes.AutoZygote(), maxiters,
            history_limit=100)
        physics = physics_evidence(r)
        timing = timing_evidence(r)
        a = A.analyze(r; physics, timing)
        prefix = joinpath(output, string(d.kind))
        checkpoint = save_model(prefix * "_parameters.txt", r)
        report = write_report(prefix * "_report.md", r, a)
        figures = plots ? save_figures(prefix, r, a) : String[]
        println(d.kind, ": training scaled MSE=", r.objective.final,
            "; interpolation sampled relative L2=", a.groups[:interpolation].errors.relative_sampled_l2,
            "; report=", report)
        push!(runs, (result=r, analysis=a, checkpoint=checkpoint, report=report, figures=figures))
    end
    runs
end
end
