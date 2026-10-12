# README modernization plan — M10D.6B input, not implementation

Baseline `377a3c45905d0e16dba1fc2adc9d8eb3dcff14ca`. Evidence: SOURCE_INSPECTED. README is unchanged in M10D.6A. Its earlier complete inspection and current hash agreement establish the inventory; no example was newly executed here.

## Concrete audit findings

| Current location | Finding | Proposed treatment |
|---|---|---|
| `README.md:3-55` | Identity is followed by a milestone chronology rather than an external-user map. M8/M9 domains appear, so they are not wholly absent, but later integration, evidence/provenance and readiness are hard to discover. | Replace chronology with capability/task table and explicit base/optional boundaries. Move history to project history, not the quickstart. |
| `README.md:14`; `Project.toml:1-4` | Version 0.1.0 is accurate; blanket API-may-change wording lacks frozen stable versus experimental distinction. | Explain pre-1.0 classification; do not claim 1.0 release or universal API stability. |
| `README.md:65-75` | Local environment guidance is valid, but unqualified `julia` may select a different installation from recorded `+release` checks. No registry claim is needed. | State Julia compatibility 1.12, tested runtime separately, repository-local instantiate/precompile route and separately activated environments. Never invent `Pkg.add` registry availability. |
| `README.md:79-111` | Small polynomial example uses actual public analysis/evaluation/comparison. Its caveat about discrepancy rather than certified error is valuable. | Retain compact form; move field dump and detailed methodology to manual. |
| `README.md:113-354` | Strong real-domain and numerical limitations overwhelm entry-level navigation. | Preserve details in authoritative guides; README keeps one warning on source capture and evidence statuses. |
| `README.md:409-411`; `Project.toml:6-17,55-63` | Direct-dependency prose omits Random and Unitful; “Test is test-only” does not enumerate SHA/TOML/Serialization/SparseArrays test extras. | Avoid hand-maintained full dependency list or derive it from Project; clearly distinguish optional extension triggers. |
| `README.md:427-444` | Historical scope wording says PDE solvers are not implemented while optional PINN sections exist. This can be read as contradiction. General matrix analysis truly is not a generic AML facility. | Explain AML's bounded symbolic/numerical APIs and optional delegated PDE learning, not a universal PDE solver. Separate native backend responsibilities. |
| `README.md:446-448`; `LICENSE:1-21` | MIT license is present. | Link actual LICENSE; do not invent DOI, publication or citation file. |
| `README.md:449-614` | Multivariate/vector/ODE material is appended after license. | Move to capability table and tutorials; integrated mechanics/trajectory/dataset example deserves first-screen navigation. |
| Repository inventory; `Project.toml:1-63` | No tracked Documenter build/navigation or citation metadata in baseline. | Links must initially point to real in-repo reports/tutorial sources; deployed documentation/Wiki URL is a later verified publication decision. |

## Proposed concise order

1. Identity: Julia library for structured mathematical and scientific analysis, scoped evidence and reusable reports.
2. Philosophy: simple by default, explicit when advanced, honest when unsupported; input → analysis → evidence → numerical experiment → view.
3. Core capabilities: scalar/real/multivariate/vector analysis; mechanics and local modes; numerical ODE trajectories; stored atomistics/statistics; explicit datasets; optional inference/learning/PINNs/operators. Not generic computer algebra, MD engine or universal PDE solver.
4. Installation: local repository environment, declared Julia compatibility, precompile expectations, tested command and separate optional environments.
5. Compact mathematical quickstart.
6. Integrated scientific example and a tested figure link when available.
7. Scientific validity: `PropertyResult(:value,:status,:method,:notes)` describes field names, not a constructor using those symbols; actual constructor is `PropertyResult(value,status,method,notes)`. Unknown is not false, numerical success is not proof, provenance identity is not value equality.
8. Numerical/scalability restrictions: checked Float64 boundaries versus generic arithmetic; bounded symbolic dimension/work limits; dense modal route; explicit resource/refusal guide.
9. Optional integrations: exact trigger sets from `Project.toml:28-33`; no hidden imports, no silent backend choice.
10. Manual and Wiki navigation after links are real; source reports meanwhile.
11. Contributing: existing canonical command and small-test conventions; no invented contribution policy.
12. MIT license and honest citation status; no invented DOI or registry guarantee.

## Selected introductory example A

Source: `README.md:79-98`, `notebooks/function_analysis.jl:3-21`, `test/runtests.jl` scalar tests. Use `using AnalyticMathLab, Symbolics`, `@variables x`, polynomial `x^3 - 6x^2 + 9x + 1`, `analyze(f,x)`, `evaluate(report,2.0)`, `evaluate(report,2.0;order=1)`, and `compare_derivatives(report,2.0)`. Do not require plotting for the first result. No arbitrary Julia-callable analysis or string parsing promise.

Expected outputs must be captured by execution in M10D.6B, not copied from a mental calculation. Optional figure: caller loads CairoMakie and saves `plot(report; xmin=0,xmax=4)`, as the existing notebook does. Plain `evaluate` does not enforce the original real domain (`README.md:205-209`).

## Selected integration example B

Source: `examples/integration/one_system_many_methods.jl:111-201`, independently defined oracle at lines 32-40. Use the dimensionless coupled harmonic oscillator: potential field → Lagrangian → linearization and Legendre transform → normal modes → native ODE trajectory → named stored observables/statistics → explicit dataset. Atomistic interpretation is a separately declared anchored-particle mapping, not an automatic ODE-to-MD conversion (lines 139-151).

Do not copy its local module helpers as AML exports. Link the script or carefully extract a bounded public-API excerpt with the same physical definition/order. No optional ML dependency is required for the core example. Existing tests: `test/m10d_flagship.jl`, `test/m10d_flagship_schema.jl`; historical verification: `docs/m10d_flagship_results.md` and M10D.5 canonical inclusion, not a fresh execution here.

Proposed figure: `examples/integration/one_system_plots.jl:11-46` supplies trajectory with analytical dashed overlays, absolute energy with sampled drift caveat, and explicitly mapped distance. Use trajectory/energy panels for README, with dimensionless axes and same-model reference. The helper does not activate a backend; caller must choose one and save files. Rendering is a later bounded gate (`test/m10d_flagship_plots.jl`).

Optional sidebar only: `examples/integration/one_system_learning.jl:52-85` performs one affine-network Adam step. It intentionally establishes pipeline behavior, not accuracy; do not make its learned curve the main README accuracy claim. Its full explicit optional imports at lines 7-8 belong in the operators environment.

## Deferred checks, not performed here

Execute the compact excerpt and core script in clean declared environments; validate exact output shapes and plot labels; check links after documentation paths exist; use current manifest/runtime evidence without claiming all operating systems. This is M10D.6B implementation work, not part of this inventory pass.
