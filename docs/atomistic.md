# M8A: Molly companion analysis

Molly runs MD. AnalyticMathLab borrows CPU data, inspects it, analyzes scalar pair
potentials and finite-sample pair distributions, and renders results. It does not
implement a second integrator, force engine, neighbor finder or coupling framework.

## Optional environment and executable vertical slice

From the repository root, using Julia 1.12:

```sh
julia --project=. -e 'using AnalyticMathLab'
julia --project=examples/molly -e 'using Pkg; Pkg.instantiate()'
julia --project=examples/molly -e 'include("test/molly_integration.jl")'
julia --project=examples/molly notebooks/molly_companion.jl
julia --project=. -e 'using Pkg; Pkg.test()'
```

The optional environment pins Molly **0.23.3** and points at this local package.
Its manifest is separate from the base environment. Base `Pkg.test()` deliberately
runs without Molly; the integration test is a separate mandatory development gate.
If unrelated depot precompilation is slow, `--compiled-modules=existing` is usable
for focused optional checks (and was used during M8A recovery); it is not the final
canonical test command.

The notebook is an executable Julia/Pluto-style script: a deterministic 16-particle
2D shifted-LJ simulation, 200 Molly VelocityVerlet steps, 21 logged frames, explicit
timestamps, inspection, RDF, textbook LJ comparison, and a separate local dimer
mode example. Plots are saved to `notebooks/output/m8a_molly_*.png`. This is not an
equilibration or convergence study. Only the caller imports/activates CairoMakie.

## Borrowed snapshot and logger contracts

```julia
using AnalyticMathLab, Molly
s = atomistic_snapshot(sys) # no forces or potential energy calculated
report = mdcheck(s; close_distance=0.9)
one_particle = inspect_particle(s, 1; cutoff=2.5)
d = pair_distances(s; max_pairs=100_000)
with_observables = atomistic_snapshot(sys; observables=true, n_threads=1)
frames = atomistic_trajectory(sys; fixed_box=true, times=actual_saved_times)
fig = mdplot(frames; frame=2, selected_particle=1, color=:speed)
```

`positions[i][axis]` is particle-major. The Molly adapter uses `sys.coords`,
`sys.velocities`, cached `Molly.masses(sys)`, and a lazy atom-type metadata view.
It does not turn coordinates into a matrix, strip their units, or copy particle
arrays. `copy_data=true` explicitly owns snapshot particle data. Otherwise mutations
are visible; replacing a System field does not retarget an older borrowed reference.
Atom-vector order, not `Atom.index`, defines particle indices. Species means
`atom_type`, not an inferred chemical element. Cached masses can become stale if
users replace Molly atoms without updating Molly's mass cache.

`observables=true` explicitly calls Molly's public system energy and force APIs.
These allocate backend results; they are not advertised as zero-copy. Backend errors
propagate. These calls use backend step zero; `time` is snapshot metadata only.
Time-dependent interactions requiring another step are not adapted automatically.
Generic inspection derives kinetic energy, momentum, total mass and centroid from
supplied data. The periodic centroid is explicitly the centroid of supplied images,
not an unwrapped periodic molecule. Missing data produce unknown observations.
No temperature, timestep stability or simulation-validity certificate is inferred.

Molly coordinate/velocity loggers have `values(logger)` histories and `n_steps`
strides, not global timestamps. Molly already copies coordinates while logging;
AML borrows those stored arrays without another history copy. The view accesses one
frame on demand and captures the current history length. `times=nothing` means
unknown. Explicit times must match the frame count and be finite and nondecreasing.

For one fresh constant-dt `simulate!` call, default logging includes step zero and
multiples of the stride; a nonmultiple final step is not saved. Every new call
restarts local step numbering and appends history, possibly duplicating the initial
frame. Therefore AML never infers times from frame count, dt or stride alone.
Coordinate and velocity logger types, stride and count are checked, but the caller
must ensure they came from synchronized simulation calls.

`fixed_box=true` is a required caller assertion that the box, particle order,
masses and species stayed fixed for the history. The adapter cannot reconstruct
box changes that were never logged. Use the generic `AtomisticTrajectoryView` with
actual per-frame metadata for changing-box data. Historical frames never inherit
the current system's energy or force as if it were a historical measurement.

GPU systems and unknown storage wrappers are rejected before scalar array access.
No host transfer is hidden. A device guard is tested; no GPU hardware execution is
claimed. M8A supports CPU Array-backed Molly systems only.

`mdplot` supports species, speed and particle-index coloring (`color=:index`).
Spatial axes have equal data scaling; marker sizes are screen pixels, not radii.

## Geometry, pair distributions and coordination

Generic snapshots accept open or fully periodic orthorhombic geometry. Generic
minimum-image separation is `delta - round(delta/L)*L`, including multiply unwrapped
coordinates. Molly snapshots use Molly's `wrap_coords` and `vector` geometry APIs
on temporary vectors, without changing their borrowed coordinates. 2D rectangular
and 3D cubic/orthorhombic finite boxes are supported. All-infinite Molly boxes are
open. Mixed finite/infinite boxes and triclinic geometry remain unsupported for
pair analysis/RDF rather than silently becoming open or fully periodic.

```julia
s = AtomisticSnapshot([[0.,0.],[1.,0.],[3.,0.]];
    species=[:A,:A,:B], boundary=(kind=:orthorhombic,lengths=[10.,10.]))
rdf = radial_distribution(s; edges=[0.,1.,2.,3.], species=(:A,:B))
counts = coordination(s; cutoff=2., species=(:A,:B))
```

RDF requires a periodic 2D or 3D orthorhombic box, nonnegative increasing edges,
and maximum edge no larger than half the shortest box length in every frame.
2D and 3D frames cannot be pooled. Bins are `[lo,hi)`, with the final right edge
included. Self pairs are excluded. Same-species/all-particle pairs are enumerated
once (`i<j`), with ideal-gas pair population `N(N-1)/2`. Distinct species use each
A-B pair once, population `NA*NB`. No factor of two is silently applied.

Expected count per bin/frame is pair population times shell measure divided by
box measure. Shell measures are `pi*(hi^2-lo^2)` in 2D and
`4pi/3*(hi^3-lo^3)` in 3D. Counts and expected counts are summed separately over
selected frames before division. Thus changing populations and box volumes are
weighted by their actual ideal-gas expected counts, not an unweighted mean of g.
Empty selections/no eligible pairs/unsupported geometry produce unknown RDF, not
zero g. Compatible Unitful length units are converted by arithmetic; incompatible
units throw dimensional errors rather than being stripped. Radii retain edge units.

RDF streams pairs with O(bins + frames + particles) working/result storage but
O(frames*N^2) work. It is not a neighbor-list engine or large-system accelerator.
Stored `pair_distances` is separately bounded by `max_pairs` because it stores pairs.
Coordination is a direct inclusive-cutoff count: same-species pairs increment both
particles; distinct A-B pairs increment A only. Open snapshots are allowed for this
unnormalized count. Neither statistic proves equilibrium or physical validity.

## Scalar potentials and configured Molly interactions

```julia
using Symbolics
@variables r
p = analyze_potential((r-2)^2, r; interval=(0.5,4.))
p.numerical.force(3.) # -2: radial force F(r) = -dU/dr
lj = lennard_jones_analysis(epsilon=1., sigma=1.)
fig = potentialplot(lj; rmin=0.95, rmax=3.)
forcefig = forceplot(lj; rmin=0.95, rmax=3.)
```

These reuse the scalar symbolic analyzer and stored derivatives/callables. Original
syntax/domain exclusions survive through `@real_function`; physical radii must be
finite and strictly positive. The univariate real study still describes the
original algebraic expression, so negative-radius conclusions are not physical.
Units here are explicit labels on consistently scaled numeric values, not implicit
Unitful conversion. Unbound symbolic parameters are rejected.

Textbook LJ is `4epsilon*((sigma/r)^12-(sigma/r)^6)`. The scaled identity `x^6=2`
verifies its positive stationary minimum, depth `-epsilon`, and curvature
`72epsilon/rmin^2`. Stored coordinates/curvature are Float64 approximations. This
local identity certificate does not upgrade unknown properties in the bounded
generic global study. The singularity at zero is excluded. Force sign is radial:
positive is repulsion, negative attraction.

`cutoff` on `analyze_potential` is metadata ONLY: the function is not truncated,
shifted, switched or mixed. In contrast, `Molly.LennardJones` uses actual configured
mixing/shortcut/special-pair/cutoff rules. Inspect those using Molly's public
`potential_energy(lj,dr,ai,aj,energy_units)` and
`force(lj,dr,ai,aj,force_units)`; pass `NoUnits` for unitless pairs. The integration
tests and notebook compare shifted-potential energy to textbook `U(r)-U(rc)` and
check unmodified interior force. Molly cutoff and vector-force semantics are not
reimplemented in AML. There is no automatic configured-interaction symbolic study.

## Minimal M7 mode bridge

```julia
s = AtomisticSnapshot([[0.,0.],[1.,0.]]; masses=[1.,2.])
r = normal_modes(s; hessian=K) # K must be 4x4: x1,y1,x2,y2
normal_modes(s).evidence.status # :unknown without a Hessian
modeplot(r; modes=[4])          # existing M7 component view
```

The caller supplies a Cartesian energy Hessian at these coordinates. No force
finite differences, equilibrium search or Hessian provider is invented. The bridge
reuses `cartesian_mass_matrix` and the existing dense Float64 M7 generalized
symmetric eigensolver. Numerical zeros do not identify physical translations,
rotations or constraints without independent evidence. Non-equilibrium snapshots
are not silently certified as equilibria.

For Unitful data, positions, masses and Hessian must all carry consistent dimensions.
Both ordinary and molar masses are supported. Conversion precedes stripping.
M7 arrays and frequencies use explicit `length_scale`, `mass_scale`,
`stiffness_scale` and `frequency_scale` in metadata. Multiply numerical frequencies
by the frequency scale, or read `metadata.angular_frequencies`, for physical angular
frequencies. Negative modes retain missing frequencies. Mode vectors are normalized
against the scaled mass matrix, not relabeled as unscaled physical displacement
amplitudes. Raw numerical eigenvalues can differ with the chosen units; physical
frequencies are invariant under compatible unit conversions.

## Boundary with M8B and M8C

M8A stops at borrowed inspection, scalar pair analysis, finite-sample RDF/direct
coordination, visualization and the minimal M7 bridge. M8B now implements
[trajectory statistics](trajectory_statistics.md), including MSD, VACF,
autocorrelation and effective sample size, without changing M8A's borrowed-data
contracts. Comparison of compatible stored M8B results belongs to M8C and requires
separate authorization. No compare_runs, stochastic rounding, Brownian/Langevin
dynamics or Monte Carlo are implemented. There is no new MD integrator, neighbor
engine, thermostat, barostat or GPU force engine.
