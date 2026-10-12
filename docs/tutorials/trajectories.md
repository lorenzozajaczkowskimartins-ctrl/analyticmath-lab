# Trajectories and statistics: what a stored mean means

[Learning path](index.md) · Previous: [ODEs](odes.md) · Next: [atomistics](atomistics.md)

Prerequisites: the ODE lesson, finite-sample means and variance. Difficulty: intermediate.
Direct dependency: AnalyticMathLab. The script includes the linked ODE script from
the checkout root; it does not use hidden state or simulate a second model.
Executable: [trajectories.jl](scripts/trajectories.jl). From the repository root:

```sh
julia +1.12.7 --project=. docs/tutorials/scripts/trajectories.jl
```

## Problem and workflow

A trajectory stores ordered states and times, but a statistic needs a selected
quantity. Follow the scientific chain:

    Trajectory → observable → stored series → descriptive summary → interpretation

Reuse $u(t)=(q,v)$ from [the oscillator lesson](odes.md), with analytical
$q=\cos t$. Select only coordinate `:q`, not both components flattened together.
`observable_series` copies actual saved times and selected values in their original
order. It neither evaluates the interpolant nor invents a regular output grid.
A callback `observable(u,t)` is another supported selector, but no callback is
needed for this component.

For $N$ stored values $x_j$, define

$$\bar x=\frac1N\sum_j x_j,\qquad
s^2=\frac1{N-1}\sum_j(x_j-\bar x)^2.$$

This is an unweighted sample mean, not $\frac1T\int_0^Tq(t)\,dt$.
Even the exact continuous-time mean $\sin(2)/2$ over this interval is a different
quantity. The adaptive saved grid is generally not uniform; points with higher
storage density receive more weight in this unweighted summary.

A second fixture, `[1,2,3,4,5]` at times `[0,1,2,3,4]`, gives an independent
hand-computable check: mean 3, centered squared deviations summing to 10,
sample variance $10/4=2.5$. Its prefix means are $1,1.5,2,2.5,3$.
This is a calibration dataset, not independent random experiments.

## Implementation

`statistical_summary` and `running_statistics` return `PropertyResult` values.
The former stores count, mean, sample variance, standard deviation and extrema;
the latter stores cumulative counts/means/variances. A first observation has no
sample variance. Both use Welford updates, avoiding explicit stored deviations.

```julia
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
```

## Verification and observed results

ANALYTICAL_REFERENCE: compare the numerical mean with
$N^{-1}\sum_j\cos(t_j)$ at the same actual saved times, not a differently weighted
continuous-time mean. NUMERICAL_COMPARISON: the discrepancy was
$5.58331\times10^{-13}$, checked at $10^{-8}$.
EXAMPLE_EXECUTED: 84 values, sample mean `0.4356053310345854` and analytical
saved-sample mean `0.4356053310351437`. Stored-time alignment and exact component
selection were checked. The five-value fixture returned count 5, mean 3.0,
variance 2.5, and standard deviation `1.5811388300841898`; moments/prefix means
were checked at $10^{-12}$. The standard error remained `nothing`.

## Descriptive statistics are not uncertainty estimates

Standard deviation describes fluctuations of the selected observations; it is
not uncertainty in their mean. Time samples of deterministic or correlated motion
are not IID replicates. We therefore report no standard error, confidence interval
or effective sample size. Running means becoming visually flat would not prove
stationarity, equilibration or ergodicity.

SOURCE_INSPECTED: numeric unitless observations retain unknown physical units.
The explicit context says this particular model is dimensionless; it does not
perform a conversion or overwrite the generic numerical unit descriptor. Labels
identify coordinates, not units. Missing, nonfinite or unavailable results must
not be interpreted as zero. Summaries are descriptive and retain heuristic status
even when small fixture arithmetic agrees exactly.

For physically justified stationary data, correlation-window and blocking
assumptions require separate analysis. The existing
[statistics/transport guide](../trajectory_statistics.md) explains these APIs.
In particular, accepted index-time MSD fitting does not establish a physical
diffusion coefficient: a real time scale and a justified diffusive fit window
are separate scientific obligations. No diffusion calculation is run here.

Continue to [particle geometry](atomistics.md) or
[the integrated investigation](one-system-many-methods.md).
[Execution record](../../reports/m10d6/tutorial_implementation_report.md).
