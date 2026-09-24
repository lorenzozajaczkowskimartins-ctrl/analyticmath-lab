# M8B — trajectory statistics and statistical mechanics

M8A describes configurations. M8B describes selected trajectory observations and
finite-sample statistical evidence. Neither layer grades a simulation. M8A snapshot
and lazy trajectory contracts are unchanged. Molly remains optional.

## Explicit time and ownership

`sampling_info(trajectory)` returns `SamplingInfo`: count, borrowed times, interval,
regularity, units, provenance and evidence. No frame is fetched. Supply actual global
saved-frame times, or explicitly declare `interval=...` (a lazy range beginning at
zero), or `index_time=true`. Absent times remain unknown. Length mismatch, nonfinite,
nonincreasing or conflicting times throw. A singleton is insufficient for lag
analysis. Relative spacing tolerance is 1e-8, with zero absolute tolerance.

Spacing calculated from explicit times is the **saved/analyzed interval**, not the
simulation timestep. Storage stride remains provenance; it cannot supply dt by
itself. For thinned data create a lazy selected-frame view with matching selected
times and record selection/stride provenance. Irregular explicit times support
single-origin MSD and descriptive moments/trends, but not lag-index autocorrelation,
VACF or integrated autocorrelation time. There is no implicit interpolation.

`ObservableSeries(values; times, interval, index_time, name, provenance)` borrows an
AbstractVector, including a view or lazy `observable_series(trajectory, name)`.
Treat arrays and metadata as read-only during analysis: changing their lengths or
times invalidates the contract. Only `missing_policy=:reject` is supported; missing,
nonfinite or non-real observations cause unknown numerical results, never dropped
samples. Quantities retain compatible Unitful units; incompatible dimensions are
not silently stripped. Numeric unitless data have unknown physical units.

## Observable extraction and Molly 0.23.3

Generic lazy names: `:kinetic_energy`, `:potential_energy`, `:total_energy`,
`:temperature`, `:total_momentum`, `:center_of_mass_velocity`. Vector observables may
be retained for momentum diagnostics; use `component=1` etc. for scalar statistics.
M8A arithmetic is reused with pair enumeration disabled. No force or potential
engine is run to manufacture historical data. Missing potential energy stays missing.

`observable_series(logger; times=actual_times, provenance=...)` supports Molly
KineticEnergyLogger, PotentialEnergyLogger, TotalEnergyLogger and TemperatureLogger.
It borrows a captured-length view of `values(logger)`. Append operations do not
extend this view; mutations to existing observations remain visible. It validates
logger observable identity and records stride, not an invented clock. Matching
counts/strides cannot prove synchronization: the caller must use loggers from the
same simulation calls. `analyze(t; series=(total_energy=e,))` checks matching counts
and explicit times before composing these series.

Molly's `simulate!` wraps coordinates before and during VelocityVerlet, logs step
zero, and restarts local step numbering on every call. Coordinate/velocity loggers
copy arrays upstream. They do not store periodic image counters, global timestamps,
or historical boxes. M8A's `fixed_box=true` assertion is still required. No current
velocity/energy/force is inserted into historical frames.

TemperatureLogger records Molly's `2K/(sys.df*sys.k)` convention. In 0.23.3, DOF
construction excludes virtual sites, subtracts periodic-direction translation DOFs,
and subtracts constraint DOFs (its constraint model has its own assumptions).
That convention is not inferred from the chosen integrator's COM-removal schedule.
Historical DOF is not in the logger. AML preserves the recorded backend temperature;
it does not retrofit a different definition using current System metadata.
Generic temperature extraction requires BOTH explicit positive `dof` and
`boltzmann`, with compatible units: no blind d*N approximation. These assumptions
are recorded. Temperature series support the same summaries/correlation/blocking
as other scalar observations.

Molly 0.23.3's potential logger calls a backend energy method with a step argument
in the buffer position. The static-interaction examples/tests here are unaffected;
this adapter does not certify time-dependent potential logging. Verify upstream
logger semantics independently for time-dependent interactions.

## Descriptive moments versus uncertainty

`statistical_summary(series)` uses one-pass Welford updates: count, mean, sample
variance (n-1), standard deviation, min/max. Standard deviation is fluctuation,
NOT uncertainty in the mean. `standard_error=nothing` deliberately avoids IID
assumptions. A singleton has a mean but no sample variance. `running_statistics`
uses the same updates and returns cumulative means/variances (first variance absent).
Flattening is not proof of equilibrium.

`autocorrelation(series; maxlag=min(N-1,128), normalization=:biased)` subtracts the
full-series mean. With centered x, covariance at lag k is sum(x[i]*x[i+k])/N for
`:biased`, or divided by N-k for `:unbiased`. The latter name specifies a denominator,
not exact unbiasedness with an estimated mean. Results preserve lags, lag times,
pair counts N-k, covariance units, normalized rho=C(k)/C(0), method and evidence.
Constant data retain zero covariance but normalized correlation is unknown.

The implementation is bounded direct O(N*K), with default K<=128: linear in N
at fixed K, O(N+K) storage and only a scalar history. A requested full lag range
remains O(N²); this is not an FFT implementation. Existing dependencies were
inspected; no new FFT package is required for this bounded-lag scope. Direct
reference tests cover both normalizations and Unitful covariance. Long-range
correlation beyond the requested window remains unresolved, not assumed zero.

`integrated_autocorrelation_time(ac; window=...)` uses
`tau_int = 1/2 + sum(rho[1:window])` in saved-sample units. The physical-time quantity
is tau_int times the saved interval. An explicit window is recorded. Automatic
selection includes the initial consecutive positive lags, stopping BEFORE the
first nonpositive lag. If no such lag is encountered, it returns unknown instead
of silently truncating a positive tail. This is a simple heuristic, not a general
oscillatory-tail estimator. At least four samples are required.

For information estimates tau is conservatively clamped to at least 1/2; raw tau
and clamping are retained. `correlated_mean` reports mean, std,
`N_eff = N/(2*tau_int)` and `SE = std/sqrt(N_eff)`. N_eff never exceeds N; estimates
below one effective sample are unavailable. Missing/unreliable correlation NEVER
falls back to std/sqrt(N). Stationarity and an adequate window are assumptions,
not demonstrated facts. N_eff is an information diagnostic, not independent
experiments. These finite-sample results are heuristic even with explicit windows.

## Independent blocking and transient diagnostics

`block_average(series; block_sizes=[...])` returns `BlockAnalysis` with complete
nonoverlapping block means, counts, discarded tail counts, sample variance of
block means and sqrt(var(block means)/number of blocks). At least two complete
blocks are needed for each SE. Blocks are not assumed independent by fiat: inspect
the size dependence. No automatic plateau is selected. Irregular data can be
blocked by stored-sample count, not equal physical duration.

`transient_analysis(series; threshold=1)` compares early/late half means against
the pooled within-half standard deviation, NOT an IID standard error or a p-value.
Eight observations are required. A large shift suggests the midpoint as an analysis
start, with index/time/method/observable/threshold retained. This does not show that
the late half is stationary. No shift does not establish equilibrium. Nothing is
silently discarded; callers must explicitly select a new trajectory/series.

## Displacement and transport

`mean_squared_displacement(t; coordinates=:auto, fixed_particles=false, species=...)`
uses one origin, frame 1, and averages squared Cartesian displacement over selected
particles. It requires stable particle identity/order (caller or M8A provenance).
`:auto` admits open geometry only. Periodic or unknown image history is rejected.
`:unwrapped` is an explicit caller assertion about the actual supplied positions;
it does NOT unwrap wrapped data. `:wrapped` returns unknown. If authoritative
unwrapped data or image counters exist upstream, expose reconstructed positions
through a generic lazy frame view. Sparse minimum-image hops cannot recover an
arbitrary crossing history and are never used here. Origin coordinates alone are
copied; results store dimension, species, particles, one origin and semantics.
Multiple-time-origin MSD is deliberately not included.

`diffusion_estimate(msd; fit_window=(a,b))` fits MSD=intercept+slope*t on an explicit
inclusive interval, requiring at least three finite points and positive span.
D=slope/(2*d), with units preserved, and the selected interval, residuals and RMS
are recorded. Negative slopes are unavailable. No window means no fit. A positive
slope does not prove a diffusive regime; the caller must justify a long-time interval.
No independent-residual OLS error bar is reported for correlated MSD observations.
Index-time transport has per-index units, not physical diffusion units.

`velocity_autocorrelation(t; maxlag, normalize=false, species, fixed_particles)`
uses all overlapping origins per requested lag:
C(k)=sum(v_i(j) dot v_i(j+k))/(P*(N-k)). It does NOT subtract mean velocity. Optional
normalization divides by C(0); all-zero velocities leave normalization unknown.
Requires actual logged finite velocities, fixed ordering and regular known sampling.
It records particle/origin counts, dimensions, units through quantities and method.
VACF decay does not prove ergodicity. No Green–Kubo diffusion estimator is added.

## Energy, momentum and the Analyst

`energy_diagnostics(series)` records deviations from the first observation, max
absolute/relative deviation (relative absent if initial value is zero), RMS and
scalar linear trend when explicit times exist. Energy variation is not automatically
called drift. Ensemble metadata is preserved; conservation is expected only for a
series named `:total_energy` with explicitly declared NVE. Kinetic and potential
energy can exchange and are not individually assumed conserved. The existing
`conservation_expected=false` means no conservation expectation is assigned, not
proof of nonconservation; unavailable diagnostics remain unknown. Even when
conservation is expected, no tolerance-based failure grade is assigned.
`momentum_diagnostics` uses vector deviations and their norms; conservation is never
assumed because external forces, thermostats or boundaries may change momentum.

`analyze(t)` returns `MDTrajectoryAnalysis` and reads sampling metadata ONLY by default.
Choose `observables`, provide trustworthy `series`, request named `correlations`,
`transients=true`, `msd=true`, or `vacf=true` explicitly. `fit_window` is never invented.
`transport_options` goes to MSD; generic VACF requires fixed-particle provenance.
`diagnose(t; ...)` or `diagnose(report)` composes Sampling, statistics, correlations,
energy/momentum, transient and transport evidence. There is no score, universal
pass/fail, or 'equilibrium proven' output. Not-requested analyses are explicit.

## Presentation and executable example

`timeseriesplot`, `autocorrelationplot`, `blockplot`, `msdplot`, `vacfplot`, and
`energyplot(::MDTrajectoryAnalysis)` return Makie figures. They consume stored
results; they do not select windows, estimate transport or activate a backend.
`msdplot(m; fit=already_computed_fit)` distinguishes the observed curve and the
selected-window dashed fit. Unknown times/statistics are rejected, not invented.

Run from repository root:

```sh
julia --project=examples/molly -e 'include("test/molly_trajectory_statistics.jl")'
julia --project=examples/molly notebooks/molly_trajectory_analysis.jl
```

The notebook explicitly activates CairoMakie. A short deterministic shifted-LJ
trajectory demonstrates energy/temperature statistics, correlations, window
sensitivity, blocking and VACF. Its wrapped periodic coordinates correctly refuse
MSD/diffusion. A separate real Molly free-flight trajectory demonstrates valid
ballistic MSD, not diffusion. No fixture is manipulated to imply equilibration.

## Memory and scope

Summary: O(N) observations, O(1) accumulator storage; frame-derived values are lazy.
Running statistics: O(N) output. Correlation: O(N*K) work and O(N+K) scalar storage.
Blocking: O(N*B) work for B requested sizes; storage includes all returned block
means (default powers-of-two sizes have O(N) total block means).
MSD: O(N*P*d) work, O(P*d+N) storage, one copied origin.
VACF: O(N*K*P*d) work, O(N*P*d) velocity history only, no snapshot/coordinate copies.
High-level requested components may make separate passes over a borrowed series;
mutable/live backing data must remain fixed throughout an analysis.

No comparator, dashboard, stochastic arithmetic, Brownian/Langevin/Monte Carlo
solver, integrator, thermostat, neighbor engine or GPU MD implementation is added.
M8C starts only after separate authorization, by comparing compatible stored M8B
results with explicit sampling/units/evidence—not by rerunning dynamics implicitly.
