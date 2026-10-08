# M10D.3 — Lightweight scientific provenance

Use the semantic meanings in [m10d_semantics.md](m10d_semantics.md). This is a
thin inspection layer over existing results, not a universal provenance struct.
The original source fields and backend objects remain available under their
existing contracts. No cryptographic reproducibility claim is made.

## Detached origin interface

`AnalyticMathLab.scientific_origin(result)` returns a NamedTuple descriptor:

- kind=:aml_scientific_origin;
- short type name and process-local objectid token;
- producing operation;
- identity_scope=:process_local_not_reproducibility;
- at most one immediate-parent descriptor;
- explicit truncation flag when ancestry is bounded.

The chain has at most eight levels. Parent records are projected onto a
whitelist, rather than merged with arbitrary metadata. Arrays, closures, source
objects and unexpected keys are never copied into the origin chain. Malformed
or unrelated `origin` metadata is not treated as a valid descriptor. Missing
ancestry stays absent, never reconstructed. This is a bounded immediate-origin
chain, **not a complete DAG**, and it does not claim globally unique immutable
identity. objectid tokens are process-local associations, not durable IDs,
content hashes, reproducibility evidence, or scientific certification.

Descriptors can be copied and serialized without keeping a source object alive.
Serialization preserves the descriptor, not the ability to recover a source
object in another process. Nothing here installs a global registry or a weak
reference cache, creates cycles, traverses source arrays, or evaluates callbacks.

## Scientific information vs detached identity

`AnalyticMathLab.scientific_metadata(result)` exposes actual scoped claims,
method/backend/approximation/tolerances, reference quality/trust, units,
domain/coordinate meaning, options/RNG/sampling/ownership, and the detached
origin record. **The whole metadata record is not promised to be detached**:
values can borrow existing domain objects, schemas, mappings, notes and arrays.
Read-only usage is required. Use the origin interface alone for a compact link.

An identity descriptor is intentionally not a complete copy of scientific
metadata. Known scientific parameters/controls remain in the native result or
metadata interface. Do not pretend a type/token/operation alone is sufficient
for reproducing a computation. The source-specific omissions are explicit.

## Recorded multi-stage examples

Mechanics analysis -> MechanicsDynamics -> trajectory -> ObservableSeries ->
statistical_summary:

- MechanicsDynamics already retains the mechanics analysis.
- The trajectory's diagnostics gains a detached descriptor of that conversion;
  it does not add a strong reference to the full conversion/analysis.
- Series already retains the trajectory; the descriptor records stored selection.
- Moments store only a bounded series origin and compact semantic context: units,
  selected component/label, sample count/regularity/time units, available solver
  tolerances and inherited numerical/sample approximation. No value/time arrays,
  selector callable or domain closure is retained by the new context.
- Symbolic energy identity remains scoped symbolic evidence; numerical trajectory
  and moments do not become physical validation.

Simulation -> dataset -> model/learning -> generalization:

- Dataset numerical reference retains actual solver algorithm/tolerances/span,
  selected grid and caller-identified parameters. Reference quality is numerical.
- Model provenance gains the dataset descriptor, declared reference-quality
  summary and known finite scalar reference tolerances, **not target arrays**.
- Learning already borrows its dataset; generalization already retains learning
  and its reference. Their descriptors add no additional source ownership.
- Generalization remains unknown for global validity; its sampled-error floor
  remains separate from reference-solver tolerances.

PINN problem -> training -> residual/reference diagnostics:

- Existing results legitimately retain problem/model/backend and query arrays.
- Detached origin describes construction/training/diagnostic operations without
  embedding these native objects.
- Established construction/shape checks, heuristic training costs and unknown
  physical/global correctness remain different claims. Declared analytical
  comparison targets are not silently inferred from a callable.

## Explicit dataset retention policy

`ScientificDataset(path; schema, source_retention=:retained)` keeps the M10D.2
compatibility behavior: ScientificDataset deepcopies provenance, including the
source trajectory, selector and arbitrary context. This can be expensive and
retains simulation state. It is deliberate existing ownership, now explicitly
named/documented, not a new lightweight guarantee. Read-only source conventions
and native solution retention continue to apply.

For a lightweight source route, use
`ScientificDataset(path; schema, source_retention=:descriptor)`.
It stores the detached trajectory origin instead of the native solution.
It retains the selected index/label/name and actual scalar solver tolerances,
algorithm/reference details. It explicitly lists omissions: source object,
source domain/context, unselected state labels and selector callable. Those
objects are neither copied nor retained through this provenance route. The
explicit dataset domain, ordered input/query names, reference quality, units,
RNG/grid declarations and selected sample data remain. This is explicit weakening
of source detail, not invention of missing context or an upgrade of reference.

The dataset still owns/copies its meaningful sample arrays and reference saved
grid under its original contract. Their size scales with selected data, not an
entire unselected source model/trajectory. This phase does not redesign dataset
storage or claim zero-copy serialization of native backend results.

## Ownership census

| Object | Existing ownership | M10D.3 addition |
|---|---|---|
| MechanicsDynamics/MechanicalLinearization/modes | Strong source fields and native matrices; original symbolic systems remain | Detached inspection descriptors, no duplicate source |
| TrajectoryResult | Native solution/problem/callable already retained | Mechanics parent descriptor only; does not eliminate existing closure ownership |
| ObservableSeries | Values borrowed in generic constructor; bridge materializes selected values/times; source/context may be retained | Detached origin accessor, no extra array ownership |
| Statistical moments | Compact PropertyResult payload | Bounded origin/context only; no upstream series/state retention |
| AtomisticSnapshot/TrajectoryView | Arrays borrowed unless copy_data; history/view legitimately retained | Inspection records existing policy; no new engine/state copy |
| ScientificSample/PINNPoints | Construction copies numeric coordinate/sample arrays | No new source retention |
| ScientificDataset | Samples/schema/reference/provenance copied; retained route can copy trajectory | Explicit descriptor opt-in and omissions; no silent policy change |
| ScientificModel | Network/parameters/state/schema; no target arrays | Detached dataset descriptor and scalar reference metadata |
| Learning/Generalization/PINN results | Dataset/problem/training/native solutions and sampled outputs retained | Descriptor access does not retain anything else |

## Bounded ownership evidence

The final bounded semantic gate compares 8 vs 4096 scalar samples, not a stress
workload or benchmark. Base.summarysize reported:

| Stored samples | Source series bytes | Detached origin bytes | Moment result bytes |
|---|---:|---:|---:|
| 8 | 380 | 72 | 368 |
| 4096 | 33084 | 72 | 368 |

Sizes are observations from this Julia runtime, not portable byte guarantees.
Object identity checks verify origin tokens and expected borrowed data. A
counterexample with an unexpected 4096-element source array in caller origin
metadata retained 32942 bytes before the review fix; the whitelist now refuses
that retention. Descriptor copying and Serialization roundtrip are tested.
The one bounded review is closed after regression fixes; it is not repeated.
