# M10D cross-milestone integration matrix

M10D.1 maps this graph only. No new adapter is implemented here. Existing bridges
are supported only under the recorded assumptions. YES means the stated path
retains the quantity, not all imaginable metadata. PARTIAL requires explicit
context; UNKNOWN means no guarantee; N/A means not a claim of that operation.
A manual extraction is not counted as an existing metadata-preserving public adapter.

Columns explicitly audit SOURCE, TARGET, SCIENTIFICALLY_VALID?, CURRENT_PUBLIC_API?,
METADATA_PRESERVED?, UNITS_PRESERVED?, DOMAIN_PRESERVED?, COORDINATES_PRESERVED?,
EVIDENCE_PRESERVED?, PROVENANCE_AVAILABLE?, CURRENT_STATUS and M10D_PHASE.

| SOURCE | TARGET | SCIENTIFICALLY_VALID? | CURRENT_PUBLIC_API? | METADATA_PRESERVED? | UNITS_PRESERVED? | DOMAIN_PRESERVED? | COORDINATES_PRESERVED? | EVIDENCE_PRESERVED? | PROVENANCE_AVAILABLE? | CURRENT_STATUS | M10D_PHASE |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Captured scalar expression | Numerical value/derivative | YES, supported expression | analyze/evaluate | PARTIAL, report retains source | No inferred unit schema | PARTIAL: legacy scalar evaluate not checked | YES, scalar variable | Report retained; scalar output alone no | Original syntax in real study | EXISTING with legacy-domain caveat | M10D.3 |
| Scalar field | Numerical gradient/Hessian | YES, open smooth locus | analyze/gradient/hessian | YES in parent report | Plain numeric contract | YES, derivative gate | YES, variable tuple | Stored stationary evidence separate | Report expression/domain | EXISTING | M10D.2 preservation tests |
| Radial potential | Equilibrium candidates/force | YES, radial model | analyze_potential/evaluate, stored equilibria | YES, provenance/cutoff | Explicit metadata/scales; not inferred | YES, radial domain | YES, radius | YES, candidates versus certificates | PotentialAnalysis.provenance | EXISTING; cutoff not an MD force engine | M10D.2 preservation tests |
| Conservative vector field | Scalar potential | CONDITIONAL, verified integrability | potential(report) | PARTIAL in parent | Plain numeric contract | Supported smooth locus, topology limitations | YES | YES, PropertyResult | Parent needed | EXISTING; not zero curl alone | M10D.3 |
| Lagrangian analysis | Hamiltonian formulation | CONDITIONAL regular affine invertible momentum map | legendre_transform | YES, assumptions | Formal caller scales | YES, restriction pullback | YES `(q...,p...)` | YES, inversion evidence | System/report | EXISTING; unsupported returns unknown | M10D.2 preservation tests |
| Mechanical analysis | M/C/K linearization | CONDITIONAL at justified equilibrium | linearize_mechanics | YES | Formal/plain scalars | YES, domain evidence | YES, coordinates/velocities | YES, local claim | source retained | EXISTING | M10D.2 preservation tests |
| Mechanical linearization | Normal modes | CONDITIONAL undamped supported SPD mass | normal_modes | YES, metadata/source | Plain scaled numbers | Domain/equilibrium retained | YES | YES, unsupported not spectrum fabrication | source retained | EXISTING | M10D.2 preservation tests |
| Mechanics | Dynamics | CONDITIONAL parameters resolved and conversion valid | dynamics | YES source/order | Explicit numerical Float64, not general Unitful conversion | YES original restrictions | YES canonical state order | Source retained; numerical claims separate | MechanicsDynamics.source | EXISTING | M10D.2 preservation tests |
| DynamicalSystemAnalysis / FirstOrderODE | TrajectoryResult | YES for accepted initial/domain/time data | trajectory | YES problem/labels/diagnostics | Explicit numeric boundary, unit schema absent | YES callback/field gate | YES labels | Retcode/completion, not accuracy proof | Native solution/problem | EXISTING | M10D.3 metadata |
| TrajectoryResult | ObservableSeries/statistics | CONDITIONAL explicit observable/component and saved times | NO direct adapter; manual extraction possible | UNKNOWN on manual extraction | UNKNOWN unless explicit | Parent source needed | Selection must be explicit | No automatic transfer | Source available upstream | MISSING narrow adapter | M10D.2 priority 1 |
| Generic ODE trajectory | AtomisticTrajectoryView | NOT generically valid; only with explicit particle layout/masses/boundary/identity | NO automatic bridge | UNKNOWN | UNKNOWN | UNKNOWN | Particle identities cannot be inferred | Cannot infer MD validity | ODE source insufficient | UNSUPPORTED generic conversion | M10D.2 refusal boundary |
| Molly System/loggers | Snapshot/lazy trajectory/ObservableSeries | CONDITIONAL CPU, synchronized history, explicit fixed-box/time assertions | atomistic_snapshot/atomistic_trajectory/observable_series | PARTIAL historical metadata caller-asserted | YES Unitful, unknown unitless | Boundary provider retained | Fixed particles/order caller asserts | Observed quantities only | Molly version/storage/stride/time origin | EXISTING optional adapter | M10D.2 preservation tests |
| AtomisticTrajectoryView | Statistical/transport report | CONDITIONAL physical times and required identity/coordinate semantics | observable_series/analyze/MSD/VACF | PARTIAL result-dependent | YES when present; unknown otherwise | Boundary/unwrapping assumptions explicit | YES if assertions valid | YES, descriptive/heuristic vs unavailable | View/series sampling provenance | EXISTING | M10D.3 retention |
| Atomistic observable result | Statistical moments/comparison | CONDITIONAL scalar samples and compatible context | ObservableSeries/statistical_summary/ComparisonInput | PARTIAL caller carries parent | YES arithmetic, context needed later | N/A to moments; selection relevant | Explicit sample/particle selection | PARTIAL summary drops source | Series/ComparisonInput can retain it | EXISTING MANUAL composition | M10D.3 priority |
| Atomistic snapshot + supplied Hessian | M7 normal modes | CONDITIONAL symmetric Cartesian Hessian and masses/scales | normal_modes(snapshot;hessian) | YES | YES explicit length/mass/stiffness/frequency scales | Equilibrium NOT certified | YES particle-major Cartesian | YES, equilibrium_status=:not_verified | source snapshot + metadata | EXISTING; no Hessian estimation | M10D.2 negative controls |
| Atomistic pair-distance series | Parameter inference observations | CONDITIONAL actual physical time/scales | distance_observations; ObservationSet(series) | YES narrow pair provenance | Explicit compatible scales | Minimum-image choice retained | Pair/frame/time order explicit | Observation provenance, not truth guarantee | Pair/source/scales/time | EXISTING | M10D.2 preservation tests |
| Simulation result | ScientificDataset | CONDITIONAL explicit family/input/output/query/splits/reference accuracy | NO general adapter; constructors exist | Must supply schema/reference/RNG/grid | Must explicitly supply | Descriptive training/query bounds | Must define input names/columns/sensors | Numerical reference needs solver/tolerances/error | Required numerical reference metadata exists | MISSING constrained adapter/specification | M10D.2 priority 2 |
| ScientificDataset | ScientificModel / learning result | YES within scalar-field surrogate/operator contract | learning_model/training_data/train | YES schema/normalization | Metadata + inverse output scaling | Descriptive bounds, no validity proof | YES fixed sensors/row order | Fit separate from physics/generalization | Dataset/model/result provenance | EXISTING optional | M10D.2 preservation tests |
| ScientificLearningResult | GeneralizationAnalysis | YES split-specific sampled evaluation | analyze(result) | YES training/dataset/reference | Physical output errors, declared units | Classify query only | YES sample IDs/query columns | YES no universal generalization claim | training retained | EXISTING optional prediction | M10D.2 preservation tests |
| PINNTrainingResult | Residual/reference diagnostics | YES at explicit points/roles | analyze/result loss_breakdown | YES points/strategy/source | Backend-specific equation units, no automatic normalization | Stored symbolic domains/point declarations | YES independent/dependent/block order | YES sampled only, reference trust explicit | training/problem/provenance | EXISTING optional | M10D.3 metric semantics |
| HNN/UDE trained result | M6 trajectory | CONDITIONAL canonical/dimension/state constraints | predict | PARTIAL trajectory stores closure, not a unified fit provenance record | Plain numeric | UDE checks known domain during RHS | YES canonical/known labels | Completion not learned physics validation | Fit provenance upstream | EXISTING; provenance accessor missing | M10D.3 |
| Arbitrary scientific result | Comparison | NOT automatically valid across unlike quantities | compare only supported MD/statistical reports; compare_derivatives separate | Requires explicit context | Compatibility checked only for supported comparisons | Match supported scope | Match selections/layout | Cannot equate heuristic and proof | Parent wrappers where supported | UNSUPPORTED universal comparison | M10D.2 scope/refusals |
| Stored scientific result | Visualization/report | YES for registered methods | plot/specialized views/show | Stored labels/evidence consumed | As stored, not guessed | Original-domain masks where relevant | As stored | No new proof from rendering | Parent held outside Figure | EXISTING; Figure not archival scientific result | M10D.3 provenance / M10D.6 docs |
| Low loss / small sampled residual | Global physical correctness | NO without independent justification | NO certificate API | N/A | N/A | Finite samples not global domain | N/A | Must remain unknown | Training evidence insufficient | INVALID inference, preserve refusal | M10D.3 / M10D.7 |

## Priorities and acceptance boundaries for M10D.2

1. Define a narrow TrajectoryResult → ObservableSeries selection contract. Require
   named component or explicit observable, use actual saved times, retain source
   and coordinate/unit context. Reject unsupported/missing identity rather than
   automatically treating ODE components as particles. Test irregular sampling,
   incomplete solves, ordering, and unknown-unit behavior at tiny sizes.
2. Specify one existing simulation-to-ScientificDataset route only if the physical
   family, split identity and numerical-reference error are supplied. Do not infer
   analytical truth from a solver return code. Avoid generic serialization APIs.
3. Add bounded preservation/negative-control tests along existing mechanics →
   dynamics → trajectory and atomistic → observation/modes paths. Reuse their
   current algorithms; do not reopen numerical/scaling audits.
4. Carry source/context enough for subsequent M10D.3 semantics work without
   prematurely designing a universal provenance container or comparison API.

No direct bridge is promised between every pair of milestones. PINNs, MD,
scalar calculus and operators remain different scientific models where appropriate.
