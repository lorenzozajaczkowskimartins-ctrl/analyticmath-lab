# M10B numeric contracts and narrowing inventory

Baseline: `d8ca9146f0ddb54f00ba0368a0d8670868ff58c9`. This initial inventory was
written before M10B production-source edits. Outcomes below describe inspected
contracts, not a claim that all combinations have already passed. Final executed
matrix and evidence will be appended after focused gates.

Contract categories: A type-preserving, B deliberate promotion, C backend-limited,
D exact-algebra subset, E real-only, F complex-capable, G approximate floating,
H unsupported. Supported means a tested subset, not every accepted Julia Number.
BigFloat is arbitrary precision, not exact arithmetic. Caller input rounding is
not recoverable by AML. Unitful support is confined to existing physical paths.

| Subsystem / public path | Categories | Intended numeric behavior | Nonfinite/domain policy / initial risk |
|---|---|---|---|
| M1 scalar evaluate / derivative callables | A,B,D,F | Julia arithmetic on stored callable; polynomial rational/complex meaningful; mixed symbolic constants can promote | Underlying numeric propagation/NaNMath documented; not a domain enforcement API |
| M2 compare_derivatives | A,B,E,G | float(x), ForwardDiff and FiniteDiff's type-dependent central step | Finite real point/output required; unsupported complex not a real derivative experiment |
| M2 derivative_convergence | C,E,G | Explicitly stored Float64 experiment, not arbitrary precision | Conversion must not erase a nonzero or higher-precision input silently |
| M3 real domains / exact study | D,E | Exact supported algebra; bounded fallback is Float64 | Exclusions apply to original syntax; real-domain predicates must not claim complex support |
| M4/5 evaluate, gradient, Hessian, Jacobian, directional derivative | A,B,D,E | Generic checked real evaluation; exact algebra where operations permit | Known original-domain membership; finite real outputs |
| M4/5 stationary/root search and Hessian classification | C,E,G | Float64 Roots/Newton/LAPACK evidence | Narrowing at numeric-search boundary is intentional, not a BigFloat solver; conversion risks require explicit refusal |
| M6 trajectory | C,E,G | Existing Float64 states/times/RHS and Tsit5 wrapper; Float32/integers promote | Reject nonfinite and collapsed time spans; tiny BigFloat RHS/state and converted dt currently high risk |
| M7 symbolic mechanics, linearization, Cartesian mass matrix | A,B,D,E | Preserve supplied exact/symbolic coefficients; parameter-binding algebra | Regularity/positive mass/original domain assumptions remain explicit |
| M7 normal_modes / stability | C,E,G | Float64 symmetric/general eigensolve, declared metadata and numerical thresholds | Singular/indefinite/unresolved mass -> unknown; no claim of arbitrary-precision LAPACK |
| M8A geometry/mdcheck | A,B,E | Generic physical arithmetic and existing Unitful quantities | Invalid physical data -> unknown; naive squared distances/energy intermediates need scale audit |
| M8A LJ | A,B,E,G | Generic potential callables; displayed minimum certificate uses Float64 | r>0, finite positive epsilon/sigma; near-singular overflow must not become plausible evidence |
| M8A RDF | C,E,G | Current expected counts explicitly Float64 | Must document accumulation boundary and refuse unrepresentable normalization; no global equilibrium claim |
| M8B moments/running statistics | A,B,E,G | Welford; float(real(x)) deliberately approximates integer/rational data, preserves float precision | Missing/nonfinite/empty -> unknown; singleton variance unavailable; extremes/cancellation audit |
| M8B correlations/IAT/ESS/blocking | A,B,E,G | Generic scalar statistics with explicit finite-window assumptions | Zero variance/insufficient support -> unknown; no fabricated DOF |
| M8B transport/deviation metrics | A,B,E,G | Existing physical units and saved-time semantics | Squared-norm intermediates and tiny normalization require checking |
| M8C differences/uncertainty | A,B,E,G | Numeric types/units inherited; B-A and explicitly independent SEM | Compatibility fail-closed; sqrt(seA²+seB²) is a likely avoidable overflow |
| M9A/B PINNPoints | C,E | Declared Float64 coordinates for NeuralPDE diagnostic blocks | Current conversion detects overflow but not underflow/precision loss |
| M9B sampled_summary | A,B,E,G | AML-owned metrics need no Float64 backend; should retain float type/range | Current unconditional Float64 narrowing is scientifically unnecessary |
| M9C ObservationSet / InferenceParameters / native problem | C,E,G | Declared Float64 data and forward solves; ForwardDiff duals in objective path | Constructors must reject unsafe conversion; dynamic theta unsupported precision must fail early |
| M9C local_sensitivity | C,E,G | Float64-oriented Jacobian/SVD; rank_atol+rank_rtol*smax | Inf for rank-deficient/zero map; finite threshold/weights required |
| M9C HNN/UDE data/model wrappers | C,E,G | Current real native Lux/ForwardDiff route, backend-limited | Tiny deterministic nonfinite-output gates, no arbitrary-precision training claim |
| M9D ScientificSample/Dataset | C,E | Current concrete Float64 storage supports CPU learning contract | Unsafe high-precision conversion must reject before silently changing data |
| M9D AffineScaling / transform | C,E,G | Stored Float64 metadata, generic arithmetic after validated scaling | Positive finite scales; constant feature convention scale=1; zero/negative metadata must reject |
| M9D field_errors / heat_residual | A,B,E,G | AML-side differences and coordinate AD may preserve float type | Nonfinite outputs rejected; relative error unavailable at tiny/zero reference |
| M9 optional Lux/Optimization/NeuralPDE/NeuralOperators | C,E,G | AML currently configures CPU Float64 models; generic upstream capability is not AML support | Existing stateless/shape contracts and finite output must hold without training |
| M9 heat checkpoints | C,G | Explicit plain Float64 numeric parameters with fixed compatible family | Not a generic serializer; no optimizer/history recovery claim |
| Makie views | C,G | Rendering conversions may use Float64 | Conversion for plotting is not a scientific result-type promise |

## Significant conversion families (source/extension/example search)

* `src/scientific_ml/diagnostics.jl`: sampled_summary Float64 conversion is an
  accidental diagnostic narrowing candidate; PINNPoints storage is intentional
  but its representability guard is incomplete.
* `src/scientific_ml/{inference,parameter_inference,trajectory_inference,surrogates}.jl`:
  concrete data, times, bounds and parameters are intentional backend boundaries;
  overflow/underflow, nonfinite bounds and precision-loss checks need regression.
* `src/{numerical,convergence,multivariate_analysis,real_analysis}.jl`,
  `src/vector_fields/zeros.jl`, `src/dynamical_systems/{integration,stability}.jl`:
  numerical searches/ODEs/classifications are deliberate Float64 algorithms.
  Generic evaluation must remain separate. A finite conversion alone is not
  sufficient evidence of representability.
* `src/mechanics/normal_modes.jl`: Float64 LAPACK and eps(Float64) are deliberate;
  singularity and degeneracy thresholds describe that arithmetic, not input type.
* `src/atomistic/potentials.jl`: minimum radius/curvature Float64 display is
  deliberate; algebraic potential and numerical derivative evaluation are separate.
* `src/atomistic/distributions.jl`: RDF expected-count conversion is an explicit
  numerical accumulation boundary requiring honest documentation and guards.
* `src/trajectory`: float(real(x)) is deliberate for approximate statistics;
  Complex values with nonzero imaginary parts are not real physical observations.
  Small nonzero terms lost by unstable formulas are a different issue from promotion.
* `ext/*`: Float64 optimizer histories and configured Float64 native arrays are
  backend/recording choices. Predictions and loss diagnostics still require
  nonfinite checks. Integer iteration/count conversions are administrative.
* `src/visualization/*`: rendering-only; do not retrofit arbitrary precision.
* `examples/operators/heat_showcase.jl`: fixed Float64 checkpoint encoding and
  parsing explicitly documented. Other example FD/oracle literals are test-only.
* `examples/validation/reference_checks.jl`: M10A finite Float64 audit gate, not a
  package-wide generic reference solver. Does not establish BigFloat validation.

## Tolerances and boundaries

Do not replace all constants mechanically. Search tolerances and metadata remain
Float64 when the algorithm is explicitly Float64. FiniteDiff default steps must
use the caller floating epsilon where that path is generic. Saved-time spacing's
1e-8 relative tolerance is a documented policy distinct from strict monotonicity.
FD, eigen classification, ODE controls, statistical normalization, and physical
reference floors are different quantities and must not share a universal tolerance.

No M10C large fixtures, sparse/matrix-free redesign, performance program, or M10D
API/result-type unification is included. Existing Float64 scientific behavior is
preserved except where a red numeric counterexample proves a defect.

## Executed-scope support matrix

This matrix supersedes the initial risk descriptions above. Entries apply only to
the named paths and tested subsets; no row promises universal Number support.
S = supported generic arithmetic; P = deliberate promotion/approximation;
B = backend-limited; R = rejected/unavailable; M = mathematically meaningless for
the real-valued contract. Ordinary floating rounding is not exact arithmetic.

| Path | Float32 | Float64 | BigFloat | Rational | Complex | Unitful | NaN/Inf |
|---|---|---|---|---|---|---|---|
| Scalar polynomial values/derivatives | S; literals may P | S | S, 128/256 | S exact tested polynomials | S algebraic polynomials | not audited | underlying IEEE propagation |
| Derivative comparison | S type-specific FD | S | S, 128/256 | P via float | M/R (real derivative experiment) | not audited | R |
| Real multivariate values/derivatives | S/P constants | S | S | S exact polynomial subset | M/R | not audited | R DomainError |
| Convergence experiments, M6 trajectories | P to Float64 | B Float64 | B rounded, not arbitrary-precision solve | P | R | R, no implicit unit stripping | R |
| Cartesian mass matrices/exact mechanics | S | S | S | S exact coefficients | M/R positive real mass | snapshot bridge only | R |
| Normal modes | P to Float64 | B LAPACK | B rounded, no BigFloat eigensolve | P to Float64 | M/R (real symmetric model) | B explicit scales then LAPACK | unknown |
| Snapshot distances and observations | S | S | S | arithmetic-dependent, not broadly certified | M/R | S tested m/kg/s | unknown |
| Lennard–Jones | P possible exact coefficients | S | S generic evaluation; B Float64 minimum display | exact scale algebra, not general exact numerics | M/R radial domain | R on potential scales; units are metadata | R |
| Moments, ACF, IAT, ESS, blocking | S/P | S | S, 128/256 | P approximate statistics | nonzero imaginary R; not complex covariance | S tested energy/time units | unknown; no dropping |
| Stored comparisons/independent SEM | S/P | S | S tested differences | inherited, not exact inference | M/R physical scalar estimates | S compatible conversions | unknown |
| sampled_summary, field_errors | S | S | S beyond Float64 range | P via float for metrics | M/R real residual summaries | R, not a unit-stripping API | unavailable summary / rejected field input |
| PINNPoints, observations, inference parameters, scientific samples | P exactly to Float64 | B | B only losslessly representable values; otherwise R | B only exact Float64 values; otherwise R | R | R | R; explicit infinite parameter bounds allowed |
| Local sensitivity | P to Float64 before AD | B ForwardDiff/SVD | B exact Float64 parameters only | B exact Float64 parameters only | R | units metadata, not quantities | R; rank-deficient condition=Inf is intentional |
| AffineScaling storage / fit_scaling | P Float64 metadata | B storage | B exact Float64 metadata only | B exact Float64 metadata only | R | R | R |
| transform / inverse_transform | P with Float64 metadata | S | S arithmetic beyond Float64 range | P with stored metadata | R | R | R |
| Native optional neural stacks | configured Float64; no Float32-training claim | B tiny deterministic native models | not a generic-training claim | not an exact-learning claim | R/unsupported real models | metadata only | prediction rejects; residual evidence unknown; unavailable relative ratios |

The M6/M7 legacy approximation boundaries retain ordinary rounding with explicit
Float64 representation/metadata. M9 concrete-data boundaries are stricter: any
range or precision loss requires callers to explicitly round before construction.
This difference is intentional preservation of existing algorithms, not API
unification. Float32 rank tolerances retain their supplied value in
`rank_atol + rank_rtol*smax`; the Jacobian/SVD is Float64, not Float32 LAPACK.
Nonpositive mass is invalid physics; singular mass is unsupported by this mode
solver; neither is evidence for a stable mode. A numerically zero eigenvalue is
not a certified exact zero. Normal-mode underflow detection added here covers
pure diagonal-mass rescaling, not a general backward-error proof.

## Demonstration and oracle map

* `test/m10b_showcases.jl`: the same 2^-160 increment cancels at 128 bits and is
  retained at 256 bits; AML sampled RMS retains BigFloat 1e400; controlled
  polynomial cancellation loses accuracy in Float32 but remains finite; centered
  512-bit stored-input variance beats the naive squared-sum formula; small
  near-singular diagonal mass systems across Float32/64, BigFloat and Rational.
* `m10b_types.jl`: independent cubic stencil using FiniteDiff's cbrt(eps(T))
  step; exact polynomial and rational identities, integer and view inputs.
* `m10b_nonfinite.jl`: original real-domain edges and signed zeros versus
  floating overflow, final directional-dot guard, ODE conversion before solve.
* `m10b_linear_algebra.jl`, `m10b_atomistic.jl`: exact rational mechanics,
  mass-orthogonality/reconstruction, inclusive spectral thresholds, anchored
  degeneracy, Unitful scale bridge, extreme distances and LJ, stored-coordinate
  cancellation and fail-closed energy squaring.
* `m10b_statistics.jl`: 512-bit centered stored-input references, Float32/64 and
  BigFloat128/256, running variance, exact four-sample ACF/IAT/ESS expectations,
  time neighbors/duplicates and hypot uncertainty oracles.
* `m10b_diagnostics.jl`, `m10b_inference_scaling.jl`: generic metric types/range,
  adjacent/duplicate observations, real/nonfinite rejection, constant and
  near-constant scaling, huge offsets, held-out poisoning, and a small analytical
  observation Jacobian with near-dependent columns.
* Optional `examples/operators/m10b_gate.jl`: fixed native Lux outputs, explicit
  overflow/nonfinite controls and UDE sum overflow; no optimizer.
* Optional `examples/pinn/m10b_gate.jl`: genuine one-layer discretized NeuralPDE
  initial state, native signed residual sampling and prediction/reference
  metrics. The explicitly labeled untrained result fixture is not a fabricated
  optimizer result and no convergence claim is made.

No neural retraining, large-memory fixture, sparse/matrix-free work, broad API
redesign, push, tag, M10C or M10D is part of this audit. Gate results and classified
findings are recorded in `m10b_bug_ledger.md`.

## Final executed counts and scope

Final verification passed without changing production source, tests, or optional
gate implementations. The recovered 26 executable candidates matched
reconstructed pre-gate SHA-256 hashes; the separate 173-file executable/environment
snapshot remained unchanged through final verification. The complete evidence,
commands, recovery caveat and logs are in `m10b_bug_ledger.md`.

* Six base numeric audits: **1,035** passing assertions.
* Added inference/scaling: **48**; required demonstrations: **17**.
* All M10B base assertions: **1,100**, registered in the canonical runner.
* Affected M10A regressions: **1,402**, also included in canonical testing.
* Optional M10A HNN/UDE and DeepONet regressions: **91**.
* Optional M10B native neural and PINN numeric gates: **35**; no training.
* One fresh canonical `Pkg.test()`: **4,696** passes / **159** top-level testsets,
  exit zero and the package completion marker; zero failed, errored or broken tests.
* Canonical plus separate optional gates: **4,822** assertions. Focused results
  are not counted a second time. M10B-specific base plus optional: **1,135**.
* One bounded parent numeric review: no blockers; 28-file candidate scan: no
  findings; whitespace checks passed. No second review or canonical run.

The five numerical demonstrations retain their actual outcomes: the 2^-160
increment is lost at 128 bits and retained at 256; sampled RMS retains BigFloat
1e400; Float32 polynomial cancellation has more error than Float64; the stored-input
centered variance reference exposes the naive formula's zero; and near-singular
normal modes remain explicitly Float64/heuristic or unknown. None establishes
general arbitrary-precision backend support or exact floating statistics.

No post-canonical optional gate was invalidated by a source or environment change.
The existing manifest-resolution warning and optional precompilation notices are
reported, not hidden by dependency changes. All support and limitation rows above
remain scoped to the tested subsets. M10C and M10D remain deferred.
