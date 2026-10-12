using AnalyticMathLab

# Root-relative include; authoritative model and implementation remain unchanged.
include(joinpath(pwd(), "examples/integration/one_system_many_methods.jl"))
r = OneSystemManyMethods.investigate()
@assert r.system.state_order == (:q1, :q2, :v1, :v2)
@assert r.system.phase_order == (:q1, :q2, :p1, :p2)
@assert r.path.solution.t == r.system.times
@assert r.metrics.saved_points == 321
@assert length(r.comparisons) == 12 && all(c.agreement for c in r.comparisons)
@assert r.metrics.trajectory_error <= 2e-8
@assert r.metrics.energy_oracle_error <= 2e-9
@assert only(r.dataset.samples).values == r.series.q1.values
@assert r.statistics.q1.value.standard_error === nothing
# These packages must not activate optional AML extensions in this base workflow.
extensions = (:AnalyticMathLabMollyExt, :AnalyticMathLabInferenceExt,
    :AnalyticMathLabDynamicsExt, :AnalyticMathLabSurrogateExt, :AnalyticMathLabPINNExt)
@assert all(e -> Base.get_extension(AnalyticMathLab, e) === nothing, extensions)
println((metrics=r.metrics, comparisons=length(r.comparisons),
    dataset_reference=r.schema.reference, optional_extensions=:not_loaded))
println("ONE_SYSTEM_MANY_METHODS_OK")
