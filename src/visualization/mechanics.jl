# Use the existing original-domain grid for optional Hamiltonian level curves.
struct _MechanicsEnergyView{D,V,M}
    conversion::D
    variables::V
    domain::M
    dimension::Int
end
evaluate(view::_MechanicsEnergyView,point::Union{Tuple,AbstractVector}) =
    _mechanics_energy(view.conversion,point,0.0)

"""
    phaseplot(conversion::MechanicsDynamics; energy_levels=nothing, kwargs...)

Reuse the cached M6 planar phase portrait. Optional energy contours are sampled
illustrations, not invariant-curve proofs. No integration or analysis is rerun.
"""
function phaseplot(conversion::MechanicsDynamics;energy_levels=nothing,
        xrange=(-2,2),yrange=(-2,2),kwargs...)
    conversion.analysis isa DynamicalSystemAnalysis ||
        throw(ArgumentError("phase portraits require autonomous mechanics"))
    fig = phaseplot(conversion.analysis;xrange,yrange,kwargs...)
    if energy_levels !== nothing
        levels = collect(energy_levels)
        !isempty(levels) && all(x -> x isa Real && isfinite(x),levels) ||
            throw(ArgumentError("energy_levels must contain finite real values"))
        issorted(levels) && length(unique(levels)) == length(levels) ||
            throw(ArgumentError("energy_levels must be strictly increasing"))
        view = _MechanicsEnergyView(conversion,conversion.variables,conversion.domain,2)
        xs,ys,zs = _mv_grid(view,xrange,yrange,101)
        axis = only(filter(c -> c isa Makie.Axis,fig.content))
        Makie.contour!(axis,xs,ys,zs;levels=Float64.(levels),color=:darkorange,linewidth=1.5)
        axis.title[] = string(axis.title[],"; orange: energy levels")
    end
    return fig
end

"""Convenience view; pass `conversion=dynamics(report)` to reuse a previous conversion."""
function phaseplot(report::Union{LagrangianAnalysis,HamiltonianAnalysis};
        conversion=dynamics(report),kwargs...)
    conversion isa MechanicsDynamics && conversion.source === report ||
        throw(ArgumentError("conversion must originate from this mechanics report"))
    return phaseplot(conversion;kwargs...)
end

"""
    energyplot(conversion, path)

Numerical Lagrangian energy function or Hamiltonian at saved trajectory points.
This does not establish conservation or certify the continuous interpolant.
"""
function energyplot(conversion::MechanicsDynamics,path::TrajectoryResult)
    samples = energy_drift(conversion,path).value
    label = conversion.source isa LagrangianAnalysis ? "Lagrangian energy function" : "Hamiltonian H"
    fig = Makie.Figure()
    axis = Makie.Axis(fig[1,1];xlabel="t",ylabel=label,
        title="Numerical energy (not a conservation certificate)")
    Makie.lines!(axis,samples.times,samples.values;linewidth=2)
    return fig
end
function energyplot(report::Union{LagrangianAnalysis,HamiltonianAnalysis},path::TrajectoryResult;
        conversion)
    conversion isa MechanicsDynamics && conversion.source === report ||
        throw(ArgumentError("conversion must originate from this mechanics report"))
    return energyplot(conversion,path)
end

"""
    modeplot(result::NormalModeAnalysis; modes=nothing, representation=:generalized)

Plot stored mode components against coordinate index; no particle geometry is
assumed. `:mass_weighted` selects e instead of a=M^(-1/2)e. Degenerate bases are
nonunique. This view neither recomputes analysis nor activates a backend.
"""
function modeplot(r::NormalModeAnalysis;modes=nothing,representation=:generalized)
    r.mode_vectors === nothing && throw(ArgumentError("modeplot requires computed modes"))
    representation in (:generalized,:mass_weighted) || throw(ArgumentError("representation must be :generalized or :mass_weighted"))
    indices = modes === nothing ? collect(eachindex(r.eigenvalues)) : collect(modes)
    !isempty(indices) && all(i->i isa Integer && 1<=i<=length(r.eigenvalues),indices) ||
        throw(ArgumentError("modes must contain valid mode indices"))
    vectors = representation == :generalized ? r.mode_vectors : r.weighted_vectors
    fig = Makie.Figure()
    label = representation == :generalized ? "a component (mass normalized)" : "e component (mass weighted, unit norm)"
    axis = Makie.Axis(fig[1,1];xlabel="Generalized-coordinate index",ylabel=label,
        title="Local mode shapes; degenerate bases are nonunique")
    for i in indices
        Makie.scatterlines!(axis,1:size(vectors,1),vectors[:,i];label="Mode $i: $(r.classifications[i])")
    end
    Makie.Legend(fig[1,2],axis)
    fig
end
