# M10D issue ledger

Baseline: `ff28e89bb08f95015d241091de7406d8f02d5861`. Severity describes
integration/release risk, not a retroactive failure of M10A/B/C scientific gates.
DEFERRED is an explicit phase decision, not resolved or verified. No finding
justifies new science. Runtime gate outcomes and review closure are recorded in
m10d_plan.md. M10D.1 findings remain frozen; M10D.2 dispositions and local
interoperability findings are added below without beginning M10D.3.

| ID | Subsystem | Category | Severity | Evidence | Root cause | Action | Status | Phase |
|---|---|---|---|---|---|---|---|---|
| D001 | ODE examples | Layout coupling | Medium | examples/scaling/large_oscillator_ode.jl and ode_ensemble.jl injected src/dynamical_systems/scaling.jl although src/AnalyticMathLab.jl already registers it | Obsolete interruption-era fallback could conceal registration regressions | Remove both fallbacks; leave helper internal; test package registration and scan examples | FIXED; layout red failed on exact two paths, then green | M10D.1 |
| D002 | Public boundary | Missing classification | High | src/AnalyticMathLab.jl export list grew through M9; architecture doc historical M4.5–M7 framing | No authoritative whole-library 1.0 policy | Assign every export to one family and explicitly include reachable unexported types; no aesthetic renaming | RESOLVED by inventory and coverage test | M10D.1 |
| D003 | Notebook | Internal helper leakage | Medium | notebooks/mechanics_addendum.jl used AnalyticMathLab._mc_zero for validation | Maintainer assertion copied into user example | Same symbolic simplification/zero check via public Symbolics operations; retain all scientific assertions | FIXED; targeted red reproduced | M10D.1 |
| D004 | Optional example environments | Dependency binding leakage | Medium | examples/operators/heat_family.jl, backend_probe.jl and examples/inference/neural_showcase.jl import Symbolics/ForwardDiff via AML; corresponding Projects omit direct deps | Example dependency convenience conflated with package re-export | Mark bindings INTERNAL; later declare example-owned deps and replace imports together with reproducible environment resolution; do not export backends | DEFERRED packaging cleanup, not a broken loader | M10D.5 |
| D005 | Analyze language | Discoverability | Medium | Eleven analyze methods; mdcheck/analyze_potential/statistical_summary/trajectory remain distinct factories; AbstractAnalysis includes input containers | Marker historically used beyond computed analyses | Document nine conceptual dispatch families and input→output distinction; preserve specialized verbs; docs navigation later | BOUNDARY RESOLVED; navigation DEFERRED | M10D.1 / M10D.6 |
| D006 | Scientific semantics | Status vocabulary | High | PropertyResult symbols; RealDomain.partial; CriticalPointAnalysis.not_requested/nonisolated; comparison compatibility statuses | Different claims encoded in local vocabularies | Map scope, not one indiscriminate enum; preserve existing behavior now | DEFERRED | M10D.3 |
| D007 | Provenance | Information loss | High | statistical_summary returns PropertyResult moments without parent series; ComparisonInput accepts series/parent/selection | Older result intentionally compact; comparison needs contextual metadata | Design lightweight retention/access conventions without guessing missing source | DEFERRED | M10D.3 |
| D008 | Dynamics/statistics | Missing narrow bridge | High | TrajectoryResult.solution/problem/labels versus ObservableSeries scalar values/sampling | No explicit observable/units/source selection contract | Add observable_series(path; component OR observable, context); saved samples only, unchanged diagnostics, unknown numeric units, early selector/shape/time refusal | FIXED; red missing dispatch, final selection/saved-boundary tests pass | M10D.2 |
| D009 | Simulation/learning | Missing scientific adapter | High | ScientificDataset requires family/splits/reference/grid/RNG; numerical reference constructor requires solver/algorithm/tolerances/grid/tspan/parameters/error | A solver output alone is not a labeled scientific family | Add exactly one explicit-schema FirstOrderODE trajectory → one scalar-field training sample route; numerical reference only, caller-declared parameters/units, actual solver metadata, no interpolation/split inference | FIXED; red UndefKeywordError from old generic constructor, schema/scaling/optional learning tests pass | M10D.2 |
| D010 | Units/coordinates/domain | Metadata mismatch | High | Unitful atomistic statistics; strings for unknown/sample index; Float64 ObservationSet/PINNPoints; descriptive dataset domains vs symbolic constraints | Different supported mathematical/scientific domains | Retain local contracts; explicit conversions with missing/unknown handling later; no Float64 generalization claim | DEFERRED | M10D.3 |
| D011 | Result containers | Ownership/constructors | Medium | Lagrangian accessors return stored arrays; Hamilton equations copies; DerivativeData borrows, ScientificSample copies; outer positional struct constructors exposed | Mixed historical lifetime/validation patterns | Document read-only and factory preference now; bounded constructor/alias audit later, no broad rewrite | DEFERRED | M10D.5 |
| D012 | Learned dynamics extension | Absent-backend error language | Medium | learned_energy/vector_field/correction etc are empty generics in base; PINN/inference/surrogate wrappers instead throw ArgumentError | Method extension versus delegated-wrapper styles | Document MethodError vs guarded absence accurately; decide consistent error convention later without adding ambiguous fallbacks | DEFERRED; no registration defect demonstrated | M10D.5 |
| D013 | Surrogate extension | Coarse trigger dependency | Low | AnalyticMathLabSurrogateExt requires NeuralOperators even for a plain Lux surrogate | Shared implementation and one native operator route | Document all triggers; no mandatory dependency promotion or speculative extension split | ACCEPTED current architecture | M10D.1 |
| D014 | PINN activation | Incomplete error hint | Low | _pinn_extension error lists four packages; Project.toml extension requires SymbolicIndexingInterface too; examples/pinn declares all five | Human-readable hint predates complete explicit trigger description | Inventory records all five; improve user-facing setup/error docs in hardening phase; no loader behavior change | DEFERRED | M10D.5 |
| D015 | Public names | Apparent concept duplicates | Low | potential/analyze_potential, linearization/linearize_mechanics, sampled_summary/statistical_summary, three predict shapes | Same broad language, different scientific obligations | Explain differences; no redundant alias or indefensible rename established | RESOLVED by explicit contracts | M10D.1 |
| D016 | Backend/provenance | Version-sensitive result payload | Medium | PINN/native solutions, Optimization result, Lux model/state retained in results | Intentional inspectable ecosystem integration | Classify ML families PUBLIC_EXPERIMENTAL; keep native objects, avoid promising stable backend layouts | POLICY RESOLVED; accessor semantics DEFERRED | M10D.1 / M10D.3 |
| D017 | Diagnostics | Evidence/tolerance location | Medium | trajectory.diagnostics vs PropertyResult.method vs provenance.evidence; not all metric tuples retain source/tolerance | Specialized result schemas | Map existing evidence and missing controls; add lightweight conventions later, no universal container | DEFERRED | M10D.3 |
| D018 | Atomistic/ODE bridge | Invalid inference boundary | High | ODE solution lacks masses/species/boundary/fixed-particle identity; MSD requires explicit coordinate semantics | Numerical state does not uniquely encode physical particles | Keep generic atomistic conversion absent; new selector rejects unsupported particle-schema fields and ambiguous output; no artificial throwing API | VERIFIED boundary; method absence and invalid-schema negative controls pass | M10D.2 |
| D019 | Documentation | Historical architecture wording | Low | docs/architecture.md still calls M8/future Molly outside the historical M7 section while earlier sections cover M9 | Append-only milestone history | Add current-authority link/banner; keep historical evidence, full user/wiki reorganization later | RESOLVED navigation; rewrite DEFERRED | M10D.1 / M10D.6 |
| D020 | Scale instrumentation | Internal experimental surface | Low | _scale_ode_problem and replayable/statistical/partial helpers used by examples/scaling | Maintainer measurements are not ordinary user APIs | Label directory and helper use explicitly; no export promotion; freeze old measurements unchanged | RESOLVED | M10D.1 |
| D021 | Optional environment registration | Stale tracked manifest | High | PINN loader audit initially passed 9/11: inference/dynamics absent despite loaded triggers; tracked PINN/Molly/inference manifests contained older AML extension metadata | Julia reads path-dependency extension registration from the resolved manifest, not just current source | Preserve manifest backups, Pkg.resolve offline, assert extension/weakdep metadata parity before imports; document fresh-process recovery. Only AML package records changed, no dependency versions or Projects changed | FIXED; four environments each pass 13/13 | M10D.1 |
| D022 | Loader audit | Transitive trigger expectation | Medium | After metadata refresh, NeuralPDE loads NeuralOperators and therefore AML surrogate extension as well | Initial manual test expected only explicitly requested backend families | Include surrogate activation in the pinned PINN environment expectation; retain ambiguity check over all loaded AML extensions | FIXED; PINN loader 11/11 plus metadata 2/2 | M10D.1 |
| D023 | Notebook text | Stale milestone wording | Low | mechanics_addendum final message says future molecular dynamics is not implemented, despite later optional Molly integration | Historical M7 example language predates M8 | Replace with the precise statement that these mode checks do not run molecular dynamics | FIXED; scientific assertions unchanged | M10D.1 |
| D024 | Canonical test environment | Default-thread portability | Medium | Default canonical stopped at test/m10c_guardrails.jl:20 with Julia threads=1 and BLAS threads=6; replacement with JULIA_NUM_THREADS=1 and OPENBLAS_NUM_THREADS=1 passed 4847/4847, 170 reported testsets, exit 0 | Test budget takes its ceiling from Threads.nthreads(), while ScaleHarness correctly enforces both Julia and BLAS counts; default BLAS initialization can exceed that ceiling | In M10D.5 define/document portable test-environment thread setup without weakening guardrails; retain explicit one-thread canonical environment now. No harness/test redesign in M10D.1 | DEFERRED hardening; controlled-environment verification passed | M10D.5 |

## Phase ownership and bounded review rule

### M10D.2 local findings and explicit semantic deferrals

| ID | Subsystem | Category | Severity | Evidence | Root cause | Action | Status | Phase |
|---|---|---|---|---|---|---|---|---|
| D025 | New trajectory observable bridge | Unit coherence | High | Review counterexamples: scalar callable returns meters then seconds, or plain numbers then meters; original series unit label inspected only first sample | Reusing ObservableSeries constructor alone did not validate an entire newly materialized selection | Locally refuse incompatible dimensions and known/unknown unit mixtures; retain compatible m/cm quantities without stripping | FIXED; two counterexamples red, final focused green | M10D.2 |
| D026 | New dataset bridge | Selected name loss | Medium | Review counterexample: selection=(observable=fn,name=:combination) name absent in resulting provenance | Selector record carried callable/component/label but not series display name | Retain provenance.observable_name; do not redesign ScientificSample | FIXED; counterexample red, final focused green | M10D.2 |
| D027 | Existing mechanics/learned dynamics → trajectory | Source linkage | Medium | MechanicsDynamics has source; trajectory retains FirstOrderODE/field/domain/labels but not full MechanicsDynamics parent; HNN/UDE fit provenance likewise remains upstream | Existing trajectory container has problem and diagnostics, no general upstream-parent accessor | New adapters preserve everything present and explicit caller context; M10D.3 should define lightweight source access/retention without universal wrappers | DEFERRED; no new loss introduced by M10D.2 | M10D.3 |
| D028 | Series/dataset ownership | Retention/lifetime policy | Medium | New series owns selected arrays but borrows source/context; existing ScientificDataset deepcopies provenance, including a retained native trajectory; statistical moments still need external parent (D007) | Different existing ownership contracts and no common source-retention convention | Document costs/read-only convention; preserve current contracts. Later choose lightweight source references/snapshots and policies for closures/mutable contexts | DEFERRED; no broad ownership change | M10D.3 (API hardening remains D011/M10D.5) |
| D029 | Numerical reference metadata | Vocabulary/normalization | Medium | Existing reference.kind=:numerical and error=:unknown are representable; error meaning is unconstrained globally, algorithm can be a type versus symbol/string, units/domain/evidence use family-specific containers | ScientificDataset metadata fields intentionally open; not a unified semantic framework | Local adapter requires numerical description and unknown/documented estimate, stores actual diagnostics and marks caller claims. M10D.3 scope status/error-quality vocabulary and backend/tolerance/source access alongside D006/D010/D017 | DEFERRED; local truth inflation refused | M10D.3 |

M10D.2's exactly one parent interoperability review is closed after D025/D026
red/green fixes. No M10D.2 blocker remains. Backward-time series refusal,
single-training-sample dataset scope, explicit parameter/unit declarations and
copied source provenance are documented constraints, not weakened contracts.
Test-fixture corrections (Legendre already returns an analysis, symbolic expand
before zero comparison, and optional Lux/NeuralOperators transform-name
qualification) changed no pre-existing production subsystem.

### Historical M10D.1 ownership rule

Only D001–D003, D021–D023 and documentation/boundary decisions belonging to M10D.1 are
implementation changes in this phase. D004, D012 and D014 are user-hardening
issues, not evidence that the optional extensions fail to register. They are
explicit future obligations, not hidden claims of universal API uniformity.
The M10D.1 freeze preserves behavior when uncertainty exists. The final 1.0 audit
must revisit unresolved high-severity later-phase entries; this checkpoint is
not the release verdict.

## M10D.3 semantic dispositions and single bounded review

The semantic census/specification is docs/m10d_semantics.md; ownership/interface
details are docs/m10d_provenance.md; gate evidence is docs/m10d_semantics_results.md.
M10D.1/M10D.2 remain verified, with no rerun of their audits or reviews.

| ID | Scope | Evidence / disposition | Status / owner |
|---|---|---|---|
| D006 | Scoped vocabulary | Native claim/search/domain/compatibility/execution vocabularies documented separately; touched inspection preserves scope and never flattens to one status | RESOLVED M10D.3 semantic contract; native symbols preserved |
| D007 | Compact statistics provenance | Source series exposes detached origin and units/time/selection/tolerance/approximation; frozen moment leaf intentionally has no context storage | RESOLVED honest inspection boundary after D038; isolated origin unavailable, existing explicit series/ComparisonInput context required |
| D010 | Units/domain/order | Original units/bounds/constraints preserved under native contracts; unknown not dimensionless; declared residual/reference row names validated without reordering | RESOLVED bounded M10D.3 policy; no new units subsystem |
| D016 | Backend result access | Qualified semantic inspection exposes public concepts while preserving native backend ownership and version sensitivity | RESOLVED M10D.3, remains PUBLIC_EXPERIMENTAL |
| D017 | Evidence/tolerance discovery | Scoped interface retains solver/mode thresholds and sampled relative guards/floors; unknown defaults not guessed | RESOLVED touched paths; older bare tuples without source controls remain documented limitations |
| D027 | Conversion origin | Mechanics conversion origin reaches trajectory/series through detached descriptors; isolated moments have no ancestry storage | FIXED mechanics path M10D.3; legacy learned-dynamics absent fit-parent and context-free leaves remain explicit limitations, not invented links |
| D028 | Source retention | Existing retained/copying policies documented; opt-in dataset source_retention=:descriptor explicitly omits arbitrary source/context/callback | RESOLVED M10D.3 lightweight route; constructor/alias hardening remains D011/M10D.5 |
| D029 | Reference vocabulary | Numerical adapter refuses analytical/exact quality; model retains declared numerical kind/scalar controls without targets; generalization/reference comparison preserve caller trust | RESOLVED M10D.3; no certification of open caller declarations |
| D030 | Named residual coordinates | Declared (t,x) was accepted by fixed (x,t) heat operation; PINN block/reference row names were not checked | FIXED M10D.3; red ordering counterexample, base/optional negative controls green; unnamed legacy positional convention unchanged |
| D031 | Descriptor hidden retention | Single review: merging caller parent tuples preserved an unexpected 4096-element source; 32942-byte detached result; malformed origin also crashed inspection | FIXED M10D.3; whitelist/schema, one parent, eight levels, malformed association absent; size/serialization/depth tests |
| D032 | Numerical approximation loss | Single review: series/moment accessor dropped source numerical_integration tag while reporting sampled data | FIXED at source-bearing series; D038 restores context-free moment layout, heuristic method/evidence retained, absent inherited tags explicitly unavailable rather than exactness |
| D033 | Options/tolerance confusion | Single review: every PINN solver option was called a tolerance; model could retain arbitrary reference tolerance metadata | FIXED M10D.3; explicit finite scalar tolerance-key projection, unknown when unspecified; options remain separate |
| D034 | Flagship comparability | One-system workflow explicitly checks quantity, model/parameters, coordinate/state order, initial conditions, units and exact samples before comparison; analytical oracle is independent, dataset remains numerical, finite learned errors do not imply physical/global validity | RESOLVED in M10D.4 flagship scope; focused compatibility/negative tests pass; see m10d_flagship_results.md. No universal comparison/ranking API |
| D035 | Open metadata/constructor policy | Native positional records/open user metadata are not certificates; string units are declarations; known backend defaults absent from results cannot be recreated | DEFERRED M10D.5 with D011; no broad constructor/unit/backend hardening |
| D036 | Semantic navigation | Qualified experimental accessors and native family contracts need user-facing navigation/examples | DEFERRED M10D.6; no Wiki work |
| D037 | Canonical value/provenance compatibility regression | Identity embedded in statistical_summary.value broke unchanged test/m10c_streaming.jl:12 despite equal moments | First correction d742e18 separated identity into optional leaf metadata; equality fixed, but D038 exposed structural incompatibility. Final correction keeps original value without leaf storage |
| D038 | Canonical public structural regression | Replacement canonical at d742e18 failed unchanged test/architecture.jl:27: fifth metadata field on PropertyResult | Restore exact verified-M10D.2 four-field struct/generated constructors and statistics producer; leaf origin unavailable, higher-level provenance preserved. Focused verification and final canonical recorded in semantic results |

Exactly one bounded parent semantic review used the question “Where can AML make
a scientific result appear stronger, more precise, better sourced, or more
physically meaningful than the evidence actually supports?” It covered touched
bridges, scoped evidence/reference/unit/domain/order/control meaning, relevant
display wording and ownership. It produced D031–D033, with D030 already fixed
during development. Fix disposition is checked through narrow counterexamples,
not a repeated review. No independent reviewer/subagent approval is claimed.
No unresolved M10D.3 blocker remains after the recorded green gates. D024 remains
deferred to M10D.5. No benchmark, stress/scaling work, push/tag or later phase.

## M10D.5 hardening dispositions

The earlier phase rows above are historical. Current evidence and commands are in
m10d_user_research_results.md; first-hour contracts and limitations are in
m10d_user_research_hardening.md. Final plain canonical is pending.

| ID | Disposition | Status |
|---|---|---|
| D004 | Examples directly import/declare ForwardDiff and Symbolics; three manifest project hashes resolved without dependency-record/version changes | FIXED; packaging and optional gates pass |
| D011 / D035 | Document factory versus raw record, borrowed versus copied data, open caller metadata and checked Float64 boundaries; preserve frozen layouts. Add actionable missing dataset fields and series name/time/unit refusals | RESOLVED bounded first-hour scope; raw positional containers are not scientific validators |
| D012 | Narrow model-typed learned-dynamics fallbacks explain Lux/Optimization absence; activated extension methods remain more specific | FIXED; absence gate and both load orders pass, no detected AML ambiguity |
| D014 | PINN activation error lists SymbolicIndexingInterface alongside the other four triggers | FIXED; base error and both PINN activation orders pass |
| D024 | Correctness fixture budgets max(Julia threads, BLAS threads); smaller explicit ceiling still refuses. No global BLAS import mutation; production harness unchanged | Focused PASS at Julia/BLAS 1/6 and 2/3; plain canonical pending |
| D039 | Default Molly System has loggers=(); keyword defaults called unsupported get before public fixed_box/logger refusal. Treat empty tuple as absent logger, preserve NamedTuple/dictionary behavior | FIXED; retained red, both load orders and 47-assertion stored-frame regression pass |

One bounded parent first-hour review is recorded, not repeated. Dataset row shape
and operators RNG-provenance omissions were new test-fixture corrections, not
scientific feature changes. SparseArrays/Serialization isolated-test imports are
declared and probed before canonical. No push, tag, subagents or M10D.6 work.
