# M10D.5 — User and research hardening

Status: VERIFIED COMPLETE. Plain canonical passed 5649/5649 assertions across
198 reported testsets on implementation checkpoint c913f9e, exit 0.
M10D.1–M10D.4 remain verified. This phase adds no scientific feature and does not
begin M10D.6. Principle: simple by default, explicit when advanced, honest when unsupported.

## Getting started without hidden setup

Use Julia 1.12 in the repository environment:

```sh
julia +release --project=. -e 'using Pkg; Pkg.instantiate(); Pkg.precompile()'
julia +release --project=. -e 'using AnalyticMathLab; println(statistical_summary(ObservableSeries([1.,2.,3.])))'
julia +release --project=. -e 'using Pkg; Pkg.test()'
```

No thread environment variables are required for correctness testing. AML import
must not change the global BLAS thread count. Julia and BLAS have separate pools;
performance experiments may explicitly budget both, but that is not an import or
test ritual. The D024 correctness fixture now budgets the larger actual pool and
still tests refusal when the explicit ceiling is too small. The production stress
harness is unchanged; no M10C stress ladder was rerun.

For a separate local environment, activate it and use `Pkg.develop(path=...)` with
the actual checkout path, then instantiate/precompile. The clean-environment gate
uses this route, an unrelated working directory and paths containing spaces.
It reuses the installed package depot: this is not an empty-depot/network-offline
installation certification. Initial dependency compilation can take minutes.

`using AnalyticMathLab` alone supports base numerical/statistical functionality.
Symbolic construction explicitly imports Symbolics; plotting explicitly imports
and chooses a Makie backend (CairoMakie supports headless file output). Neither
analysis nor AML import activates a renderer or opens a window. Example paths
should be constructed with `joinpath`; package runtime does not require the
checkout root as current directory or a user's home path.

## Public constructors and refusal contracts

Prefer documented keyword factories to raw positional result records. A
PropertyResult or open metadata container is not a certificate of scientific
validity; its caller-supplied status/reference/unit descriptions remain claims.
The frozen four-field PropertyResult layout and compatibility constructors remain
unchanged. Broad validation of every raw record would break compatibility and is
not promised here.

- ScientificDataset requires explicit kind, family, input/coordinate order,
  domains, splits, reference, units, grid and RNG information. Missing domain
  coordinates/inputs/descriptors or reference.kind now give actionable ArgumentError
  messages instead of internal property errors. No split or reference quality is inferred.
- ScientificSample represents one scalar output at coordinate columns. Scaling
  arrays use component rows and query columns: for scalar output use
  `reshape(sample.values, 1, :)`, then `AnalyticMathLab.transform` and
  `inverse_transform`. A vector means one column of components, not an inferred
  series of scalar queries. Qualification avoids other packages' transform names.
- ObservableSeries borrows its vector (including lazy ranges). Its name is a
  Symbol; explicit time count must match stored values. The error reports both
  counts. Construction inspects the first value for units, not every lazy value.
  Moment/running analyses reject incompatible dimensions and mixed known/unknown
  units while accepting compatible units such as meters/centimeters. Missing,
  nonfinite and non-real observations produce unknown results, not silent filtering.
- `observable_series(path; component=... OR observable=...)` uses stored samples.
  It does not choose physical coordinates, infer particle identities, invent units
  or resample. Physical quantities from plain ODE states require explicit caller meaning.
- Molly `atomistic_trajectory` requires an explicit fixed-box/fixed-particle-history
  assertion and stored coordinate loggers; times are explicit, not inferred from
  stride. A default system with no loggers now reaches the public refusal instead
  of `get(::Tuple{}, Symbol, Nothing)` MethodError. Snapshot arrays remain borrowed
  unless `copy_data=true`; existing logger frames are not duplicated.

Read-only-by-convention arrays are not deeply immutable. ScientificSample copies
its numeric input; ObservableSeries and several mechanics accessors borrow data.
Retain the source/context when interpreting compact statistical leaves: they have
no hidden ancestry storage. These ownership boundaries are intentional.

## Optional dependencies

Base functionality must load without these optional backends. To activate an
optional family, instantiate its explicit `examples/<family>` environment, then
import its dependencies and AML in either order:

| Environment | Explicit activation imports | Bounded public check |
|---|---|---|
| molly | Molly | Borrowed snapshot, geometry and missing-history refusal |
| inference | Lux, Optimization | Inspect zero correction, evaluate known vector field, short prediction |
| operators | Lux, Optimization, NeuralOperators | Two-point scalar model, prediction and objective; no training |
| pinn | Lux, NeuralPDE, ModelingToolkit, Optimization, SymbolicIndexingInterface | Construct a tiny Lux PINN network; no training |

The inference extension itself requires Optimization; learned dynamics requires
Lux and Optimization. The current surrogate extension requires NeuralOperators
even for a plain Lux surrogate. PINN's pinned dependency graph also activates the
surrogate extension transitively. No fallback backend is selected silently.
Missing learned-dynamics backends now raise an actionable ArgumentError; invalid
signatures after activation still produce normal MethodError. PINN guidance lists
all five required triggers. Existing PINN/inference/surrogate guarded wrappers
remain in place.

Optional example Projects now declare their own ForwardDiff/Symbolics imports
rather than reaching through AML's internal dependency bindings. Resolved manifest
dependency records/versions are unchanged; only project hashes changed. A learning
model requires explicit normalization, RNG and rng_provenance; seed metadata cannot
be recovered honestly from an opaque RNG, so supply it explicitly.

Manual load-order check:

```sh
julia +release --startup-file=no --project=examples/pinn test/m10d_user_optional.jl pinn aml-first
julia +release --startup-file=no --project=examples/pinn test/m10d_user_optional.jl pinn backend-first
```

Substitute molly, inference or operators for the family. These gates stay outside
base Pkg.test; installing optional scientific stacks is not a base-test requirement.

## Numeric and research honesty

Generic symbolic polynomial evaluation retains supported Int/Float32/Float64/
BigFloat/complex arithmetic. This is not a whole-library numeric-generic promise.
Moment summaries support tested real numeric and compatible Unitful values; integer
means use floating arithmetic. ODE presentation, ScientificSample, normal modes and
learning retain their documented checked Float64 boundaries. Sparse normal-mode
input does not imply sparse eigensolver execution. Unsupported complex mode input
returns unknown; dimensioned values are not silently stripped to satisfy a Float64 API.

A solver success/termination code is not an error bound. Training/reference labels
and string units are caller declarations, not physical certification. No automatic
interpolation, dataset split, reference promotion, coordinate reordering, unit
inference, GPU transfer or backend substitution was added. Optional ML remains
PUBLIC_EXPERIMENTAL and version-sensitive; stateful/GPU cases are not newly supported.

The standalone Stranger scripts cover a student scalar/multivariate workflow,
physicist mechanics→stored observables, a 10,000-value lazy research series with
serialization and sparse/dense-boundary checks, explicit scientific datasets and
atomistic data without Molly. These are correctness checks, not performance claims.

## Verification and readiness

See [m10d_user_research_results.md](m10d_user_research_results.md) for recovery,
exact durable evidence, gate dispositions, review and canonical status. Linux
headless/path/thread checks do not establish Windows/macOS coverage or bitwise
cross-platform reproducibility. The single bounded first-hour parent review found
no additional blocker beyond the recorded fixes/fixture corrections.

M10D.5 user/research readiness is verified for the documented bounded workflows:
plain canonical passed with Julia threads=1 and BLAS threads=6, both thread
environment variables unset. This is not a 1.0 release declaration: navigation
work belongs to M10D.6 and the final adversarial
release verdict belongs to M10D.7. No new scientific feature, large ML training or
scale stress workload was introduced.
