# AnalyticMathLab.jl public API reference

This manual documents source-grounded contracts, not an idealized future API.
AML is pre-1.0 (0.1.0). A stable classification is not a post-1.0 compatibility
promise; experimental payloads remain experimental under shared stable generics.

Start with the [reference index](reference/index.md). Scientific tutorials remain
canonical in docs/tutorials; this site supplies raw repository resources rather
than duplicate rendered tutorial pages.

```@raw html
<p><a href="repository/docs/tutorials/index.md">Tutorial learning path (raw Markdown resource)</a></p>
```

## Build locally

From the checkout root, set up only the documentation project:

```sh
julia +1.12.7 --project=docs -e 'using Pkg; cd("docs") do; Pkg.develop(path=".."); Pkg.instantiate(); end'
julia +1.12.7 --project=docs docs/make.jl
```

The docs-specific Manifest pins the resolved Documenter 1.19.0 and registers AML
at the relative path `..`. Root runtime dependency files are untouched.
Open docs/build/index.html or serve docs/build with a local HTTP server. This is
a local build, not deployment. Source links/edit buttons to an unpublished revision
are intentionally absent; packaged raw resources match the checkout being built.

## Evidence categories

STATIC_API_AUDIT / SOURCE_INSPECTED means implementation-derived contracts.
REFERENCE_COVERAGE_VERIFIED means inventory-to-entry reconciliation.
DOCUMENTER_BUILD_VERIFIED means actual local site construction.
EXAMPLE_EXECUTED applies only to newly executed examples; none are introduced by
this reference. M10D.6C tutorial runs and M10D.5's 5,649 assertions are
HISTORICAL_TEST_EVIDENCE here, not reruns.

Manual entries supplement incomplete docstrings without modifying scientific
source. checkdocs=:none selects manual coverage instead of requiring every
registered docstring to be included; it does not disable warnings or broken-xref
errors. Doctests are disabled because this manual contains signatures as text and
links historical scientific examples, not new executable training blocks.

## Standalone build and size policies

Documenter normally leaves version scripts to deployment. The builder supplies
explicit local-only scripts and redirects the versions link into build/; the
version selector is disabled, with no invented published version or deployment.

The consolidated scientific-ml page retains its authoritative primary ownership
instead of fragmenting shared training/prediction contracts. Its measured size
exceeds Documenter's 100 KiB advisory threshold, so this one page is exempt from
that advisory check while the original 200 KiB hard limit is enforced independently.
All other page thresholds remain default. The complete 179-entry search index has
a finite 640 KiB warning/builder/checker budget instead of the default 500 KiB.
These two scoped performance-policy exceptions are explicit; warnonly=false and
all scientific cross-reference warning/error checks remain active. This is not
an unrestricted-defaults or globally warning-suppressed build.
