# M10B numerical robustness bug and verification ledger

## Recovery and scope

Baseline HEAD: `d8ca9146f0ddb54f00ba0368a0d8670868ff58c9`.
Recovery found five modified source files, the numeric inventory, and six complete
focused test files. The index was empty. The three delegated audits were already
completed; their final outputs were recovered from session
`20261002_080537_83d9d8`, message 4095. No task was redelegated or recreated.
The parent's earlier diagnostics red log had 55 passes and 73 failures; the
existing five-source-file fix was preserved and executed rather than rewritten.
All Julia gates are parent-owned and serial, with `julia +release` (1.12.7).

The six recovered files were read in full. Focused execution exposed additional
failures after earlier top-level testsets were repaired; an early failing testset
is not proof that later sections ran. Test/oracle corrections below are separate
from production defects. No tolerance was relaxed to conceal a source error.

## Confirmed findings and disposition

| ID | Classification | Red counterexample / cause | Minimal disposition and regression |
|---|---|---|---|
| B01 | genuine source bug | `sampled_summary` unconditionally narrowed to Float64, overflowing/erasing BigFloat; divided subnormals before summation; L2 overflow returned Inf | Preserve float type, normalize before sums/squares, unavailable nonfinite norm; `m10b_diagnostics` |
| B02 | undocumented/unsafe backend boundary | M9 concrete Float64 constructors silently lost high precision or range, including finite bounds becoming infinite | Shared checked conversion requires explicit caller rounding; legitimate infinite bounds retained; diagnostics and inference/scaling gates |
| B03 | genuine source bug | Finite gradient dot normalized direction overflowed without a final guard | `_finite_real` on directional result; nonfinite gate |
| B04 | genuine source bug | ODE `dt` validated before conversion, becoming zero/Inf; tiny nonzero initial/RHS values became zero | Validate converted positive dt and reject nonzero-to-zero state/RHS; nonfinite gate |
| B05 | genuine source bug | Normal-mode positive tolerance underflowed; diagonal mass weighting erased nonzero stiffness into a purported zero mode | Reject erased tolerance, return unknown for destructive diagonal scaling; linear algebra gate |
| B06 | genuine source bug | Kinetic-energy velocity squaring underflowed before large mass rescaled it | Explicit unknown via shared guarded kernel for system and particle inspection; atomistic gate |
| B07 | genuine source bug | Welford accumulated M2 overflowed although final sample variance was representable | Equivalent online sample-variance recurrence with divided increments, retaining O(1) storage and generic units/types; statistics/running regressions |
| B08 | genuine source bug | Independent SEM `sqrt(seA²+seB²)` spuriously overflowed/underflowed | `hypot` after existing unit conversion; statistics Float32/64 and Unitful regressions |
| B09 | genuine source bug plus recovered-fix defect | Scaling accepted invalid scales, overflowed subtract/multiply intermediates; recovered `map` fix truncated matrix columns | Validated metadata and real inputs, broadcast safe subtraction/scaling, fused inverse, final finite checks; diagnostics gate |
| B10 | genuine source bug | Half-endpoint min/max fit erased equal subnormal offsets and misclassified underflowed nonconstant ranges as constants | Same-sign difference midpoint, preserve equal endpoints, only true constant uses scale=1; inference/scaling gate |
| B11 | unsupported/backend-limited contract and genuine control bugs | Inference parameter types reached unsupported AD/SVD paths; initial/tolerance conversion lost range; finite rank controls produced infinite threshold | Exact Float64 parameter boundary before solve/AD, Float64 dual preservation, finite weighted matrix/threshold checks; analytical nearly dependent observation map |
| B12 | genuine source bug | Field errors accepted complex values then failed incidentally; relative finite/finite division could overflow | Explicit real input contract and unavailable overflowing relative error; diagnostics gate |
| B13 | genuine optional-source bugs | Surrogate inverse scaling bypassed checked generic inverse, learning objective returned NaN/Inf, UDE sum overflowed after individually finite terms | Checked inverse reuse, explicit objective/combined-field failure; fixed native models in optional operator gate |
| B14 | genuine optional-source bugs | PINN prediction narrowed coordinates, accepted nonfinite outputs; reference relative ratio overflowed | Checked coordinate/output boundary, explicit invalid prediction failure, missing unrepresentable relative ratios; optional PINN gate |
| T01 | test/oracle error | `@test` caught DomainError inside a surrounding try before the test could classify it | Evaluate once outside the macro, then assert correct result or DomainError |
| T02 | backend-limited oracle error | BigFloat Unitful output used BigFloat default tolerance even though eigenvalue came from Float64 LAPACK | Explicit 8eps(Float64) relative oracle consistent with declared backend |
| T03 | test syntax error | `2.+1e-9` and `2.+1e-7` are ambiguous Julia syntax | Unambiguous `2.0+...`; no change to tested values |
| T04 | expected floating-point limitation | Earlier parent used exact equality for computed L2=5 | Recovered approximate comparisons retained; no claim of exact floating norm |

## Honest limitations, not defects hidden by tolerances

* Input rounding cannot be undone: Float64 coordinates at 2^60 lose a unit
  displacement, whereas stored BigFloat coordinates retain it.
* Float32 cancellation loses more information than Float64. The demonstration
  preserves the finite result and reports the actual error, not equal accuracy.
* Raw M1 scalar callables retain underlying IEEE NaN/Inf behavior; checked real
  field/experiment APIs are separate. A valid domain point may still overflow.
* M6 and M7 remain documented Float64 approximations; normal modes are heuristic,
  not an arbitrary-precision eigensolver. Singular/indefinite/very ill-conditioned
  masses yield unknown. Diagonal scaling guard is not a general conditioning proof.
* Statistics are approximate, not exact or order-independent. Variances below
  working range can round to zero; nonfinite intermediate/result evidence is
  unknown. Correlation of a constant sequence and unearned IID/independence claims
  remain unavailable. The online variance fix is not compensated summation.
* Unitful is supported only on existing physical paths, not implicitly stripped
  into PINNs or training arrays. Complex polynomials are meaningful; the audited
  real fields, radial models and residual summaries are not complex analyses.
* M9 storage/AD boundaries require losslessly representable Float64 values, or
  explicit caller rounding. Generic summaries, errors and scaling arithmetic
  still retain BigFloat range. No arbitrary-precision neural training is claimed.
* Optional PINN test objects are explicitly untrained initial-state fixtures
  around genuine discretization and Lux parameters, never simulated training.

## Verification checkpoints

Logs live under `/home/lorenzozm/.hermes/cache/scratch/`.
Initial serial passes/failures were recorded as `m10b-*-first.log`; subsequent
red/green logs were retained, including `m10b-diagnostics-red.log` from recovery.
The six base audits passed after the classified fixes. Added M9 inference/scaling
and required-showcase focused files also passed. Final-source focused, M10A,
optional, review and canonical results are recorded below when complete.

## Final verification — complete

Finalization resumed from the existing 28-file candidate on `main`, with an empty
index and baseline HEAD unchanged. No production source, tests, optional gates,
or dependency manifests were edited during final verification. Only the two M10B
documents received completion records. No task was redelegated, no base audit was
rewritten, and no completed focused M10B gate or showcase was rerun separately.

### Recovered source identity and reusable evidence

No original pre-gate hash manifest survived. Instead, the pre-gate contents were
reconstructed in memory from baseline Git blobs, original complete file writes,
and successful recorded patch outputs. Replayed duplicate events were ignored;
compressed payloads were not used as file content. All **26 executable candidate
files** matched their reconstructed SHA-256 hashes, including the eight focused
files, two optional gates and runner. This is reconstructed historical evidence,
not a claim that the old test process emitted hashes.

The final serial command is retained in session `20261003_001452_f2f92d`, messages
4237–4238 (`proc_a407b106f9e0`). It ran all eight M10B focused files followed by the
five M10A files, aborting on any nonzero exit. Surviving successor logs establish
completion of each predecessor. Its process handle is no longer available, so
only the last M10A inference/operator gate was freshly repeated to establish its
exit independently. All executable-file modification times precede that old
serial run, and the reconstructed contents match the current files.

A separate SHA-256 snapshot covers **173** source, extension, test, example and
environment files. It remained unchanged through optional gates, the bounded
review and canonical testing. Local artifacts under the scratch directory:

* `m10b-recovered-hash-evidence.json`: reconstructed candidate comparisons.
* `m10b-final-executable-hashes.json`: final executable/environment snapshot;
  SHA-256 `8b99e220fd66b0800b285b76ca979baaa2efe12a0ac86957b028078f03560d15`.
* `m10b-final-gate-counts.json`, `m10b-canonical-counts.json`: parsed summary rows.

### Focused and affected regression results

| Gate | Passing assertions / top-level testsets | Disposition / log |
|---|---|---|
| M10B types | 140 / 5 | Reused `m10b-types-final.log` |
| M10B nonfinite/domain | 112 / 4 | Reused `m10b-nonfinite-final.log` |
| M10B linear algebra | 90 / 4 | Reused `m10b-linear_algebra-final.log` |
| M10B atomistic | 146 / 4 | Reused `m10b-atomistic-final.log` |
| M10B statistics | 419 / 1 | Reused `m10b-statistics-final.log` |
| M10B diagnostics | 128 / 1 | Reused `m10b-diagnostics-final.log` |
| M10B inference/scaling | 48 / 2 | Reused `m10b-inference_scaling-final.log` |
| M10B required demonstrations | 17 / 1 | Reused `m10b-showcases-final.log` |
| M10A reference checker | 20 / 1 | Reused `m10b-regression-references.log` |
| M10A calculus/dynamics | 282 / 4 | Reused `m10b-regression-calculus_dynamics.log` |
| M10A mechanics | 51 / 4 | Reused `m10b-regression-mechanics.log` |
| M10A atomistic/statistics | 290 / 1 | Reused `m10b-regression-atomistic_statistics.log` |
| M10A inference/operators | 759 / 5 | Fresh `m10b-final-m10a-inference.log` |

Six base audits: **1,035** assertions. All eight M10B base files: **1,100**.
Affected M10A regressions: **1,402**. These counts are contained in, not added to,
the canonical total below. Every named focused summary exactly matches its
canonical summary row.

### Optional native numeric and regression gates

All commands used `JULIA_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 julia +release
--startup-file=no`, with the corresponding example directory as `--project`.
Process `proc_9e0964140c80` completed the fresh final M10A gate and the following
optional gates sequentially, with exit **0** and explicit per-gate PASS markers.

| Entry point | Passing assertions / top-level testsets | Log |
|---|---|---|
| `examples/inference/m10a_gate.jl` | 48 / 2 | `m10b-final-optional-inference.log` |
| `examples/operators/m10a_gate.jl` | 43 / 2 | `m10b-final-optional-operators-regression.log` |
| `examples/operators/m10b_gate.jl` | 20 / 1 | `m10b-final-optional-operators.log` |
| `examples/pinn/m10b_gate.jl` | 15 / 1 | `m10b-final-optional-pinn.log` |

Optional total: **126** assertions, including **35** M10B-specific assertions.
No optimizer, neural retraining, or heavy showcase was run. Optional startup
reported precompilation/version-cache notices, but no ERROR or failed assertions.
No post-canonical optional rerun was required: all optional gates completed on the
same executable/environment hashes, and canonical execution changed none of them.

### Candidate scan and one bounded numeric review

`git diff --check` passed. The bounded candidate scan examined all **28** files,
finding **zero** credential, unsafe-execution, suspicious-path, binary or size
findings. Generated output, local logs and verification artifacts remain outside
the candidate. Exact staged blobs are checked against their working-file hashes
and executable snapshot before committing; the staged scan is retained as
`m10b-candidate-staged.json`.

The parent completed **one** bounded numeric-correctness review, without
delegation, covering the changed arithmetic and guards, their callers, all new
tests/gates, runner registration and documented limitations. Verdict: **pass,
zero blocking numeric findings and zero security concerns**. The recurrence was
checked against Welford divided by n-1; scaling shape/rounding, checked conversion,
dual preservation, mass scaling, shared kinetic guards, relative-error sentinels
and optional final-output checks were traced to their regressions. No source
correction or second review was needed. This is explicitly a parent review, not
an independently delegated approval or a universal correctness proof.

Artifact: `m10b-final-numeric-review.json`, SHA-256
`d12d3f23cfb959b250e4b70ad6c4b4a1a497a4e5ecda3881dc1eb34b0d0e0d5b`.

### One fresh canonical suite

Command:
`JULIA_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 julia +release --project=. --startup-file=no -e 'using Pkg; Pkg.test()'`.

Process `proc_cab6632c3293` exited **0**. The complete log reports **4,696 passing
assertions across 159 top-level testsets**, with no failures, errors or broken
tests. It includes all **1,100 M10B** and **1,402 M10A** assertions, ends with
`Makie view: 11/11`, and contains `Testing AnalyticMathLab tests passed`.
The pre-existing project/manifest-resolution warning remains; no dependency or
manifest was changed to suppress it.

Log: `m10b-final-canonical.log`, SHA-256
`fdaf8442cabd5160aeb06cef00ce1287d3d6572a9e18df267c2ace814521e87b`.
The separate `m10b-final-canonical.exit` records zero.

Canonical plus separate optional gates: **4,822** passing assertions, without
double-counting focused reruns. M10B-specific base plus optional: **1,135**.
The ledger retains **14 B-series classified findings** and **4 T-series
test/oracle/rounding classifications**; all recorded fixes have passing evidence,
and no additional blocker was found during finalization. The honest limitations
above remain applicable.

M10B final verification is complete. The local milestone commit is
`[verified] Complete M10B numerical robustness audit`. No push, tag, M10C or M10D
work is included.
