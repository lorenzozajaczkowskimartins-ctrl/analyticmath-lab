# AnalyticMathLab.jl

A Julia library for structured mathematical and scientific analysis: turn symbolic
models or stored scientific data into reusable results, numerical comparisons and
scientific views. It is intended for students, researchers and Julia developers
who need explicit assumptions and inspectable evidence—not just a plotted answer.

**Pre-1.0, version 0.1.0.** Core public APIs have a documented stable classification;
scientific datasets, inference, learning and the qualified metadata interfaces are
experimental. This is not a 1.0 release or a general-purpose computer algebra system.

[Quick Start](#quick-start) · [Coupled-oscillator investigation](#one-system-many-methods)
· [Guides and examples](#guides-and-examples)

## Why AnalyticMathLab?

AML connects existing analytical and numerical tools around scientific objects:

```text
Scientific object → symbolic analysis → numerical analysis
                  → verification / comparison → visualization
                  → structured scientific result
```

This is a conceptual workflow, not a promise that every object supports every
stage. Results can be inspected and reused without repeating their analysis;
assumptions, unknown conclusions and numerical limitations remain visible.
Symbolics supplies symbolic machinery, SciML supplies numerical integration,
Makie supplies visualization, and optional packages supply specialized simulation
or learning backends. AML composes these tools rather than replacing them.

## Capabilities at a glance

“Core” means no optional extension activation; it does not mean dependency-free.
Availability and API maturity are separate:

| Area | Supported work | Availability / maturity |
|---|---|---|
| Scalar functions and real domains | Symbolic derivatives, bounded stationary searches, supported original-domain reasoning | Core / stable |
| Numerical derivatives | Symbolic–AD–finite-difference comparisons and sampled convergence experiments | Core / stable |
| Multivariate and vector calculus | Ordered gradients, Hessians, rectangular Jacobians, scoped divergence/curl/potential evidence | Core / stable |
| Dynamics | Equilibria, local stability and native SciML first-order ODE trajectories | Core / stable |
| Analytical mechanics and modes | Lagrangian/Hamiltonian analysis, supported affine Legendre transforms, local linearization and dense normal modes | Core / stable |
| Atomistic data | Geometry, supplied radial potentials, RDF/coordination and stored-data inspection | Core; Molly adapter optional / stable |
| Stored trajectories | Explicit observables, descriptive statistics, correlation/blocking, MSD/VACF and compatibility-gated comparisons | Core / stable |
| Scientific datasets | Explicit schema, splits, references, coordinate order and train-only scaling | Core / experimental |
| Parameter inference | ODE forward objectives and local sensitivity; optional optimizer-based fitting | Core forward analysis; Optimization fitting optional / experimental |
| Scientific learning | PINNs, Hamiltonian networks, UDE corrections, coordinate surrogates and fixed-sensor DeepONet | Optional / experimental |
| Scientific views | Stored-result Makie figures and text inspection | Core view APIs / stable; experimental payloads remain experimental |

## Installation

The project declares Julia compatibility `1.12`. The examples below were verified
with **Julia 1.12.7 on Linux**; that is not certification of every compatible Julia
version or platform. With Juliaup, `julia +1.12.7` selects that runtime. Otherwise
use the executable for your installed Julia 1.12.7. The moving `+release` channel
may select a different version.

### Independent consumer environment

Start Julia in a directory where you want a new `aml-first-run` environment, then:

<!-- readme: consumer-install -->
```julia
using Pkg
Pkg.activate("aml-first-run")
Pkg.add(url="https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab.git")
Pkg.add("Symbolics")
```

`Symbolics` is an explicit consumer dependency because the Quick Start imports it
and uses `@variables`. Installing AML does not make every AML dependency a direct
import of your own project. This URL-based installation makes no General Registry
claim. Dependency download/precompilation may take time; retain the consumer
Manifest for reproducibility. To reopen this environment, launch
`julia +1.12.7 --project=aml-first-run` from the same parent directory.

The URL installs the repository's published revision, which can differ from an
unpushed local checkout. The verified remote installation used scientific baseline
`377a3c4`; the documentation work does not require or perform a push.

### Checkout and development

For the scripts linked below, clone the repository and use its declared environment:

<!-- readme: checkout -->
```sh
git clone https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab.git
cd analyticmath-lab
julia +1.12.7 --project=. -e 'using Pkg; Pkg.instantiate()'
```

The committed checkout Manifest currently emits a nonfatal project/manifest
freshness warning during `instantiate`. The Quick Start still passed with that
Manifest; this documentation change does not refresh dependency files. The
independent consumer route above resolves its own Manifest.

To use a local checkout as a dependency while developing it, start Julia from its
root and activate a separate environment before registering the local path:

<!-- readme: local-develop -->
```julia
using Pkg
Pkg.activate(temp=true)
Pkg.develop(path=pwd())
Pkg.add("Symbolics")
```

The temporary environment is session-specific; use a separate persistent project
for ongoing work. Neither method requires changing AML's dependency constraints.

## Quick Start

In the consumer or checkout environment, analyze
$f(x)=x^3-6x^2+9x+1$ and compare its first derivative numerically:

<!-- readme: quick-start -->
```julia
using AnalyticMathLab, Symbolics

@variables x
report = analyze(x^3 - 6x^2 + 9x + 1, x)
println(evaluate(report, 2.0))           # 3.0
println(evaluate(report, 2.0; order=1))  # -3.0

comparison = compare_derivatives(report, 2.0)
println(comparison.values)              # symbolic, automatic, central
println(comparison.absolute_errors)     # discrepancies from symbolic evaluation
```

The evaluated symbolic derivative and automatic derivative are both `-3.0` in the
verified run; the central-difference discrepancy was approximately `1.86e-10`.
Discrepancies are not certified error bounds. The report stores derivatives and reusable
callables; analysis does not print or create a figure unless requested.

When exclusions matter, capture original syntax with `@real_function` before
symbolic cancellation. Univariate `evaluate` retains the generated callable's
behavior; it is not an original-domain certificate. The
[function-analysis notebook](notebooks/function_analysis.jl) adds an explicit
stationary-search interval and caller-selected plotting.

## One system, many methods

The [complete investigation](examples/integration/one_system_many_methods.jl)
uses one dimensionless, two-degree-of-freedom coupled oscillator. For ordered
coordinates $(q_1,q_2)$, velocities $(v_1,v_2)$, and $m=k=\kappa=1$:

$$
T=\tfrac12(v_1^2+v_2^2),\qquad
V=\tfrac12(q_1^2+q_2^2)+\tfrac12(q_2-q_1)^2,\qquad L=T-V.
$$

The script connects potential gradient/Hessian, Euler–Lagrange equations, local
mechanical linearization, a verified affine Legendre transform, normal modes and
SciML integration. The mass/stiffness matrices are
$M=I$, $K=\begin{pmatrix}2&-1\\-1&2\end{pmatrix}$; angular frequencies
are $1$ and $\sqrt3$. State order is $(q_1,q_2,v_1,v_2)$; canonical
phase order is $(q_1,q_2,p_1,p_2)$, with the explicit conversion $p=mv$.

It then selects stored observables, computes descriptive statistics, constructs
an explicitly declared anchored-particle interpretation, and builds an
**experimental** scientific dataset. The dataset's targets remain numerical, not
analytical truth. Provenance inspection uses qualified experimental interfaces;
the independent modal-superposition oracle describes the same model but is not
derived from the numerical trajectory.

From the checkout root:

<!-- readme: flagship -->
```sh
julia +1.12.7 --project=. examples/integration/one_system_many_methods.jl
```

The verified run retained 321 samples over `t=0:0.03125:10`, checked all its
cross-method comparisons, and had maximum state discrepancy below `2e-8` against
the independent analytical oracle. This is a bounded example, not a global error
certificate or a general promise that `saveat` produces an exclusively uniform
grid. [Model, conventions and interpretation](docs/m10d_one_system_many_methods.md)
are documented separately. Optional learning and rendering are not prerequisites
for the core script; the existing one-step learning branch demonstrates a pipeline,
not an accurate replacement for the oscillator.

## Scientific visualization

![Dimensionless coupled oscillator: solid numerical trajectories and dashed analytical references for the ordered coordinates and velocities](docs/assets/readme/coupled_oscillator.png)

Solid curves are saved numerical states; dashed curves are the independent
analytical reference at the same dimensionless times, nearly coincident at this
scale. Agreement is a comparison, not a physical-validity certificate.
Reproduce the image from the checkout root:

<!-- readme: figure -->
```julia
include("examples/integration/one_system_plots.jl")
r = OneSystemPlots.OneSystemManyMethods.investigate()
using CairoMakie
CairoMakie.activate!()
figures = OneSystemPlots.figures(r)
mkpath("docs/assets/readme")
save("docs/assets/readme/coupled_oscillator.png", figures.trajectory)
```

Run that block in `julia +1.12.7 --project=.`. CairoMakie is directly declared in
the checkout project; an independent plotting consumer must declare it too.
The helper also offers absolute-energy and explicitly mapped-distance views.
Sampled energy drift is not proof of conservation. AML and the helper do not
activate a rendering backend; the calling code chooses it explicitly.

## Scientific reliability

A `PropertyResult` has exactly `value`, `status`, `method` and `notes`. Inspect the
scope of its claim: `:established` applies to the stated claim and assumptions;
`:heuristic` is approximate evidence, not proof. **Unknown is neither false nor
zero**, and an empty heuristic search is not proof of absence. Solver completion,
small residuals, numerical
agreement and low learning loss do not establish mathematical or physical truth.
A declared reference is not automatically independent analytical ground truth.

Unit labels do not convert data; absent units are not automatically dimensionless.
Provenance identity is distinct from scientific value equality.
`AnalyticMathLab.scientific_metadata(result)` and
`AnalyticMathLab.scientific_origin(result)` are **qualified experimental**
inspection interfaces, not exports or certification engines. Origin tokens are
process-local identities, not reproducibility hashes; isolated PropertyResult
leaves may have no recorded ancestry. See [evidence semantics](docs/m10d_semantics.md)
and [provenance/ownership](docs/m10d_provenance.md).

## Computational limits

- Symbolic scalar-field analysis accepts 1–32 ordered variables. A supplied matrix
  is a different route; 3000 symbolic variables are not supported.
- ODE integration and several data/modal pathways use checked Float64 conversion;
  generic scalar arithmetic is not a universal arbitrary-precision guarantee.
- Normal modes use a full dense spectrum, even with sparse input.
  `normal_modes(...; max_memory_bytes=...)` and
  `pair_distances(...; max_bytes=...)` are operation-specific byte-estimate controls,
  not peak-RSS guarantees. Adapter allocations can precede a modal preflight.
  There is no global AML memory setter or generic public sparse-Hessian, HVP,
  matrix-free or partial-mode API.
- Domain, coordinate order, physical scales and sampling require explicit meaning.
  Eligible index-time MSD can be fitted by `diffusion_estimate`; interpreting a
  physical diffusion coefficient requires justified time-scale and fit-window
  assumptions. No direct physical-clock refusal is claimed.
- Optional learning has experimental backend/layout boundaries. Successful fitting
  or sampled residual diagnostics do not certify generalization or PDE correctness.

[Supported-workflow boundaries](docs/m10d_user_research_hardening.md) and the
[source-audited resource controls](reports/m10d6/resource_controls.json) give detail.
Maintainer scaling experiments are not additional supported public APIs.

## Optional integrations

Extensions activate only when **all** their trigger packages are loaded:

| Integration | Required trigger packages | Scope |
|---|---|---|
| Molly data adapter | Molly | Stable stored-data adapter; no second MD engine |
| Parameter fitting | Optimization | Experimental optimizer-backed inference |
| Hamiltonian networks / UDE | Lux, Optimization | Experimental learned dynamics |
| Surrogates / DeepONet | Lux, Optimization, NeuralOperators | Experimental; NeuralOperators is required even for the plain Lux surrogate |
| PINNs | Lux, NeuralPDE, ModelingToolkit, Optimization, SymbolicIndexingInterface | Experimental construction, training and diagnostics |

Base import does not load the optional ML stack. Activation alone is not a ready
scientific experiment: models, optimizers, AD choices, RNG, data schema and physical
assumptions must still be explicit. Use the declared example projects and linked
guides rather than adding every stack to your first environment.

## Guides and examples

- [Dynamics and ODEs](docs/dynamical_systems.md), [vector fields](docs/vector_fields.md)
  and [analytical mechanics](docs/mechanics.md).
- [Atomistic data](docs/atomistic.md), [trajectory statistics/transport](docs/trajectory_statistics.md)
  and [stored-result comparison](docs/trajectory_comparison.md).
- [Parameter inference](docs/parameter_inference.md), [learned dynamics](docs/learned_dynamics.md),
  [PINNs](docs/scientific_ml.md), [PINN diagnostics](docs/pinn_diagnostics.md)
  and [datasets/surrogates](docs/surrogates.md).
- [Runnable notebooks](notebooks) and the [integrated oscillator](examples/integration/one_system_many_methods.jl).

These are existing repository resources. A versioned Documenter reference and
question-led GitHub Wiki are planned, not deployed documentation linked here.
Historical milestone reports are execution records, not current installation guarantees.

## Development and license

Use the checkout environment for development. The full test suite is a separate,
potentially lengthy developer gate—not required for the Quick Start:

<!-- readme: full-suite-not-run -->
```sh
julia +1.12.7 --project=. -e 'using Pkg; Pkg.test()'
```

The recorded scientific baseline passed 5,649 assertions on Julia 1.12.7 in its
recorded environment. This README work verifies the introductory examples and
figure separately; it does not claim a new canonical-suite pass. Exact commands,
installation scope and results are in the
[README verification report](reports/m10d6/readme_implementation_report.md).

Licensed under the [MIT license](LICENSE). No DOI or formal citation metadata is
provided; cite the repository and the exact revision used rather than inventing
a publication or bibliographic identifier.
