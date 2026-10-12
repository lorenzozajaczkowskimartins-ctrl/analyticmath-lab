# M10D.6F-PUBLISH — GitHub Wiki publication report

## Current result

VERIFIED COMPLETE for Wiki content and live navigation. WIKI_SOURCE_VERIFIED,
WIKI_PUBLICATION_READY and WIKI_PUBLISHED are now independently supported;
publication is no longer blocked on initialization. No user action is required.

Live Wiki: https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki

Verification recorded at 2026-10-12T23:46:34.619470+00:00 (UTC).
The initial blocked preflight is preserved verbatim at the end as historical,
superseded evidence. Its NEEDS_USER_ACTION status is not the current result.

| Verification level | Result | Actual evidence |
|---|---|---|
| SOURCE_VERIFIED | PASS | 90/90 original questions, 17 categories, 25 P0, 65 P1; substantive-answer and reconciliation validator passes |
| REMOTE_GIT_VERIFIED | PASS | Wiki remote master equals 02791d812c0e821dc17d5f1b930f42f51aa4094f; all 20 committed files equal final canonical source |
| LIVE_PAGE_VERIFIED | PASS | Signed-out browser reads all 19 reader-facing pages and the injected sidebar; full answer text and original question wording checked |
| LIVE_NAVIGATION_VERIFIED | PASS | 90 FAQ-index clicks, 90 page-local question clicks, 19 sidebar clicks, 6 Home links, 34 category returns |
| README_LINK_VERIFIED | PASS | Public rendered README link clicked to actual Wiki Home; published README bytes equal the committed file |

## Resumed repository inspection

Main checkout: /home/lorenzozm/PROJETOS/analyticmath-lab.
Branch: main.
Starting HEAD: 155697067e076788abc5442f959b1a7fbe027fc6.
Origin: https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab.git.
Starting remote main after fetch: 155697067e076788abc5442f959b1a7fbe027fc6.

At resume, local and remote main already matched. The completed source milestone
had become remotely accessible since the blocked preflight; this task did not
need to push that source commit. The only initial untracked file was this existing
publication report. It was read in full, independently copied to scratch and
SHA-256 recorded before any edits. No unrelated changes were present.

GitHub CLI authentication returned exit 0. Authenticated repository metadata
confirmed the exact public owner/repository, Wiki enabled and push permission.
No credentials, token lines, cookies or authorization headers were copied into
reports or browser input. Live read-back used a signed-out browser, establishing
public access rather than relying on maintainer permissions.

Actual read-only preflight included git fetch origin, git ls-remote origin
refs/heads/main and git ls-remote --symref for the official Wiki endpoint. Ancestry
was rechecked before ordinary pushes. No divergence was detected or repaired by
reset, rebase, force push or history rewriting.

## Official Wiki repository and initialization reconciliation

Git endpoint:
https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab.wiki.git

Observed default branch: master, independently of main's branch name.
Initial Wiki HEAD: f123205df29bd38b01fe60c476b90684b5909417.
Initial subject: Initial Home page.
Initial history: one root commit; the only file was Home.md.

The 133-byte Home placeholder was inspected in full. It contained the package
title, a documentation/FAQ description and a statement that the full Wiki was
being prepared. It was not substantive unrelated documentation. No other pages,
branches or conflicting content required reconciliation.

The user initialized the Wiki before this continuation. This task did not use an
initialization API, create another repository or change Wiki permissions. It
cloned the actual Wiki into a separate temporary directory:
/home/lorenzozm/.hermes/cache/scratch/m10d6f-publish-c447f507/wiki-repository

All 20 approved Markdown files were copied into its root. The initial staged
blobs matched source commit 155697067e076788abc5442f959b1a7fbe027fc6 byte-for-byte;
only the minimal Home placeholder was replaced. Existing Wiki history was retained.

First publication commit:
7e5f67056fba4f604cd0cb058aa2e45f2cc18118
Subject: [m10d] Publish M10D.6F scientific FAQ and Wiki source.
Parent: f123205df29bd38b01fe60c476b90684b5909417.

Final Wiki commit:
02791d812c0e821dc17d5f1b930f42f51aa4094f
Subject: [m10d] Record verified Wiki publication state.
Parent: 7e5f67056fba4f604cd0cb058aa2e45f2cc18118.

The second commit corrects Home's obsolete preparation-time publication prose
only. The correction was disclosed before editing, applied identically to
canonical wiki/Home.md and the separate checkout, then pushed normally. All 90
answers, IDs, question wording, fragments, sidebar, FAQ index, technical targets
and repository links remain unchanged. Nineteen of the 20 Markdown files remain
byte-identical to the approved source milestone; Home's scientific text and every
link are unchanged. No unexplained source/published-content divergence remains.

Both Wiki pushes were ordinary fast-forward git push origin master operations.
After each, git fetch and independent git ls-remote verified remote equality;
committed blobs were compared with canonical bytes. The initialization commit is
still an ancestor of final HEAD. The Wiki checkout has no uncommitted files.

## Final page inventory and canonical SHA-256

There are 20 Markdown files: 19 reader-facing pages plus _Sidebar.md. GitHub's
Pages count of 19 is correct: _Sidebar is injected navigation, not a twentieth
ordinary page URL. Every ordinary page rendered and every page carried the sidebar.

| Canonical filename / Wiki root filename | Final SHA-256 |
|---|---|
| Atomistic-Computing.md | 39221829885ab7090d61e663d3f894957cef2dcb2fbd1ccc2fc144052b39b8ad |
| Calculus-and-Symbolics.md | 11946f703a0baa28cb7174b65d500ad091b57584ac470d0558275c42f152ac43 |
| Differential-Equations.md | e8a3eebab5e017688bc1abd64c2bb497143a4d7100bea9d0aed0590f160ff0db |
| FAQ-Index.md | 89d82478f50f11b4b05f6e9dbd3ec2d11eba835af288235cc9592a64109983ae |
| Getting-Started.md | 1da52b1e960f7d0760ff0cecf9d01aec30c8f5f9f6c35824df2e94d70ab6b8d8 |
| Home.md | 0cd16021cfde72c27715a7107230ea7e083ec6d096c59854c10adfc85422ccf4 |
| Linear-Algebra.md | c971304123c05d29e438187e86bf8d0756d2c2bc455cd7b43c45e45b1192a5b5 |
| Mechanics-and-Dynamics.md | ad7416b1e02549e4e7d6d038565775932fd5b6e832d7c73109ebbc3bf348c730 |
| Memory-and-Performance.md | e6e4f293903d73a6480d77d78c225989cb900d82d97c77a0bbadb5351df324c5 |
| Numerical-Methods.md | dc637cd2ec2406b2943979701f967a893daa4c49d9e0e8c7bd5e1d9e9ed6f8f3 |
| Optional-Extensions.md | 52ff3b62b3cb03ae8756e99c8c27e8942b31f4742a2a0523973ec2c8504daf9a |
| Scientific-Datasets.md | 7f890f4856e8201609b9fc17e5c38afaf40bb9e9a435417acaad7c5c14dcbeb6 |
| Scientific-Evidence-and-Provenance.md | 3c65d6a19f4d88dc1ee24b9f649c2b06ba6bc9e4ddea2867140d603d3981d608 |
| Scientific-Machine-Learning.md | fd7daa84e34235fa561cda4111d2ec7a10a0d4a898a753c5aae753cd9c1068e4 |
| Statistics.md | ff593f631fb9da77e309c81a8792682d79f240c08d6873edc160dbbeaaf795d2 |
| Trajectories.md | 4bc7b7607e3f38946b867ee283cd7661b59a89486b01771a6d4d314ef5bece6b |
| Troubleshooting.md | c29cc98f8b597bf7869eb0364f5f9d2b21b87b8021da7b5dc02065fb834db87b |
| Units-and-Precision.md | 06304e688a040e88d432b3aba012d74dcaea155d87cbcc46f9e5a1c3093d45ae |
| Vector-Calculus.md | 4f9b950650f699d1aea52922f1a8d41870db115046cfb01a70cdbd1544a979cf |
| _Sidebar.md | 13904cdf87f0882ab213fba03dc4759c539c934311e3657b988d1b4b57416e1b |

## Answer and scientific-contract preservation

Coverage is 90/90 primary answers, 17/17 categories, 25 P0
and 65 P1. All IDs Q001–Q090 and all original wording remain
unchanged. Exactly one answer location per ID is present, and every indexed link
selects that location. Q049 retains the corrected diffusion question; Q086–Q090
are included. Every live answer contains a short answer, explanation, practical
action, scientific boundary, related documentation and evidence classification.

No new scientific reasoning or functionality was introduced during publication.
Preserved distinctions include original-domain exclusions versus simplification,
search completeness, local versus global stability, numerical discrepancies
versus certified bounds, physical-time interpretation versus index-time diffusion
fits, symbolic dimension guards versus dense mode preflights, byte estimates
versus peak RSS, chunk/history/source retention, experimental extension triggers,
unknown versus false/zero evidence and process-local versus persistent provenance.

The existing 90-row target reconciliation and prior scientific audits remain
unchanged. Technical links still pin the already published scientific-reference
revision 4e2143953baf23542d91ab62ee08c7673d5ce6cb, not a guessed deployed
Documenter URL. Forty unique repository resources were fetched as public GitHub
file pages: each returned HTTP 200, the exact requested URL without redirection
and the expected repository/file title. The Documenter manual remains locally
built historical evidence, not a newly deployed website. GitHub source rendering
does not execute Documenter-specific directives.

## Deterministic validation and frozen audit context

Actual initial command:

    python3 reports/m10d6/wiki_check.py

Exit 0; PASS. Results: 20 files, 90 primary answers, 17 categories, 25 P0, 65 P1,
90 mappings, 278 Wiki-internal link occurrences, no missing/duplicate questions,
no unresolved/pending links and zero errors. The copied Wiki-root fixture also
passed the unchanged validator before publication.

The original validator protects the M10D.6D README bytes and per-target audit
hashes. Adding an authorized public README navigation link necessarily changes
those bytes. It would be misleading to claim the unchanged validator's historical
baseline check passes against the mutable post-publication README.

For final checks, a separate local clone was detached at source milestone
155697067e076788abc5442f959b1a7fbe027fc6, preserving its frozen technical-reference
context. The unchanged validator was imported from that checkout, with WIKI
explicitly set first to the actual final canonical folder and then to the actual
published checkout. Both final validations returned PASS with zero errors and
90/90 coverage. This is a pinned reference-context check, not a suppressed error
or a claim that the current README is identical to M10D.6D. All 512 non-authorized
tracked baseline files were independently SHA-256 compared with the starting
source commit. The only changed existing paths are README.md and wiki/Home.md.

Reference snapshot: /home/lorenzozm/.hermes/cache/scratch/m10d6f-publish-c447f507/reference-snapshot.
Validator source, inventories, target reconciliation and previous verification
reports were not edited. The new Home lifecycle prose introduces no new links.

Historical stateless GFM rendering and negative-fixture evidence was not rerun or
misrepresented as live publication testing. This task instead performed fresh
DOM-backed live checks against the actual GitHub Wiki.

## Live rendering, anchors and navigation

Actual browser read-back covered Home, FAQ-Index and all 17 categories. Rendered
answer text was collected, checked against the immutable inventory and associated
with its real H2 heading. Every question has exactly one explicit named anchor
and one generated heading permalink; all DOM IDs are unique. The two anchor forms
refer to the same primary answer, not separate answers.

GitHub Wiki rewrites extensionless sibling links correctly, including the special
Home route. Verified live fragments use #user-content-q001 through
#user-content-q090. No guessed heading slug or link repair was needed.

Counts from persisted evidence, not manual counting:

- 90/90 FAQ-index links clicked to the intended visible answer heading.
- 90/90 page-local question links clicked to the intended visible heading.
- 19/19 sidebar destinations clicked and rendered.
- 6/6 Home quick-navigation destinations clicked and rendered.
- 34/34 category-to-Home/FAQ-index return links clicked and rendered.
- 278 source-internal link occurrences resolve; _Sidebar counted once here.
- 620 live internal-link occurrences resolve across the 19 pages, including
  361 repeated sidebar-link occurrences.
- 40/40 unique pinned repository resources returned public HTTP 200 file pages.
- The rendered README link was clicked to the correct public Wiki Home.

Position checks used native anchor activation, the real URL and the real
heading's bounding rectangle; they did not scroll the target into view to
manufacture a pass. In this browser harness, default CSS smooth-scroll animation
did not settle reliably. Deterministic native-click checks therefore disabled
only scroll animation with a session-local scrollBehavior=auto style. No href,
anchor, scientific content or repository CSS was changed. Default animated
scroll timing and every other browser/platform are not certified by this report.
This disclosed cosmetic harness limitation is not treated as an AML scientific
runtime defect or a reason to rewrite correctly resolving links.

Screenshot inspection sampled Home/sidebar and rendered question sections,
including Q005, Q050 and Q085. Every other page has DOM-backed rendering evidence;
this is not a claim of individual screenshot inspection for all pages. Final
Home was read back after its lifecycle-only push and no longer says publication
is pending.

### Question-by-question live verification

Both click columns denote a real native link activation reaching the exact
answer heading, with only smooth-scroll animation disabled as described above.

| ID | Priority | Category | Unique live answer | FAQ index click | Page-local click |
|---|---|---|---|---|---|
| Q001 | P1 | Getting Started | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Getting-Started#user-content-q001) | PASS | PASS |
| Q002 | P1 | Getting Started | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Getting-Started#user-content-q002) | PASS | PASS |
| Q003 | P1 | Getting Started | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Getting-Started#user-content-q003) | PASS | PASS |
| Q004 | P1 | Getting Started | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Getting-Started#user-content-q004) | PASS | PASS |
| Q005 | P1 | Getting Started | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Getting-Started#user-content-q005) | PASS | PASS |
| Q006 | P1 | Calculus and Symbolics | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Calculus-and-Symbolics#user-content-q006) | PASS | PASS |
| Q007 | P1 | Calculus and Symbolics | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Calculus-and-Symbolics#user-content-q007) | PASS | PASS |
| Q008 | P1 | Calculus and Symbolics | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Calculus-and-Symbolics#user-content-q008) | PASS | PASS |
| Q009 | P1 | Calculus and Symbolics | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Calculus-and-Symbolics#user-content-q009) | PASS | PASS |
| Q010 | P1 | Calculus and Symbolics | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Calculus-and-Symbolics#user-content-q010) | PASS | PASS |
| Q011 | P1 | Linear Algebra | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Linear-Algebra#user-content-q011) | PASS | PASS |
| Q012 | P1 | Linear Algebra | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Linear-Algebra#user-content-q012) | PASS | PASS |
| Q013 | P1 | Linear Algebra | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Linear-Algebra#user-content-q013) | PASS | PASS |
| Q014 | P1 | Linear Algebra | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Linear-Algebra#user-content-q014) | PASS | PASS |
| Q015 | P1 | Linear Algebra | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Linear-Algebra#user-content-q015) | PASS | PASS |
| Q016 | P1 | Vector Calculus | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Vector-Calculus#user-content-q016) | PASS | PASS |
| Q017 | P1 | Vector Calculus | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Vector-Calculus#user-content-q017) | PASS | PASS |
| Q018 | P1 | Vector Calculus | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Vector-Calculus#user-content-q018) | PASS | PASS |
| Q019 | P1 | Vector Calculus | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Vector-Calculus#user-content-q019) | PASS | PASS |
| Q020 | P1 | Vector Calculus | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Vector-Calculus#user-content-q020) | PASS | PASS |
| Q021 | P1 | Numerical Methods | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Numerical-Methods#user-content-q021) | PASS | PASS |
| Q022 | P1 | Numerical Methods | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Numerical-Methods#user-content-q022) | PASS | PASS |
| Q023 | P1 | Numerical Methods | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Numerical-Methods#user-content-q023) | PASS | PASS |
| Q024 | P1 | Numerical Methods | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Numerical-Methods#user-content-q024) | PASS | PASS |
| Q025 | P1 | Numerical Methods | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Numerical-Methods#user-content-q025) | PASS | PASS |
| Q026 | P1 | Differential Equations | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Differential-Equations#user-content-q026) | PASS | PASS |
| Q027 | P1 | Differential Equations | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Differential-Equations#user-content-q027) | PASS | PASS |
| Q028 | P1 | Differential Equations | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Differential-Equations#user-content-q028) | PASS | PASS |
| Q029 | P1 | Differential Equations | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Differential-Equations#user-content-q029) | PASS | PASS |
| Q030 | P1 | Differential Equations | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Differential-Equations#user-content-q030) | PASS | PASS |
| Q031 | P1 | Mechanics and Dynamics | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Mechanics-and-Dynamics#user-content-q031) | PASS | PASS |
| Q032 | P1 | Mechanics and Dynamics | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Mechanics-and-Dynamics#user-content-q032) | PASS | PASS |
| Q033 | P1 | Mechanics and Dynamics | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Mechanics-and-Dynamics#user-content-q033) | PASS | PASS |
| Q034 | P1 | Mechanics and Dynamics | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Mechanics-and-Dynamics#user-content-q034) | PASS | PASS |
| Q035 | P1 | Mechanics and Dynamics | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Mechanics-and-Dynamics#user-content-q035) | PASS | PASS |
| Q036 | P1 | Trajectories | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Trajectories#user-content-q036) | PASS | PASS |
| Q037 | P1 | Trajectories | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Trajectories#user-content-q037) | PASS | PASS |
| Q038 | P1 | Trajectories | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Trajectories#user-content-q038) | PASS | PASS |
| Q039 | P1 | Trajectories | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Trajectories#user-content-q039) | PASS | PASS |
| Q040 | P1 | Trajectories | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Trajectories#user-content-q040) | PASS | PASS |
| Q041 | P1 | Atomistic Computing | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Atomistic-Computing#user-content-q041) | PASS | PASS |
| Q042 | P1 | Atomistic Computing | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Atomistic-Computing#user-content-q042) | PASS | PASS |
| Q043 | P1 | Atomistic Computing | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Atomistic-Computing#user-content-q043) | PASS | PASS |
| Q044 | P1 | Atomistic Computing | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Atomistic-Computing#user-content-q044) | PASS | PASS |
| Q045 | P1 | Atomistic Computing | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Atomistic-Computing#user-content-q045) | PASS | PASS |
| Q046 | P1 | Statistics | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Statistics#user-content-q046) | PASS | PASS |
| Q047 | P1 | Statistics | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Statistics#user-content-q047) | PASS | PASS |
| Q048 | P1 | Statistics | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Statistics#user-content-q048) | PASS | PASS |
| Q049 | P1 | Statistics | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Statistics#user-content-q049) | PASS | PASS |
| Q050 | P1 | Statistics | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Statistics#user-content-q050) | PASS | PASS |
| Q051 | P1 | Scientific Datasets | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Scientific-Datasets#user-content-q051) | PASS | PASS |
| Q052 | P1 | Scientific Datasets | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Scientific-Datasets#user-content-q052) | PASS | PASS |
| Q053 | P1 | Scientific Datasets | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Scientific-Datasets#user-content-q053) | PASS | PASS |
| Q054 | P1 | Scientific Datasets | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Scientific-Datasets#user-content-q054) | PASS | PASS |
| Q055 | P1 | Scientific Datasets | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Scientific-Datasets#user-content-q055) | PASS | PASS |
| Q056 | P1 | Scientific Machine Learning | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Scientific-Machine-Learning#user-content-q056) | PASS | PASS |
| Q057 | P1 | Scientific Machine Learning | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Scientific-Machine-Learning#user-content-q057) | PASS | PASS |
| Q058 | P1 | Scientific Machine Learning | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Scientific-Machine-Learning#user-content-q058) | PASS | PASS |
| Q059 | P1 | Scientific Machine Learning | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Scientific-Machine-Learning#user-content-q059) | PASS | PASS |
| Q060 | P1 | Scientific Machine Learning | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Scientific-Machine-Learning#user-content-q060) | PASS | PASS |
| Q061 | P0 | Units and Precision | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Units-and-Precision#user-content-q061) | PASS | PASS |
| Q062 | P0 | Units and Precision | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Units-and-Precision#user-content-q062) | PASS | PASS |
| Q063 | P0 | Units and Precision | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Units-and-Precision#user-content-q063) | PASS | PASS |
| Q064 | P0 | Units and Precision | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Units-and-Precision#user-content-q064) | PASS | PASS |
| Q065 | P0 | Units and Precision | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Units-and-Precision#user-content-q065) | PASS | PASS |
| Q066 | P0 | Memory and Performance | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Memory-and-Performance#user-content-q066) | PASS | PASS |
| Q067 | P0 | Memory and Performance | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Memory-and-Performance#user-content-q067) | PASS | PASS |
| Q068 | P0 | Memory and Performance | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Memory-and-Performance#user-content-q068) | PASS | PASS |
| Q069 | P0 | Memory and Performance | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Memory-and-Performance#user-content-q069) | PASS | PASS |
| Q070 | P0 | Memory and Performance | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Memory-and-Performance#user-content-q070) | PASS | PASS |
| Q071 | P0 | Scientific Evidence and Provenance | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Scientific-Evidence-and-Provenance#user-content-q071) | PASS | PASS |
| Q072 | P0 | Scientific Evidence and Provenance | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Scientific-Evidence-and-Provenance#user-content-q072) | PASS | PASS |
| Q073 | P0 | Scientific Evidence and Provenance | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Scientific-Evidence-and-Provenance#user-content-q073) | PASS | PASS |
| Q074 | P0 | Scientific Evidence and Provenance | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Scientific-Evidence-and-Provenance#user-content-q074) | PASS | PASS |
| Q075 | P0 | Scientific Evidence and Provenance | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Scientific-Evidence-and-Provenance#user-content-q075) | PASS | PASS |
| Q076 | P0 | Optional Extensions | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Optional-Extensions#user-content-q076) | PASS | PASS |
| Q077 | P0 | Optional Extensions | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Optional-Extensions#user-content-q077) | PASS | PASS |
| Q078 | P0 | Optional Extensions | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Optional-Extensions#user-content-q078) | PASS | PASS |
| Q079 | P0 | Optional Extensions | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Optional-Extensions#user-content-q079) | PASS | PASS |
| Q080 | P0 | Optional Extensions | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Optional-Extensions#user-content-q080) | PASS | PASS |
| Q081 | P0 | Troubleshooting | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Troubleshooting#user-content-q081) | PASS | PASS |
| Q082 | P0 | Troubleshooting | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Troubleshooting#user-content-q082) | PASS | PASS |
| Q083 | P0 | Troubleshooting | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Troubleshooting#user-content-q083) | PASS | PASS |
| Q084 | P0 | Troubleshooting | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Troubleshooting#user-content-q084) | PASS | PASS |
| Q085 | P0 | Troubleshooting | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Troubleshooting#user-content-q085) | PASS | PASS |
| Q086 | P1 | Memory and Performance | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Memory-and-Performance#user-content-q086) | PASS | PASS |
| Q087 | P1 | Memory and Performance | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Memory-and-Performance#user-content-q087) | PASS | PASS |
| Q088 | P1 | Memory and Performance | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Memory-and-Performance#user-content-q088) | PASS | PASS |
| Q089 | P1 | Memory and Performance | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Memory-and-Performance#user-content-q089) | PASS | PASS |
| Q090 | P1 | Memory and Performance | [answer](https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki/Memory-and-Performance#user-content-q090) | PASS | PASS |

### Repository-source resource checks

All URLs retain the same published revision 4e2143953baf23542d91ab62ee08c7673d5ce6cb.

| Repository path | HTTP status |
|---|---|
| Project.toml | 200 |
| README.md | 200 |
| docs/atomistic.md | 200 |
| docs/learned_dynamics.md | 200 |
| docs/m10d_one_system_many_methods.md | 200 |
| docs/m10d_user_research_hardening.md | 200 |
| docs/parameter_inference.md | 200 |
| docs/pinn_diagnostics.md | 200 |
| docs/scientific_ml.md | 200 |
| docs/src/guides/api-boundaries.md | 200 |
| docs/src/index.md | 200 |
| docs/src/reference/atomistic.md | 200 |
| docs/src/reference/comparison.md | 200 |
| docs/src/reference/core.md | 200 |
| docs/src/reference/datasets.md | 200 |
| docs/src/reference/derivatives.md | 200 |
| docs/src/reference/dynamics.md | 200 |
| docs/src/reference/evidence.md | 200 |
| docs/src/reference/index.md | 200 |
| docs/src/reference/mechanics.md | 200 |
| docs/src/reference/plots.md | 200 |
| docs/src/reference/scalar.md | 200 |
| docs/src/reference/scientific-ml.md | 200 |
| docs/src/reference/statistics.md | 200 |
| docs/src/reference/transport.md | 200 |
| docs/src/reference/vector.md | 200 |
| docs/surrogates.md | 200 |
| docs/trajectory_statistics.md | 200 |
| docs/tutorials/atomistics.md | 200 |
| docs/tutorials/calculus.md | 200 |
| docs/tutorials/index.md | 200 |
| docs/tutorials/mechanics.md | 200 |
| docs/tutorials/multivariate.md | 200 |
| docs/tutorials/normal-modes.md | 200 |
| docs/tutorials/odes.md | 200 |
| docs/tutorials/one-system-many-methods.md | 200 |
| docs/tutorials/trajectories.md | 200 |
| docs/tutorials/vector-calculus.md | 200 |
| examples/integration/one_system_learning.jl | 200 |
| reports/m10d6/resource_controls.json | 200 |

## README, main commits and completion identity

README publication commit:
6ebe6d8fed7004856897ce6a29182c1719c7ce1e
Subject: [m10d] Link published scientific FAQ in README.
Parent: 155697067e076788abc5442f959b1a7fbe027fc6.
Only README.md changed in that commit; ordinary git push origin main succeeded.
Independent git ls-remote and fetch agreed with this commit. Public raw README
bytes matched the local committed file. The live rendered README link was found
inside the Markdown article, not confused with GitHub's navigation tab, and
clicked to the published Home page.

README changes are limited to adding the public scientific FAQ link and replacing
obsolete planned-Wiki text while retaining the honest undeployed-Documenter note.
No installation command, API example or historical execution claim changed.

The final Home-source synchronization and this completion report are committed
under subject [m10d] Complete M10D.6F Wiki publication verification. That containing
commit is a child of the verified README checkpoint; its own full SHA cannot be
embedded in this document without a self-reference. Resolve it using:

    git log -1 --format='%H%n%P%n%s' -- reports/m10d6/wiki_publication_report.md
    git ls-remote origin refs/heads/main

Post-commit/push exact SHA, clean-worktree, remote equality, committed-blob and
protected-file read-back are recorded outside Git in:
/home/lorenzozm/.hermes/cache/scratch/m10d6f-publish-c447f507/final_readback.json

The final response also reports the full containing SHA. No commit is amended
merely to insert its own hash. No source reset, rebase, force push, tag, release,
repository visibility/permission change or documentation-site deployment occurs.

## Changed paths and source integrity

Main repository, relative to resume:

- README.md — public Wiki link and publication-state wording.
- wiki/Home.md — publication lifecycle prose only; synced to the actual Wiki.
- reports/m10d6/wiki_publication_report.md — this completion report, retaining the
  original uncommitted preflight verbatim below.

Separate Wiki repository, relative to initialization: exactly the 20 listed
Markdown files. No generated build/cache artifacts or unrelated pages are present.
All final Wiki blobs equal the canonical files. The 17 question-bearing pages,
FAQ index and sidebar are byte-identical to the approved source milestone.

All 512 other tracked baseline files remain unchanged. In particular src/, ext/,
test/, examples/, notebooks/, Project.toml, Manifest.toml, LICENSE and previous
milestone artifacts were not edited. No new Julia snippets, scientific tests,
training, stress benchmarks, optional dependency installation or Documenter build
were run. Historical scientific results remain historical.

## Evidence retention and limitations

Git and browser evidence workspace:
/home/lorenzozm/.hermes/cache/scratch/m10d6f-publish-c447f507

It contains initial-state/report preservation, original and final transfer
manifests, initial and pinned-context validator results, protected-file hashes,
Wiki/README read-back, HTTP resource records and complete live-page/index/return
navigation JSON. Browser helpers live outside both repositories. Scratch retention
is temporary; durable per-file hashes, 90 per-question results, actual commit
identities and check scopes are recorded in this committed report.

Original preflight report SHA-256:
fce88c985a3f1c09480cc4e291cf7d452ddab06ff9018ff5b7e3e10080cfbc1b.

No mandatory Wiki-content/navigation blocker remains. Default browser animation
timing is the disclosed verification limitation, not a guarantee. The Documenter
site is intentionally not deployed. The technical-reference revision is pinned;
future main-branch changes do not automatically update scientific FAQ contracts.
M10D.6E/G/H remain outside this publication task. M10D.6G was not started.

## Preserved historical blocked preflight

The following original report is preserved verbatim. Its repository state,
NEEDS_USER_ACTION status and absent-Wiki findings describe the earlier blocked
attempt only; they are superseded by the verified resumed publication above.

<details>
<summary>Original preflight report — historical, not current publication status</summary>

# M10D.6F-PUBLISH — publication preflight

## Status

NEEDS_USER_ACTION. Canonical source verification passed, but publication did not
begin because the Wiki Git endpoint remains unavailable and the available browser
session is not authenticated to GitHub. This is not WIKI_PUBLISHED or a completed
publication. No unsupported Wiki initialization API, replacement repository,
permission change or credential transfer into the browser was attempted.

Verification levels:

| Level | Status | Evidence |
|---|---|---|
| SOURCE_VERIFIED | PASS | Existing Wiki validator passed; canonical hashes match the M10D.6F verification report |
| REMOTE_GIT_VERIFIED | NOT ACHIEVED for Wiki | Wiki Git endpoint returns exit 128, Repository not found |
| LIVE_PAGE_VERIFIED | NOT ACHIEVED for Wiki | Requested Wiki route redirects to the main repository |
| LIVE_NAVIGATION_VERIFIED | NOT RUN | No published Wiki pages available to inspect |

## Starting main repository

Path: /home/lorenzozm/PROJETOS/analyticmath-lab.
Branch: main.
Starting HEAD: 155697067e076788abc5442f959b1a7fbe027fc6.
Subject: [m10d] Complete M10D.6F scientific FAQ and Wiki source.
Starting worktree: clean.
Origin: https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab.git.
Starting remote main: 4e2143953baf23542d91ab62ee08c7673d5ce6cb.

The remote was fetched without changing local history. A git merge-base ancestry
check confirms origin/main is an ancestor of local main. Main is one commit ahead;
there is no detected divergence. The authorized normal fast-forward push was not
performed because the initialization prerequisite requires user action and the
requested workflow requires stopping at that boundary. No history was reset,
rebased, cleaned, amended or overwritten.

## Authentication and repository identity

GitHub CLI authentication status exited 0. The active authenticated account is
lorenzozajaczkowskimartins-ctrl. Authenticated metadata confirms the exact public
repository lorenzozajaczkowskimartins-ctrl/analyticmath-lab, default branch main,
Wiki enabled and push/admin/maintain permissions present.

Authentication metadata was inspected without printing token lines, keyring
secrets or credential values. GitHub CLI authentication does not authenticate an
independent browser session. The available browser displays Sign in links and no
first-page creation action. Its other page tab is an unused new tab; no existing
authenticated GitHub session was found in that browser context.

## Wiki initialization state

Expected public destination:
https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab/wiki

Expected Git endpoint:
https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab.wiki.git

Actual Git probe:

    git ls-remote --symref https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab.wiki.git

Exit: 128. Response: Repository not found.

The browser requested the official Wiki destination and ended at:
https://github.com/lorenzozajaczkowskimartins-ctrl/analyticmath-lab

The main-repository page renders, but that is not a rendered Wiki Home page.
The endpoint failure and redirect are consistent with an uninitialized Wiki;
they do not independently prove that no Wiki repository or history exists.
Authenticated CLI permissions are verified, but suitable authenticated browser
access for the official first-page creation flow is unavailable.

Wiki default branch: unavailable; not guessed.
Previous Wiki commit: unavailable; not fabricated.
Wiki initialization performed: no.
User action required: yes.
Separate Wiki clone created: no; endpoint must become available first.
Existing Wiki content/history inspected: not possible yet.
Conflicting remote content overwritten: none.

## Canonical source and validation

The expected source milestone commit and the current HEAD match exactly.
There are exactly 20 canonical Markdown pages in wiki/, including Home.md,
_Sidebar.md, FAQ-Index.md and all 17 thematic pages. The existing script and
implementation/verification reports were inspected without modification.

Actual validator command:

    python3 reports/m10d6/wiki_check.py

Exit: 0. Status: PASS.
Results: 90 primary answers, 17 categories, 25 P0 and 65 P1, 90 structured IDs,
278 resolved internal link occurrences, zero pending links, zero errors and no
missing or duplicate primary answers. The validator includes exact original
wording, corrected Q049, Q086–Q090, answer substance, question anchors,
Home/sidebar/index/category navigation, actual target reconciliation and
baseline integrity checks.

Current canonical page, validator and target-reconciliation SHA-256 hashes all
match the recorded M10D.6F verified-content hashes. No answers, questions,
scientific contracts, filenames or reference URLs were regenerated or rewritten.

Repository-resource links intentionally remain pinned to the previously verified
published revision 4e2143953baf23542d91ab62ee08c7673d5ce6cb. That revision is still
remote main during this preflight. There is no reason to blindly replace those
links with the local HEAD. The Documenter resources remain honestly labeled
technical-reference source, not a deployed public manual.

Pages transferred: 0.
Copied-file hash verification: not applicable; no accessible Wiki checkout yet.
New scientific execution, package installation or Documenter build: none.

## Publication and live read-back

Published Wiki commit: none.
Wiki push: not performed.
Remote Wiki commit read-back: unavailable.
Live Wiki Home/sidebar/FAQ/category verification: not run.
Live question-fragment verification: not run.

The existing stateless M10D.6F GFM anchor evidence remains historical source
preparation evidence, not live Wiki rendering evidence. In particular,
#user-content-q001, #user-content-q049 and #user-content-q066 have not been checked
on a published Wiki. An HTTP success at the main repository or a future Wiki URL
will not by itself establish correct fragments or scrolling.

After initialization, publication must resume by cloning the Wiki into a separate
scratch directory, inspecting its actual default branch/history/content and
stopping on substantial conflicting content. Only a verified minimal Home
initialization placeholder may be replaced without further reconciliation.
The 20 canonical files must be copied into the Wiki checkout root, checked
byte-for-byte, committed and pushed ordinarily. Remote Git equality and actual
rendered DOM/navigation verification must follow before claiming publication.

## README navigation and final main state

README public Wiki link: not added. The Wiki has not been demonstrably published.
README documentation structure and all previous milestone reports are unchanged.
Final main publication commit: none.
Publication-report commit: none; this preflight report is left uncommitted so the
user-action boundary does not silently perform an extra push or finalization.

Main HEAD remains 155697067e076788abc5442f959b1a7fbe027fc6.
Remote main remains 4e2143953baf23542d91ab62ee08c7673d5ce6cb.
The remaining synchronization limitation is explicit: local main is ahead by the
completed source milestone, but no main push has occurred in this task.
The only new worktree file is reports/m10d6/wiki_publication_report.md.

Protected source, extensions, tests, examples, notebooks, dependency manifests and
prior milestone artifacts remain unchanged. No force push, tag, release,
Documenter deployment, repository visibility change or Wiki-contribution
permission change occurred. M10D.6E/G/H were not implemented.

## Required user action

1. Open the AnalyticMathLab repository on GitHub.
2. Select Wiki.
3. Create the first page.
4. Title it Home.
5. Use a minimal initialization message.
6. Save the page.
7. Return to Hermes so publication can continue.

This action only initializes the Wiki; it does not publish the approved 20-page,
90-answer FAQ. Subsequent cloning, reconciliation, validation, ordinary pushes,
live read-back, README navigation and the completion report remain necessary.

</details>
