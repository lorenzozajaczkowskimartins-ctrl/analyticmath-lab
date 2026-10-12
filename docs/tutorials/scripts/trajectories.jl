using AnalyticMathLab

# Run from the repository root. Reuse, rather than reimplement, the ODE model.
include(joinpath(pwd(), "docs/tutorials/scripts/odes.jl"))
path = HarmonicTutorial.path
qseries = observable_series(path; component=:q,
    context=(model=:unit_harmonic_oscillator, units=:dimensionless, scope=:stored_samples))
@assert qseries.sampling.times == path.solution.t
@assert qseries.values == [u[1] for u in path.solution.u]
summary = statistical_summary(qseries)
@assert summary.status == :heuristic
@assert summary.value.count == length(path.solution.t)
@assert summary.value.standard_error === nothing
reference_mean = sum(cos, path.solution.t)/length(path.solution.t)
mean_error = abs(summary.value.mean - reference_mean)
@assert mean_error <= 1e-8

# Separate hand-computable stored observations; not another simulation.
series = ObservableSeries([1.0, 2.0, 3.0, 4.0, 5.0];
    times=[0.0, 1.0, 2.0, 3.0, 4.0], name=:calibration)
small = statistical_summary(series)
running = running_statistics(series)
@assert small.value.count == 5
@assert abs(small.value.mean - 3.0) <= 1e-12
@assert abs(small.value.variance - 2.5) <= 1e-12
@assert small.value.standard_error === nothing
@assert collect(running.value.counts) == collect(1:5)
@assert maximum(abs, running.value.means - [1.0, 1.5, 2.0, 2.5, 3.0]) <= 1e-12
@assert first(running.value.variances) === nothing
@assert abs(last(running.value.variances) - 2.5) <= 1e-12
println((oscillator_count=summary.value.count, sample_mean=summary.value.mean,
    analytical_sample_mean=reference_mean, mean_discrepancy=mean_error,
    calibration=small.value, running_means=running.value.means))
println("TRAJECTORIES_OK")
