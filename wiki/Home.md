# AnalyticMathLab.jl — scientific questions and support

AML connects symbolic mathematics, numerical methods, mechanics, atomistic stored
data and explicit scientific evidence in Julia. Start with a declared object and
ordered variables/data, then interpret the returned result under its assumptions.
This Wiki answers practical questions; tutorials teach complete problems and the
API reference states exact contracts.

## Start here

- [Installation and first steps](Getting-Started)
- [Troubleshooting](Troubleshooting)
- [Memory and computational regimes](Memory-and-Performance)
- [Evidence, unknown results and ancestry](Scientific-Evidence-and-Provenance)
- [Optional backend activation](Optional-Extensions)
- [Searchable index of all 90 questions](FAQ-Index) — grouped by category; IDs Q001–Q090 remain stable.
- [README installation and Quick Start](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/README.md).
- [First executable tutorial: scalar calculus](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/calculus.md).
- [Nine-tutorial learning path](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/tutorials/index.md).
- [Technical reference source and local build instructions](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/index.md).
- [Complete public-symbol reference source index](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/reference/index.md).

## Scientific scope

The package is pre-1.0. The audited inventory has 177 exports (130 stable,
47 experimental), plus qualified experimental scientific_metadata/scientific_origin.
Stable labels are not post-1.0 compatibility guarantees; an experimental payload
remains experimental under a shared stable generic. Raw constructors, a successful
solve, low optimizer loss and metadata availability do not certify physics.

## Publication and link conventions

These pages are canonical Wiki source stored in wiki/ in the main repository.
They are published in the separate GitHub Wiki repository, using flat,
extensionless sibling Wiki page links. Updating the main repository alone does
not update the published Wiki.
Repository-resource links pin published commit 4e2143953baf23542d91ab62ee08c7673d5ce6cb; the remote Git tree
was inspected before selecting that revision. Newer main may differ from this FAQ.

The Documenter 1.19.0 manual was built locally during M10D.6D, not deployed.
TECHNICAL REFERENCE SOURCE links open docs/src Markdown: GitHub does not execute
Documenter @ref/@docs directives. For the RENDERED TECHNICAL MANUAL, follow its
local build instructions and open docs/build/index.html in your checkout.

Question fragments target explicit named anchors, with GitHub GFM's observed
user-content- sanitization prefix, rather than guessed title slugs. Live page
rendering and all 90 question destinations were checked during publication.

## Reading evidence

SOURCE_SUPPORTED means an audited current contract. HISTORICAL_VERIFICATION means
an earlier recorded run, not a rerun here. USER_ASSUMPTION marks the required
scientific declaration. UNAVAILABLE_CAPABILITY is not automatically a defect.
No new scientific Julia examples or optional training are introduced in this FAQ.

M10D.6E scientific guides and the detailed M10D.6G refusal handbook remain deferred.
For current boundaries, use [API-boundaries reference source](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/docs/src/guides/api-boundaries.md), not a nonexistent future handbook.

## Publication procedure — completed for M10D.6F

1. Obtain separate authorization for Wiki creation/publication and any main-repository push.
2. Recheck the remote main revision and Wiki state. At preparation time the Wiki
   feature was enabled, but Wiki Git access returned Repository not found and the
   web route redirected to the repository. The maintainer subsequently initialized
   Home; publication preserved that commit and replaced only its minimal placeholder.
3. If the Wiki is uninitialized, an authorized maintainer must create the initial
   page through GitHub. If it exists, clone and inspect its history/pages first.
4. Clone the conventional analyticmath-lab.wiki.git repository into a separate
   directory. Discover its actual default branch; do not assume the main repository's
   branch name is the Wiki branch.
5. Compare the 20 canonical Markdown pages with that checkout. Preserve unrelated
   pages/history and resolve Home/sidebar/name conflicts; do not blindly overwrite.
6. Copy the reviewed flat pages into the Wiki repository root, run this milestone's
   coverage/link check on the source and inspect the Wiki rendering preview.
7. Review and commit in the Wiki checkout. Push only after explicit authorization;
   never force-push or rewrite its history as a publication shortcut.
8. Read back the remote Wiki commit, Home, sidebar and every question fragment.
   Only then label WIKI_PUBLISHED and add a separately reviewed public Wiki README link.

The Wiki is published. Future updates still require authorization, reconciliation
and independent remote read-back; this checklist does not authorize another push.
See [the versioned repository entry point](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/blob/4e2143953baf23542d91ab62ee08c7673d5ce6cb/README.md) for installation and first steps.
