# M10D.6F — GitHub Wiki and scientific FAQ

## 1. Status and scope

WIKI_SOURCE_VERIFIED and WIKI_PUBLICATION_READY for the local canonical source.
WIKI_PUBLISHED is false. This is documentation-only, not a release, deployment,
scientific feature or newly executed scientific verification. All local content
acceptance gates pass. The final local milestone identity and post-commit state
are read back separately as described in section 20.

M10D.6E remains deferred. No detailed M10D.6G refusal handbook, M10D.6H remediation
or M10D.7 work was implemented. No subagents were launched.

## 2. Starting Git state and draft recovery

Verified starting HEAD: 4e2143953baf23542d91ab62ee08c7673d5ce6cb.
Subject: [m10d] Complete M10D.6D public API reference. Branch: main.
Origin: https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab.git.
Actual remote main was read with git ls-remote and matched that SHA, including
at the final local verification gate; it was not assumed outdated.

This continuation started with five untracked status entries: wiki/ and the four
Wiki milestone reports/script. Eleven existing Markdown pages, a 90-row target
draft, and F1/F2 progress were recovered. The recovered report's original
clean-worktree statement was historical; this continuation did not begin clean.
No unrelated tracked or untracked changes were found. SHA-256 snapshots of every
recovered candidate are preserved in wiki_verification.json. No reset, clean,
stash, rebase, history rewrite or blind overwrite was performed.

Recent starting commits were 4e21439 (reference), b327e43 (tutorials), 97d8d13
(README), 143b5ee (audit), and 377a3c4 (scientific hardening). No other local Wiki
infrastructure was found in the bounded project-directory search.

## 3. Audit inputs and authority

The authoritative input is reports/m10d6/wiki_inventory.json: Q001–Q090,
90 questions, 17 categories, 25 P0 and 65 P1. The older wiki_questions.md and
wiki_questions.json contain 85 questions and were consulted only as historical
inputs. Neither inventory nor any historical milestone report was changed.

Also consulted: documentation_architecture_reconciled.md, api.json, exports.json,
qualified_api.json, resource_controls.json, refusal_review.json and
scientific_contracts.md under reports/m10d6/. Current README, tutorial index,
docs/src/index.md, reference index and API-boundaries guide supplied the current
reader journey. Selected scalar, core, derivative, vector, dynamics, mechanics,
atomistic, statistics, transport, comparison, dataset, scientific-ML, evidence and
plotting contracts supplied answer semantics. Existing scientific guides are
secondary context, not authority over implementation or reconciled contracts.

The checked audit still has 177 exports (130 stable / 47 experimental), two
qualified experimental inspection interfaces and 196 exported-contract variants.
Current bytes match all 70 files in the semantic refusal-audit snapshot.
Implementation was inspected narrowly where needed: the Molly adapter's logger
selection resolves missing versus valid-empty history for Q043.

## 4. Information architecture and exact pages

Twenty flat GitHub Wiki-compatible Markdown files: seventeen category pages and
Home.md, _Sidebar.md, FAQ-Index.md. Home introduces AML, installation, the first
scalar tutorial, reference source/local rendering, troubleshooting, resource
budgets, evidence and optional activation, with explicit pre-1.0 boundaries.
The sidebar is automatically injected by GitHub, not an ordinary route that Home
must link to. Each category has Home/index return links and a local question list.

| Category page | Unique authoritative question IDs |
|---|---|
| wiki/Getting-Started.md | Q001, Q002, Q003, Q004, Q005 |
| wiki/Calculus-and-Symbolics.md | Q006, Q007, Q008, Q009, Q010 |
| wiki/Linear-Algebra.md | Q011, Q012, Q013, Q014, Q015 |
| wiki/Vector-Calculus.md | Q016, Q017, Q018, Q019, Q020 |
| wiki/Numerical-Methods.md | Q021, Q022, Q023, Q024, Q025 |
| wiki/Differential-Equations.md | Q026, Q027, Q028, Q029, Q030 |
| wiki/Mechanics-and-Dynamics.md | Q031, Q032, Q033, Q034, Q035 |
| wiki/Trajectories.md | Q036, Q037, Q038, Q039, Q040 |
| wiki/Atomistic-Computing.md | Q041, Q042, Q043, Q044, Q045 |
| wiki/Statistics.md | Q046, Q047, Q048, Q049, Q050 |
| wiki/Scientific-Datasets.md | Q051, Q052, Q053, Q054, Q055 |
| wiki/Scientific-Machine-Learning.md | Q056, Q057, Q058, Q059, Q060 |
| wiki/Units-and-Precision.md | Q061, Q062, Q063, Q064, Q065 |
| wiki/Memory-and-Performance.md | Q066, Q067, Q068, Q069, Q070, Q086, Q087, Q088, Q089, Q090 |
| wiki/Scientific-Evidence-and-Provenance.md | Q071, Q072, Q073, Q074, Q075 |
| wiki/Optional-Extensions.md | Q076, Q077, Q078, Q079, Q080 |
| wiki/Troubleshooting.md | Q081, Q082, Q083, Q084, Q085 |

Navigation files created/recovered and finalized: wiki/Home.md,
wiki/_Sidebar.md and wiki/FAQ-Index.md. The table names every category file and
maps all 90 questions; the JSON reconciliation supplies individual destinations.
No one-page-per-question fragments or nested Wiki directory routes were created.

## 5. Question identity and answer format

All original wording and priorities are preserved byte-for-byte in structured
mapping records. No display aliases were needed (display_alias is null). Every
answer has one primary structured ID, an explicit qNNN named anchor, the original
Question, Short answer, Explanation, Practical action, Scientific boundary and
Related documentation. Evidence scope is explicit. Other pages link rather than
providing duplicate primary answers. The index lists all 90 questions grouped by
category, including Q066 and Q086–Q090.

## 6. Answer review strategy

A sequential parent review checked each complete answer against the relevant
current audited clauses and selective reference prose. It is not an independent
subagent approval or a mathematical proof performed by the validator. A 90-row
review ledger in wiki_verification.json records the claim, contract symbols,
question-specific rationale and verdict. Mapping evidence retains current file
hashes and verified reference section ranges where appropriate.

SOURCE_SUPPORTED denotes audited current behavior; HISTORICAL_VERIFICATION is
previous execution, not a rerun. USER_ASSUMPTION marks physical/schema/reference
declarations. UNAVAILABLE_CAPABILITY is not automatically a defect. There are no
new EXECUTED_EXAMPLE claims. Answers explain a supported action or interpretive
next step rather than merely saying "See documentation" or "Not supported".

## 7. Target reconciliation and corrected historical mappings

All 90 original documentation_target values are preserved in the separate
wiki_target_reconciliation.json. Each row records category, original question,
priority, actual answer page/fragment, current technical destination, useful
learning resources, version, individual decision and supporting evidence.

Explicit corrections include:

- Q001: scalar reference → current README Installation.
- Q016: scalar reference → vector/Jacobian contracts for rectangular maps.
- Q027: scalar reference → FirstOrderODE/AutonomousSystem dynamics contracts.
- Q056: scalar reference → experimental scientific-ML and PINN diagnostics.
- Q066: scalar-only target → derivatives plus dense modes and resource boundaries.
- Q076: generic ML target → exact activation table and unchanged Project.toml.
- Q084: unrelated derivative-only target → boundaries and audited resources.

Other improvements include Q005's actual threading contract, Q020's multivariate
lesson, snapshot-mode and energy-drift lesson links, and Q086–Q090's actual
atomistic/ML/dataset resources instead of a nonexistent resource-limits guide.
The actual one_system_learning.jl is linked, not a guessed learning filename.
Some existing guides are useful secondary resources; they are labeled repository
resources, not newly executed tutorials. Historical inputs remain unchanged.

## 8. Link and technical-reference strategy

All main-repository resource links pin the actually published starting revision
4e2143953baf23542d91ab62ee08c7673d5ce6cb. Forty distinct linked paths were confirmed
in the untruncated remote Git tree, then independently retrieved via raw HTTP
with status 200 and checkout-identical bytes. This verifies resource existence
and source content, not a deployed rendered documentation site.

TECHNICAL REFERENCE SOURCE means docs/src Markdown in the main repository.
GitHub does not execute its Documenter @ref/@docs directives. RENDERED TECHNICAL
MANUAL means the existing local Documenter build or a user's separate local build.
Documenter 1.19.0 / Julia 1.12.7 and the 17-page manual are historical M10D.6D
facts. No new Documenter build or public site deployment is claimed. Whole-file
repository links avoid guessed heading fragments and nonexistent future guides.

Wiki links are flat extensionless sibling page slugs, never filesystem-relative
links into the separate main repository. Explicit question anchors use the
user-content- prefix observed in GitHub's stateless GFM sanitization. Final
HTML rendering of all twenty pages confirmed the ninety actual question anchors
and every intended internal fragment. This is not live Wiki route verification.

## 9. Mathematical and physical semantics preserved

Original-domain capture precedes symbolic cancellation; scalar FunctionAnalysis
evaluation is not a universal domain guard. Formal derivatives differ from
checked smooth-neighborhood queries. Unknown roots and empty heuristic searches
do not prove absence or completeness. Rectangular Jacobians and local
linearizations keep ordered coordinates and their actual scope.

Mode normalization uses mass; sparse input remains dense. Snapshot curvature
is not equilibrium, and nonhyperbolic eigenvalues do not decide general nonlinear
stability. Legendre transformation is scoped verified affine inversion, not a
universal nonlinear/constrained/dissipative conversion. Energy drift and solver
completion are numerical evidence, not conservation or rigorous error bounds.

Saved observations are not internal integrator steps. Stored-data bridges do not
infer interpolation, physical identity or unit meaning. Descriptive fluctuations
are not IID mean uncertainty. Blocking/correlation and compatible comparisons do
not establish stationarity or independent experiments. Dataset reference labels
and numerical targets cannot be promoted to analytical truth by conversion.

Q049 preserves the corrected question and actual eligible index-time fitting:
there is no universal physical-time-only refusal. Physical diffusion needs a
justified clock, particle/coordinate convention and defensible diffusive window;
no independent-residual uncertainty or physical validity is invented.

## 10. Resource and provenance semantics preserved

Q066 separates 1–32-variable symbolic analysis (exactly 32 passes) from an existing
matrix route. The source-grounded dense estimate 24*sizeof(Float64)*n^2 gives
1,728,000,000 bytes at n=3000, versus default 536,870,912 bytes. Those quantities
were calculated with Python, not measured with an eigensolve. The preflight is not
peak RSS; adapters can allocate first. No global AML memory setter, generic HVP,
matrix-free, partial-mode or sparse-Hessian route is fabricated.

Q086 preserves pair-count/byte-output limits and RDF quadratic work. Q087 separates
query chunking from complete output/training storage. Q088 preserves earliest
PINN/inference entries versus rolling recent learned-dynamics/surrogate history.
Q089 limits summary_only to omitted arrays, not universal one-pass streaming or
released inputs. Q090 names descriptor omissions, not compression or a persistent
hash; selected data/schema and some caller metadata still occupy storage.

PropertyResult has exactly value/status/method/notes. Unknown is neither false
nor zero. Qualified experimental scientific_metadata/scientific_origin inspect
supported records without certification; metadata can borrow values. Origin is
process-local recorded identity, not a persistent reproducibility hash. Isolated
leaves can lack ancestry, and an independent analytical oracle need not derive
from the numerical path. No missing lineage is reconstructed.

## 11. Optional extensions and troubleshooting

The exact Project.toml trigger sets are preserved and programmatically checked:
Molly; Optimization; Lux+Optimization; Lux+Optimization+NeuralOperators; and
Lux+NeuralPDE+ModelingToolkit+Optimization+SymbolicIndexingInterface. All triggers
must be loaded; installation, activation and a scientifically valid model differ.
Plain Lux surrogates still require NeuralOperators on this route. No automatic
scientific backend or CairoMakie renderer choice is claimed.

Troubleshooting distinguishes unsupported dispatch, invalid data, unknown
scientific evidence, missing extensions, numerical resource refusal and genuine
supported-input defects. Public type/shape, domain, figure configuration, status,
notes and ownership checks precede repairs. Name qualification is separated from
scaling validity; borrowed-array mutation is separated from documented copying.
No internal constants or public validation bypasses are recommended. Deeper
refusal decision trees remain M10D.6G; links point to existing API boundaries.

## 12. Executable examples and intentionally skipped runtime checks

New executable Julia examples introduced: zero. Existing README and tutorial
commands are linked, not copied into new unverified snippets. Only documentation
validation, source hashing, byte read-back, stateless Markdown rendering, bounded
negative fixtures and integer resource calculations ran in this milestone.

Not run: cold-depot installation; Julia tutorial reruns; package/canonical tests;
new Documenter build; optional package installation; ML/PINN training; large
symbolic constructions; dense 3000-square eigensolves; stress/scaling benchmarks.
All prior scientific execution evidence remains historical. No dependency or
scientific source changes justify pretending those gates ran again.

## 13. Deterministic validation and negative controls

reports/m10d6/wiki_check.py uses Python 3.11+ standard libraries and Git. Default
invocation is offline. It checks inventory/priority/category totals, original
wording, exactly one primary heading/structured block per ID, global unique
anchors, four substantive prose fields plus linked evidence, high-risk semantic
distinctions, exact extension triggers, target hashes, flat filenames, index
coverage, Home/sidebar/category navigation and preserved baseline file content.
Its substantive heuristics complement, not replace, scientific review.

Actual commands (all final commands exited 0):

    python3 reports/m10d6/wiki_check.py --checkpoint F2
    python3 reports/m10d6/wiki_check.py --checkpoint F3
    python3 reports/m10d6/wiki_check.py --checkpoint F4
    python3 reports/m10d6/wiki_check.py --render --evidence-dir "$TMPDIR/m10d6f-sol/render"
    python3 reports/m10d6/wiki_check.py --verify-resources --evidence-dir "$TMPDIR/m10d6f-sol/render"
    python3 reports/m10d6/wiki_check.py --evidence-dir "$TMPDIR/m10d6f-sol/render"
    python3 reports/m10d6/wiki_check.py --self-test

Final result: 90/90 substantive answers; 17 categories; 25 P0 / 65 P1; 20 pages;
90 anchors; 278 resolved internal link occurrences; zero pending/missing/duplicate
answers or unresolved targets. Fourteen scratch-only negative fixtures are
rejected: missing/duplicate answer, wording drift, placeholder, broken page,
broken fragment, missing index question, future guide, fake deployment, wrong
triggers, automatic backend guarantee, missing resource distinction, missing
mapping and duplicate anchor. The canonical positive control passes.

A flat-root copying fixture passed with all twenty page bytes identical and no
Wiki repository initialization. Rendering manifests, source/HTML hashes, remote
resource hashes and review decisions survive in wiki_verification.json.

## 14. Checkpoints and resolved implementation findings

F1: recovered architecture/90-row reconciliation, verified actual branch/HEAD,
remote main and Wiki availability; original draft preserved.
F2: recovered forty answers/eight categories; structure revalidated before F3.
F3: added twenty-five answers/five categories; 65 total, 60 P1 / 5 P0 passed.
F4: added the remaining twenty-five answers/four categories; 90 total passed.
F5: complete sequential review, mappings, GFM rendering, source/resource/link
checks, negative fixtures, copy/readiness checks and final candidate inspection.
The local commit/read-back closure is identified in section 20.

The first F4 check correctly preserved its failed result while exposing an
incorrect validator requirement that _Sidebar be an ordinary reachable page.
The check now validates the injected sidebar separately and all ordinary pages
from Home. A text-edit attempt with insufficiently unique context was rejected
atomically; exact rereads and contextual edits succeeded without partial writes.
The recovered draft also records its earlier guessed learning path, resolved
before publication by locating the actual script. None is a scientific source fix.

## 15. External limitations and Wiki repository state

The main repository is public and its Wiki feature is enabled. Wiki Git ls-remote
returns exit 128, "Repository not found". The conventional Wiki web route returns
HTTP 200 only after redirecting to the main repository. No accessible remote Wiki
pages/history were found; remote Wiki existence/content cannot be independently
inspected. No remote Wiki commit is fabricated.

Stateless /markdown POSTs are rendering requests, not Wiki publication. GitHub
source-path and raw-byte checks do not verify Gollum routing, UI/sidebar placement,
editing behavior or anchors on a live published Wiki. Those remain explicit
post-publication checks. Repository blob pages contain source directives rather
than an executed Documenter manual.

## 16. Publication procedure and README follow-up

The same procedure is documented on Wiki Home:

1. Obtain separate authorization and re-inspect both remote repositories.
2. If no Wiki has been initialized, an authorized maintainer creates its first
   page through GitHub. Do not assume an access failure grants creation authority.
3. Clone the conventional analyticmath-lab.wiki.git into a separate directory;
   inspect actual branch/history/content and preserve unrelated pages.
4. Compare each flat canonical page, reconcile Home/sidebar/name/content conflicts,
   then copy reviewed pages into the Wiki repository root. Never blindly overwrite.
5. Run canonical coverage/link checks, review a Wiki preview, and commit there.
6. Push only with explicit authorization; no forced history replacement.
7. Independently read back the remote Wiki commit, Home/sidebar and every question
   destination before claiming WIKI_PUBLISHED.
8. Only then add a separately authorized README public Wiki link.

This milestone executes none of those publication operations. No premature
public Wiki link or invented public Documenter site was added to the README.

## 17. Changed files

Exactly 24 authorized files: the twenty Markdown pages named in section 4 and:

- reports/m10d6/wiki_check.py
- reports/m10d6/wiki_target_reconciliation.json
- reports/m10d6/wiki_implementation_report.md
- reports/m10d6/wiki_verification.json

No root README modification was needed. No src/, ext/, test/, examples/, notebooks/,
Project.toml, Manifest.toml, LICENSE, existing audit/tutorial/reference entries or
previous reports were modified. Generated rendering/copy/negative-fixture and
read-back evidence lives in scratch, not the Git candidate.

## 18. Integrity, candidate security and evidence limits

All 490 starting-commit files remain hash-identical and present, including source,
tests, dependencies, tutorials, technical reference and historical measurements.
The exact 24-path candidate contains no generated build/cache artifacts or
unauthorized files; high-confidence private-key/token/credential-URL scan has zero
findings. Final index modes, whitespace, staged hashes and committed blobs are
checked against the frozen candidate and recorded in the external read-back
ledger. Existing local ignored build output was neither regenerated nor deleted.

The deterministic validator does not prove every scientific statement, statistical
assumption or live publication state. The source-grounded parent review and
explicit scope labels provide that separate semantic obligation.

## 19. Open findings

No mandatory local content/coverage/link criterion remains open. Publication
requires separately authorized remote inspection/reconciliation and live checks.
The post-publication README link is intentionally deferred. M10D.6E deeper guides
remain deferred. M10D.6G detailed refusal/recovery trees require authorization.
Previously recorded M10D.6H findings (atomistic "Source: ." artifact and the large
ML reference/size-policy review) were preserved, not reopened or repaired.

## 20. Final local commit and Git read-back

Subject: [m10d] Complete M10D.6F scientific FAQ and Wiki source.
Parent: 4e2143953baf23542d91ab62ee08c7673d5ce6cb. Branch: main.
The final local commit is the commit containing this report; resolve its full SHA:

    git log -1 --format='%H %s' -- reports/m10d6/wiki_implementation_report.md
    git status --short --branch
    git show --format=fuller --stat HEAD

A committed report cannot embed its own containing SHA without self-reference.
The external post-commit read-back ledger at
/home/lorenzozm/.hermes/cache/scratch/m10d6f-sol/post_commit_readback.json and final
response record the full SHA, exact changed paths, parent/subject, clean worktree,
committed-blob equality, protected integrity and unchanged remote main. The commit
step occurs only after mandatory local verification and exact staging checks.
No push, tag, release, remote Wiki modification or deployment is authorized or
performed. The source is committed locally for a later authorized publication.
