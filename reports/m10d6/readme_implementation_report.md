# M10D.6B — README and first experience implementation report

Status: mandatory documentation, installation, example and rendering acceptance
VERIFIED. B1–B3 are complete; B4 pre-commit checks are verified, with local commit
identity and post-commit Git state closed by the separate read-back in section 17.
No new canonical-suite pass, release or documentation-site deployment is claimed.

## 1. Initial HEAD and Git status

Expected and observed HEAD: `143b5eecba95b63593457f709b2da3aaa3f91952`,
`[m10d] Complete M10D.6A documentation audit`. Branch: `main`, ahead 1 of
`origin/main`. This continuation began with modified `README.md` and three
untracked files: `reports/m10d6/readme_check.py`, this report, and
`reports/m10d6/readme_verification.json`. These were a recovered incomplete
M10D.6B draft, not unrelated work. No staged or unrelated uncommitted changes
were found. The inherited clean-start/load assertions lacked surviving runtime
logs and were not reused as fresh evidence. The draft was preserved and completed.
No reset, clean, stash, rebase, history rewrite or subagent was used.

Actual origin fetch/push URL:
`https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab.git`.
`git ls-remote origin refs/heads/main` returned
`377a3c45905d0e16dba1fc2adc9d8eb3dcff14ca`.

The HEAD README agrees with `readme_inventory.json`: SHA-256
`abe431002c717ca0f4ad58976f2b87a978e5cd6bb11eed2a6c6a65b46f7ab203`.
The working README is the draft and intentionally differs. Project agrees with
HEAD and audit `coverage.json`: SHA-256
`82f9cb87b2a53dc1a03cc1aeafb0ae55c709d25a9450601c46806102d8178f6b`.
Version remains 0.1.0; Julia compatibility remains `1.12`; MIT license is present.

## 2. Audit artifacts consulted

Under `reports/m10d6/`: `audit_summary.md`,
`documentation_architecture_reconciled.md`, `readme_plan.md`,
`readme_inventory.json`, `api.json`, `exports.json`, `qualified_api.json`,
`scientific_contracts.md`, `resource_controls.json`, `refusal_review.json`, and
`examples_tests_inventory.json`. These were read or parsed selectively for this
README, not re-audited across the repository. `coverage.json` was checked only for
Project's recorded hash. All M10D.6A files remain unchanged.

Also inspected: README, Project, LICENSE, `notebooks/function_analysis.jl`, the
canonical `examples/integration/one_system_many_methods.jl`, its plot helper, and
`test/m10d_flagship.jl`, `test/m10d_flagship_schema.jl`,
`test/m10d_flagship_plots.jl`. Targeted implementation reads:
`src/symbolic.jl:1-51`, `src/numerical.jl:1-90`, `src/analysis.jl:78-90`.
Current implementation outranks historical prose; the reconciled architecture
supersedes the initial proposal, including its index-time diffusion correction.

## 3. README structure before and after

Before at HEAD: 614 lines; milestone chronology, long scalar/domain/convergence
methodology, and multivariate/vector/dynamics material appended after the license.
Installation did not explain an independent consumer's direct Symbolics dependency.

After: 301 lines. Identity/maturity → conceptual workflow → compact capability table
→ URL and checkout/development installation → mathematical Quick Start → integrated
oscillator → genuine scientific visualization → reliability → computational limits
→ exact optional triggers → existing guides/examples → development and MIT/citation
status. GitHub-supported dollar-delimited math replaces draft backslash delimiters.
No badges, unsupported speed claims, invented citation or hypothetical deployed links.

## 4. Key scientific communication decisions

- Workflow stages are conceptual, not a universal object protocol.
- Core/optional availability and stable/experimental API maturity are separate.
- Symbolics is explicitly installed in the independent consumer project.
- The flagship preserves dimensionless parameters, ordered coordinates/velocities,
  canonical momenta and the explicit `p=m*v` conversion. No SI units are invented.
- Its independent analytical modal oracle and numerical dataset reference are
  distinguished; same-model agreement does not imply recorded derivation ancestry.
- Descriptive moments do not establish independent samples or a mean error bar.
- Solver completion, small sampled residual/drift, low loss and numerical agreement
  do not certify mathematical correctness, physical truth or generalization.
- Four-field PropertyResult, scoped statuses, unknown-versus-false/zero, unit labels
  versus conversion and identity versus value equality remain unchanged.
- Qualified experimental metadata/origin interfaces are not presented as exports
  or certification engines. Origin tokens are process-local, not reproducibility hashes.

## 5. APIs used in published examples

Quick Start: `analyze(expression, x)`, `evaluate(report, point)`,
`evaluate(report, point; order=1)`, `compare_derivatives(report, point)`,
`comparison.values` and `comparison.absolute_errors`. All are current exported
stable contracts. `@variables` is imported explicitly from Symbolics.

Linked flagship (unchanged): `LagrangianSystem`, `analyze`, `linearize_mechanics`,
`legendre_transform`, `normal_modes`, `dynamics`, `trajectory`, `observable_series`,
`statistical_summary`, `running_statistics`, `energy_drift`, `AtomisticSnapshot`,
`pair_distances`, `energy_function`, `hamilton_equations`, `gradient`, `hessian`,
and experimental `ScientificDataset`. `AnalyticMathLab.scientific_origin` is used
qualified. Its module-local model/oracle/comparison helpers are not AML exports.

Figure: existing `OneSystemPlots.figures(r)` consumes AML `timeplot`, `energyplot`
and `timeseriesplot` with public Makie overlays. Caller explicitly activates
CairoMakie and saves only the trajectory figure for the README.

## 6. Exact execution commands

Root working directory is `/home/lorenzozm/PROJETOS/analyticmath-lab` unless the
command changes it. The README helper launched each child below, retaining stdout,
stderr, real exit, environment, timestamps and SHA-256 in `readme_verification.json`.
Logs are under `/home/lorenzozm/.hermes/logs/analyticmath-lab/m10d6b/`.

Exact README blocks were extracted using:

    python3 reports/m10d6/readme_check.py extract BLOCK DESTINATION

`BLOCK` and the concrete extracted paths/hashes are recorded in
`readback_evidence.executed_snippets`. All five extracted installation/Quick Start/
figure blocks match the final README bytes. The flagship shell command was run
directly; the full-suite block was deliberately not run. The Quick Start verifier
includes that unchanged block, then asserts f(2)=3, f'(2)=-3, matching symbolic/AD
values, AD discrepancy zero, central discrepancy below 1e-8, and exactly the four
PropertyResult fields. Its actual source is preserved outside the repository in
`reproduction/verify-quick-start.jl` beside the execution logs.

### root-load — exit 0

Working directory: `/home/lorenzozm/PROJETOS/analyticmath-lab`. Log: `root-load.log`.

```sh
julia +1.12.7 --startup-file=no --project=. -e 'println("Julia: ", VERSION); println("Project: ", Base.active_project()); println("Depot: ", first(DEPOT_PATH)); using AnalyticMathLab; println("AML: ", pkgversion(AnalyticMathLab)); println("Path: ", pathof(AnalyticMathLab)); println("AML_LOAD_OK")'
```

### consumer-install — exit 0

Working directory: `/home/lorenzozm/PROJETOS/analyticmath-lab`. Log: `consumer-install.log`.

```sh
env JULIA_LOAD_PATH=@:@stdlib JULIA_PKG_PRECOMPILE_AUTO=0 JULIA_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 sh -c 'cd /home/lorenzozm/.hermes/cache/scratch/aml-m10d6b-e29h6ryq && julia +1.12.7 --startup-file=no consumer-install.jl'
```

### quick-start-local — exit 0

Working directory: `/home/lorenzozm/PROJETOS/analyticmath-lab`. Log: `quick-start-local.log`.

```sh
env JULIA_LOAD_PATH=@:@stdlib JULIA_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 julia +1.12.7 --startup-file=no --project=. /home/lorenzozm/.hermes/cache/scratch/aml-m10d6b-e29h6ryq/verify-quick-start.jl
```

### quick-start-consumer — exit 0

Working directory: `/home/lorenzozm/PROJETOS/analyticmath-lab`. Log: `quick-start-consumer.log`.

```sh
env JULIA_LOAD_PATH=@:@stdlib JULIA_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 julia +1.12.7 --startup-file=no --project=/home/lorenzozm/.hermes/cache/scratch/aml-m10d6b-e29h6ryq/aml-first-run /home/lorenzozm/.hermes/cache/scratch/aml-m10d6b-e29h6ryq/verify-quick-start.jl
```

### checkout-install — exit 0

Working directory: `/home/lorenzozm/PROJETOS/analyticmath-lab`. Log: `checkout-install.log`.

```sh
env JULIA_LOAD_PATH=@:@stdlib JULIA_PKG_PRECOMPILE_AUTO=0 JULIA_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 sh -c 'cd /home/lorenzozm/.hermes/cache/scratch/aml-m10d6b-e29h6ryq && sh checkout.sh'
```

### local-develop — exit 0

Working directory: `/home/lorenzozm/PROJETOS/analyticmath-lab`. Log: `local-develop.log`.

```sh
env JULIA_LOAD_PATH=@:@stdlib JULIA_PKG_PRECOMPILE_AUTO=0 JULIA_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 julia +1.12.7 --startup-file=no -e 'include("/home/lorenzozm/.hermes/cache/scratch/aml-m10d6b-e29h6ryq/local-develop.jl"); include("/home/lorenzozm/.hermes/cache/scratch/aml-m10d6b-e29h6ryq/verify-quick-start.jl")'
```

### flagship — exit 0

Working directory: `/home/lorenzozm/PROJETOS/analyticmath-lab`. Log: `flagship.log`.

```sh
env JULIA_LOAD_PATH=@:@stdlib JULIA_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 julia +1.12.7 --project=. examples/integration/one_system_many_methods.jl
```

### figure — exit 0

Working directory: `/home/lorenzozm/PROJETOS/analyticmath-lab`. Log: `figure.log`.

```sh
env JULIA_LOAD_PATH=@:@stdlib JULIA_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 julia +1.12.7 --project=. -e 'include_string(Main, read("/home/lorenzozm/.hermes/cache/scratch/aml-m10d6b-e29h6ryq/figure.jl", String), joinpath(pwd(),"README.md")); println("Julia: ", VERSION); println("Project: ", Base.active_project()); println("CairoMakie: ", pkgversion(CairoMakie)); println("FIGURE_RENDERED ", filesize("docs/assets/readme/coupled_oscillator.png")); ax = OneSystemPlots.Makie.content(figures.trajectory[1,1]); println("PLOT_LABELS ", (title=ax.title[], xlabel=ax.xlabel[], ylabel=ax.ylabel[])); @assert ax.xlabel[] == "t [dimensionless]"; @assert ax.ylabel[] == "q, v [dimensionless]"; println("FIGURE_ASSERTIONS_OK")'
```

### focused-flagship — exit 0

Working directory: `/home/lorenzozm/PROJETOS/analyticmath-lab`. Log: `focused-flagship.log`.

```sh
env JULIA_LOAD_PATH=@:@stdlib JULIA_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 julia +1.12.7 --startup-file=no --project=. -e 'include("test/m10d_flagship.jl"); include("test/m10d_flagship_schema.jl"); println("FOCUSED_FLAGSHIP_COMPLETE")'
```

### quick-start-clone — exit 0

Working directory: `/home/lorenzozm/PROJETOS/analyticmath-lab`. Log: `quick-start-clone.log`.

```sh
env JULIA_LOAD_PATH=@:@stdlib JULIA_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 julia +1.12.7 --startup-file=no --project=/home/lorenzozm/.hermes/cache/scratch/aml-m10d6b-e29h6ryq/analyticmath-lab /home/lorenzozm/.hermes/cache/scratch/aml-m10d6b-e29h6ryq/verify-quick-start.jl
```

The figure command uses `include_string` with the README root filename so relative
`include` behaves as in the documented root REPL, not relative to the extracted
scratch file. This changes no code within the README block. Backend activation
and output saving are explicit caller actions. No existing example was modified.

## 7. Julia version and environments

Actually executed: Julia 1.12.7, Linux 7.0.0-38-generic, x86_64. Juliaup's moving
release channel lists 1.13.1, which was not used or certified.

- Checkout: root Project and unchanged committed Manifest, AML 0.1.0 resolved to
  this repository's source. Flagship, focused tests and rendering use this environment.
- URL consumer: separately activated `aml-first-run` under the recorded scratch
  directory, with only AML and Symbolics as explicit direct dependencies.
- Local development: `Pkg.activate(temp=true)` selected
  `/home/lorenzozm/.hermes/cache/scratch/jl_AeNIis/Project.toml`; `Pkg.develop(path=pwd())`
  resolved to this checkout. This environment is session-specific.
- Fresh clone: separately cloned remote baseline and its committed Manifest;
  instantiate and Quick Start both succeeded, clone worktree remained clean.

| Dependency | Checkout | Fresh URL consumer |
|---|---|---|
| Symbolics | 7.39.2 | 7.45.0 |
| CairoMakie | 0.15.14 | 0.15.15 |
| Makie | 0.24.14 | 0.24.15 |
| SciMLBase | 3.54.0 | 3.57.0 |
| OrdinaryDiffEqTsit5 | 2.1.4 | 2.1.5 |

The existing `/home/lorenzozm/.julia` depot was reused. Installations disabled Pkg
automatic precompilation; imports really executed and triggered needed package
precompilation. Bounded consumer/scientific gates used `JULIA_LOAD_PATH=@:@stdlib`,
one Julia thread and one OpenBLAS thread; only the initial load used the inherited
process environment. No global fallback dependency import was used for the consumer.
Consumer Project/Manifest hashes are in the manifest, with copies durably preserved
under `reproduction/consumer/` outside the repository. Fresh resolution is not an
identical-dependency claim; retaining the consumer Manifest makes its versions explicit.

## 8. Actual execution results

Every one of the 10 recorded runtime/install gates exited 0. Four Quick Start
routes (root, independent URL consumer, developed checkout, fresh clone) emitted
`QUICK_START_ASSERTIONS_OK` with:

    f(2) = 3.0
    evaluated symbolic derivative = -3.0
    automatic derivative = -3.0
    central derivative = -2.9999999998139817
    AD absolute discrepancy = 0.0
    central absolute discrepancy = 1.8601831186515483e-10

Flagship: 321 saved samples on the exact declared grid, all 12 compatibility-scoped
comparisons agreed. Observed metrics:

    maximum state discrepancy = 4.335370951125128e-11
    maximum sampled energy drift = 1.083398648571432e-11
    analytical energy discrepancy = 1.0833993424608224e-11
    Hamiltonian energy discrepancy versus sampled energy = 6.938893903907228e-18
    Hamiltonian flow discrepancy = 0.0
    mode residual = 0.0
    mass-orthogonality discrepancy = 2.220446049250313e-16
    angular frequencies = [1.0, 1.7320508075688772]
    analytical model energy = 0.035

Focused existing tests: canonical definition 10/10, mechanics-to-investigation
180/180, detached dataset schema 7/7; parsed total 197 passing assertions,
zero failures/errors, exit 0 and `FOCUSED_FLAGSHIP_COMPLETE`.
This is not a new canonical-suite pass. Property leaf ancestry remains unknown,
statistics' standard errors remain unavailable, and dataset references stay numerical.

## 9. Installation verification scope

INSTALLATION_VERIFIED: exact URL install plus direct Symbolics dependency, exact
clone/instantiate block, and temporary local development block. Loading and
Quick Start were exercised afterward, not inferred from successful resolution.
The URL consumer's `git-tree-sha1` is
`1d2925c160b46d6043f0e18c52ce8a95705d046e`, matching cloned remote commit
`377a3c45905d0e16dba1fc2adc9d8eb3dcff14ca`. All 241 tracked source/extension/test/
example/notebook files in the installed package match the local immutable snapshot.
This scoped executable equality is not whole-repository revision identity.

The URL did not install the unpushed local documentation commits. No push was
performed to enable installation. No General Registry availability is claimed or
required. Cached-depot installation does not establish a cold download on every
network, host or platform. Local consumer dependency files, not repository files,
were resolved. The clone's instantiate emitted a nonfatal project/manifest freshness
warning; it exited 0 and its Quick Start subsequently passed with the committed lockfile.

## 10. Figure generation, interpretation and provenance

FIGURE_RENDERED: `docs/assets/readme/coupled_oscillator.png`, 1200 × 900 PNG,
161,521 bytes, SHA-256
`8e637c99d0a2395fdc8c1638a7d38a25342d7b48abb8fe5817b48ef3d24e0d1b`.
Source: unchanged canonical `investigate()` and unchanged plot helper, invoked by
the exact README figure block. CairoMakie 0.15.14 was explicitly activated only in
that rendering process. No synthetic data, globally selected backend or figure
from an optional learned approximation was substituted.

Programmatic assertions checked axis labels. The actual PNG was loaded and
visually inspected: complete readable title, t [dimensionless], q/v [dimensionless],
q1/q2/v1/v2 color legend, full sampling interval and no clipping. Dashed independent
analytical overlays nearly coincide with solid numerical curves at this scale;
the title/caption state the line convention and the caption explains the overlap.
The figure does not show error bars or prove physical validity. The helper also
constructs energy/distance views, but those are not committed README assets.

## 11. Link, source-path and SHA-256 validation

Executed:

    PYTHONDONTWRITEBYTECODE=1 python3 reports/m10d6/readme_check.py evidence /home/lorenzozm/.hermes/cache/scratch/aml-m10d6b-e29h6ryq
    PYTHONDONTWRITEBYTECODE=1 python3 reports/m10d6/readme_check.py static
    git diff --check

Results: no broken relative Markdown links or README anchors: 26 occurrences,
25 unique targets. Both linked integration source paths exist. Seven marked code
blocks are extracted deterministically; five executed extracted blocks match their
README hashes. The flagship command is separately executed; full-suite block is
explicitly skipped. The PNG signature, dimensions, size and hash are validated.
All 438 protected baseline paths retain their SHA-256; Git baseline diffs also
exclude protected-file changes. All 10 real execution log hashes and exits agree.
This is targeted milestone preservation, not a rerun of M10D.6A's semantic audit.
Final candidate/index checks are part of the external finalization ledger in section 17.

## 12. Stable/experimental capability classification

Unchanged audit ownership: F01–F25 stable mathematical/scientific analysis families;
F26–F34 experimental PINN/inference/learning/dataset/scaling/generalization families;
F35 stable view names, with payload maturity inherited separately; F36 internal.
Qualified metadata/origin remain two additional experimental interfaces, not exports.
The README table does not enumerate or reclassify all exports.

Exact extension triggers from unchanged Project:
Molly; Optimization for inference; Lux + Optimization for learned dynamics;
Lux + Optimization + NeuralOperators for surrogates/operators (including plain Lux
surrogates); Lux + NeuralPDE + ModelingToolkit + Optimization +
SymbolicIndexingInterface for PINNs. All trigger packages must be loaded; activation
alone does not supply scientific models, AD choices, optimizers or data assumptions.

## 13. Scientific limitations represented

Scalar-field symbolic analysis accepts exactly 1–32 ordered variables; 3000 symbolic
variables are outside that path. A supplied 3000-square matrix is a different dense
modal route, not a symbolic Hessian capability. Sparse input still uses dense full
spectra; no generic sparse-Hessian/HVP/matrix-free/partial-mode API is advertised.
`normal_modes(...; max_memory_bytes=...)` and `pair_distances(...; max_bytes=...)`
are operation-specific byte estimates, not global memory/RSS guarantees. Adapter
allocations may precede modal preflight. Checked Float64 boundaries are distinct
from generic scalar arithmetic. Caller domain/order/scales/sampling remain explicit.
Eligible index-time MSD is numerically accepted by diffusion fitting; a physical
coefficient needs justified time-scale and fit-window assumptions, not a claimed
nonexistent direct physical-time refusal. These restrictions are SOURCE_INSPECTED
from the unchanged audit, not newly exercised large-dimension/transport stress gates.

## 14. Unresolved findings and skipped checks

- Nonfatal checkout Manifest freshness warning: dependency/environment owner
  follow-up, not repaired in this documentation-only milestone. Do not run a
  dependency upgrade as part of README completion.
- The audit's known source-recovery wording and adapter preflight caveats remain
  their owning scientific follow-ups; this milestone represents rather than fixes them.
- Documenter reference and Wiki remain later authorized milestones. No infrastructure
  or publication began, and no future URL is presented as deployed.
- Skipped explicitly: full 5,649-test canonical, optional learning/training/stacks,
  stress benchmarks, Julia 1.13.1/other versions/platforms, empty-depot installation,
  and standalone optional plot test file. The README figure itself was executed and
  inspected instead. No Documenter build or Wiki publication was attempted.
- No runtime defect was discovered in the executed examples. No mandatory gate failed.

## 15. Files changed

Only authorized candidates:

- `README.md`
- `docs/assets/readme/coupled_oscillator.png`
- `reports/m10d6/readme_check.py`
- `reports/m10d6/readme_implementation_report.md`
- `reports/m10d6/readme_verification.json`

The helper is a bounded README verification tool, not a scientific runtime API.
Source, extensions, tests, existing examples/notebooks, Project/Manifest, license,
M10D.6A artifacts and historical reports are byte-unchanged. No unrelated files,
new model, dependencies, API dispatch or result layout are included.

## 16. Final verification and checkpoints

SOURCE_INSPECTED: mandatory audit handoff and targeted current implementation.
EXAMPLE_EXECUTED: exact Quick Start, numerical assertions, core flagship and
197 focused assertions. FIGURE_RENDERED: actual CairoMakie PNG plus visual review.
INSTALLATION_VERIFIED: separate URL, clone and local development routes with the
revision/depot limits above. HISTORICAL_CANONICAL: prior M10D.5's 5,649 assertions
on recorded Julia 1.12.7 are historical evidence only; M10D.6A ran no science.

B1 repository/audit/outline, B2 install/Quick Start and B3 flagship/rendering were
persisted after their real evidence existed. B4 pre-commit validation checks the
final README/snippet/log/protected-file hashes, links and this report. A bounded
parent review (not independent subagent approval) compared every final README
section against the cited audit, source, executed outputs and the unchanged Project
extension sets. It found no unsupported public/scientific claim. Security/size,
staged equality, final commit and Git read-back are recorded separately below.
No subagent, canonical rerun, optional training or later milestone was launched.

## 17. Commit identity and final Git status

Local commit subject: `[m10d] Complete M10D.6B README and first experience`.
The immutable report cannot embed the SHA of its own containing commit. Resolve
that full SHA from the repository using:

    git log -1 --format=%H -- reports/m10d6/readme_implementation_report.md

The definitive actual commit hash, parent, subject, exact changed paths, committed
blob hashes, post-commit `git status` and ahead/behind count are recorded outside
this self-referential candidate at:
`/home/lorenzozm/.hermes/logs/analyticmath-lab/m10d6b/commit_readback.json`.
The corresponding pre-commit candidate/security/index checks are in
`/home/lorenzozm/.hermes/logs/analyticmath-lab/m10d6b/candidate_audit.json`.
B4 is closed only when that read-back exists and confirms the actual commit;
the in-commit manifest deliberately records the pre-commit boundary rather than
pretending a future commit was already verified. No push, tag, release, registry
submission or M10D.6C action is performed. M10D.6C requires separate authorization.
