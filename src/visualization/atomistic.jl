# Presentation owns only small rendering buffers; source arrays remain untouched.
_at_plot_scale(x,scale)=Float64(x isa Unitful.AbstractQuantity ? Unitful.ustrip(Unitful.NoUnits,x/scale) : x/scale)

"""
    mdplot(snapshot; color=:species, selected_particle=nothing, markersize=14)
    mdplot(trajectory; frame=1, kwargs...)

Render supplied 2D/3D coordinate images, with optional particle highlight and
orthorhombic box. Marker size is in screen pixels, never an inferred atomic radius
or bond. `color=:species` uses metadata categories; `:speed` uses supplied velocities.
Only the requested lazy frame is accessed. No backend activation, dynamics, file
output, unwrapping, interpolation, or chemical bond inference occurs.
"""
function mdplot(s::AtomisticSnapshot;color=:species,selected_particle=nothing,markersize=14)
    _at_positions_ok(s) && s.dimension in (2,3) && !isempty(s.positions) ||
        throw(ArgumentError("Finite nonempty 2D/3D coordinates required."))
    color in (:species,:speed,:index) || throw(ArgumentError("color must be :species, :speed or :index"))
    selected_particle===nothing || (selected_particle isa Integer && 1<=selected_particle<=length(s.positions)) ||
        throw(BoundsError(s.positions,selected_particle))
    isfinite(markersize) && markersize>0 || throw(ArgumentError("markersize must be finite and positive"))
    scale=first(first(s.positions)) isa Unitful.AbstractQuantity ? oneunit(first(first(s.positions))) : 1
    unit=_at_unit(first(first(s.positions)))
    points=[Makie.Point{ s.dimension,Float64}(Tuple(_at_plot_scale(x,scale) for x in p)) for p in s.positions]
    fig=Makie.Figure(size=(800,650))
    labels=(xlabel="x [$unit]",ylabel="y [$unit]",title="Particle snapshot — supplied coordinate images")
    ax=s.dimension==2 ? Makie.Axis(fig[1,1];labels...,aspect=Makie.DataAspect()) :
        Makie.Axis3(fig[1,1];labels...,zlabel="z [$unit]",aspect=:data)
    if color==:speed
        _at_velocities_ok(s) || throw(ArgumentError("Finite velocities required for speed coloring."))
        speeds=LinearAlgebra.norm.(s.velocities)
        vscale=first(speeds) isa Unitful.AbstractQuantity ? oneunit(first(speeds)) : 1
        values=[_at_plot_scale(v,vscale) for v in speeds]
        scatter=Makie.scatter!(ax,points;color=values,markersize,colormap=:viridis)
        Makie.Colorbar(fig[1,2],scatter;label="Speed [$(_at_unit(first(speeds)))]")
    elseif color==:index
        scatter=Makie.scatter!(ax,points;color=collect(eachindex(points)),markersize,colormap=:viridis)
        Makie.Colorbar(fig[1,2],scatter;label="Particle index")
    elseif s.species!==nothing && length(s.species)==length(points)
        groups=unique(s.species)
        for (k,group) in enumerate(groups)
            Makie.scatter!(ax,points[findall(==(group),s.species)];markersize,
                color=Makie.wong_colors()[mod1(k,length(Makie.wong_colors()))],label=string(group))
        end
        Makie.Legend(fig[1,2],ax,"Species / atom type")
    else
        Makie.scatter!(ax,points;markersize,color=:steelblue)
    end
    if _at_box_ok(s)
        L=[_at_plot_scale(x,scale) for x in s.boundary.lengths]
        d=s.dimension
        vertices=[Makie.Point{d,Float64}(Tuple(((bits>>(k-1))&1)*L[k] for k in 1:d)) for bits in 0:(2^d-1)]
        segments=typeof(first(points))[]
        for bits in 0:(2^d-1),k in 1:d
            bits & (1<<(k-1)) == 0 || continue
            append!(segments,[vertices[bits+1],vertices[(bits | (1<<(k-1)))+1]])
        end
        Makie.linesegments!(ax,segments;color=(:gray,0.6),linewidth=1)
    end
    if selected_particle!==nothing
        Makie.scatter!(ax,[points[selected_particle]];markersize=markersize+10,color=:transparent,
            strokecolor=:red,strokewidth=3)
    end
    fig
end
mdplot(r::AtomisticSystemAnalysis;kwargs...)=mdplot(r.source;kwargs...)
mdplot(t::AtomisticTrajectoryView;frame::Integer=1,kwargs...)=mdplot(t[frame];kwargs...)
mdplot(x;kwargs...)=mdplot(atomistic_snapshot(x);kwargs...)

"""Render stored RDF bins; unknown normalization is not displayed as zero g(r)."""
function plot(r::RadialDistributionAnalysis)
    r.rdf.value===nothing && throw(ArgumentError("RDF normalization unavailable; inspect rdf.notes."))
    scale=first(r.centers) isa Unitful.AbstractQuantity ? oneunit(first(r.centers)) : 1
    fig=Makie.Figure(size=(800,500))
    ax=Makie.Axis(fig[1,1];xlabel="r [$(r.units.radius)]",ylabel="g(r)",
        title="Finite-sample RDF — $(r.frame_count) frame(s)")
    Makie.lines!(ax,[_at_plot_scale(x,scale) for x in r.centers],r.rdf.value)
    Makie.hlines!(ax,[1.];color=:gray,linestyle=:dash)
    fig
end
