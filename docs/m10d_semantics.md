# M10D.3 — Unified scientific semantics

This is the semantic authority for the existing M1–M9 concepts and M10D.2
bridges. It extends, rather than rebuilds, the M10D.1 inventory and integration
matrix. Semantic consistency is not type homogenization. No new solver,
scientific algorithm, scientific bridge, or universal result container is added.

## Governing rule and scope

The same scientific concept has the same meaning across AML. A transformation
may preserve or weaken the strength of a claim, but must never silently
strengthen it. Strength is compared **within a claim's scope**, not by comparing
unrelated symbols in different result types. A symbolic energy-conservation
identity and successful integration of that model concern different claims.
The identity can remain established while the trajectory is approximate and
its physical validity unknown. Independent additional evidence may justify a
new explicitly scoped claim; a projection or relabeling alone may not.

## Canonical vocabulary derived from existing contracts

Scientific value equality is not provenance identity. `PropertyResult.value`
keeps its established scientific payload, equality, hash and destructuring
contract. Optional `PropertyResult.metadata` holds descriptive origin/context,
read through scientific_origin/scientific_metadata, not folded into the value.
The four-argument and PropertyResult{T} constructors remain compatible; metadata
defaults to nothing. No custom == or global identity registry is introduced.
This additive local correction is justified by the actual M10D.3 canonical
regression, not a reopening of the M10D.1 inventory/type hierarchy.

| Concept | Existing representation and meaning | Setter / downstream rule | Absence and forbidden inference |
|---|---|---|---|
| Established result | PropertyResult.status=:established: the specified property was established by its recorded method under its assumptions | Scientific operation that supplies the justification; preserve scope or weaken | Not an overall validation of an input model, physical system, backend or future computation |
| Numerical/approximate result | :heuristic, with numerical/sampled method, assumptions and controls | Numerical operation; preserve approximation or weaken to unknown | Not exact truth or certified error; a measured/stored coordinate is not a measured physical result |
| Unknown result | :unknown: no justified conclusion for that claim | Operation lacking sufficient evidence; never turn into false or absence | value=nothing is unavailable payload, not a negative scientific answer |
| Unsupported operation | Usually method=:unsupported or :unsupported_backend_api plus :unknown; some APIs refuse via ArgumentError or MethodError | Applicable operation/backend boundary; preserve reason | Unsupported is not a mathematical nonexistence result or failed numerical execution |
| Failed computation | Native trajectory retcode/success/completed, optimizer termination, exception | Backend/execution boundary; report separately from scientific claims | No new global :failed PropertyResult status introduced; failure does not prove a false physical theory |
| Unrequested work | Native :not_requested / :not_evaluated or missing optional diagnostics | Request/diagnostic orchestration | Not failure or lack of mathematical applicability |
| Unavailable metadata | nothing, missing, :unknown, unspecified unit labels; interface availability=:unknown | Source/adapter lacking information | Never infer units, coordinates, reference quality, tolerances, RNG seed or missing parents |
| Not-applicable metadata | Existing query classification :not_applicable; interface availability=:not_applicable for concepts not used by that operation | Operation with a justified inapplicability boundary | Distinct from unknown, false and failure; e.g. backend of an unsupported property operation, function-family extrapolation for scalar surrogate inputs |
| Scientific evidence | PropertyResult, local status/method/notes, scoped diagnostics and limitations | Operation establishing that particular claim | Retcode, low loss, sample agreement, compatibility and construction checks are not global scientific evidence |
| Reference data | Explicit comparison targets and caller provenance | Caller supplies; operation retains quality and trust boundary | Neither ground truth nor independent validation follows just from being a target |
| Analytical reference | reference.kind=:analytical where used: caller identifies analytical source | Caller/producer; preserve declaration, not certify | Numerical solution may not acquire this label |
| Manufactured reference | Explicit constructed/manufactured target, when caller records it; no new enum required | Caller records construction and scope | Exact satisfaction of a manufactured equation does not validate a physical model |
| Numerical reference | reference.kind=:numerical with actual solver/algorithm/tolerances/grid/span/parameters/error contract | Simulation adapter restricts label; downstream preserves | Solver completion, zero sampled difference and training cannot upgrade it to analytical/exact truth |
| Experimental reference | Observations marked experimental where declared; retain measurement/context/uncertainty | Data producer/caller | Never infer measured origin from a variable name or arbitrary array |
| Unknown reference quality | Missing declaration or PINN default :user_supplied_unknown_trust | Preserve missingness/default trust | Presence of a callable or target matrix is not analytical provenance |
| Method | Scientific operation or justification (linearization, normal modes, numerical integration, sampled diagnostics, learning architecture) | Producing scientific operation | Not interchangeable with backend or epistemic status |
| Backend | Computational library/algorithm/native version metadata | Actual backend adapter | Backend success is not scientific validation; package presence is not proof every package executes every operation |
| Approximation | Linearization, numerical integration, surrogate, sampled residual/error scope, backend derivative approximation | Producer; downstream unions relevant inherited scope or explicitly declares unavailable | Never erase integration/linearization while making a sampled result appear exact |
| Tolerance | Numerical threshold actually supplied/used: abstol/reltol, atol/rtol, relative_floor/relative_guard | Operation/actual source metadata | Not an error bound; missing backend defaults remain unknown; optimizer options are not all tolerances |
| Units | Unitful arithmetic, explicit scales, or caller annotation of numeric scales | Arithmetic that establishes dimensions or explicit caller declaration | Unknown is not dimensionless; no inference from position/time labels; strings are not conversions |
| Domain | Original-syntax constraints, callable admissibility, boundary context, or descriptive dataset bounds | Respective domain producer/caller; preserve interpretation | Sample extents are not a continuum domain; descriptive bounds are not validity guarantees |
| Coordinates | Explicit ordered variables/rows, stored time columns, particle-major Cartesian coordinates, component/label selector | Input/producer; projection records selected identity | No permutation, physical-name invention, fixed-particle or regular-grid inference |
| Source/origin | Immediate input/result association actually retained/recorded | Producing operation | No invented parent, durable identity or cryptographic reproducibility claim |
| Provenance | Origin plus actual method/backend/options/assumptions/reference/context information available in the source | Producer records; adapter projects with explicit omissions | A descriptor identifies an operation, not proof of reproducibility or scientific certification |

Metadata `availability=:known` means **present**, not established, accurate,
complete, or trustworthy. Structured units may be present while individual
labels remain "unknown". A known domain object can itself have :partial or
:unknown status. Read those native distinctions, not only availability.
`claims=()` means this inspected container has no general claim to expose; it
is not silently :established. No universal ordering is imposed on search,
compatibility, execution and epistemic vocabularies.

## Semantic census (existing representations, grouped repeated occurrences)

The following census uses the authoritative F01–F36 inventory and M10D.2 edge
findings as its index. Repeated field occurrences within a family have the
same contract below; native layouts remain authoritative. Classifications are
semantic, not judgments that differently shaped types must be rewritten.

| Occurrence / source family | Actual representation | Classification / disposition |
|---|---|---|
| Status, evidence, method, notes: core/contracts.jl and per-property M1–M9 results | PropertyResult(value,status,method,notes); :established/:heuristic/:unknown | CANONICAL within claim scope; common interface preserves fields and scope |
| RealDomain / MultivariateDomain (F02/F03/F05), critical/stationary/zero searches | status/method/notes; domain :partial; search :not_requested/nonisolated and local classifications | COMPATIBLE_VARIANT, not a single claim enum; original constraints remain original constraints |
| Comparisons F04/F24 | compatibility status plus checks/PropertyResults, metadata and explicit ComparisonInput context | COMPATIBLE_VARIANT; compatibility is neither physical truth nor independence; context association remains caller-asserted |
| Evidence F06–F13 mechanics/dynamics and F14–F16 modes | nested evidence properties; linearization.evidence; modes.evidence; matrix/representation/reconstruction metadata | CANONICAL scoped symbolic identities vs heuristic modes; historical evidence-location mismatch INCONSISTENT for discovery, addressed by inspection rather than layouts |
| Trajectory F09/F10/F13 | solution/problem/labels/diagnostics; success/completed/retcode/algorithm/abstol/reltol | BACKEND_SPECIFIC execution plus COMPATIBLE_VARIANT numerical evidence; physical validation NOT_APPLICABLE to retcode itself |
| Notes and approximation across F01–F36 | notes, limitations, diagnostic notes, method, residual/sample normalization | COMPATIBLE_VARIANT; legacy discovery INCONSISTENT, touched accessors expose distinct approximation scope; no parsing prose into stronger claims |
| Source mechanics -> dynamics -> trajectory | MechanicsDynamics.source; trajectory.problem but formerly no conversion parent | INFORMATION_LOSS fixed locally by detached diagnostics.origin; existing native ODE problem still owns its callable |
| Domain F02/F03/F05/F08/F11–F18 | symbolic restrictions, callable domain, radial intervals, atomistic boundary | COMPATIBLE_VARIANT scientifically different scopes; no artificial common domain type |
| Units mechanics/dynamics/derivative data F04/F08–F16 | symbolic expressions/numeric arrays without a universal unit schema; mode metadata/scales | MISSING_BUT_MEANINGFUL physical unit declarations; unknown stays unknown; no whole-library Unitful conversion |
| Units atomistics/statistics F17–F24 | Unitful values, unit strings, :unknown/:explicit_scales, derived variance/time/transport units | CANONICAL where arithmetic establishes dimensions; COMPATIBLE_VARIANT metadata; sample index is not seconds |
| Units ScientificDataset/learning F33/F34 | explicit units object / ordered string tuples; model schema copies it | COMPATIBLE_VARIANT caller declarations, not dimensional conversion or certification; preserved through generalization |
| Units PINN F29–F31 | numeric coordinate/target matrices; caller provenance may describe nondimensionalization | MISSING_BUT_MEANINGFUL physical units; accessor explicitly unknown, no PDE-symbol unit inference |
| Coordinates/state identity F05–F16 | ordered variables, q then v / canonical phase order, original ODE labels, selected component | CANONICAL local ordering; identity is actual label or u2 fallback, not physical naming inference |
| Coordinates atomistics F17/F19–F23 | particle-major Cartesian layout; explicit wrapped/unwrapped/boundary assumptions | COMPATIBLE_VARIANT, physical selection must remain explicit; no generic ODE particle inference |
| Time/sample ordering F10/F20–F24 and M10D.2 | saved native order, SamplingInfo increasing times/regularity, stored-only selection | CANONICAL; backward/duplicate clocks refused by series route rather than silently sorted; regularity is descriptive |
| Dataset coordinate/parameter rows and splits F33/F34 | input_names/coordinate_names, columns-as-queries, explicit descriptive bounds and splits | CANONICAL; no coordinate permutation, automatic split, resampling or continuum validity inference |
| PINNPoints/residual/reference ordering F29–F31/F34 | coordinate matrix plus generation/provenance; backend independent/block variable order | COMPATIBLE_VARIANT; previously MISSING_BUT_MEANINGFUL names and unchecked declarations addressed via provenance.coordinate_names; explicit contradictory names now refused |
| Tolerances F01–F16/F25–F34 | residual controls; trajectory diagnostics; mode metadata; inverse/learning controls; field_errors.relative_floor; reference guard | COMPATIBLE_VARIANT; retained where source exposes them; generic older scalar/derivative tuples with no stored controls remain MISSING_BUT_MEANINGFUL, not reconstructed |
| Backend metadata F17/F25–F34 | Molly provenance, native SciML/Optimization solution, PINN backend_metadata, Lux model/state/package versions | BACKEND_SPECIFIC; inspection exposes recorded public concepts, not extension implementation records as new APIs |
| Approximation F14–F16/F20–F34 | linearization, eigensolve evidence, sampled moments/errors/residuals, numerical reference, surrogate limitations | CANONICAL scope; touched inheritance no longer drops numerical-source approximation when projecting to series/moments |
| Reference quality F25–F34 | ObservationSet kind/provenance; inference problem reference; numerical dataset contract; PINN reference.value.provenance; GeneralizationAnalysis.reference | COMPATIBLE_VARIANT; labels/trust are explicit. Missing declaration MISSING_BUT_MEANINGFUL; no enum normalization or truth inflation |
| RNG F25–F34 | explicit RNG object at construction; provenance seed/type/package/initialization; dataset.rng | COMPATIBLE_VARIANT / BACKEND_SPECIFIC; type alone is not seed/state or reproducibility; deterministic symbolic work NOT_APPLICABLE scientifically |
| Grid/resampling F20–F24/F30–F34 | saved times/regularity; PINN collocation snapshot/strategy; dataset.grid; model resampling=:none | COMPATIBLE_VARIANT; no resampling or coverage proof inferred; PINN all-training history explicitly unknown |
| Ownership all existing families | borrowed snapshot/observable arrays; copied points/sample arrays; retained backend objects; dataset deepcopy of provenance | COMPATIBLE_VARIANT with documented policy; hidden whole-source costs INFORMATION_LOSS in ownership discovery now documented; opt-in detached dataset route avoids that cost |
| Bare sampled metric tuples and older inverse/learned-dynamics payloads | local evidence/provenance/controls, not one shared result layout | COMPATIBLE_VARIANT; missing upstream links MISSING_BUT_MEANINGFUL, reported as limitations; no guessed or retroactively reconstructed lineage |

## Units and domain rules

Unitful scalar observations and mathematically derived moments keep dimensions:
variance has squared units and standard deviation has original units. The
M10D.2 materialization refuses mixed known/unknown samples and incompatible
Unitful dimensions across a selected series. Compatible m/cm values remain
quantities. The dataset route refuses Unitful targets instead of stripping
units; callers must explicitly nondimensionalize and declare scales. Numeric
ODE labels do not establish physical units. Dimensionless declarations remain
known and distinct from unknown. Broader string-unit parsing and whole-library
unit-aware derivative/PINN arithmetic are not introduced.

Symbolic domains retain original-syntax exclusions and native status. ODE
callable domains retain their existing applicability contract. Atomistic
boundary metadata does not establish physical validity. Dataset bounds are
`descriptive_bounds_not_validity`. PINN declared domains are not residual
coverage claims. Sampled points alone never establish a continuum domain or
regular-grid meaning. A compact moment summary intentionally omits arbitrary
source-domain callables; its origin traces the source and it does not invent a
domain. The descriptor dataset route explicitly records omitted source context.

## Qualified public semantic inspection

`AnalyticMathLab.scientific_metadata(result)` and
`AnalyticMathLab.scientific_origin(result)` are PUBLIC_EXPERIMENTAL qualified
interfaces, not new exports. The F01–F36 export freeze remains unchanged. These
interfaces cover PropertyResult, Lagrangian/Hamiltonian analysis,
MechanicsDynamics, MechanicalLinearization, NormalModeAnalysis, TrajectoryResult,
ObservableSeries, AtomisticSnapshot/SystemAnalysis/TrajectoryView,
ScientificDataset/Model/LearningResult, GeneralizationAnalysis, PINNPoints,
PINNProblem/TrainingResult/Analysis. Unsupported unrelated types have no invented
fallback result. Native family accessors remain valid and need not share fields.

Metadata inspection returns scoped claims; method; backend; approximation;
units; domain; coordinates; tolerances; reference; execution; sampling; RNG;
operation options; ownership; and a detached provenance descriptor. Values other
than provenance can borrow native metadata/arrays and are read-only by convention.
Use **scientific_origin alone** when a detached small record is required.
Tolerances are actual known finite scalar tolerance options, not all solver
keywords or undocumented backend defaults. Empty unspecified PINN solver
options leave tolerances unknown. Relevant normalization/options remain separate.

For an explicit point schema use
`PINNPoints(X; provenance=(coordinate_names=(:x,:t),), generation=:explicit)`.
Declared names must match the operation's required order. Unnamed legacy points
retain the documented positional convention; no new name is inferred. PINN
residuals use each block's order, reference queries use the problem's order,
and heat_residual uses (x,t). Names cannot trigger silent reordering.

## Display/report honesty and limits

Existing trajectory, mechanics, mode, atomistic/statistics and PINN displays
present native status/diagnostics or explicitly sampled/unknown quantities.
The bounded display check found no need to redesign visualization. New metadata
inspection exposes approximation and caller-trust boundaries rather than
printing backend success as validation. Default generic display may include
native retained objects; it is not a promise of compact serialization. A
qualified metadata record is not a new validation report.

Some historical bare metric results lack all caller controls or lineage. Some
legacy learned-dynamics trajectories cannot reconstruct the upstream fit.
Those absences are explicit, not fixed by guessed parents. Constructor
hardening, presentation/navigation, default-thread portability (D024), and
comprehensive packaging remain later-phase work. M10D.1 and M10D.2 are not
reopened; their bridges and scientific meanings are reused.
