# M10D.6A documentation architecture proposal

Evidence level: SOURCE_INSPECTED for current repository; PROPOSED destinations are not existing pages or deployed URLs. Baseline: `377a3c45905d0e16dba1fc2adc9d8eb3dcff14ca`. This is design, not Documenter implementation or publication.

## Roles and information hierarchy

Documenter.jl is the proposed primary technical manual: exact supported signatures, executable tutorials, scoped contracts, numerical restrictions, and extension prerequisites. The GitHub Wiki is the secondary question/diagnosis index; it links to authoritative manual sections rather than maintaining duplicate API tables. No registry, documentation deployment URL, Wiki availability, release guarantee or DOI is asserted. Root `Project.toml:1-63` currently specifies package identity/dependencies/test targets, not a Documenter dependency. Introducing a docs environment and CI belongs to a later authorized phase.

The distinction is important because `docs/m10d_architecture_inventory.md:25-42` freezes supported factory/accessor contracts, not every raw positional constructor. Stable exported view names can consume experimental ML payloads. Qualified experimental semantics accessors in `src/scientific_metadata.jl:1-22` require reference coverage despite not being exports.

## Proposed Documenter navigation

| Section | Proposed pages | Source of truth / content boundary |
|---|---|---|
| Home | `index.md` | Scientific input → reusable report → scoped claims → explicit numerical work → stored presentation; no universal solver claim |
| Start here | `installation.md`, `quickstart.md` | Root Project/Manifest, explicit Julia environment, first load, first analysis; base versus optional; first precompile can take time |
| Tutorials | `tutorials/calculus.md`, `multivariate.md`, `vector-calculus.md` | Existing scalar/multivariate/vector notebooks and their tests; original syntax capture, formal vs checked numerical derivatives |
| Integrated science | `tutorials/one-system-many-methods.md` | `examples/integration/one_system_many_methods.jl:111-201`; same model/order/units and independent modal oracle |
| Dynamics | `tutorials/mechanics.md`, `normal-modes.md`, `odes.md` | Lagrangian/Hamiltonian → conversion → trajectory; modal assumptions and dense boundary, not general matrix analysis |
| Stored observations | `tutorials/trajectories.md`, `statistics.md`, `atomistics.md` | Sampling, lazy frames, unknown metadata, correlated uncertainty, transport and compatibility |
| Learning | `tutorials/datasets.md`, `inference.md`, `learning.md`, `pinn.md`, `operators.md` | Separate environments, exact triggers, explicit RNG/AD/optimizer, no implicit splits or certification |
| Scientific contracts | `guides/evidence.md`, `provenance.md`, `units.md`, `precision.md`, `ownership.md`, `coordinates.md` | M10D.2/3/5 contracts; PropertyResult fields unchanged; source identity is not value equality |
| Computational regimes | `guides/computational-regimes.md`, `resource-limits.md`, `large-hessian.md` | Public versus internal controls, preflight versus actual memory, dense/sparse/lazy/matrix-free distinctions; refusal matrix |
| Backends | `extensions/index.md`, `molly.md`, `inference.md`, `lux-dynamics.md`, `pinn.md`, `operators.md`, `plotting.md` | `Project.toml:19-33`; caller-owned rendering backend; version-sensitive native objects |
| API reference | `reference/scalar.md`, `domains.md`, `derivatives.md`, `multivariate.md`, `vector.md`, `dynamics.md`, `mechanics.md`, `modes.md`, `atomistics.md`, `statistics.md`, `transport.md`, `comparison.md`, `datasets.md`, `learning.md`, `pinn.md`, `evidence.md`, `visualization.md` | Per-symbol coverage matrix; separate shared-generic method sections and stability badges |
| Help | `troubleshooting/index.md`, `installation.md`, `inputs.md`, `optional-activation.md`, `resources.md`; `known-restrictions.md` | Exact diagnostics, public configuration controls, actionable alternatives, unresolved defects explicitly separated |
| Maintenance | `contributing.md`, `verification.md`, `citation.md` | Existing license and test commands only; future citation metadata needs an explicit decision |

Names are planned information architecture, not a commitment to final filesystem naming. The coverage matrix's per-symbol targets may be more specific; reconcile anchors during implementation instead of assuming these proposals already resolve.

## Reference page contract

For each public operation/type, present: stability and supported construction path; signature/dispatch table; keyword/default table; accepted shapes/coordinate order; return type and status semantics; unit and numeric boundaries; ownership; extension prerequisites; exceptions AND structured refusal results; verified small example; links to relevant tests and limits. Distinguish raw result records from validating factories. For overloaded `analyze`, `predict`, `train`, `evaluate`, `normal_modes`, `observable_series`, and `plot`, dispatch tables must prevent cross-family output/keyword promises.

Every page must name its evidence level. SOURCE_INSPECTED is not a new test run. Historical successful gates remain linked to their recorded candidate and scope. Notebook output is not automatically current executable documentation.

## Executable documentation design (later work)

Use isolated doctest/example groups with explicit imports. Keep base tutorials independent of ML environments. Do not put large ML training, M10C stress ladders or optional load permutations into every docs build. A small explicit backend cell can save a figure headlessly; do not activate CairoMakie in AML import or global documentation setup for unrelated tests. Plotting examples must state that masks and stored observations do not establish mathematical validity.

Use deterministic examples with scientifically justified oracles, tolerances, fixed sample order and explicit units. Do not bless optimizer convergence as physics. Separate direct script execution, doctest success, visual inspection, and historical scientific regression evidence. Link generated figures to their generating script and version; no hand-drawn chart presented as AML output.

## Wiki navigation

Proposed subject indexes: Getting Started; Calculus and Symbolics; Linear Algebra; Vector Calculus; Numerical Methods; Differential Equations; Mechanics and Dynamics; Trajectories; Atomistic Computing; Statistics; Scientific Datasets; Scientific Machine Learning; Units and Precision; Memory and Performance; Scientific Evidence and Provenance; Optional Extensions; Troubleshooting.

Use one canonical question slug, short answer first, exact symptom/diagnostic, minimal reproduction, explanation, supported recovery, limitations, technical-manual link and evidence refs. Add related-question links (for example Hessian → dense modes → sparse input → memory preflight). Wiki indexes must distinguish internal maintainer examples from supported APIs. Foundations topics are future links/outlines, not a mathematical textbook in M10D.6.

## Acceptance rules for later implementation

No invented URLs or badges before deployment exists. Validate all local links and anchors, run bounded examples in their declared environments, and verify absent optional dependencies remain absent from base-load instructions. Install docs dependencies only when separately authorized. README implementation belongs to M10D.6B; this audit does not begin it.
