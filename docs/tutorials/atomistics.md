# Atomistic stored data: geometry, ordering and units

[Learning path](index.md) · Previous: [trajectories](trajectories.md) ·
Next: [integrated investigation](one-system-many-methods.md)

Prerequisites: Euclidean distance and scientific units. Difficulty: introductory–intermediate.
Dependencies: AnalyticMathLab and Unitful, both declared in the root project.
Molly is not required. Executable: [atomistics.jl](scripts/atomistics.jl).
From the repository root:

```sh
julia +1.12.7 --project=. docs/tutorials/scripts/atomistics.jl
```

## Problem and declared interpretation

Construct a small stored configuration, not a simulation. Particle positions in
an open two-dimensional plane are

$$r_1=(0,0)\ {\rm nm},\quad r_2=(3,0)\ {\rm nm},\quad r_3=(0,4)\ {\rm nm}.$$

Each outer array entry is a particle; each inner entry is an ordered Cartesian
coordinate $(x,y)$. Masses are caller-supplied positive illustrative values
$(1,2,3)$ atomic mass units (`u"u"`), not inferred chemical masses or a force field.
Species `A,A,B` are selection labels, not discovered elements. The snapshot time
is supplied as zero picoseconds; it establishes no simulation history.

Euclidean distances for open geometry are

$$d_{ij}=\|r_j-r_i\|_2.$$

The resulting triangle has sides 3, 4 and 5 nm. Same/all-particle pairs are stored
once with $i<j$. Selecting `(:A,:B)` instead requests directed A-to-B indices:
$(1,3)$ and $(2,3)$. Selection and geometry are different operations: changing
species selection does not change positions or the metric.

## Implementation

Unitful quantities carry actual compatible dimensions through arithmetic; they
are not merely string labels. `copy_data=true` gives owned particle data, allowing
the final check to demonstrate isolation from a later input mutation. Default
snapshots borrow arrays, which must be treated read-only during analysis.
No velocities, forces, potential energy or equilibrium certificate are supplied.

```julia
using AnalyticMathLab, Unitful

# Particle-major 2D open geometry. A/B are labels, not inferred elements.
positions = [[0.0, 0.0], [3.0, 0.0], [0.0, 4.0]] .* u"nm"
snapshot = AtomisticSnapshot(positions; masses=[1.0, 2.0, 3.0] .* u"u",
    species=[:A, :A, :B], boundary=(kind=:open,), time=0.0u"ps", copy_data=true)
@assert snapshot.dimension == 2
@assert length(snapshot.masses) == length(snapshot.positions) == 3
allpairs = pair_distances(snapshot; max_pairs=3, max_bytes=1024)
@assert allpairs.status == :heuristic
@assert allpairs.value.pairs == [(1, 2), (1, 3), (2, 3)]
@assert allpairs.value.distances == [3.0u"nm", 4.0u"nm", 5.0u"nm"]
selected = pair_distances(snapshot; species=(:A, :B), max_pairs=2, max_bytes=1024)
@assert selected.value.pairs == [(1, 3), (2, 3)]
@assert selected.value.distances == [4.0u"nm", 5.0u"nm"]
refused = pair_distances(snapshot; max_pairs=2)
@assert refused.status == :unknown && refused.value === nothing
# Owned particle data do not change when a caller later edits the input array.
positions[1][1] = 99.0u"nm"
@assert snapshot.positions[1][1] == 0.0u"nm"
println((pairs=allpairs.value.pairs, distances=allpairs.value.distances,
    selected_pairs=selected.value.pairs, units=allpairs.value.units,
    limited_output_status=refused.status))
println("ATOMISTICS_OK")
```

## Verification and interpretation

ANALYTICAL_REFERENCE: coordinate differences are $(3,0)$, $(0,4)$ and $(-3,4)$
nm; the Pythagorean identity gives lengths 3, 4 and 5 nm independently of AML.
EXAMPLE_EXECUTED: pair order was `[(1,2),(1,3),(2,3)]` and distances
`[3.0 nm,4.0 nm,5.0 nm]`; the A-to-B selection returned `[(1,3),(2,3)]`.
These values are exactly representable for this small geometry, so exact equality
checks are appropriate. The reported unit was `nm`. A two-pair budget for the
three-pair output returned `:unknown` with `value === nothing`, not an empty list
or zero distances. Ownership was checked by modifying the caller's input after
construction and verifying the snapshot retained its original coordinate.

A successfully analyzed configuration is not necessarily mechanically stable,
equilibrated, chemically realistic or a valid molecular model. Masses are stored
but not needed for these distances. A bare unit label would not convert numbers;
the actual Unitful arrays are what give this example length and mass dimensions.

## Pair count, geometry and scope

SOURCE_INSPECTED: all-pair enumeration stores $N(N-1)/2$ unordered pairs, with
quadratic work and output growth. `max_pairs` limits output count; `max_bytes`
checks an operation-specific estimate. These are not universal streaming or peak-RSS
guarantees, and no global memory setter is implied. This tutorial uses at most
three pairs and a 1024-byte estimate limit. Unknown output must be investigated,
not automatically treated as physically absent pairs.

Open Euclidean geometry is deliberately chosen. Fully periodic orthorhombic
minimum-image distances have different semantics; no periodic box or image
history is invented here. Supplied potentials would be caller interaction models,
not automatic force-field discovery. No RDF, force calculation or dynamics is run.

The existing [atomistic guide](../atomistic.md) describes the optional Molly adapter
and its separately declared [example environment](../../examples/molly/Project.toml).
Loading Molly and supplying synchronized stored data are separate steps; do not
install it just to reproduce this base lesson. Continue to the
[capstone](one-system-many-methods.md).
[Execution record](../../reports/m10d6/tutorial_implementation_report.md).
