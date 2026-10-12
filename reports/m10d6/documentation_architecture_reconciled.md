# Reconciled documentation architecture — M10D.6A

Baseline: `377a3c45905d0e16dba1fc2adc9d8eb3dcff14ca`.
Status: design complete for this source audit; documentation implementation,
Documenter installation/build, Wiki answers and publication have not begun.
This supplements, rather than overwrites, `documentation_architecture.md`.

## Authority and reader journey

The README is a short entry point: purpose, supported scope, honest boundaries,
one base-only starter, one flagship pointer, optional activation, and links.
Documenter is the proposed versioned technical source of truth for contracts.
The Wiki is a question-led discovery layer linking to that technical reference,
not a second signature/default table. Historical milestone records remain frozen.
Source at the stated baseline outranks stale future/pending prose. Family ownership
and stability remain those of `exports.json`; M10D.2 bridges, corrected M10D.3
semantics and M10D.5 hardening qualify the older family synopsis.

Every tutorial follows input declaration → operation → stored result → evidence
interpretation → domain/unit/order/ownership limitations → optional presentation.
A marker supertype, accepted raw constructor or rendered Figure does not certify
scientific validity. The qualified experimental metadata interfaces remain
additional to the explicit exports, without promoting internal types.

## Proposed technical pages and family assignment

These are destinations to create later, not existing links. Symbol anchors must
be defined explicitly when documentation is implemented. Shared generic ownership
is unique, but its overloads link to every affected scientific family.

| Proposed reference page | Primary families / additional interfaces |
|---|---|
| reference/core.md | F01–F02 |
| reference/scalar.md | F03–F04 |
| reference/derivatives.md | F05–F06 |
| reference/vector.md | F07 |
| reference/dynamics.md | F08–F09 |
| reference/mechanics.md | F10–F14, including dense modes |
| reference/atomistic.md | F15–F18 |
| reference/statistics.md | F19–F22, F24 |
| reference/transport.md | F23 |
| reference/comparison.md | F25 |
| reference/scientific-ml.md | F26–F30, F33–F34; experimental payloads |
| reference/datasets.md | F31–F32 |
| reference/plots.md | F35; payload stability inherited separately |
| reference/evidence.md | Qualified scientific_metadata/scientific_origin; F01 cross-link |
| guides/api-boundaries.md | F36 INTERNAL: reachable fields, not constructor promises |

Normalize earlier draft target aliases to this table: `reference/Fxx.md` goes to
its assigned page, `reference/modes.md` to `reference/mechanics.md#normal-modes`,
`reference/pinn.md` and `reference/learning.md` to relevant sections of
`reference/scientific-ml.md`. Earlier question inventories' `reference/vector.md`
and `reference/scalar.md` remain aligned. Question targets are explicit proposals;
no unresolved proposed path is represented as a deployed page.

The navigation also needs installation.md; extensions/index.md and plotting.md;
guides/evidence.md, provenance.md, ownership.md, units.md, precision.md,
computational-regimes.md and resource-limits.md; troubleshooting/inputs.md;
tutorials/calculus.md, trajectories.md and one-system-many-methods.md.
The architecture is a navigation/coverage specification, not a promise to generate
one page per exported name or duplicate every historical guide.

## Public-reference contract template

Each exported symbol uses `api.json`, preserving all reviewed variants:

1. Unique ownership and stable/experimental status; qualified-only distinction.
2. Literal public signatures, required keywords and defaults. Separate raw field
   constructors from validated factories; no native backend default guesses.
3. Input shape/order, copied versus borrowed content, source retention.
4. Returned shape/fields, statuses and the scope of each scientific claim.
5. Known exceptions, structured unknowns, unrequested diagnostics and partial
   solver returns. Internal error helpers are not necessarily private to callers.
6. Units, original domain, coordinate conventions, numeric precision boundaries.
7. Optional activation packages and native backend escape-hatch limitations.
8. Resource controls, allocation/preflight scope and unavailable alternatives.
9. Source/hash citations and relevant tests/examples, clearly static versus run.
10. Dedicated docstring/guide gaps and any unresolved interpretation.

For shared `analyze`, `evaluate`, `normal_modes`, `train`, `predict`, `plot`,
`observable_series` and `loss_breakdown`, use an input-type → output → dependency →
contract cross-table. Never add an `analyze(::Any)` promise or universal schema.

## Resource and scientific corrections carried forward

`resource_controls.json` is the authoritative audit table. Two direct operations
expose byte-estimate preflights: matrix `normal_modes(...;max_memory_bytes)` and
`pair_distances(...;max_bytes)`. Pair count, history limits, query batch size,
summary-only results and source-retention options are not byte/RSS budgets.
No global AML memory setter exists. Exactly 32 scalar-field variables is accepted;
3000 is outside that symbolic path. A supplied 3000-square matrix is a different
modal route. Private native ODE/partial-chain experiments do not override public
symbolic/state limits. Adapter allocations can precede the modal gate.

Diffusion correction: `diffusion_estimate` numerically accepts eligible index-time
MSD. An existing test constructs such a fit. Physical-time semantics are necessary
for interpreting a physical coefficient, but no direct physical-clock refusal is
implemented. Do not repeat the stronger F23 synopsis or Q049 premise as behavior.
The current statistics guide already explains per-index fitted quantities.

Likewise, unknown provenance on an isolated PropertyResult is intentional; tokens
are process-local identities. Zero curl is not a global potential certificate,
small residual/loss is not physical validity, and a successful native return code
is not a rigorous error bound. Separate unweighted sampled metrics from statistical
uncertainty and independent reference error.

## Existing material disposition

Reuse source-grounded scientific explanation in existing guides and notebooks;
link or move only with an explicit migration table, preserving history and links.
`examples_tests_inventory.json` distinguishes demonstrations, optional/manual
checks, maintainer scaling, environment locks and test source. Training showcases
must not become default live doctests. Source assertions are not executed-test
proof. `documentation_inventory.json` indexes historical records and measurement
assets without claiming new semantic validation or regenerated figures.

Retain historical M10A/B/C and M10D verification reports, CSVs and figure bytes.
Tag their role through navigation, not destructive rewrites. Do not import old
pending/next-phase statements into current user capability descriptions.

## Deferred implementation and acceptance gates

In an independently authorized later phase, choose Documenter/compat in a docs-only
project; no dependency/version choice is established here. Review minimal snippets,
then execute bounded base examples in fresh processes. Optional environments and
rendering remain explicit separate gates; no heavy optimization/stress/doctest is
implied. Build technical docs, verify real source anchors and navigation, and only
then draft/publish Wiki pages. A URL or target in this audit is not publication.

Before implementation closure: reference all explicit exports and qualified
interfaces, retain stable/experimental boundaries, resolve every authoritative
correction, verify links without treating proposals as broken deployed links,
check small negative controls where separately authorized, and state actual
build/runtime evidence. These gates are not part of M10D.6A execution and have
not been silently counted as passed.
