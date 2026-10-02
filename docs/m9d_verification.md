# M9D verification ledger

## Recovered checkpoint

Recovered from `037c3ba` plus tracked diff, untracked source/tests/examples,
scratch logs and actual process state. Nothing was reset, stashed or redesigned.
No Julia process survived into this recovery session.

- `ScientificSample` / `ScientificDataset` existed, with explicit parameter or
  fixed-sensor function representations, coordinates, split roles, analytical or
  numerical reference provenance, units, grids and seeds.
- Train, unseen interior interpolation, parameter extrapolation, amplitude shift,
  frequency shift and later-coordinate partitions already existed. Train-only
  affine scaling, exact duplicate protection and held-out objective exclusion
  were implemented and tested.
- The Lux coordinate surrogate and public NeuralOperators DeepONet adapter were
  present with native optimization objects, model prediction, full-batch training,
  bounded history and target-free model schemas.
- Analytical sine/Fourier heat families existed with pre-optimization IC/BC/PDE
  consistency checks, seven training diffusivities and 32 training functions.
- `GeneralizationAnalysis` existed and its export/include had been written at the
  interruption. The last analysis gate log was red because it predated that
  definition. The recovered gate passed without changing the implementation.
- ForwardDiff heat residuals already reused M9B `PINNPoints` / `sampled_summary`;
  domain classification and descriptive warmed timing/amortization existed.
- Backend research was complete. The public DeepONet gradient/Hessian/training
  and FNO forward-only probe passed. FNO is deferred, not a trained AML route.
- Root exports/includes and extension metadata existed and were coherent; base
  test-runner and architecture export/include ownership updates were missing.
- Full heat benchmark/showcase files, figures and user-facing M9D guide were
  missing. These were completed during recovery, without replacing core code.

## Existing evidence retained

- `m9d-focused-green.log`: 26 passing assertions (model surface 1, surrogate and
  objective leakage 15, genuine operator 10). Original training was not repeated.
- `m9d-backend-probe2.log`: 6 passing backend probe assertions; not trained FNO.
- `m9d-data-green.log`, `m9d-heat-green.log`, and `m9d-diagnostics-green.log`:
  historical successful contracts. Fresh base-focused execution also checks
  their current integration state; no research or data redesign was repeated.

Source hashes and original successful log timestamps were captured in the local
scratch `m9d-recovery-ledger.txt`. Original logs lacked source hashes, so recovered
results are not misrepresented as having historical hash attestations. The
adapter, focused gate and heat-family files predate their successful logs; new
recovery hashes identify the preserved source state.

## Executed gates

All Julia jobs ran sequentially, using Julia 1.12.7. No canonical suite was used
as an editing loop.

| Gate | Passing assertions | Evidence |
|---|---:|---|
| Base architecture, M9D contracts and relevant M9A/B/C base regressions | 270 | `m9d-base-focused.log` |
| Recovered GeneralizationAnalysis and AD prediction | 14 | `m9d-analysis-recovered.log` |
| Optional M9A/M9B backend regression suite | 224 | `m9d-m9ab-regression.log` |
| Optional M9C extension/result regression | 21 | `m9d-m9c-regression.log` |
| Heat interpolation/extrapolation, leakage, residual, timing, checkpoint and artifact gate | 255 | `m9d-heat-resumed.log` |
| Optional M9D registration/isolation/ambiguity gate | 11 | `m9d-isolation.log` |

The first full heat run completed surrogate training, checkpoint and report,
then failed in plotting because ComponentArrays and CairoMakie both exported
`Axis`. A narrow ComponentArray import fixed this without touching training.
The saved surrogate was reused (initial/final objectives recomputed and checked
against its original report), and the operator trained once. Native optimizer
objects/history absent from numeric checkpoints were left unavailable, not
fabricated. The 255-assertion gate passed. A later figure-only correction moved
legends outside axes so they could not obscure the largest residuals. Both
checkpoints then passed the same gate without optimization
(`m9d-figure-recovery.log`), plus explicit objective roundtrip checks.

Eight PNGs were opened and visually inspected: split-error, interpolation-field,
sampled-residual and timing views for each model. Separate colorbars, query axes,
raw scales, scientific caveats and the largest extrapolation failures remain
visible. No figures are staged; generated artifacts stay ignored.

## Measured scientific results

Each number is an unweighted relative sampled L2 against the analytical Fourier
reference, aggregated only within its named split. These are not continuum norms
or a ranking between models.

| Split | Parametric surrogate | DeepONet |
|---|---:|---:|
| Training | 0.00352986 | 0.0174363 |
| Unseen interpolation | 0.00324407 | 0.0181190 |
| Parameter extrapolation | 0.174769 | Not tested / fixed alpha |
| Amplitude extrapolation | Not applicable | 0.0159878 |
| Frequency extrapolation | Not applicable | 3.39054 |
| Later-time coordinate extrapolation | 0.0915146 | 0.359659 |

The fixed interpolation threshold (<0.15) passed for both. Frequency
extrapolation failed badly as a prediction task; this limitation is retained,
not hidden by averaging or relabeling it interpolation. Passing a software gate
does not mean extrapolation is accurate.

Independent ForwardDiff residual RMS ranges over interpolation cases were
0.0317–0.1096 (surrogate) and 0.0475–0.2807 (operator), despite small reference
errors. Parameter-extrapolation residual RMS reached 1.103; frequency-shift
operator residual RMS ranged 3.142–4.464. Analytical-reference residual RMS
remained below 5e-16 on these points. These are 12-point sampled observations per
case, not global physical correctness, continuum norms or stability guarantees.

Optimization took 41.193 s (surrogate) and 46.271 s (operator), with compilation
potentially included and preprocessing excluded. The final figure-recovery timing
sample gave warmed median complete-query costs of 13.429 microseconds analytical
reference versus 249.873 microseconds surrogate inference, and 34.318 versus
249.595 microseconds for the operator. Both returned unavailable break-even
counts: the analytical reference was faster. This is not a numerical PDE solver
speedup benchmark. Timing varies between runs; original and recovered reports
retain their own measurements and scopes.

FNO remains deferred: the retained forward probe is not a trained FNO gate.
No manual FFT, global quality score, automatic ranking, discretization-invariance
claim or long-term-stability claim was added.

## Final publication gates

Candidate security scan and `git diff --check` passed before the single bounded
review. The one independent bounded review returned `passed=true`, no security
concerns and no correctness blockers. Two non-blocking scope clarifications were
documented: custom layers must preserve training batch shape/state, and generic
amplitude/frequency labels are caller-declared even though out-of-domain
separation is validated. No core source changes or extra review were needed.
Canonical suite and final post-canonical checkpoint gates completed successfully
before the local milestone commit.

### Final checkpoint recovery

The final recovery found no surviving Julia process and no started/completed M9D
canonical run. All source, test, example and environment candidates matched the
pre-review SHA-256 audit. Only this ledger and the two documented clarifications
in `surrogates.md` had changed. No implementation, architecture, dataset, training
budget or tolerance was changed, and neither model was retrained.

The completed bounded review was recovered from session
`20261001_121803_b0112e`, message 3539 (`deleg_47c4380e`); no second review was run.
Historical focused/backend counts are also retained in that session, message
3447, for logs no longer present in scratch storage.

| Final gate | Result | Evidence |
|---|---|---|
| One fresh canonical `Pkg.test()` | 2,194 passing assertions, 122 top-level testsets | `m9d-final-canonical.log` |
| Separate post-canonical checkpoint integration | 261/261 assertions | `m9d-final-postcanonical.log` |
| Source, environment, checkpoint, report and figure hashes after both gates | Unchanged | `m9d-final-source-artifact-hashes.json` |

Both commands used Julia `+release` (1.12.7), `--startup-file=no`,
`JULIA_NUM_THREADS=1` and `OPENBLAS_NUM_THREADS=1`. The base command was
`julia +release --project=. --startup-file=no -e 'using Pkg; Pkg.test()'`.
Its success marker was `AnalyticMathLab tests passed`; the sequential process
exited zero. Optional validation ran only after canonical success, in
`--project=examples/operators`. It reused the existing `verify_runs` gate
(255 assertions) plus six checkpoint objective/import checks, without training,
rewriting reports or rendering figures. Native optimizer/history remained
explicitly unavailable on checkpoint reload.

The root manifest emitted a project/compat-resolution warning. It did not block
the canonical run; dependencies and lockfiles were not upgraded or rewritten.
Base architecture tests confirmed every public export is defined and optional
ML dependencies remain unloaded. Existing optional activation/isolation evidence
was reused for the unchanged registration files.

All eight final figures were opened again during final recovery, under
`notebooks/output/m9d_heat/`:

- `surrogate_reference_errors.png`
- `surrogate_interpolation_field.png`
- `surrogate_physics_residual.png`
- `surrogate_timing.png`
- `operator_reference_errors.png`
- `operator_interpolation_field.png`
- `operator_physics_residual.png`
- `operator_timing.png`

Reference/prediction and residual/error distinctions, split labels, shared field
color ranges, separate error colorbars, axes, readable caveats and unclipped
legends passed inspection. The large frequency-extrapolation failure remains
visible. These references are analytical Fourier solutions, not numerical
references mislabeled as exact. Generated artifacts remain ignored and local.

Candidate security/size scanning covered 26 files with no findings, and
`git diff --check` passed. Final staging checks compare candidate hashes against
the index; no generated artifacts or credentials belong to the commit.

M10 integration/hardening and M11 stochastic work remain outside M9D. No
uncertainty calibration, stochastic operator support, universal generalization,
long-term stability or discretization invariance is established here.
