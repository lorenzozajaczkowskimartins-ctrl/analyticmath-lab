# M10D.6D — complete public API reference

Status: PRE-COMMIT VERIFIED. All documentation acceptance gates passed; the
containing milestone commit and clean-tree read-back are identified by the
procedure below, not a self-referential SHA embedded in this file.

## Initial Git state and source authority

Starting HEAD: b327e43485d5d0e06b6fffb537e74a846455dc0b.
Subject: [m10d] Complete M10D.6C executable scientific tutorials.
Branch: main. Initial worktree: clean. Existing origin is the HTTPS GitHub
repository. Read-only ls-remote found remote main at
97d8d13a5fdde467c4e44f406150a98bde9547e9. No fetch/reset/rebase/history rewrite,
push, tag, deployment, registry submission or version change was performed.
The local tracking ref is not a claim about future remote state.

Authority is current implementation, then reconciled M10D.6A contracts, current
scientific semantics, verified examples, and historical prose. Consulted:
audit_summary.md, documentation_architecture_reconciled.md, api.json,
exports.json, qualified_api.json, resource_controls.json, refusal_review.json,
scientific_contracts.md and coverage.json; README, Project.toml and module;
M10D.6B/C reports/manifests, tutorial index and selected existing guides. This
reuses the inventory rather than repeating the 311-file semantic audit.

Selective source resolution checked qualified metadata/origin declarations,
PINN diagnostic dispatch and learned-dynamics fallback behavior. All 58 distinct
audited source hashes still match. All 464 protected tracked baseline files,
including src/ext/test, examples/notebooks/tutorials, root Project/Manifest,
LICENSE and earlier milestone evidence, match baseline Git blobs. README is the
only changed pre-existing file: one navigation line; now 303 lines.

## Isolated environment and reproducible commands

Actual runtime: Julia 1.12.7. Documenter: 1.19.0. AML: unchanged 0.1.0 checkout.
docs/Project.toml declares AML, Documenter, Pkg and TOML. Documenter compatibility
is 1.19; the docs-only Manifest pins the resolved environment. The root Manifest
seed avoided needless scientific dependency upgrades. Registration was normalized
to relative path .. in both docs Project sources and Manifest, not an absolute
machine-specific source or another remote revision. Root dependencies are unchanged.

From repository root, the executed setup is:

```sh
julia +1.12.7 --project=docs -e 'using Pkg; cd("docs") do; Pkg.develop(path=".."); Pkg.instantiate(); end'
```

The normal build command is:

```sh
julia +1.12.7 --project=docs docs/make.jl
```

Actual bounded final command:

```sh
env JULIA_LOAD_PATH=@:@stdlib JULIA_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 julia +1.12.7 --project=docs docs/make.jl
```

Coverage and negative-fixture commands:

```sh
PYTHONDONTWRITEBYTECODE=1 python3 reports/m10d6/reference_check.py --build
PYTHONDONTWRITEBYTECODE=1 python3 reports/m10d6/reference_check.py --self-test
```

The metadata-only inspection command is:

```sh
env JULIA_LOAD_PATH=@:@stdlib JULIA_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 julia +1.12.7 --project=docs docs/inspect_api.jl /home/lorenzozm/.hermes/logs/analyticmath-lab/m10d6d/symbols.txt
```

The symbol-list input contains the 177 inventory exports and two qualified names.
The probe checks current binding kind, module-local registered docstring presence,
actual concrete field names/outer mutability and isexported. It asserts the
selected runtime and intended checkout. It is not a scientific numerical example.
The builder separately asserts the checkout source and all five AML optional
extensions remain unloaded. Every final command exited 0.

## Documentation architecture and family ownership

The source tree has 17 navigated pages: home, reference index, 14 primary contract
pages and one internal-boundary guide. All 177 names have unique primary owners.
The two qualified experimental interfaces are separate entries in evidence.md.
No F36 internal receives a public entry or supported constructor guarantee.

| Family | Subject | Primary owner | Explicit exports |
|---|---|---|---|
| F01 | Evidence and analysis markers | docs/src/reference/core.md | 2 |
| F02 | Original-expression capture | docs/src/reference/core.md | 2 |
| F03 | Scalar function analysis | docs/src/reference/scalar.md | 5 |
| F04 | Real domains and exact studies | docs/src/reference/scalar.md | 6 |
| F05 | Derivative evidence | docs/src/reference/derivatives.md | 4 |
| F06 | Multivariate scalar fields | docs/src/reference/derivatives.md | 8 |
| F07 | Vector calculus | docs/src/reference/vector.md | 5 |
| F08 | Autonomous systems | docs/src/reference/dynamics.md | 5 |
| F09 | Numerical ODE trajectories | docs/src/reference/dynamics.md | 3 |
| F10 | Lagrangian mechanics | docs/src/reference/mechanics.md | 7 |
| F11 | Hamiltonian mechanics | docs/src/reference/mechanics.md | 6 |
| F12 | Legendre transformation | docs/src/reference/mechanics.md | 1 |
| F13 | Mechanics-to-dynamics bridge | docs/src/reference/mechanics.md | 3 |
| F14 | Linearization and normal modes | docs/src/reference/mechanics.md | 5 |
| F15 | Stored atomistic inputs and adapters | docs/src/reference/atomistic.md | 4 |
| F16 | Snapshot inspection and pair geometry | docs/src/reference/atomistic.md | 4 |
| F17 | Supplied radial potentials | docs/src/reference/atomistic.md | 3 |
| F18 | Distribution and coordination analysis | docs/src/reference/atomistic.md | 3 |
| F19 | Sampling and observables | docs/src/reference/statistics.md | 4 |
| F20 | Descriptive moments | docs/src/reference/statistics.md | 2 |
| F21 | Correlation-aware analysis | docs/src/reference/statistics.md | 4 |
| F22 | Blocking and transient evidence | docs/src/reference/statistics.md | 3 |
| F23 | Particle transport | docs/src/reference/transport.md | 5 |
| F24 | Stored trajectory diagnostics | docs/src/reference/statistics.md | 4 |
| F25 | Compatibility-gated comparisons | docs/src/reference/comparison.md | 6 |
| F26 | PINN construction and training | docs/src/reference/scientific-ml.md | 8 |
| F27 | Sampled PINN diagnostics | docs/src/reference/scientific-ml.md | 4 |
| F28 | Parameter inference | docs/src/reference/scientific-ml.md | 8 |
| F29 | Distance-observation bridge | docs/src/reference/scientific-ml.md | 1 |
| F30 | Learned dynamics | docs/src/reference/scientific-ml.md | 10 |
| F31 | Scientific datasets | docs/src/reference/datasets.md | 3 |
| F32 | Train-only affine scaling | docs/src/reference/datasets.md | 4 |
| F33 | Scientific surrogate and operator learning | docs/src/reference/scientific-ml.md | 5 |
| F34 | Generalization and sampled physics | docs/src/reference/scientific-ml.md | 4 |
| F35 | Scientific views | docs/src/reference/plots.md | 26 |
| F36 | INTERNAL boundaries | docs/src/guides/api-boundaries.md | 0 |

The exact page list is the docs/src Markdown subset of the file list below.
Tutorials were not rewritten, moved or copied into docs/src. Build-only raw
resources preserve their canonical bytes. Their raw Markdown/script download
links work in the generated HTML, without relying on the currently unpublished
M10D.6C remote revision. Full rendered tutorial navigation remains deferred.

## Coverage, dispatch and substantive contracts

REFERENCE_COVERAGE_VERIFIED: 177/177 exports; 130 stable and 47 experimental;
2/2 qualified experimental interfaces; 179 primary entries; no missing,
duplicate, misclassified or conflicting primary owners. The independently
validated manual retains all 196 audited exported-symbol contract variants,
plus both qualified records. Actual bindings include 112 exported generic
functions, 63 exported types/constructors, one abstract type and one macro;
the two qualified interfaces add two generic functions, not two exports.

Each route preserves exact source declaration text, argument order/defaults,
input shape/order, output, refusal/error, numerical, unit, ownership and dependency
content. Every concrete type lists actual stored field names in order. Raw record
construction is distinguished from validated factories and stored inspection.
Entry and contract metadata are checked against structured audit records; heading
counts, empty labels and a successful build are not the coverage oracle.

Eight dispatch maps cover analyze, evaluate, normal_modes, train, predict, plot,
observable_series and loss_breakdown. They retain distinct result shapes,
optional triggers and scientific contracts, with cross-family backlinks.
Backend controls/private forwarding context are explicitly labeled, not promoted
as untyped universal AML overloads or unrestricted native kwargs support.
Qualified evidence pages include the exact current source dispatch declarations,
not a universal metadata/origin fallback.

DOCSTRING_PRESENT is distinct from completeness: 141 module-local registered
bindings among 179 inspected names. One native PropertyResult docstring is displayed
with Documenter's normal @docs mechanism; all names have substantive manual
contracts regardless of docstring presence. No indiscriminate autodocs expose
internals. checkdocs=:none intentionally chooses independent manual coverage,
not a claim of complete docstring inclusion; other warning/error checks stay active.

Seven scratch-only negative fixtures successfully reject missing entries,
duplicate owners, wrong classifications, signature drift, output drift, field
layout drift and wrong ownership. They do not modify scientific files or run the
canonical suite.
The validator ran on Python 3.14.4; the same seven fixtures also passed with
TMPDIR unset and HOME redirected inside scratch, exercising its portable cache
fallback without writing system temporary files or changing the repository.

## Scientific and numerical semantics preserved

- PropertyResult keeps exactly value/status/method/notes; unknown is neither false
  nor zero, and an unrequested diagnostic is not a failed one.
- A marker type or raw record constructor is not scientific certification; immutable
  outer records can contain borrowed mutable payloads.
- Original syntax matters before simplification. FunctionAnalysis evaluate does not
  automatically check original-domain membership; PotentialAnalysis differs.
- Scalar-field analysis accepts 1 through 32 ordered variables. Exactly 32 passes
  the guard, not a symbolic memory/scalability guarantee.
- Velocity and canonical momentum, particle/coordinate/component/sample order,
  physical units and original domains are not interchangeable.
- normal_modes uses dense Float64 full-spectrum computation even for sparse input;
  max_memory_bytes is a scoped estimate, not RSS. Snapshot/mechanical adapters may
  allocate first. No generic sparse-Hessian/HVP/matrix-free/partial-spectrum API.
- pair_distances max_bytes and max_pairs are different preflight/cardinality
  controls, not universal streaming/peak-memory guarantees. No global AML budget.
- saveat, internal steps, adaptive saved history and interpolation are distinct;
  solver success is not a rigorous error bound. Partial solver output is explicit.
- Descriptive means/variance do not establish independent samples or inferential
  uncertainty. Missing standard errors are not zero; sample means need not equal
  continuous-time averages.
- diffusion_estimate accepts eligible index-time MSD numerically. The reference
  corrects older stronger family prose without inventing a physical-clock refusal;
  physical diffusion interpretation still requires justified clock/window assumptions.
- Learned-dynamics guarded missing-extension behavior is described from current
  contracts, not the older inventory's blanket MethodError claim.
- History retention, temporary query chunking, summary output and source-retention
  policies have distinct scopes; none limits all native optimizer/backend memory.
- Local stability, zero curl, low training loss, declared metadata and equal values
  do not imply global stability, global potentials, physical validity or ancestry.
- Qualified metadata/origin inspection remains experimental, scoped and uncertified.

No scientific defect was corrected by changing implementation. Older frozen prose
remains historical; follow-up guide reconciliation belongs to separately authorized
M10D.6E work, not this reference milestone.

## Optional integrations and example execution policy

Exact root extension triggers:
Molly; PINN: Lux/NeuralPDE/ModelingToolkit/Optimization/SymbolicIndexingInterface;
inference: Optimization; learned dynamics: Lux/Optimization;
surrogates/operators: Lux/Optimization/NeuralOperators, including plain surrogates.
Base stored-data/metric/accessor routes are distinguished from backend-dependent
construction/training. Stored PINNAnalysis loss_breakdown needs no optional import;
PINNTrainingResult diagnostic recomputation needs the PINN triggers.

Stable plotting names do not stabilize experimental payload semantics. Makie is
already a root dependency; a rendering backend must be explicitly selected.
No optional scientific stack or training run was added. No new scientific executable
examples, plots, large eigensolves, symbolic stress tests, optimizer sweeps or
canonical run occurred. Doctests are disabled because this manual supplies signature
text and historically verified examples, not new expensive scientific code.
M10D.6C tutorial execution evidence and M10D.5's 5,649 assertions are
HISTORICAL_TEST_EVIDENCE only. Candidate test paths are not a resolved call graph.

## Build failures, corrections and explicit policies

D1 skeleton built cleanly. Two metadata-helper attempts failed (exit 1): abstract
fieldnames are undefined; TOML cannot serialize tuples as table values. Skip
abstract field extraction and collect concrete names into vectors. Corrected probe
exited 0; both original stderr logs remain outside the repository.

The first full build exited 0 but was not accepted: two performance advisories
(scientific-ml HTML above 100 KiB; complete search index above 500 KiB). The first
site checker exited 1 for 34 missing deployment-only siteinfo/versions script
occurrences. The local-only builder now supplies explicit disabled-version-selector
configuration and rewrites version-script links into build/. No deployment or
published version is fabricated, and no artifact escapes build/.

A later README-aware gate initially failed (exit 1) because it wrongly treated the
existing notebooks directory link as a required file. It now accepts valid existing
file/directory targets. The original failure is retained; final checks pass.

The first staged whitespace check exited 2 for redundant blank EOF lines in 14
new reference pages. Only trailing empty lines were trimmed; audited contract
content was unchanged. The corrected staged whitespace gate exited 0.

Two intentional, scoped size policies retain the authoritative page ownership:
only scientific-ml is exempt from the default 100 KiB advisory check; its original
200 KiB hard bound is independently enforced by builder and validator. All other
page thresholds stay default. The complete search index has a finite 640 KiB
warning/hard budget. Final scientific-ml HTML is 167918 bytes;
search index is 569229 bytes. No global warning suppression:
warnonly=false remains active. This is not presented as an unrestricted-defaults
clean build. remotes=nothing deliberately avoids unpublished remote source/edit
URLs, not unresolved local symbol links.

DOCUMENTER_BUILD_VERIFIED: final exit 0, zero warnings/errors under these documented
policies. REFERENCE_COVERAGE_VERIFIED: final checker exit 0. Validated 224
explicit source anchors, every primary generated API anchor, 358 manual Markdown
link occurrences, 25 README relative-link occurrences and 2573 generated HTML
local-link/resource occurrences. No missing local targets or anchors. All 17
pages are in navigation. All 184 packaged raw resources match checkout bytes.
Local HTTP read-back delivered 212 unique pages/assets/resources with status 200
and byte equality; server shut down. External CDN/footer links (187 occurrences)
were not network-checked; no external-link/deployment availability guarantee is made.

## Integrity, review and files changed

The final staged diff must contain only the following 26 authorized files, with no
build output, scientific source, dependency-root or earlier evidence changes.
Review includes the full staged manifest/file list and diff, contract comparison,
standalone path containment, added-line secret/unsafe-code scan, whitespace gate
and byte-equivalent staged/working files. Subagents and full scientific tests are
not used for this sequential documentation milestone.

- README.md
- docs/.gitignore
- docs/Manifest.toml
- docs/Project.toml
- docs/inspect_api.jl
- docs/make.jl
- docs/src/guides/api-boundaries.md
- docs/src/index.md
- docs/src/reference/atomistic.md
- docs/src/reference/comparison.md
- docs/src/reference/core.md
- docs/src/reference/datasets.md
- docs/src/reference/derivatives.md
- docs/src/reference/dynamics.md
- docs/src/reference/evidence.md
- docs/src/reference/index.md
- docs/src/reference/mechanics.md
- docs/src/reference/plots.md
- docs/src/reference/scalar.md
- docs/src/reference/scientific-ml.md
- docs/src/reference/statistics.md
- docs/src/reference/transport.md
- docs/src/reference/vector.md
- reports/m10d6/reference_check.py
- reports/m10d6/reference_implementation_report.md
- reports/m10d6/reference_verification.json

## Final commit identification and Git read-back

The single authorized subject is:
[m10d] Complete M10D.6D public API reference

After committing, identify the containing full SHA with git rev-parse HEAD;
verify git log -1 --format=%H%n%s, git branch --show-current,
git diff-tree --no-commit-id --name-only -r HEAD, git status --porcelain,
and the baseline/protected-file check. Compare committed blobs to the verified
candidate hashes, and confirm build output is not tracked. No push/tag/deployment.
The final worktree status is proven in the external commit read-back ledger rather
than predicted here or embedded circularly in the committed report.

Detailed execution/checkpoint evidence: reference_verification.json.
External logs/read-back: /home/lorenzozm/.hermes/logs/analyticmath-lab/m10d6d/.
Local manual entry: /home/lorenzozm/PROJETOS/analyticmath-lab/docs/build/index.html.

## Limitations and next authorization

This is complete public manual coverage, not complete source docstrings, post-1.0
compatibility, a rerun of all scientific methods, or independent certification of
caller-supplied results. Optional native keywords are only documented within
supported AML forwarding contracts. Tutorials remain raw linked resources rather
than duplicated rendered site pages. External network resources are not certified.
Scoped size policies are explicit above. No mandatory blocker remains before the
local commit/read-back gate. Next: M10D.6E — Scientific Guides, only after separate
authorization; no M10D.6E/F/G/H or M10D.7 work started.
