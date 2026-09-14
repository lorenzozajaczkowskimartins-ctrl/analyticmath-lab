# Rendering samples the field only; it never differentiates or infers properties.
function _vf_arrows(report, xrange, yrange, samples, arrowscale)
    report.input_dimension == report.output_dimension == 2 ||
        throw(ArgumentError("vector plots require R² → R² fields"))
    xa,xb = _mv_view_bounds(xrange,:xrange); ya,yb = _mv_view_bounds(yrange,:yrange)
    count = _mv_samples(samples;maximum=50)
    scale = Float64(arrowscale)
    isfinite(scale) && scale > 0 || throw(ArgumentError("arrowscale must be finite and positive"))
    points = Makie.Point2f[]; vectors = Makie.Vec2f[]
    for x in range(xa,xb;length=count), y in range(ya,yb;length=count)
        point = Makie.Point2f(x,y)
        all(isfinite,point) || continue
        # Test the rendered Float32 anchor, so rounding cannot place an arrow on
        # an excluded boundary even if the original Float64 grid point was valid.
        p = Tuple(point)
        domain_contains(report.domain,p) === true || continue
        value = try
            evaluate(report,p)
        catch err
            err isa InterruptException && rethrow()
            continue
        end
        vector = Makie.Vec2f(scale*value[1],scale*value[2])
        all(isfinite,vector) || continue
        push!(points,point); push!(vectors,vector)
    end
    return points,vectors
end

"""
    vectorplot(report; xrange=(-2,2), yrange=(-2,2), samples=15, arrowscale=1)

Unnormalized 2D field arrows from stored callables, with explicit positive scale.
Unknown/invalid anchors are masked. Arrows are glyphs, not integral curves or a
certificate that an entire arrow shaft lies in the domain. No backend is activated.
"""
function vectorplot(report::VectorFieldAnalysis; xrange=(-2,2),yrange=(-2,2),
        samples::Integer=15,arrowscale::Real=1)
    points,vectors = _vf_arrows(report,xrange,yrange,samples,arrowscale)
    figure = Makie.Figure()
    axis = Makie.Axis(figure[1,1];xlabel=string(report.variables[1]),ylabel=string(report.variables[2]),
        title="Vector field (unnormalized; scale=$(Float64(arrowscale)))",aspect=Makie.DataAspect())
    isempty(points) || Makie.arrows2d!(axis,points,vectors;normalize=false)
    Makie.xlims!(axis,xrange...); Makie.ylims!(axis,yrange...)
    return figure
end
plot(report::VectorFieldAnalysis;kwargs...) = vectorplot(report;kwargs...)
