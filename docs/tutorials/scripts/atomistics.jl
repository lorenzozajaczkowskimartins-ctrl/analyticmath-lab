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
