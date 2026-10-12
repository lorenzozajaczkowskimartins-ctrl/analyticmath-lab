# M10D.6C — executable scientific tutorials

Status: tutorial implementation and mandatory scientific/documentation gates
VERIFIED COMPLETE. C1–C4 complete, C5 pre-commit gates verified; the actual
local-commit closure and final Git status are recorded in the external read-back
ledger identified at the end of this report, not fabricated inside this commit.

## C1: repository, curriculum and evidence mapping

Starting HEAD: `97d8d13a5fdde467c4e44f406150a98bde9547e9`.
Branch: `main`; initial `git status --short` empty. Expected starting subject
matches `[m10d] Complete M10D.6B README and first experience`.
No reset, remote mutation, subagent or dependency resolution was performed.
Juliaup supplies Julia 1.12.7; the root Project declares every planned direct
import (AnalyticMathLab itself, Symbolics, LinearAlgebra). Use restricted
`JULIA_LOAD_PATH=@:@stdlib`, one Julia thread and one OpenBLAS thread.

Consulted existing evidence: M10D.6A `audit_summary.md`,
`documentation_architecture_reconciled.md`, `api.json`, `exports.json`,
`examples_tests_inventory.json`; M10D.6B `readme_implementation_report.md`,
`readme_verification.json`; current README and Project.toml. Resource and refusal
inventories inform the later bounded review. These are SOURCE_INSPECTED, not new
runtime evidence. Historical M10D.5 5,649 assertions and M10D.6B results remain
HISTORICAL_VERIFICATION; neither is a new M10D.6C suite run.

Existing guides inspected: mechanics, vector fields, dynamical systems,
trajectory statistics and atomistics. Existing reusable notebooks inspected:
function analysis, derivative convergence, multivariable analysis and vector
fields. The new curriculum explains and verifies focused workflows without
migrating or replacing those guides. The flagship source was read; it remains
canonical and unchanged.

Planned learning path and contract mapping:

| Tutorial | Mathematical model / independent reference | Public contract authority |
|---|---|---|
| calculus | cubic, factored first derivative, central-difference polynomial identity | `src/symbolic.jl`, `src/numerical.jl`, `src/analysis.jl` |
| multivariate | positive quadratic; gradient, Hessian, completed square | `src/multivariate_analysis.jl` |
| vector-calculus | planar rotation and radial gradient; Jacobian/div/curl | vector-field guide, verified notebook and audited API |
| mechanics | one-dimensional oscillator with mass 2, stiffness 8; EL and Hamilton equations | `src/mechanics/core.jl`, `hamiltonian.jl`, mechanics guide |
| normal-modes | canonical two-coordinate stiffness, M=I; symmetric/antisymmetric directions | `src/mechanics/normal_modes.jl`, canonical example |
| odes | unit-frequency harmonic oscillator; cos/sin reference | `src/dynamical_systems/integration.jl` |
| trajectories | stored oscillator observable plus hand-computable five-value series | `src/trajectory/interoperability.jl`, `statistics.jl` |
| atomistics | open 3-4-5 triangle; species-directed pairs | `src/atomistic/core.jl` |
| one-system-many-methods | unchanged canonical model and modal superposition | `examples/integration/one_system_many_methods.jl` |

Core routes above are stable, per the unchanged export audit. ScientificDataset
and qualified scientific_metadata/scientific_origin in the capstone remain
experimental. No optional extension packages or heavy learning are planned.
Exactly 32 symbolic variables pass the scalar-field guard; no large symbolic
construction or dense eigensolve is planned. Full suite, optional training,
installation/resolve, Documenter, Wiki publication and later milestones are
excluded. C2–C5 require persisted actual evidence before closure.

## C2: scalar and field tutorials

Created three complete pages and identical supporting scripts. Executed
`PYTHONDONTWRITEBYTECODE=1 python3 reports/m10d6/tutorial_check.py run C2`.
The runner records each exact published Julia command, runtime probe, log hash,
source hash, exit and completion marker in `tutorial_verification.json`.
All three final commands exited 0. Calculus recovered the two analytical roots,
checked symbolic/AD derivatives and a finite-difference reference; multivariate
verified exact gradient/Hessian and stationary classification; planar fields
verified Jacobian/divergence/curl and the radial potential.

One initial tutorial assertion failed: it incorrectly expected `:minimum` instead
of the source-defined `:minimum_candidate`. The original failed execution/log is
preserved under previous_attempts; targeted source inspection confirmed the actual
classification contract. Only the tutorial assertion changed. The corrected
script passed; the unchanged successful calculus execution was reused by hash.
No scientific runtime change or canonical-suite run occurred.

## C3: mechanics, modes and ODEs

Created three complete pages and matching scripts; executed the C3 runner.
All three commands exited 0. Mechanics checked exact EL residuals, mass 2,
canonical momentum 2v, Hamiltonian p²/4+4q² and Hamilton flow.
Modes checked the canonical 2×2 system against independent symmetric/antisymmetric
directions at 1e-12; frequencies 1 and sqrt(3), residual 0 and mass orthogonality
discrepancy 2.220446049250313e-16. ODEs retained 84 samples despite 17 requested
stops; maximum saved-state reference discrepancy 1.7564838472594602e-12 and
interpolated query discrepancy 8.177902799388903e-13 both passed 1e-8.
Actual commands, source/log hashes and output are persisted in the manifest.
No optional extension, large solve or full suite was executed.

## C4: stored observations, atomistics and capstone

Created three complete pages and scripts plus the learning-path index. C4 executed
all three scripts and the unchanged canonical example's published direct command;
all exited 0. Trajectories reused the ODE implementation and checked the stored
mean against cosine at the identical saved times (error 5.583311590839912e-13
at tolerance 1e-8). The independent five-value fixture verified mean 3,
sample variance 2.5, prefix means and unavailable standard error.
Unitful triangle geometry returned ordered 3/4/5-nm distances and the correct
A-to-B pairs, checked ownership and a three-pair output refused under max_pairs=2.
The capstone newly retained 321 points, passed 12 comparisons, and observed state
reference discrepancy 4.335370951125128e-11 under 2e-8. No optional AML extensions
were loaded. The old README figure is reused unchanged and explicitly historical,
not rerendered. ScientificDataset/origin inspection stays experimental.

The index links the existing optional projects; their declarations were inspected,
not installed or run. All new commands refer only to the root project. One README
navigation line was added after the target pages existed. C5 will verify snippets,
links, protected files and the scoped candidate before the authorized local commit.

## Public APIs and maturity

The unchanged `exports.json` supplies the classification; this tutorial collection
does not promote an experimental overload through a stable generic name.

- Scalar/field calculus (stable): `analyze`, `evaluate`, `compare_derivatives`,
  `gradient`, `hessian`, `domain_contains`, `jacobian`, `divergence`, `curl`, `potential`.
- Mechanics/modes (stable): `LagrangianSystem`, `generalized_momenta`,
  `velocity_hessian`, `euler_lagrange`, `energy_function`, `legendre_transform`,
  `hamilton_equations`, `linearize_mechanics`, `normal_modes`, `dynamics`, `energy_drift`.
- Stored trajectories/statistics (stable): `FirstOrderODE`, `trajectory`,
  `observable_series`, `ObservableSeries`, `statistical_summary`, `running_statistics`.
- Particle data (stable): `AtomisticSnapshot`, `pair_distances`.
- Capstone dataset (experimental): `ScientificDataset`, through the unchanged
  canonical implementation and its explicit schema.
- Qualified `AnalyticMathLab.scientific_origin` (experimental) is exercised by
  the canonical example. `scientific_metadata` is identified as experimental in
  navigation/related material but is not a new tutorial runtime demonstration.

Public signatures and return shapes were resolved before writing the relevant
code, except for the initial classification-label mistake recorded above.
PropertyResult remains exactly value/status/method/notes; no fields, APIs,
global memory setter, sparse eigensolver or generic PDE solver were invented.

## Execution environment and exact commands

EXAMPLE_EXECUTED: Julia **1.12.7**, selected explicitly by Juliaup, on Linux.
Actual active project:
`/home/lorenzozm/PROJETOS/analyticmath-lab/Project.toml`.
AML 0.1.0; Symbolics 7.39.2. The unchanged root Project and Manifest and existing
depot were used. No Pkg resolution, installation, update or optional-environment
activation occurred. Other Juliaup channels (including release 1.13.1) were not used.

The runner used `JULIA_LOAD_PATH=@:@stdlib`, `JULIA_NUM_THREADS=1`,
`OPENBLAS_NUM_THREADS=1`, `JULIA_PKG_PRECOMPILE_AUTO=0`. Each gate had a 240-second
timeout and ran sequentially in a fresh Julia process. Its separate runtime probe
used `--startup-file=no`, verified VERSION and Base.active_project, and loaded
AML/Symbolics/LinearAlgebra. Scientific commands below are the literal published
commands (including the same working directory); all final commands exited 0.
The published commands do not disable a user's startup file. This evidence is
for the recorded host, not a promise that an arbitrary custom startup is harmless;
restricted LOAD_PATH prevents global package fallback in the verification runs.

    julia +1.12.7 --project=. docs/tutorials/scripts/calculus.jl
    julia +1.12.7 --project=. docs/tutorials/scripts/multivariate.jl
    julia +1.12.7 --project=. docs/tutorials/scripts/vector_calculus.jl
    julia +1.12.7 --project=. docs/tutorials/scripts/mechanics.jl
    julia +1.12.7 --project=. docs/tutorials/scripts/normal_modes.jl
    julia +1.12.7 --project=. docs/tutorials/scripts/odes.jl
    julia +1.12.7 --project=. docs/tutorials/scripts/trajectories.jl
    julia +1.12.7 --project=. docs/tutorials/scripts/atomistics.jl
    julia +1.12.7 --project=. docs/tutorials/scripts/one_system_many_methods.jl
    julia +1.12.7 --project=. examples/integration/one_system_many_methods.jl

Orchestration and integrity checks actually used:

    PYTHONDONTWRITEBYTECODE=1 python3 reports/m10d6/tutorial_check.py run C2
    PYTHONDONTWRITEBYTECODE=1 python3 reports/m10d6/tutorial_check.py run C3
    PYTHONDONTWRITEBYTECODE=1 python3 reports/m10d6/tutorial_check.py run C4
    PYTHONDONTWRITEBYTECODE=1 python3 reports/m10d6/tutorial_check.py static
    git diff --check

The C2 command had one initial failure followed by the corrected successful run.
Hash-matched successful gates are reused, not rerun unnecessarily. The ten final
scientific commands all have script hash, completion marker, real exit, observed
stdout and external log hash in `tutorial_verification.json`. Original execution
logs and the failed initial log are retained under
`/home/lorenzozm/.hermes/logs/analyticmath-lab/m10d6c/`.
The ODE is intentionally executed again when included by the independent
trajectories workflow; the capstone wrapper and canonical CLI are two explicitly
different published entry points, not double-counted test-suite assertions.

There are 99 authored `@assert` statements across nine new scripts. Each final
script executed its assertions. This is a count of statements in the tutorials,
not a Test.jl test total or a canonical-suite rerun. The unchanged capstone also
checks twelve explicit cross-method agreements.

## Models, independent references, observations and tolerances

| Lesson | Independent reference / mathematical justification | Actual observed result | Acceptance metric |
|---|---|---|---|
| calculus | differentiated cubic; factorization 3(x-1)(x-3); exact centered-stencil identity -3+h² | f(2)=3; symbolic/AD=-3; central=-2.9999999998139817; h=1/8 stencil=-2.984375 | symbolic zero differences; root/value max absolute differences ≤1e-10; symbolic/AD ≤1e-12, central ≤1e-7, explicit stencil ≤1e-12 |
| multivariate | direct gradient/Hessian; principal minors 2,7; completed square | gradient(1,2)=[4,9], Hessian=[2 1;1 4], f(1,2)=11; rational origin; established exact_linear_system | exact symbolic zero differences and exact small evaluations/classification contract |
| vector-calculus | differentiate rotation components; radial gradient potential | J=[0 -1;1 0], div=0, planar curl=2; rotation potential unknown; radial potential x²+y² | exact matrix/identity checks and evidence statuses |
| mechanics | direct differentiation of L=v²-4q²; invert p=2v | mass=2; EL=2a+8q; H=p²/4+4q²; Hamilton flow [p/2,-8q]; established transform | exact symbolic zero differences, ordering and matrix checks |
| normal-modes | multiply K by independent symmetric/antisymmetric directions | eigenvalues [1,3]; frequencies [1,1.7320508075688772]; eigenpair residual 0; orthogonality discrepancy 2.220446049250313e-16 | max-entry errors ≤1e-12; reference multiplication ≤1e-14; compare directions modulo sign |
| odes | cos(t),-sin(t), differentiated and initial conditions checked mathematically | 84 samples; 17 requested stops; 83 accepted,2 rejected; saved-state discrepancy 1.7564838472594602e-12; interpolation discrepancy 8.177902799388903e-13 at t=.37 | entrywise max errors ≤1e-8; all requested times present; labels/shape/time order checked |
| trajectories | mean of cos at actual stored times; independent fixture [1,2,3,4,5] | mean .4356053310345854 versus .4356053310351437; difference 5.583311590839912e-13; fixture mean 3, variance 2.5, prefix means [1,1.5,2,2.5,3] | reference-mean discrepancy ≤1e-8; fixture moments/prefixes ≤1e-12; exact stored selection/time alignment; SE nothing |
| atomistics | Euclidean coordinate differences and 3-4-5 Pythagorean triangle | ordered pairs (1,2),(1,3),(2,3); 3/4/5 nm; selected A-B pairs (1,3),(2,3); limited-output unknown | exact representable Unitful geometry/order; own-copy isolation; unknown value nothing |
| capstone | independent two-mode cos/sin superposition; analytical energy .035 | 321 samples; 12 agreements; state discrepancy 4.335370951125128e-11; energy-oracle discrepancy 1.0833993424608224e-11 | full saved-state max-entry error ≤2e-8; energy ≤2e-9; default algebra/modal comparisons 1e-13; dataset selection exactly identical |

Additional newly observed capstone metrics: sampled energy drift
1.083398648571432e-11, Hamiltonian energy discrepancy 6.938893903907228e-18,
Hamilton flow discrepancy 0, mode residual 0, mass orthogonality discrepancy
2.220446049250313e-16. These are example observations, not universal guarantees.
All comparisons in the unchanged canonical CLI logged agreement true.

EXACT_IDENTITY and ANALYTICAL_REFERENCE are mathematical derivations explained
on the pages. Symbolic checks exercise agreement with those explicit independent
expressions; AML is not the sole oracle for itself. NUMERICAL_COMPARISON measures
finite agreement at stated points, not proof or certified global error. Mathematical
circulation/topology examples are analytical explanation, not falsely advertised
executed AML line-integral functionality. SOURCE_INSPECTED guard/memory/negative-mode
contracts are clearly distinguished from newly executed small examples.

## Dependencies, integrations and scientific boundaries

Direct tutorial imports are exclusively AML itself and declared root dependencies:
Symbolics, LinearAlgebra, Unitful. Included scripts' dependencies are explicit;
the canonical example imports AML, Symbolics and LinearAlgebra. No Test dependency
or global package is needed for the tutorial scripts. AML internally supplies its
declared ForwardDiff, FiniteDiff, SciMLBase and OrdinaryDiffEqTsit5 integrations.
Optional AML extension absence is explicitly asserted after capstone execution.

The index lists the already declared Molly/inference/operators/PINN example
projects with their actual trigger packages. A bounded parent review corrected
the draft learned-dynamics environment link from scaling (which has no Lux or
Optimization) to inference (which declares both). Those optional projects were
source-inspected only; no training or optimizer claims are based on them.
The existing one-step flagship learning branch is linked, not run.

The README PNG is byte-unchanged and carries HISTORICAL_VERIFICATION from M10D.6B.
No new plot was generated, no backend activated and no figure reproduction block
republished as new executable code. The capstone references the existing README
instructions. Actual numerical capstone metrics were rerun and are newly observed.

Conventions preserved: (x,y) derivative ordering; component-row/variable-column
Jacobians; q/v versus q/p distinction; canonical oscillator parameters/amplitudes;
dimensionless oscillator times; particle-major Cartesian ordering; actual Unitful
length/mass/time dimensions in the triangle; unknown generic unitless descriptors;
stored-only observable extraction; unweighted descriptive moments with no IID SE.
Provenance is ancestry, not value equality or independent-reference truth.

## Known limitations, failures and deliberately skipped checks

- One corrected tutorial-only classification assertion failed initially; the red
  log and old source hash are preserved. No unresolved mandatory execution failure.
- The old checkout Manifest freshness warning remains a historical installation
  finding. Instantiate/resolve and cold-depot or consumer installations were not
  performed here; no package dependency constraints or lockfiles changed.
- Full 5,649-test canonical, optional integration suites, ML training, optimization,
  Monte Carlo, large Hessians/spectra, stress benchmarks, other versions/platforms,
  new rendering, Documenter, deployment, Wiki, releases and later milestones were
  intentionally skipped. This milestone verifies tutorial-sized scientific gates.
- Exactly 32 symbolic variables pass a guard; no large symbolic capability is
  inferred. Normal modes remain full dense even with sparse input; byte estimates
  do not cap RSS, and adapter allocations can precede preflight. No partial-mode
  API is invented. Pair-distance output is bounded, not universal streaming.
- Solver saved histories can exceed requested stops; interpolation is a numerical
  approximation. No physical diffusion, global nonlinear stability, arbitrary
  domain potential, statistical uncertainty or physical validity is certified.
- Experimental dataset/metadata coverage is intentionally narrow. Training loss
  is not a guarantee of generalization, a physically meaningful measurement or
  PDE correctness. Recorded units/provenance are not automatic certification.
- Verification helper logs/snapshot paths refer to this local host. Published
  scientific scripts do not require those logs. The committed manifest retains
  observations and hashes; maintainers rerunning the helper need their local
  evidence directory, while tutorial calculations are independently runnable.

## Files created or changed

Only the following 23 milestone paths belong in the local commit:

    README.md
    docs/tutorials/index.md
    docs/tutorials/calculus.md
    docs/tutorials/multivariate.md
    docs/tutorials/vector-calculus.md
    docs/tutorials/mechanics.md
    docs/tutorials/normal-modes.md
    docs/tutorials/odes.md
    docs/tutorials/trajectories.md
    docs/tutorials/atomistics.md
    docs/tutorials/one-system-many-methods.md
    docs/tutorials/scripts/calculus.jl
    docs/tutorials/scripts/multivariate.jl
    docs/tutorials/scripts/vector_calculus.jl
    docs/tutorials/scripts/mechanics.jl
    docs/tutorials/scripts/normal_modes.jl
    docs/tutorials/scripts/odes.jl
    docs/tutorials/scripts/trajectories.jl
    docs/tutorials/scripts/atomistics.jl
    docs/tutorials/scripts/one_system_many_methods.jl
    reports/m10d6/tutorial_check.py
    reports/m10d6/tutorial_implementation_report.md
    reports/m10d6/tutorial_verification.json

No source, extensions, tests, original examples/notebooks, dependency files,
existing M10D.6A/B evidence or historical reports belong in the candidate.

## C5: cross-tutorial validation and bounded review

The static check passed: ten Markdown tutorial pages including the index, nine
complete Julia blocks byte-identical to nine executed scripts, and ten successful
published scientific commands (the extra command is the unchanged canonical CLI).
Real execution establishes Julia syntax as well as calculation success. Imported
packages are declared, included dependencies are explicit, and final executable
hashes match successful execution records. No hidden REPL state is required.

Link validation covered all ten tutorial pages, README and this report: 143
relative-link occurrences, 74 unique relative targets, zero missing paths or
README heading anchors. No Documenter/Wiki/deployment links were invented.
The README remains 302 lines; removing the one new navigation line reproduces the
starting README byte-for-byte, including every previously verified code block.

All **442 protected tracked starting paths** other than README retain SHA-256
equality with the C1 snapshot. That broader preservation set includes every
scientific source, extension, test, dependency file, existing canonical example,
notebook, M10D.6A/B artifact and historical report. This is file integrity, not a
repeat of the repository-wide semantic audit. The ignored pre-existing outputs
and other local data were not removed or incorporated into the commit.

A bounded parent review, not independent subagent approval, inspected the staged
README change, complete script/helper diffs, and educational Markdown prose.
Repeated Julia blocks were verified against those scripts rather than reviewed
as different implementations. It compared equations, ordering, units, outputs,
tolerances, source-derived restrictions and experimental classifications with the
consulted inventory and actual logs. The two draft findings (classification label
and optional environment link) are resolved as recorded above. The reused PNG was
also visually inspected: complete dimensionless axes, q1/q2/v1/v2 legend, explicit
solid-numerical/dashed-analytical title, no clipping. It remains a historical render.
No unresolved scientific or documentation blocker was found.

Candidate checks found exactly the 23 listed paths, no unexpected generated files,
no file over the 200,000-byte audit threshold, and zero high-confidence credential
findings. The explicit staged candidate passed `git diff --cached --check`.
Final index equality/security and committed-blob read-back are recorded in the
external ledgers below. All scoped gates must remain passing for final closure.

## Commit identity, final Git status and completion boundary

Authorized subject:
`[m10d] Complete M10D.6C executable scientific tutorials`.
One local milestone commit only; no push, tag, release, registry action or version
change. A containing commit cannot store its own full SHA in its candidate files.
Resolve it from the actual repository, rather than inventing a future hash:

    git log -1 --format=%H -- reports/m10d6/tutorial_implementation_report.md

The definitive full SHA, parent (the starting commit), subject, branch, changed
paths, candidate/index/committed blob equality, protected-file checks and actual
post-commit working-tree status are persisted outside the self-referential commit:

    /home/lorenzozm/.hermes/logs/analyticmath-lab/m10d6c/candidate_audit.json
    /home/lorenzozm/.hermes/logs/analyticmath-lab/m10d6c/commit_readback.json

The in-commit manifest deliberately stops at PRE_COMMIT_VERIFIED. C5 and the
milestone close only when the read-back ledger actually reports VERIFIED_COMPLETE,
the intended subject/parent and exact 23-file scope on main, matching committed
blobs, and an empty `git status --porcelain`. Until then no commit success or clean
final tree is claimed by this immutable report. The final response supplies the
actual resolved SHA/status after that read-back. This separation preserves an
honest execution-to-commit evidence chain without a second metadata-only commit.

Next authorized planning target: M10D.6D — Public API Reference, only after
separate authorization. No M10D.6D implementation began in this milestone.
