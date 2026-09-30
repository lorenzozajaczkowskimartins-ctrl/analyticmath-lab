# M8 trajectory observations and LJ inference

`distance_observations(view::AtomisticTrajectoryView, (i,j); frames=1:length(view),
name=:r, units=nothing)` freezes one pair's distances and actual saved times as an
existing `ObservableSeries`. It retains the source view, selected frames and pair,
copied snapshot boundary/provenance metadata, and the geometry convention.
Distances use M8's backend callback when supplied, otherwise open Euclidean or
orthorhombic minimum-image geometry. Unsupported boundaries and invalid frames
are rejected. Wrapped coordinates are never naively subtracted across a boundary.

Unknown times remain unknown. Conflicting snapshot/view times are rejected;
frame numbers never become inferred physical times. Unitful values retain units.
For unitless values, `units` is a caller-supplied label, not a conversion.
The source view is borrowed for provenance; frozen values/times remain separate.

`ObservationSet(series; time_scale=nothing, length_scale=nothing,
kind=:user_supplied, role=:fit, weights=nothing)` copies the observations into the
numeric inference boundary. It rejects unknown and sample-index time. Unitful
inputs require explicit compatible scales; division must produce dimensionless
coordinates. Unit metadata records both original units and scales, while
`provenance.source_series` retains the original series. No timestamps, units,
noise distribution or uncertainty are invented.

## Controlled epsilon benchmark

```sh
julia +release --project=examples/inference examples/inference/lj_gate.jl
```

The trusted generator composes M8's symbolically differentiated Lennard-Jones
potential with the existing M6 Cartesian two-particle solver. Saved snapshots
are wrapped into an orthorhombic box of length 10 and exposed through M8's lazy
trajectory view. This is an M8-consistent controlled trajectory, not a Molly run.
All numerical coordinates use explicitly declared reduced units, with equal
particle masses 1, true epsilon 1.2 and known sigma 1. There is no cutoff,
thermostat, surrounding medium or many-body interaction.

The observed coordinate is minimum-image separation r(t). Odd/even saved frames
form disjoint fit/held-out sets. The independent forward inverse model uses
`r'' = 2 F(r)/m`: the reduced mass is m/2, not m. Initial relative velocity is
known to be zero. Its explicit radial law is checked against the M8 symbolic
potential, symbolic force and independent ForwardDiff derivative, including
repulsive/attractive signs and the force zero at `2^(1/6) sigma`.

Only epsilon is inferred, from initial guess 0.9, using 400 Adam iterations.
Sigma is fixed explicitly; joint epsilon/sigma inference is not attempted, and
no claim about its conditioning is made. The result retains the local one-column
sensitivity and all deterministic-inference provenance/evidence.

Potential and force errors are measured separately over the observed distance
range and an outside range. The latter is labeled extrapolation, even when
errors are small. A known parametric family containing the generating law makes
this a parameter-recovery demonstration, not governing-law discovery. Generic
many-body pair distances do not obey this closed scalar dimer equation.

Generated figures:

- `notebooks/output/m9c_lj_fit.png`: fit/held-out observations, recovery and SVD.
- `notebooks/output/m9c_lj_potential_force.png`: observed-range and extrapolation
  potential/force comparisons with the radial sign convention.

A small trajectory mismatch does not prove a correct governing law, a unique
parameter, or validity beyond sampled conditions. No global identifiability,
Bayesian uncertainty or general molecular force-field reconstruction is claimed.
