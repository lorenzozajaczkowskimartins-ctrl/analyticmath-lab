"""
Optional stored-data figures using AML views and public Makie overlays.
Choose/activate a backend in the calling session, for example CairoMakie.activate!().
Include this file, call r=OneSystemPlots.OneSystemManyMethods.investigate(), then
OneSystemPlots.figures(r). No backend is selected by AML or by this helper.
"""
module OneSystemPlots
using AnalyticMathLab, Makie
include("one_system_many_methods.jl")

function figures(r)
    trajectory = timeplot(r.path)
    ax = Makie.content(trajectory[1,1])
    ax.title = "Same oscillator: solid numerical, dashed analytical"
    ax.xlabel = "t [dimensionless]"
    ax.ylabel = "q, v [dimensionless]"
    for i in 1:4
        Makie.lines!(ax,r.system.times,vec(r.exact[i,:]);linestyle=:dash,color=Cycled(i))
    end
    energy = energyplot(r.conversion,r.path)
    ax = Makie.content(energy[1,1])
    ax.xlabel = "t [dimensionless]"
    ax.ylabel = "Energy [dimensionless]"
    # Keep the absolute energy scale visible; auto-zoom otherwise magnifies
    # tiny integration drift while rounding every tick to the same value.
    Makie.ylims!(ax,0.0,1.1*r.metrics.energy)
    ax.title = "Numerical energy (not a conservation certificate)\n" *
        "Maximum sampled drift = $(round(r.metrics.energy_drift;sigdigits=3))"
    Makie.hlines!(ax,[r.metrics.energy];linestyle=:dash,color=:black,label="Analytical energy")
    Makie.axislegend(ax)
    indices = r.atomistic.indices
    values = [only(d.value.distances) for d in r.atomistic.distances]
    series = ObservableSeries(values;times=r.system.times[indices],name=:pair_distance,
        provenance=(mapping=:explicit_longitudinal,units=:dimensionless))
    distance = timeseriesplot(series)
    ax = Makie.content(distance[1,1])
    ax.title = "Explicit anchored-particle interpretation (not a new MD simulation)"
    ax.xlabel = "t [dimensionless]"
    ax.ylabel = "Pair distance [dimensionless]"

    exact = abs.(r.system.equilibrium_positions[2]-r.system.equilibrium_positions[1] .+
                 r.exact[2,:].-r.exact[1,:])
    Makie.lines!(ax,r.system.times,exact;linestyle=:dash,color=:black,label="Analytical mapped distance")
    Makie.scatter!(ax,r.system.times[indices],values;color=:blue)
    Makie.axislegend(ax)
    (;trajectory,energy,distance)
end
end
