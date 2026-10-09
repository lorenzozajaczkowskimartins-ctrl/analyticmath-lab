# One system, many methods

Status: recovered implementation; core and bounded learning focused gates passed.
Canonical completion is recorded separately in the results report below.

This investigation asks whether one dimensionless, two-degree-of-freedom coupled
oscillator remains the same physical model across mathematical analysis,
mechanics, modes, integration, sampled statistics, explicit particle geometry and
scientific learning. It is not a benchmark or an assertion of total AML coverage.

## Run

From the repository root, use the root project for the core investigation:

    env JULIA_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 julia +release --project=. examples/integration/one_system_many_methods.jl

For the optional, existing Lux scientific-learning route:

    env JULIA_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 julia +release --project=examples/operators examples/integration/one_system_learning.jl

The operators project directly declares Symbolics and LinearAlgebra because the
shared example imports them. No dependency-binding re-export is used. All
pre-existing pinned package versions remain unchanged. Optional backend triggers
remain optional; the canonical base suite does not import them.

For plots, load a backend yourself, include
`examples/integration/one_system_plots.jl`, and call its `figures` function on the
investigation result. AML and the helper never activate a backend. Rendering is
separate from canonical correctness.

## Canonical system and independent oracle

`canonical_system()` is the authoritative parameter/convention definition:

- m=k=κ=1, ordered displacements (q1,q2), velocities (v1,v2), state (q1,q2,v1,v2).
- Canonical phase space is (q1,q2,p1,p2), with p=m v, not an inferred renaming.
- Every physical scale, including time, mass, displacement, momentum and energy,
  is explicitly dimensionless. AML's plain-numeric unit fields remain unknown
  where its established contract has no declaration slot. The example's context,
  dataset unit schema and figure labels carry the caller declaration. Unknown
  native metadata is not treated as meaning dimensionless.
- Equilibrium q*=0; anchored particle positions x⁰=(0,1).
- Euclidean-normalized directions φs=(1,1)/√2, φa=(1,-1)/√2.
- Initial modal amplitudes (0.20,0.10), initial modal velocities (0,0).
- V=k(q1²+q2²)/2+κ(q2-q1)²/2, T=m(v1²+v2²)/2, L=T−V.
- M=mI, C=0, K=[k+κ −κ;−κ k+κ].
- ωs²=k/m, ωa²=(k+2κ)/m. Thus q(t)=0.20φs cos(t)+0.10φa cos(√3t),
  v(t)=−0.20φs sin(t)−0.10√3φa sin(√3t).

The analytical oracle uses neither AML eigenvectors nor numerical solution
samples. Its exact mathematical formulas are evaluated in floating-point
arithmetic for comparisons. Exact identities and floating-point agreement are
reported separately. Both modes are nonzero. Global equivalence of the local
linearization and this quadratic model is established independently by the
Euler–Lagrange polynomial identity; AML's local-applicability evidence is not
upgraded into a universal linearization theorem.

## Stored times and numerical controls

The declared binary grid is 0:0.03125:10. AML's `saveat` forces accepted stops but
also retains adaptive steps. The example supplies the same initial step and
abstol=reltol=1e-8, then requires exact saved-grid identity. It does not interpolate,
filter, round times, fabricate a TrajectoryResult or call SciML directly.
A solver/backend change that inserts extra samples causes an explicit refusal.
This is a checked bounded configuration, not a new promise about `saveat`.

Development at 1e-10 exposed additional adaptive steps despite all requested
stops being present. That was an existing documented API boundary, not a
mechanics regression. A small direct probe selected the declared configuration;
scientific accuracy remains a separate comparison with the independent oracle.
The trajectory maximum-component acceptance threshold is 2e-8; energy drift is
bounded by 2e-9 for this small smooth model. Neither is a rigorous global bound.

## Scientific dataset and bounded learning

The numerical bridge uses explicit q1 selection, time query rows, amplitude
input, ordered dimensionless unit labels, sample ID, split, stored/no-resampling
grid and deterministic-generation declaration. Reference quality is numerical,
with unknown certified error and actual source solver/tolerances/span/grid.
Analytical comparisons are separate; success never relabels targets analytical.

The same model family varies only symmetric initial amplitude. Explicit cases:
training 0.20, 0.15, 0.25; interpolation 0.175; parameter extrapolation 0.35.
The latter is a finite-dimensional amplitude parameter: AML's operator-specific
`amplitude_extrapolation` label would be incorrect here. All cases use the same
initial antisymmetric amplitude, zero velocities and time grid.

Each one-run bridge needs a standalone training sample; temporary standalone
bounds enclose its parameter. No temporary dataset is fitted. Family assembly
uses public ScientificSample constructors to assign explicit final roles before
normalization or training. Only the three final training IDs enter fitting.
The family training bounds remain [0.15,0.25].

The existing PUBLIC_EXPERIMENTAL scientific-learning architecture uses one
Lux.Dense(2=>1), seed 41, train-only min/max normalization and one Adam step.
There are three affine coefficients. An affine function of amplitude and time
cannot represent the oscillatory family accurately. The intentionally weak
bounded-error criterion checks a functioning finite pipeline, not useful
surrogate accuracy. Actual errors against numerical targets and the separate
analytical oracle must be reported. Generalization evidence stays unknown,
query membership has guarantee=:none, and errors are unweighted sampled errors.

## Derivation, same-model consistency and retention

- Mechanics → dynamics → trajectory → selected ObservableSeries is legitimate
  derivation exposed by `scientific_origin`.
- Statistical summaries are deliberate four-field leaves. Their origin is
  unavailable. The workflow keeps the source series alongside them; it does
  not insert source identity into values, notes or a new field.
- Modes derive from the mechanical linearization, whose source is the analysis.
- Legendre transformation constructs the Hamiltonian, but its native origin
  accessor does not record that parent. Keep the explicit transformation result;
  do not fabricate a descriptor chain.
- An atomistic snapshot is explicitly constructed from selected stored positions,
  with particle IDs, open boundary, time and dimensionless declaration. Its
  caller provenance carries a detached trajectory descriptor. The snapshot
  origin accessor itself has no parent; this boundary remains visible.
- Numerical simulation → dataset uses source_retention=:descriptor, deliberately
  omitting native source objects, callbacks, source context/domain and unselected
  labels. No giant upstream object is retained by an origin descriptor.
- The family dataset records all input dataset descriptors separately. Its bounded
  single-parent trace selects the canonical dataset, which really contributed
  values; it explicitly omits the other runs from that one chain. This is not
  presented as a complete provenance DAG.
- Analytical formulas and numerical results describe the same model; the
  independent oracle is NOT descended from the trajectory or eigensolver.
- Process-local tokens are neither durable identity nor reproducibility hashes.
  Equal scientific statistics remain equal/hash-equal despite different origins.

## Comparison compatibility

The example's comparison helper is local workflow code, not a new AML universal
comparison API. Before numeric subtraction it checks model, physical parameters,
coordinate/state convention, initial amplitudes/velocities, variable, units and
exact sample coordinates, plus explicitly compatible reference qualities. Shape
agreement alone is insufficient. Negative tests reject changed variables, units,
parameters, ordering, sample times and unknown quality.

Detailed measured agreements, actual learning errors, coverage, information losses,
recovery classification, review disposition and gate evidence are recorded in
[m10d_flagship_results.md](m10d_flagship_results.md). The deliberately underfit
learning branch preserves scientific data/reference semantics; it does not produce
a dynamically equivalent or accurate replacement for the oscillator.
