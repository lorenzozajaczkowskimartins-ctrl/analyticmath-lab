# M10D cross-milestone integration matrix

The first table is the frozen M10D.1 starting graph, not a new graph. M10D.2's
row-by-row revalidation and tested preservation matrix below supersede its
historical CURRENT_STATUS/API cells for the two implemented bridges. Existing bridges
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

## M10D.2 revalidation of the existing graph

Row numbers below refer to the first table in its original order. No family
classification or export changed; F09/F19 own trajectory selection and F31 owns
the constrained dataset constructor. F31 remains PUBLIC_EXPERIMENTAL; the
observable_series route uses the existing PUBLIC_STABLE F19 factory.

| Row / original edge | M10D.2 classification | Disposition |
|---|---|---|
| 1 captured scalar → number/derivative | EXISTING_BUT_METADATA_LOSS | Bare numeric result has no source; parent retained separately. D007/D017, M10D.3; legacy evaluation domain caveat unchanged |
| 2 scalar field → gradient/Hessian | EXISTING_AND_VALID | Ordered variables and open-domain gate verified; numeric arrays are not evidence containers |
| 3 radial potential → equilibria/force | EXISTING_AND_VALID | Radius domain, units, provenance and descriptive cutoff verified |
| 4 vector field → potential | DEFERRED_TO_LATER_PHASE | Existing verified-integrability contract unchanged; source/access conventions belong to M10D.3 |
| 5 Lagrangian → Hamiltonian | EXISTING_AND_VALID | Existing affine inversion returns a HamiltonianAnalysis inside PropertyResult; canonical ordering verified |
| 6 mechanics → M/C/K | EXISTING_AND_VALID | Equilibrium/domain/source retained; tiny coupled oscillator oracle |
| 7 M/C/K → modes | EXISTING_AND_VALID | Local source retained; unverified equilibrium/damping stay unknown |
| 8 mechanics → dynamics | EXISTING_AND_VALID | Source identity, original-domain restrictions and canonical order verified |
| 9 dynamics/ODE → trajectory | EXISTING_BUT_METADATA_LOSS | FirstOrderODE, labels/domain and solver diagnostics retained; original MechanicsDynamics/HNN training parent not a direct result link (D027) |
| 10 trajectory → series/statistics | EXISTING_AND_VALID | Was MISSING_VALID_BRIDGE; implemented explicit saved component/callable selection. Moments alone still have D007 |
| 11 generic ODE → atomistic trajectory | INVALID_GENERIC_BRIDGE | No particle identities/masses/boundary inferred; no automatic method added |
| 12 Molly → atomistic view/series | EXISTING_AND_VALID | Conditional fixed-box/history/time assertions remain mandatory; bounded existing optional gate rerun |
| 13 atomistic view → statistical/transport report | EXISTING_BUT_METADATA_LOSS | Existing lazy observables work; summaries need parent context. No new transport adapter; D007/D028 |
| 14 atomistic observable → moments/comparison | EXISTING_BUT_METADATA_LOSS | Exact statistics/units verified; compact moments omit source, ComparisonInput remains explicit |
| 15 atomistic snapshot + Hessian → modes | EXISTING_AND_VALID | Particle-major geometry/unit scales retained; equilibrium remains not_verified |
| 16 pair series → inference observations | EXISTING_AND_VALID | Frozen pair/frame/time order and explicit Unitful scales verified |
| 17 simulation → ScientificDataset | EXISTING_AND_VALID | Was MISSING_VALID_BRIDGE; exactly one constrained FirstOrderODE trajectory/scalar-field route, explicit schema only |
| 18 dataset → model/learning | EXISTING_AND_VALID | Tiny affine Lux fixture, one optimizer step; schema/order/scaling/IDs retained |
| 19 learning result → generalization | EXISTING_AND_VALID | Same tiny fixture; numerical reference, sample IDs/coordinates and unknown global evidence retained |
| 20 PINN → residual/reference diagnostics | DEFERRED_TO_LATER_PHASE | Existing explicit-point route unchanged; M10D.3 metric/evidence conventions, no PINN architecture changes |
| 21 HNN/UDE → trajectory | EXISTING_BUT_METADATA_LOSS | Existing source closure/domain retained but no unified fitted-parent accessor; D027, M10D.3 |
| 22 arbitrary result → comparison | INVALID_GENERIC_BRIDGE | Existing supported comparison families only; no universal scientific equivalence API |
| 23 result → visualization | DEFERRED_TO_LATER_PHASE | Existing registered displays remain; Figure is not archival evidence; M10D.3/M10D.6 |
| 24 low loss/sampled residual → global correctness | INVALID_GENERIC_BRIDGE | Learning evidence remains unknown after successful fit; zero sampled error/query membership is not a continuum certificate |

No additional missing bridge is implemented. No edge needs the
EXISTING_BUT_API_AWKWARD classification as its primary disposition here: where
manual context is awkward, its actual source-retention loss is recorded instead.

## M10D.2 tested metadata preservation

Scope is the stated public operation, not every imaginable metadata field.
"Absent at source" never means "lost". Source links allow inspection, not proof
of physical validity. Plain ODE/mechanical numbers have no physical-unit schema.
All new extracted arrays are owned snapshots; source/context links on series are
borrowed read-only. ScientificDataset retains its existing copied metadata/source
policy, which can copy the native solution too (D028); no ownership redesign.

Tests below abbreviate `test/m10d_interoperability.jl` as I, and
`test/m10d_interoperability_learning.jl` as L. M is the existing bounded
`test/molly_trajectory_statistics.jl` optional gate. All are executed; exact counts
and log paths are in m10d_interoperability_results.md.

| Source → target / API | Valid? / status | Units | Domain | Coordinates | Time order | Source/context | Evidence | Reference | Intentional omission / refusal | Test evidence |
|---|---|---|---|---|---|---|---|---|---|---|
| ScalarFieldAnalysis → derivative arrays / gradient,hessian | Yes / verified existing | Physical units absent at source | Original open-domain gate retained in parent | Input tuple order retained, including reversed named order | N/A | Parent report needed; arrays alone have no link | No certificate added | No reference asserted | Arrays do not embed report; invalid domain raises DomainError | I field/radial, exact quadratic derivatives and cancelled-domain hole |
| PotentialAnalysis → force/equilibria / analyze_potential,evaluate | Yes / verified existing | Explicit metadata retained in report | Radial gate retained | Radius meaning retained | N/A | Report provenance retained | Candidate/certificate vocabulary unchanged | Model supplied, not MD validation | Force number alone has no metadata; nonpositive radius refused; cutoff remains descriptive | I field/radial, harmonic radius oracle |
| LagrangianAnalysis → HamiltonianAnalysis / legendre_transform | Conditional / verified existing | Unit schema absent at source | Existing restriction pullback retained | (q,v) → explicit (q,p), not reinterpretation | N/A | Hamiltonian report retains transformed expression/assumptions, not full L parent | Verified affine inversion PropertyResult | Formal identity, not numerical truth | Velocities replaced by verified momentum map; unsupported force/inversion stays unknown | I mechanics, analytic oscillator energy; affected mechanics_dynamics restrictions |
| Mechanics → M/C/K / linearize_mechanics | Conditional / verified existing | Physical units absent at source | Original domain and equilibrium evidence retained | Source coordinate/velocity order | N/A | source === report | Local applicability only | Exact equilibrium check separate from numerical spectrum | Local matrices omit nonlinear dynamics as targets; unverified equilibrium remains unknown | I mechanics/local modes, K=[2 -1;-1 2] |
| MechanicalLinearization → modes / normal_modes | Conditional / verified existing | Plain scales; units absent at source | Accessible through source | Same displacement order, mass normalization explicit | N/A | source === linearization | Heuristic eigensolve, no strengthening | No global-stability reference | Local undamped modes only; damping/unverified equilibrium returns unknown | I mechanics/local modes, eigenvalues [1,3] |
| Mechanics → dynamics → trajectory / dynamics,trajectory | Conditional / verified existing with parent-link limitation | Physical units absent at source, Float64 boundary explicit | Original restrictions survive RHS/domain checks | (q,v)/(q,p) labels retained | Saved native order | Dynamics retains mechanics source; trajectory retains problem/field, not full conversion link (D027) | Formal conservation and heuristic drift kept separate | Solver success not accuracy proof | Symbolic parent not directly retained in path; energy_drift refuses unrelated path | I mechanics, cos(2t), -2sin(2t), energy 2; affected mechanics_dynamics |
| TrajectoryResult → ObservableSeries / observable_series | Conditional / implemented | Numeric units unknown; callable Unitful values retained; no guessed time unit | Predicate retained in provenance/source, not promoted to continuum validity | Explicit component index/unique label or (u,t) callable; labels retained | Exact saved sequence copied; no interpolation/sorting/resampling | Exact borrowed source + caller context + unchanged diagnostics | Partial-solve diagnostics unchanged; moments heuristic | No reference truth claim | Only selected scalar is target; source still has full state. Missing/invalid selectors, incompatible shape/units, non-scalar/nonfinite outputs, backward/duplicate times refused | I selection and saved-only tests: exact linear oracle, irregular times, no callable interpolant, partial source |
| Molly system/loggers → atomistic view/series / atomistic_trajectory,observable_series | Conditional / verified existing optional | Unitful retained when present; fixture unitless units unknown | Boundary/fixed-box assertions retained | Fixed-particle history asserted, not inferred | Explicit saved times and stride, not integrator dt | Borrowed logger/view; backend provenance retained | Observed/heuristic; missing potential not reconstructed | No MD accuracy certificate | Missing time stays unknown; coordinate logger is not scalar series; wrapped MSD withheld | M, two particles/eight steps; no large MD |
| Atomistic view → pair series → statistics / distance_observations,statistical_summary | Conditional / verified existing | nm/nm² arithmetic preserved | Boundary geometry recorded | Explicit pair/frame order | Frozen exact supplied physical times | Series keeps view; moments omit parent (D007) | Heuristic summary, standard_error=nothing | No independent/ground-truth assertion | Unselected particles/frames omitted from values; moments discard temporal context intentionally; invalid frame order refused | I atomistics, distances [1,2,3] nm, mean 2 nm, variance 1 nm² |
| Pair series → ObservationSet / ObservationSet(series; scales...) | Conditional / verified existing | Explicit compatible scales + original source units retained | Pair geometry via source series | One scalar variable and ordered columns | Actual saved times scaled explicitly, no sorting | source_series identity retained | Caller numerical observation kind, not truth | Actual source retained | Numeric scaled values; original quantities remain in source. Missing/index time or absent/incompatible unit scales refused | I atomistics + affected trajectory_inference (minimum-image/frozen ownership) |
| Atomistic snapshot + Hessian → modes / normal_modes(snapshot;hessian) | Conditional / verified existing | Explicit unit scales/angular frequencies retained | Boundary/source accessible, equilibrium not established | Particle-major Cartesian order | N/A | source === snapshot | equilibrium_status=:not_verified | No equilibrium truth inferred from supplied Hessian | Numeric scaled matrices, physical scales retained; no Hessian/masses/incompatible units gives unknown, shape mismatch refused | I atomistics + atomistic_modes, diagonal independent spectrum |
| FirstOrderODE TrajectoryResult → ScientificDataset / ScientificDataset(path;schema) | Conditional / implemented | Explicit ordered caller strings or unknown; never inferred or stripped | Explicit descriptive training bounds plus source predicate in provenance | Ordered model input + one (:t,) query row + selected scalar targets | Exact saved times become query columns | Existing copied source/context/selector/name/labels; parameters and units marked caller-declared | Diagnostics retained, no fit/physics claim | Forced numerical source + actual solver/algorithm/tolerances/grid/span + explicit unknown/error estimate | Unselected outputs excluded from learning targets; one completed run/one training sample only. Missing schema/split, wrong dimensions, partial solve, truth labels, implicit resampling, Unitful targets refused | I dataset: independent linear oracle, all schema fields, ordering, ownership, scaling; L |
| ScientificDataset → model/learning / learning_model,training_data,train | Conditional / verified existing optional | Schema strings and inverse output scaling retained | Descriptive bounds retained | Named input rows then query rows, original target columns | Query column order retained | Result retains dataset, batch IDs explicit | Optimizer termination never global correctness | Numerical dataset reference stays in result.dataset | Model excludes target/reference objects from its schema; no split inference; schema/ID mismatch rejected by existing contract | L, Dense(3=>1), explicit RNG/normalization, one step |
| Learning result → GeneralizationAnalysis / analyze(result) | Yes / verified existing optional | Output inverse scaling; units reachable via training dataset | Descriptive query classification, guarantee=:none | IDs/query columns retained | Same stored query columns | training === result | status=:unknown even after fit | Same numerical reference; no surrogate-exact claim | Sampled errors are not continuum norms; no invented heldout group | L, numerical reference/unknown error/only training group |

Backward trajectories are scientifically valid ODE results but are incompatible
with the current increasing-time series contract. Refusal, not reversal or
index-time relabeling, is the supported M10D.2 behavior. A series may represent
the stored part of a failed solve; this is not a complete-solve assertion. The
dataset route deliberately requires successful completion but still labels its
reference numerical, never exact. Its one-sample training requirement comes from
the existing dataset constructor; it does not infer a split from the trajectory.
