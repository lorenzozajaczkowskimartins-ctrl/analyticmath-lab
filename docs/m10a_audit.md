# M10A mathematical consistency audit

## Scope and recovery

Starting HEAD: `dbe96a5a53dffdd9112031c746366891c2e520d3`.
The recovered tree had no tracked or staged diff and six untracked entries.
All intended files, untracked contents, scratch logs and matching filenames under
`test/`, `docs/`, `examples/`, `src/`, `ext/` and the scratch directory were inspected
before editing. No surviving Julia process was found. Provider HTTP 429 failures
were reported by the recovery request; they are not scientific test failures.
No reset, checkout, revert, discard, push, tag, or other M10 phase was used.

Classification at recovery (A coherent; B salvageable missing obligations;
D syntax broken; E logical/API defect; F absent):

| File | Class | Recovery action |
|---|---|---|
| `examples/validation/reference_checks.jl` | E | Preserved helper; replaced one substitution call after reproducing the failure |
| `test/m10a_references.jl` | B | Preserved all tests; added per-condition, BC-only corruption and unknown-closure checks |
| `test/m10a_calculus_dynamics.jl` | B | Preserved all sections; added constant-rate exponential decay case |
| `test/m10a_mechanics.jl` | F | Added bounded force, canonical, Legendre, local-mechanics and mode audit |
| `docs/m10a_early_inventory.md` | F | Added obligation/oracle matrix |
| `test/m10a_atomistic_statistics.jl` | A | Retained byte-for-byte; executed unchanged |
| `docs/m10a_m8_inventory.md` | F | Added obligation/oracle matrix |
| `test/m10a_inference_operators.jl` | D | Fixed ambiguous scalar power literal; preserved sections, completed rank, error/residual and actual observed-range checks |
| `examples/inference/m10a_gate.jl` | A | Retained byte-for-byte; native HNN/UDE algebraic gate |
| `examples/operators/m10a_gate.jl` | F | Added controlled native DeepONet, batching, leakage and refusal gate |
| `docs/m10a_m9cd_inventory.md` | F | Added obligation/oracle matrix |

No syntactically truncated file was found. The parse error was a malformed literal,
not evidence that all delegated work had been lost. No implementation scope was
redelegated. All five base audit modules are registered in `test/runtests.jl`;
optional stacks remain outside `Pkg.test()`.

## Overall obligation matrix

| Subsystem / object | Obligation | Independent oracle | Tolerance / exactness | Status / regression | Finding / limitation |
|---|---|---|---|---|---|
| M1–M5 calculus | Derivative/gradient/Jacobian/directional/Hessian identities, symmetry and original domain | Hand analytic derivatives, separate AD closures, central FD | Analytic/AD 2e-11; first FD 2e-7; Hessian FD 2e-6; exact domain/order checks | Focused pass; `test/m10a_calculus_dynamics.jl` | [Early inventory](m10a_early_inventory.md); finite smooth cases |
| M6 dynamics | Analytic reference governing equations and IC before solver comparison; ordering | Exponential, Gaussian-in-time decay, harmonic and logistic functions | Reference 2e-11; solver 1e-11; sample comparison 2e-8 | Focused pass; calculus/dynamics and inference oscillator | No rigorous trajectory error bound |
| M7 mechanics/modes | Force sign, canonical J/order, L/H equivalence, local M/C/K and generalized eigenpair | Explicit gradients, full matrices and determinant roots | Algebraic 1e-12; matrix-scaled residual 1e-11; cubic nonlinear bounds | Focused pass; `test/m10a_mechanics.jl` | [Early inventory](m10a_early_inventory.md); repeated eigenvectors not unique |
| M8 atomistic/statistics | Geometry, LJ, mode bridge, hand statistics, clocks, NVE and comparisons | Explicit distances, formulas, hand fixtures and direct residuals | Exact metadata; fixture-specific roundoff/FD/eigen tolerances | Focused pass; `test/m10a_atomistic_statistics.jl` | [M8 inventory](m10a_m8_inventory.md); existing NVE fix protected |
| M9A/B internal reference gate | Actual heat PDE, left/right Dirichlet BCs and IC; fail before consuming wrong reference | Substitute independent analytic callable into actual declared equations and conditions; symbolic differentiation then numeric samples | atol=rtol=1e-11; BC/IC tested separately | Focused pass; `test/m10a_references.jl` | `:heuristic`, finite sampled consistency, never a continuum proof; not a general public theorem prover |
| M9B/D diagnostics | PDE residual differs from reference error | Constant shift: residual zero but error 2; nonzero residual fixture 0.26 | Residual 1e-11; field error 1e-12 | Focused pass; `test/m10a_inference_operators.jl` | No full NeuralPDE benchmark/training rerun; broader PDE families not audited here |
| M9C inference/HNN/UDE | Truth exclusion, order, sensitivity/rank, canonical/gauge identity and additive correction | Analytic decay/oscillator, FD solves, controlled native Lux coefficients | Analytic/FD/solver tolerances distinguished | Base focus verified; optional status below | [M9C/D inventory](m10a_m9cd_inventory.md); no heavy retraining |
| M9D Fourier/operators | PDE/BC/IC, split semantics, leakage, fixed sensors/trunk/query/batch/state | Analytic Fourier term derivatives and explicit bilinear operator formula | Analytic 1e-13–2e-10; exact invariance/refusals | Base focus verified; optional status below | Fixed discretization, caller-declared semantic metadata; no generalization theorem |

## Failure and bug ledger

| Subsystem | Symptom / expected vs actual | Classification / severity | Root cause | Fix / regression | Status |
|---|---|---|---|---|---|
| Delegated execution | Tasks interrupted by HTTP 429; expected completed audit delivery | Model service failure / operational blocker | Provider limits, as reported in recovery request | Recover actual files, not task status | Recovered; not an AML bug |
| Parent reference gate, first RED | Expected helper file; `isfile(helper)` false (0 pass, 1 fail) | Test infrastructure incomplete / blocking | Helper absent at that first historical run | Helper existed at recovery; original tests retained | Historical RED preserved in scratch |
| Parent reference gate, next RED | Exact heat solution should pass; numeric conversion encountered unresolved Differential(u) (1 pass, 1 error) | Test/helper implementation failure / blocking | Symbolics ordinary `substitute` treats Differential applications as opaque; expanding the unchanged derivative does not substitute the callable | `substitute_in_deriv` before `expand_derivatives`; positive PDE/BC/IC and inconsistent-reference regression | Resolved; no AML source change |
| M9C/D audit file | Expected parsed tests; `2.^(1/6)` produces ambiguous-dot ParseError | Test implementation syntax failure / blocking | Scalar float/broadcast syntax ambiguity | `2.0^(1/6)`; full focused module | Resolved; no assertion/tolerance weakening |
| M8 NVE | Kinetic/potential exchange must not be automatically labeled conserved in NVE | Historical scientific semantics bug / misleading scientific interpretation | Prior conservation expectation was too broad | Existing source fix `1bb7897`; M10A all energy-kind/ensemble combinations plus constant kinetic control | Already resolved before M10A; regression strengthened, not claimed as a new fix |
| Finite references and diagnostics | Sample agreement cannot prove continuum correctness; zero PDE residual need not imply correct BC/IC | Undocumented-assumption/overclaim risk / scientific interpretation | Missing assumptions if residual treated as global error | Explicit heuristic notes, BC/IC controls, shifted-reference fixture | Guarded; no continuum guarantee |
| FD, solver and eigen results | Small nonzero discrepancies are expected | Expected numerical approximation / not a bug | Truncation, solver and floating-point roundoff | Separate scale-appropriate tolerances; no failure-driven inflation | Documented |

No new scientific AML source defect has been established by this audit. This
statement is scoped to tested obligations, not a clean bill for all mathematics.

## Verification ledger

Every Julia process runs serially with `julia +release --startup-file=no`.
Base focused command: `--project=. -e 'include("test/<file>.jl")'`.
Optional commands: `--project=examples/inference examples/inference/m10a_gate.jl`
and `--project=examples/operators examples/operators/m10a_gate.jl`.
Logs live under `/home/lorenzozm/.hermes/cache/scratch/` and are local, not committed.
A filename containing "green" is not considered proof of success.

| Gate | Passing assertions / top-level testsets | Log |
|---|---|---|
| Reference checker | 20 / 1 | `m10a-reference-final.log` |
| Calculus/dynamics | 282 / 4 | `m10a-calculus-final.log` |
| Mechanics | 51 / 4 | `m10a-mechanics.log` |
| Atomistic/statistics | 290 / 1 | `m10a-atomistic.log` |
| Inference/Fourier/contracts | 759 / 5 | `m10a-inference-operators-final.log` |
| Optional HNN/UDE | 48 / 2 | `m10a-inference-gate.log` |
| Optional DeepONet/leakage | 43 / 2 | `m10a-operator-gate.log` |

Base focused total: 1,402 assertions. Optional total: 91 assertions.
All focused and optional processes exited zero. Counts are parsed from top-level
summary rows, not inferred from source `@test` counts or double-counted nested
testsets. No training occurred. The optional inference gate was preserved intact.

Initial candidate security/size scan: 13 files, zero findings. `git diff --check`
passed. The one bounded independent review (`deleg_49357243`, task
`sa-0-9bf82623`) returned `passed=true`, with no security concerns or logic errors.
It read all 13 candidates and targeted supporting contracts; it did not rerun
tests or modify files. Its nonblocking caveats are retained: coupled reference
fields, parameter substitution and derivative boundary conditions are not
established by this scalar heat fixture, and shared solver/symbolic infrastructure
limits independence as described below. No source correction or second review
was needed.

The one fresh canonical command was
`JULIA_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 julia +release --project=. --startup-file=no -e 'using Pkg; Pkg.test()'`.
It exited **0**, with **3,596 passing assertions across 137 top-level testsets**,
including all 1,402 M10A assertions. The log ends with `Makie view: 11/11` and
`Testing AnalyticMathLab tests passed`. There are no ERROR lines or failed tests.
The existing project/manifest-resolution warning also appeared in M9D; no
dependencies or manifests were changed to suppress it.

Final provider-interruption recovery found the complete 13-file candidate staged
but no M10A commit. All staged and working-file SHA-256 hashes matched the saved
candidate audit; all nine Julia files also matched the saved reviewed-code hashes.
Package source, extensions and manifests remained unchanged from starting HEAD.
The canonical exit was recovered from process `proc_417950dba2c7`; counts were
parsed from `m10a-final-canonical.log` and checked against each focused M10A count.
Only this documentation-only completion entry changed afterward. Successful
focused, optional, canonical and review gates were reused rather than rerun.
Final candidate/index checks exclude generated artifacts and compare exact staged
blobs to their audited working-file hashes before the local milestone commit.

## Independence and limits

The Symbolics checker and AML symbolic calculus share Symbolics, but the checker
substitutes an independent analytic reference into caller-declared identities and
does not reuse NeuralPDE loss lowering. Calculus additionally uses hand formulas,
ForwardDiff and FD. M6 compares a solver against analytic functions. Inference
FD/AD share a solver, with analytic decay and oscillator cross-checks. HNN/UDE
fixtures use native Lux parameters, not fitted weights. Cartesian/radial LJ and
nonstationary UDE comparisons share Tsit5 and are reduction checks, not independent
integrator validation. Eigen tests check direct residuals rather than stored
residual metadata. Bare arrays cannot reveal falsely declared sensor/coordinate
identities; explicit mismatched sensor metadata and changed training grids fail.

No optional ML environment is added to base dependencies. No optimizer is invoked
by M10A's gates. M10B numerical-type torture, M10C scale/memory stress, and M10D
cross-milestone API unification remain deferred. No push or tag is authorized.
