# Executable scientific tutorials

These lessons connect mathematical formulation, Julia implementation, independent
verification and scientific interpretation. They assume basic Julia familiarity,
not knowledge of AML's result layouts. Read the pages directly on GitHub; no
Documenter build is required.

## Environment and reproducibility

Use a checkout of AnalyticMathLab from its repository root. The existing root
Project/Manifest supplies the tutorial dependencies; follow the
[README checkout instructions](../../README.md#checkout-and-development) if those
dependencies are not already installed. Each lesson gives its exact Julia command
and a complete Julia block byte-identical to its script. The published commands
were executed with Julia 1.12.7 on Linux in M10D.6C; no moving channel or global
user package fallback was used. No dependency files were changed.

For manual copy/paste, start Julia 1.12.7 with the root project active and the
working directory at the checkout root. Each block initializes its own objects;
run different lessons in fresh sessions to avoid name collisions. The trajectories
lesson includes its ODE lesson explicitly, and the capstone includes the unchanged
canonical example. These are visible dependencies, not hidden REPL state.

Required direct packages are already declared: Symbolics for symbolic lessons,
LinearAlgebra for modes and the canonical example, Unitful for atomistic quantities.
AML internally uses its declared SciML/AD/finite-difference dependencies. No optional
ML or Molly packages are needed. CairoMakie is declared but not loaded by these
mathematical scripts. Installation itself was not rerun in M10D.6C; the existing
checkout Manifest freshness warning documented in M10D.6B remains unrepaired.

## Recommended learning sequence

The difficulty labels describe concepts, not estimated runtime or performance.
You may start with an individual page: each declares its model and assumptions.

| Order / lesson | Prerequisite knowledge | Mathematical topic | Direct imports | Difficulty | Executable code |
|---|---|---|---|---|---|
| 1. [Scalar analysis](calculus.md) | Derivatives, local extrema | Symbolic/AD/finite differences; stationary points | AML, Symbolics | Introductory | [calculus.jl](scripts/calculus.jl) |
| 2. [Multivariate calculus](multivariate.md) | Partial derivatives, matrices | Ordered gradients/Hessians; positive definiteness | AML, Symbolics | Intermediate | [multivariate.jl](scripts/multivariate.jl) |
| 3. [Vector calculus](vector-calculus.md) | Partial derivatives, circulation | Jacobian, divergence, planar curl, potential | AML, Symbolics | Intermediate | [vector_calculus.jl](scripts/vector_calculus.jl) |
| 4. [Analytical mechanics](mechanics.md) | Energy, differentiation | EL equations, regularity, momentum, Hamiltonian | AML, Symbolics | Intermediate | [mechanics.jl](scripts/mechanics.jl) |
| 5. [Normal modes](normal-modes.md) | Eigenvectors, harmonic motion | Generalized eigenproblem; mass normalization | AML, LinearAlgebra | Intermediate | [normal_modes.jl](scripts/normal_modes.jl) |
| 6. [Differential equations](odes.md) | First-order ODEs, initial conditions | Adaptive integration; analytical reference metrics | AML | Intermediate | [odes.jl](scripts/odes.jl) |
| 7. [Trajectories and statistics](trajectories.md) | ODE lesson, sample moments | Stored observables; descriptive versus inferential statistics | AML; explicitly includes ODE lesson | Intermediate | [trajectories.jl](scripts/trajectories.jl) |
| 8. [Atomistic stored data](atomistics.md) | Euclidean geometry, units | Particle ordering, species selection, pair limits | AML, Unitful | Introductory–intermediate | [atomistics.jl](scripts/atomistics.jl) |
| 9. [One system, many methods](one-system-many-methods.md) | Previous concepts | Coupled oscillator, cross-method evidence and provenance | AML; canonical example imports Symbolics, LinearAlgebra | Integrative | [wrapper](scripts/one_system_many_methods.jl), [canonical example](../../examples/integration/one_system_many_methods.jl) |

Core lesson APIs are stable according to the existing source audit, not a promise
of post-1.0 compatibility. The capstone's ScientificDataset and qualified metadata/
origin interfaces remain experimental. Availability in the core environment is
not the same as scientific maturity.

## Reading the evidence

- EXACT_IDENTITY: a mathematically established identity, with its assumptions.
- ANALYTICAL_REFERENCE: an independently justified reference expression or dataset.
- NUMERICAL_COMPARISON: measured agreement with a stated metric/tolerance.
- SOURCE_INSPECTED: behavior traced to existing implementation/audited contracts.
- EXAMPLE_EXECUTED: code actually ran with a recorded exit and checked result.
- HISTORICAL_VERIFICATION: earlier recorded evidence, not a new execution here.

Numerical agreement is not a mathematical proof. Unknown is not false or zero.
Each page places its limitations next to the relevant scientific claim.
The [implementation report](../../reports/m10d6/tutorial_implementation_report.md)
and [machine-readable execution manifest](../../reports/m10d6/tutorial_verification.json)
record actual commands, observations, tolerances, hashes, the corrected draft
assertion and intentionally skipped work. The old full-suite total remains
historical; the full suite was not run for these tutorials.

## Related guides and optional, experimental work

Existing guides supply deeper contracts, not additional newly verified tutorial
blocks. These optional environments are already in the repository; they were
not instantiated or exercised by M10D.6C. Trigger packages must all be loaded;
installation or extension activation alone does not define a valid experiment.

| Topic / existing guide | Optional triggers | Declared example project |
|---|---|---|
| [Molly stored data](../atomistic.md) | Molly (stable adapter) | [Molly](../../examples/molly/Project.toml) |
| [Parameter inference](../parameter_inference.md) | Optimization for experimental fitting | [inference](../../examples/inference/Project.toml) |
| [Learned dynamics](../learned_dynamics.md) | Lux, Optimization (experimental) | [inference / learned dynamics](../../examples/inference/Project.toml) |
| [Surrogates](../surrogates.md) / [operators](../operator_backends.md) | Lux, Optimization, NeuralOperators (experimental; including plain Lux surrogates) | [operators](../../examples/operators/Project.toml) |
| [PINNs](../scientific_ml.md) / [diagnostics](../pinn_diagnostics.md) | Lux, NeuralPDE, ModelingToolkit, Optimization, SymbolicIndexingInterface (experimental) | [PINNs](../../examples/pinn/Project.toml) |

No long training, optimizer convergence, generic PDE solving or complete coverage
of experimental APIs is claimed. A public API reference, Documenter integration
and Wiki publication belong to separately authorized future work.
