# M8C — evidence-aware comparison of stored trajectory analyses

M8A provides atomistic inspection; M8B computes trajectory statistics. M8C compares
**already-computed** M8B results. It does not run dynamics, reconstruct observations,
evaluate forces, compute missing analyses, select windows, or certify a simulation.
Molly is not needed to compare generic results originally obtained from its loggers.

## Stored inputs and provenance

```julia
using AnalyticMathLab, Unitful
sA = ObservableSeries([1.,2.,3.]u"J"; name=:total_energy)
sB = ObservableSeries([2.,3.,4.]u"J"; name=:total_energy)
rA, rB = statistical_summary(sA), statistical_summary(sB) # M8B first
A = ComparisonInput(rA; series=sA, label="A")
B = ComparisonInput(rB; series=sB, label="B")
c = compare(A, B)                                        # M8C only
c.compatibility.status # :compatible
c.difference.value     # 1 J, always B - A
c.uncertainty.status   # :unknown, NOT sample std combined as SE
```

M8B `PropertyResult` summaries and standalone autocorrelations do not store their
observable names. `ComparisonInput(result; series=nothing, parent=nothing,
label=nothing, selection=nothing)` binds existing metadata without reading series
observations. An IAT needs its stored autocorrelation as `parent`; a diffusion fit
needs its stored MSD. The caller asserts these associations; metadata consistency
checks detect conflicting clocks, sample counts and retained names, but cannot
prove original computational lineage. An absent association stays unknown.

Inputs are retained by reference, including labels, original evidence, provenance,
sampling/window metadata, counts, block tails, and original estimator parameters.
No trajectory history is copied. Treat source arrays and comparison arrays as
read-only. Mutating borrowed backing data after analysis invalidates its contract.

`ObservableComparison <: AbstractAnalysis` stores `a`, `b`, `quantity`,
`compatibility`, `metadata`, `difference`, `uncertainty`, `assumptions`, and `notes`.
`metadata.a` / `.b` expose the selected values, grids, estimator definitions,
sampling, dimensional semantics, original evidence and uncertainty estimators.
`metadata.conversion` records source and reference units; physical subtraction
converts B to A's units. Original quantities remain unchanged.

## Compatibility before arithmetic

`ComparisonCompatibility <: AbstractAnalysis` has `status`, named `checks`, and
`reasons`. Checks use the existing `PropertyResult` contract:

- `true`, established: this particular metadata check passed;
- `false`, established: an explicit contradiction;
- `nothing`, unknown: not enough information.

An explicit contradiction gives `:incompatible`; otherwise any unresolved check
gives `:unknown`; only all passed checks give `:compatible`. Compatibility is not
physical correctness. Numerical differences remain heuristic and unavailable
values are `nothing`, never a manufactured zero, false, NaN or empty curve.

Observable names must match (the placeholder `:observable` is unknown). Names come
from `ObservableSeries`, not report dictionary keys. Stored component, temperature,
DOF, Boltzmann, selection and normalization conventions are checked when present.
Unknown conventions are not reconstructed from a backend or current system.

Compatible Unitful dimensions support conversion (e.g. J and kJ); energy and length
are incompatible, including the underlying covariance of normalized correlations.
Unitless physical scales are unknown by default. `unitless=true` explicitly asserts
a common numeric/reduced-unit meaning; it does not strip quantities or infer a
conversion between plain numbers and dimensional data. Counts and normalized
correlations have explicitly dimensionless meaning. No relative percentages are
produced, including at zero reference values.

## Time, sampling and estimator rules

Explicit index time stays index time. Explicit times/intervals with Unitful time
units can be compared after conversion. Unitless explicit clocks need the separate
`unitless_time=true` assertion of a shared clock scale. Absent clocks remain unknown;
logger stride and frame count never manufacture timestamps or a simulation dt.
Index versus explicit time is incompatible for time-sensitive comparisons, even
with either unitless assertion. `quantity=:physical_tau` is unavailable for index
time, despite M8B retaining a numeric interval product in its `physical_tau` field.

Scalar descriptive means, variances, standard deviations and extrema do not require
identical sample counts, intervals or observation windows. Their source windows
remain in the retained sampling metadata. They compare descriptions, not identical
thermodynamic states or equilibrium ensembles.

Pointwise comparisons require matching grids, with exact equality after compatible
unit conversion. No interpolation, resampling, nearest-neighbor alignment, smoothing,
truncation, normalization, transient removal or rebinning occurs. Shapes are checked
before subtraction; no `zip`-truncation can silently discard mismatched curve data.

Supported quantities (`quantity=:auto` selects the bold default):

| Stored result | Quantities | Additional compatibility |
| --- | --- | --- |
| `statistical_summary` | count, **mean**, variance, std, minimum, maximum | Welford / n−1 definitions; std is fluctuation, not SE |
| `correlated_mean` | **mean**, std, count, standard_error, tau_int, effective_samples | Correlation definitions/windows/interval for diagnostic quantities; central mean alone does not require matching uncertainty windows |
| `AutocorrelationAnalysis` | **autocorrelation**, autocovariance | method, denominator normalization, full lag range, grid, saved interval |
| stored IAT | **tau**, raw_tau, physical_tau | parent correlation, explicit versus automatic window method, window, computed lag range, saved interval |
| `BlockAnalysis` | **standard_errors**, variances, block_counts, discarded | identical block-size definitions and saved interval; all tails/counts/means retained; no plateau selection |
| `MeanSquaredDisplacement` | **msd** | dimensions, population count, species, coordinate semantics, origin count/method, time grid |
| stored diffusion fit | **diffusion**, slope, intercept, rms_residual | parent MSD semantics, explicit fit window and selected endpoint interval, spatial dimension, clock scale |
| `VelocityAutocorrelation` | **raw**, normalized | dimensions, population/species, overlapping-origin method, lag range/grid and interval |
| energy/momentum diagnostic | **maximum_absolute**, maximum_relative, rms, linear_slope | initial-reference definition, scalar versus vector dimensionality; trend also requires compatible clocks |
| transient diagnostic | **mean_shift**, pooled_fluctuation, suggested_start, suggested_time | threshold, early/late sample-window definition, saved interval and clock scale |

Use `quantity=(:normalized,:raw)` to explicitly compare differently selected VACF
representations: the result is incompatible. The existence of a stored normalized
VACF does not remove its raw representation; `:auto` consistently selects raw.
Different IAT windows or diffusion windows are not silently treated as the same
estimator. Unsupported selectors on known available result types throw an argument
error. Unsupported/unavailable stored results remain structured unknowns.

Transport comparisons require explicit equal `selection` tokens in both inputs.
These assert corresponding particle populations, not independence; equal particle
counts or species names alone cannot prove correspondence. M8B fixed ordering is an
intra-run assertion, not a cross-run identity. Wrapped/auto/unwrapped semantics are
not merged, and single-origin MSD is never relabeled as multiple-origin MSD.

## Uncertainty is separate from central differences

`independence=:unknown` is the default. A central difference can be available while
its combined uncertainty remains unknown. Filenames, labels, seeds, trajectories,
N_eff and apparent block plateaus do not establish independent estimators.

With `independence=:independent`, M8C can propagate available stored correlated-mean
SEs as `sqrt(SE_A^2 + SE_B^2)`. The result is still heuristic and conditional on
M8B's stationarity and adequate-window assumptions. This initial conservative
implementation additionally requires matching uncertainty estimator definitions,
windows and saved intervals; differing definitions leave uncertainty unavailable
without hiding the central difference. The identical stored result cannot be
asserted independent of itself. No covariance-supplied propagation is implemented.

There are no p-values, hypothesis tests, confidence intervals, significance labels,
run rankings or quality verdicts. A larger effective sample count is not universal
simulation quality; a positive fitted diffusion is not proof of a diffusive regime;
a smaller transient suggestion is not proof of faster equilibration. No detected
shift does not establish equilibrium.

Energy diagnostics retain the corrected M8B NVE semantics untouched: only total
energy with NVE may carry a conservation expectation. Kinetic/potential NVE energy
do not inherit it. `conservation_expected=false` means no expectation was assigned,
not proof of nonconservation. Numerical closeness of momentum does not establish
conservation in the presence of forces, thermostats or boundaries.

## Two-report composition and static presentation

```julia
comparison = compare_runs(reportA, reportB;
    components=(:summaries, :correlations, :vacf), labels=("A", "B"))
comparison.components[:summaries][:total_energy]
diagnose(comparison) # structured component evidence, no grade
```

`compare(::MDTrajectoryAnalysis, ::MDTrajectoryAnalysis)` aliases `compare_runs`.
`MDTrajectoryComparison <: AbstractAnalysis` retains both reports, labels, selected
components, assumptions and notes. The named-map components are `:summaries`,
`:correlations` (stored correlated means), `:deviations`, and `:transients`; the
transport components are `:msd`, `:vacf`, `:diffusion`. Defaults request all these
stored groups. Map keys are their union, so one-sided absence is explicit. Empty
maps mean neither report supplied an entry, not zero differences. Pass
`selections=(population_token_A,population_token_B)` for transport. For specialized
quantities or standalone blocks/IAT, use `ComparisonInput` directly.

`comparisonplot(::ObservableComparison)` overlays compatible stored curves or
shows scalar A/B points. `differenceplot` shows B−A and, for scalars, a ±1 SE bar
only when M8C actually propagated it. Refused comparisons produce a labeled
incompatibility/unknown figure. Plots do not recompute estimates, activate backends,
open windows or save files. Load CairoMakie explicitly in application code.

Run the small synthetic, non-simulation example:

```sh
julia +release --project=. notebooks/trajectory_comparison.jl
```

It constructs M8B reports first, then demonstrates mean and conditional uncertainty
comparison, an observable mismatch, compatible curves and refused alignment. It
saves four static figures under ignored `notebooks/output/m8c_*.png`.

## Scope and remaining limitations

Two-run comparisons only. No experiment database or ensemble manager. Work is
linear in the compared stored curves/metadata; scalar summaries do not read original
observations. Time metadata consistency checks can traverse the stored clock array,
never particle frames. Curves allocate differences, not a second trajectory store.
Missing historical provenance cannot be recovered. Different valid estimator
windows currently require separate inspection rather than an override claiming
equivalence; block comparisons with unknown/irregular intervals remain unresolved.
Constant-series autocovariance also remains conservatively unavailable for comparison
because M8B's shared autocorrelation evidence describes undefined normalized correlation,
even though it retains zero covariance. M8C does not upgrade that input evidence.

M8D remains future interactive atomistic visualization/animation: no dashboard,
temporal controller, particle renderer, synchronized explorer or camera controls.
[M9A Scientific ML](scientific_ml.md) now provides a separate optional PINN bridge,
superseding the older stochastic M9 placeholder. No stochastic rounding, Monte Carlo
estimator, MCMC, Brownian or Langevin simulation is added here.
