# M10D.4 — One System, Many Methods: recovery and results

Status: VERIFIED COMPLETE; recovered final canonical passed. M10D.5 is
not started. The scientific investigation and commands are in
[m10d_one_system_many_methods.md](m10d_one_system_many_methods.md).

## Initial recovery from filesystem truth (historical)

Recovered HEAD: `b5b6876e665bbf2f6681de1b3db1f0e511de2542`, the verified M10D.3
baseline. No M10D.4 implementation/completion commit exists in recovered history.
The index was empty. Four tracked modifications and eight untracked files survived:
three integration examples, four flagship tests and the draft investigation doc.
The tracked changes are runner registration, plan status and the operators
Project/Manifest direct-import declarations. No src/ or ext/ file changed.

All surviving Julia files and changed TOML parsed; complete modules, functions and
entry points survived. No conflict markers, truncated generated blocks, duplicate
implementation or tracked debugging artifact was found. No reset, restore,
stash, cleanup, rollback or reconstruction was needed. Original candidate files
are preserved in `recovery-original-files.tar.gz` outside scratch.

Durable evidence directory (all gate basenames below are relative to it):

`/home/lorenzozm/.hermes/logs/analyticmath-lab/m10d4/`

`recovery.json` stores original hashes, operation classification and backup path.
Earlier logs/JSON are unchanged. `reused-regressions.json` links unchanged test
bodies and production hashes to successful baseline canonical rows. The root
Project/Manifest also match. The optional manifest has exactly the same dependency
records/versions; only its project hash changes for two newly direct imports.

### Recovered operation disposition

| Prior operation | Classification | Evidence / action |
|---|---|---|
| definition-red; investigation-red; learning-red; plots-red | FAILED | Historical expected missing implementation/file checks; preserve, do not rerun red gates |
| definition-green | PASSED | 10 assertions, exit 0 against an earlier partial implementation; not a final flagship verdict |
| investigation-first | FAILED | Historical Julia entry-point parse error; surviving explicit if/end already fixes it |
| investigation-second | FAILED | Historical saved-grid mismatch; surviving grid refusal/control configuration retained |
| schema-red | FAILED | Fixed physical model originally lost from detached dataset context; surviving family NamedTuple fixes that specific loss |
| investigation-green | RESULT_INCOMPLETE | SIGTERM/compilation stack, no full exit recorded; do not infer crash or scientific failure |
| investigation-complete | RESULT_INCOMPLETE | Retained `proc_95a25bc3f3a7.json` proves exit -15 from `process.kill`, not machine-crash attribution |
| flagship-focused | RESULT_INCOMPLETE | Seven schema assertions finished; no whole-gate exit. Process no longer exists after restart; exact termination cause unavailable |
| Optional learning green / plot rendering | NOT_STARTED | No completed durable green evidence recovered |
| Bounded review | NOT_STARTED at recovery | No durable M10D.4 review found; one parent review performed below |
| Implementation checkpoint | NOT_STARTED | No equivalent subject/commit in all-branch history |
| M10D.4 canonical | NOT_RUN | No canonical command/log/process record for this candidate; no M10D.4 canonical failure found |

No operation is labeled INTERRUPTED_BY_CRASH merely because the machine crashed;
where termination evidence is missing, RESULT_INCOMPLETE is the honest category.

### Workstreams at recovery

COMPLETE here means implementation present and structurally intact, not a claim
that an interrupted runtime gate passed. The gate section supplies that verdict.

| # | Workstream | Recovered classification | Continuation |
|---|---|---|---|
| 1 | Canonical system definition | COMPLETE | Reuse canonical_system and independent exact_state |
| 2 | Mathematical/symbolic view | COMPLETE | Reuse scalar field and symbolic identity tests |
| 3 | Lagrangian mechanics | COMPLETE | Reuse public LagrangianSystem/analyze |
| 4 | Hamiltonian view | COMPLETE | Reuse public Legendre transform and canonical flow checks |
| 5 | Normal modes | COMPLETE | Reuse linearization, spectrum, generalized eigenpair checks |
| 6 | Numerical dynamics | COMPLETE | Reuse stored-grid refusal and independent modal comparison |
| 7 | Energy comparison | COMPLETE | Reuse numerical drift, Hamiltonian and analytical energy checks |
| 8 | Trajectory → ObservableSeries | COMPLETE | Reuse named components and explicit scalar callbacks |
| 9 | Sampled statistics | COMPLETE | Reuse independent same-sample moment/prefix tests |
| 10 | Atomistic interpretation | COMPLETE | Reuse explicit anchored snapshots and distance oracle |
| 11 | ScientificDataset bridge | COMPLETE | Reuse surviving fixed-definition family schema correction |
| 12 | Bounded scientific ML | PARTIAL | Implementation/tests present; successful execution unproven |
| 13 | Cross-method comparison | COMPLETE | Reuse explicit compatibility helper and negative tests |
| 14 | Provenance trace | COMPLETE | Reuse honest bounded ancestry and unavailable leaf context |
| 15 | User-facing flagship | PARTIAL | Core/learning/plot examples present; green execution/rendering unproven |
| 16 | Integration tests | PARTIAL | Registered base tests present; full flagship exit unproven |
| 17 | Documentation | PARTIAL | Investigation prose present; this evidence/results report missing |
| 18 | Bounded adversarial review | NOT_STARTED | Exactly one parent review, not a subagent |
| 19 | Implementation checkpoint | NOT_STARTED | Create only after required green gates |
| 20 | Canonical verification | NOT_STARTED | One fresh canonical authorized after checkpoint |

## Scientific stage and loss table

All physical quantities are explicitly dimensionless at workflow level. Native
plain-numeric AML unit metadata remains unknown when its contract has no storage
slot. The following declarations are not automatic unit inference/conversion.
Stable/experimental API status follows the frozen inventory; qualified semantic
accessors and ScientificDataset/learning are intentionally PUBLIC_EXPERIMENTAL.

| STAGE | AML PUBLIC API | SCIENTIFIC QUANTITY | ORACLE / REFERENCE | ERROR / AGREEMENT | STATUS / EVIDENCE | UNITS | ORIGIN | INFORMATION LOST |
|---|---|---|---|---|---|---|---|---|
| Definition | Local workflow definition supplied to public constructors | m,k,κ; q/v/p ordering; zero equilibrium; both modal amplitudes | Explicit user-defined oscillator | Exact parameter/IC assertions | Canonical-definition tests | Dimensionless declaration | Caller definition | No universal AML system-identity type is invented |
| Mathematical field | analyze(V,q), gradient, hessian | ∇V(0), Hessian V | 0 and [2 -1;-1 2] | Exact entries | Symbolic/field assertions | Dimensionless; native unknown | Independent expression for same model | No units certification |
| Lagrangian | LagrangianSystem, analyze, euler_lagrange, generalized_momenta, energy_function | EL equations, p=m v, T+V | M q̈+Kq=0 | Symbolic polynomial zeros | Established symbolic identities | Dimensionless | L=T−V | Formal identities do not certify a numerical trajectory |
| Hamiltonian | legendre_transform, hamilton_equations, energy_function | H(q,p), canonical flow | p²/(2m)+V; p=m v explicitly | Symbolic zero and sampled roundoff | Transform established; numerical consistency separate | Dimensionless | Actual Legendre transformation; no invented native parent descriptor | Native accessor does not record Legendre ancestry |
| Linearization | linearize_mechanics | M=I,C=0,K; equilibrium | Exact quadratic coefficients | Exact matrices | Local applicability; global equivalence independently proven for this quadratic | Dimensionless | Source mechanics retained | Generic local linearization is not globally exact |
| Modes | normal_modes | λ=(1,3), ω=(1,√3), normalized eigenspaces | Independent symmetric/antisymmetric directions | Residual/orthogonality and sign-invariant overlap | Numerical modal evidence heuristic | Dimensionless angular frequencies | Linearization → mechanics | Float64 eigensolver; signs not physical identity |
| Dynamics | dynamics, trajectory | q1,q2,v1,v2 at declared times | Independent closed-form modal superposition | Max component <2e-8; exact stored-grid equality | Completed numerical solve plus independent accuracy test | Dimensionless | Mechanics → dynamics → trajectory | Finite saved grid; no continuum error certificate |
| Energy | energy_drift; energy_function | T+V, Hamiltonian energy, drift | Constant analytical modal energy | Drift/oracle discrepancy <2e-9 | Sampled drift heuristic, not conservation theorem | Dimensionless energy | Numerical energy derived from trajectory; analytical constant independent | Unsampled behavior not certified |
| Observable projection | observable_series | q1,q2,energy,symmetric amplitude | Selected stored state/callback | Exact component/time/order preservation | Stored only; no resampling | Explicit context declaration; native unknown | Trajectory selection | Other components omitted from target; source retained |
| Statistics | statistical_summary, running_statistics | Mean, n−1 variance, prefixes | Independent calculations on same saved samples | Roundoff <1e-15 | Heuristic descriptive statistics; no standard error | Dimensionless | Workflow retains source series beside leaf | Four-field leaf has unavailable origin/context; no IID/continuum claim |
| Atomistic view | AtomisticSnapshot, pair_distances | r1=(q1,0,0),r2=(1+q2,0,0), pair distance | abs(1+q2−q1) | <2e-8 against analytical mapping | Five explicit stored snapshots, open boundary | Dimensionless declaration | Caller mapping from actual stored frames | Not an MD solve; no native snapshot parent; fixed identity caller-declared |
| Dataset | ScientificDataset(path;schema,source_retention=:descriptor) | q1 target; amplitude input; t coordinate | Actual selected numerical samples | Exact source values/query grid | Explicit schema, training split, numerical reference/error unknown | Ordered dimensionless schema | Detached trajectory origin | Context/native source/callback/unselected labels omitted; fixed definition retained in family |
| Learning | learning_model, training_data, train | Scalar q1(amplitude,t) affine surrogate | Numerical training targets; separate analytical oracle | Finite bounded errors <2; actual errors reported after gate | Seed 41, one Dense layer, one Adam step; accuracy not established | Schema preserved; inverse output scaling | Dataset → model/fit | Affine model cannot represent oscillatory family accurately |
| Generalization | analyze(fit), field_errors, classify_query | Per-case sampled error and split membership | Explicit numerical targets and independent oracle | Independent sampled RMS checks | Unknown global validity; membership guarantee none | Same schema and samples | Fit/dataset chain; canonical primary source is not complete DAG | Finite family/samples; no universal extrapolation claim |
| Cross-method agreement | Local comparison helper over public results | Same named quantity and conventions | Explicit compatible reference qualities | Checks quantity/order/parameters/IC/units/times before subtraction | Negative controls reject mismatches | Explicitly dimensionless only | Same model is not a fabricated derivation | No universal AML equivalence/ranking API |
| Provenance | AnalyticMathLab.scientific_origin/scientific_metadata | Scoped claims, bounded derivation | Actual construction/selection relationships | Equality/hash independent of source identity | Honest unknown leaf/parent omissions | Declared/unknown remain distinct | At most eight levels, one parent | Not full DAG, durable identity, content hash or reproducibility proof |

## Subsystem coverage

| Subsystem | Disposition | Reason |
|---|---|---|
| Scalar-field symbolic calculus, mechanics, Hamiltonian/Legendre, modes | USED | Different consistent views of the same coupled oscillator |
| Numerical dynamics and energy diagnostics | USED | Public integration with independent analytical oracle |
| Observable projection and sampled statistics | USED | Exact stored samples and explicit descriptive scope |
| Base atomistic geometry | USED | Explicit longitudinal interpretation, not inferred particles |
| ScientificDataset, scalar surrogate, train-only scaling, generalization | USED | Bounded existing experimental route; amplitude family explicitly identified |
| Stored visualization | USED | Optional user-chosen backend; rendered/inspected, not canonical scientific evidence |
| Molly MD/backend adapter | NOT_APPLICABLE | No second physical simulation is required for explicit snapshots |
| PINN | NOT_APPLICABLE_TO_THIS_FLAGSHIP | No natural existing exact-oscillator workflow established; no new formulation |
| Radial potentials/RDF, diffusion/transport, inverse inference, operator network | NOT_APPLICABLE | Would change or add a scientifically unnecessary question |
| Large-scale/performance/ML training workloads | NOT_APPLICABLE | Recovery/correctness task, not benchmarks |
| D024/default-thread portability and general constructor hardening | DEFERRED | M10D.5 scope, not started |
| Wiki/universal subsystem coverage/1.0 verdict | DEFERRED | Later milestone obligations; no universal coverage claim |

## Single bounded adversarial integration review

One parent review asked whether the flagship silently changes the physical system.
Full disposition: durable `recovery-review.md`, bound to `recovery.json` source
hashes. Parameter/order/unit/IC/time consistency, mode sign/normalization,
independent references, atomistic mapping, schema retention, actual ancestry,
ML split/reference honesty and public API boundaries were inspected. No new
scientific model blocker was found. Historical schema loss was already repaired in the
surviving implementation, not repaired a second time. No source-library redesign,
M10D.1–M10D.3 reopening or extra review was performed. Runtime gates remain
separate from this static disposition.

Rendering then exposed one local presentation defect: default energy-axis zoom
magnified a 1e-11 drift while rounding every tick to 3.5e-2. The optional plot helper
now uses a zero-based absolute energy scale and prints the measured drift in its
title. The regression assertion first failed (5 passed/1 failed, exit 1;
`recovery-energy-scale-red.log`). Only this helper and its optional test changed;
core investigation, learning, mandatory tests and all library source remain
unchanged. This is a disposition within the same bounded review, not a second
scientific review or reopening of the visualization subsystem.

Replacement rendering passes 6/6 assertions. The corrected energy figure has a
legible zero-based axis and the measured 1.08e-11 drift explicitly in its title.
Trajectory/distance final PNG hashes equal the previously inspected versions;
units, analytical/numerical labels and anchored-particle disclaimer are legible.
Final figures are under durable `figures-final/`; earlier outputs remain preserved.
Core and learning gates are not repeated because neither loads the changed plot
helper/test. Their relevant executable hashes still match, and final rendering's
complete executable hash inventory matches the final candidate.

## Verification ledger

Reused baseline regressions are hash-backed subsets, not a claim that M10D.3's
canonical tested the new flagship. Durable original canonical evidence:
`/home/lorenzozm/.hermes/logs/analyticmath-lab/m10d3/structural-correction/dependency-corrected-canonical.json`.
Its log SHA-256 was rechecked; it exited 0 with the required success marker.
`reused-regressions.json` records exact matching named rows and source hashes.

| Gate | Assertions / reported testsets | Disposition |
|---|---|---|
| Existing mechanics | 196 / 12 | PASSED, reused unchanged source/test bodies |
| Existing modes | 150 / 8 | PASSED, reused unchanged source/test bodies |
| Existing trajectory/statistics | 185 / 10 | PASSED, reused unchanged source/test bodies |
| M10D.2 interoperability | 189 / 6 | PASSED, reused unchanged source/test bodies |
| M10D.3 semantics/provenance/structural compatibility | 152 / 7 | PASSED, reused unchanged source/test bodies |
| Existing architecture | 152 / 6 | PASSED, reused baseline contracts; new example API guards tested separately |
| Flagship integration/schema | 197 / 3 | PASSED, exit 0; recovery-flagship.json/log; unchanged surviving implementation |
| Optional learning | 118 / 1 | PASSED, exit 0; recovery-learning.json/log; unchanged surviving implementation |
| Optional plots | 6 / 1 | PASSED, exit 0; recovery-plots-final.json/log; all three figures visually checked |
| M10D.4 canonical | 5388 / 186 | PASSED, exit 0; recovery-canonical.json/log; recovered completion, no rerun |

Counts are gate-local, not additive milestone totals. No M10C stress workload is
run; canonical's already registered bounded correctness tests are not benchmarks.

All new gates use `JULIA_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1`. The base focused
command includes `test/m10d_flagship.jl` then `test/m10d_flagship_schema.jl`, flushing
stdout after each. The optional gate uses `--project=examples/operators` and
includes `test/m10d_flagship_learning.jl`. Exact argv, tested baseline plus
working-file hashes, UTC timestamps, exits and parsed summaries are in their JSON.
New canonical imports (Test, AnalyticMathLab, Symbolics, LinearAlgebra) are all
declared directly in root dependencies/test targets; no transitive import is used.

### Measured oscillator agreement

From `recovery-flagship.log`, with 321 saved states on exactly the declared grid:

| Quantity | Observed absolute discrepancy |
|---|---:|
| Trajectory maximum component versus analytical oracle | 4.335370951125128e-11 |
| Energy drift from initial numerical energy | 1.083398648571432e-11 |
| Numerical energy versus analytical constant 0.035 | 1.0833993424608224e-11 |
| Hamiltonian versus T+V at selected states | 6.938893903907228e-18 |
| Hamilton equations versus expected canonical flow | 0.0 |
| Generalized eigenpair residual | 0.0 |
| Mass-orthogonality discrepancy | 2.220446049250313e-16 |

Frequencies: 1.0 and 1.7320508075688772. Reported zero floating-point residuals
are observations, not arbitrary-precision guarantees. All pair-distance,
same-sample statistics, source-value/schema, negative-compatibility and legitimate
provenance assertions passed; no numerical tolerances were weakened during recovery.

### Bounded learning: actual errors, not an accuracy claim

One affine network (seed 41), one Adam step, train-only min/max scaling. Errors
are unweighted sampled q1 errors in declared dimensionless units:

| Case | Explicit split | Numerical-reference RMS | Independent-oracle RMS | Maximum numerical-reference error |
|---|---|---:|---:|---:|
| canonical, amplitude 0.20 | training | 0.1773382516114224 | 0.1773382516151757 | 0.41755537196471987 |
| lower, amplitude 0.15 | training | 0.3512432778724537 | 0.3512432778730896 | 0.6030789944378965 |
| upper, amplitude 0.25 | training | 0.2002413627757969 | 0.20024136278143345 | 0.4171604355951545 |
| interior, amplitude 0.175 | interpolation | 0.2546350452836927 | 0.2546350452854281 | 0.5103171832013083 |
| outside, amplitude 0.35 | parameter_extrapolation | 0.5992531160309786 | 0.5992531160345117 | 0.9289581644208547 |

This deliberately underfit model is not scientifically accurate; successful
integration means reference, split, coordinate, normalization and provenance
semantics survived a real training/analysis pass. It does not mean the learned
function is dynamically equivalent to the exact oscillator. Training and held-out
cases are explicitly different initial conditions within the same fixed model
family; only the canonical case retains the flagship initial-value problem.

## Implementation checkpoint and final canonical

Focused implementation and the single bounded review are complete. The existing
checkpoint is `4ffc31499c0a962cc428a00bbab5be154d8bfba4`, subject
`[m10d] Add One System Many Methods flagship`, directly following the verified
M10D.3 baseline. It is preserved, not recreated or amended.
The canonical command is exactly:

    env JULIA_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 julia +release --project=. -e 'using Pkg; Pkg.test()'

### Restart recovery and completed canonical

The later restart recovery found a clean working tree at the implementation
checkpoint, with all 14 checkpoint files intact. The earlier NOT_STARTED/NOT_RUN
rows above describe the initial recovery, not the current state. No completion
commit existed yet; only documentation and the separate completion commit remained.

The canonical had already completed successfully before this recovery:

- Tested commit: `4ffc31499c0a962cc428a00bbab5be154d8bfba4`.
- Tested tree: `b63ee50c4d26543c2bc74d349b66dc7d701b039c`.
- Start UTC: `2026-10-09T21:30:38.304679+00:00`.
- End UTC: `2026-10-09T21:44:45.237349+00:00`.
- Exit status: 0; 5388 passed, 0 failed, 0 errors; 186 reported testsets.
- Final marker: `Testing AnalyticMathLab tests passed`.
- Log: `recovery-canonical.log`; full command, hashes and counts:
  `recovery-canonical.json`, both in the durable directory above.
- Log SHA-256: `e438ce18b91992af9708c3476f01620f69d47254a2b3ddc792e10c3b100542d9`.
- Independent retained process result:
  `/home/lorenzozm/.hermes/logs/process-results/proc_4ae0f6f90c58.json`,
  recording normal completion and exit 0.

Recovery independently reparsed all summary rows and checked the final marker,
log digest and all 231 canonical source/environment hashes against the working
tree and index. The three mandatory flagship rows total 197 passing assertions,
matching the focused gate. No executable or environment file changed.

Core 197/197, optional learning 118/118 and final rendering 6/6 evidence is reused.
Their log digests and relevant candidate hashes match. Earlier core/learning
inventories differ only in later documentation and the already-reviewed optional
plot correction, which those gates do not load. The final rendering inventory
matches all executable files; only later report/plan prose differs.

`restart-finalization.json` records this recovery verification beside the original,
unchanged gate evidence. No canonical or focused gate was rerun. Finalization is
documentation-only and local: no amend, push, tag, subagent or M10D.5 work.
