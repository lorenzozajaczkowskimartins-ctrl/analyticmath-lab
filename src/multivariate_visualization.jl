function _mv_view_bounds(bounds, name)
    bounds isa Tuple && length(bounds) == 2 || throw(ArgumentError("$name must be a pair"))
    a,b = Float64.(bounds)
    isfinite(a) && isfinite(b) && a < b || throw(ArgumentError("$name must contain finite increasing bounds"))
    return a,b
end

function _mv_samples(samples; maximum=501)
    samples isa Integer && 2 <= samples <= maximum ||
        throw(ArgumentError("samples must be an integer between 2 and $maximum"))
    return samples
end

function _mv_safe_value(report, point)
    domain_contains(report.domain, point) === true || return NaN
    value = try evaluate(report, point) catch; NaN end
    return value isa Real && isfinite(value) ? Float64(value) : NaN
end

function _mv_restriction_value(restriction, report, point)
    names = Symbol[_mv_ast(v) for v in report.variables]
    value = try _mv_eval_ast(restriction.expression, names, point) catch; NaN end
    return value isa Real && isfinite(value) ? Float64(value) : NaN
end

# Conservative interval arithmetic for rendering cells, not analysis evidence.
# Unsupported interval operations blank cells rather than bridge an exclusion.
_mv_enclose(a,b) = isnan(a) || isnan(b) ? (-Inf,Inf) : (prevfloat(a),nextfloat(b))
_mv_iadd(a,b) = _mv_enclose(a[1]+b[1],a[2]+b[2])
_mv_ineg(a) = (-a[2],-a[1])
function _mv_imul(a,b)
    values = (a[1]*b[1],a[1]*b[2],a[2]*b[1],a[2]*b[2])
    any(isnan,values) && return (-Inf,Inf)
    _mv_enclose(minimum(values),maximum(values))
end
function _mv_idiv(a,b)
    b[1] <= 0 <= b[2] && return (-Inf,Inf)
    _mv_imul(a,_mv_enclose(1/b[2],1/b[1]))
end
function _mv_interval(e, names, box)
    if e isa Real
        value = Float64(e)
        return _mv_enclose(value,value)
    elseif e isa Symbol
        k = findfirst(==(e),names)
        return k === nothing ? (-Inf,Inf) : box[k]
    end
    e isa Expr && e.head == :call || return (-Inf,Inf)
    op = _mv_op(e); args = e.args[2:end]
    if op == :^ && length(args)==2 && args[2] isa Integer && -32<=args[2]<=32
        a = _mv_interval(args[1],names,box); exponent=args[2]
        r = (1.0,1.0)
        for _ in 1:abs(exponent); r=_mv_imul(r,a); end
        return exponent<0 ? _mv_idiv((1.0,1.0),r) : r
    end
    aa = [_mv_interval(a,names,box) for a in args]
    isempty(aa) && return (-Inf,Inf)
    op == :+ && return foldl(_mv_iadd,aa)
    op == :* && return foldl(_mv_imul,aa)
    op == :- && return length(aa)==1 ? _mv_ineg(only(aa)) : foldl((a,b)->_mv_iadd(a,_mv_ineg(b)),aa)
    op in (:/, ://) && length(aa)==2 && return _mv_idiv(aa[1],aa[2])
    (-Inf,Inf)
end

function _mv_grid(report, xrange, yrange, samples)
    report.dimension == 2 || throw(ArgumentError("scalar-field plotting is available only in two dimensions"))
    xa,xb = _mv_view_bounds(xrange,:xrange); ya,yb = _mv_view_bounds(yrange,:yrange)
    count = _mv_samples(samples)
    xs = collect(range(xa,xb; length=count)); ys = collect(range(ya,yb; length=count))
    zs = [_mv_safe_value(report,(x,y)) for x in xs, y in ys]
    # Enclose each original constraint over the entire cell. Sign sampling
    # alone misses even-multiplicity zeros and small holes inside a cell.
    if report.domain.status in (:established,:partial)
        names = Symbol[_mv_ast(v) for v in report.variables]
        for restriction in report.domain.restrictions
            for i in 1:count-1, j in 1:count-1
                low,high = _mv_interval(restriction.expression,names,((xs[i],xs[i+1]),(ys[j],ys[j+1])))
                crossing = restriction.relation == :nonzero ? low<=0<=high :
                    restriction.relation == :positive ? low<=0 : low<0
                crossing && for (ii,jj) in ((i,j),(i+1,j),(i,j+1),(i+1,j+1)); zs[ii,jj]=NaN; end
            end
        end
    end
    return xs,ys,zs
end

function _mv_stationary_xyz(report, xrange, yrange)
    xs=Float64[]; ys=Float64[]; zs=Float64[]
    for candidate in report.stationary_points.value
        x,y = candidate.point
        domain_contains(report.domain,(x,y)) === true || continue
        xrange[1] <= x <= xrange[2] && yrange[1] <= y <= yrange[2] || continue
        isfinite(candidate.value) || continue
        push!(xs,Float64(x)); push!(ys,Float64(y)); push!(zs,Float64(candidate.value))
    end
    return xs,ys,zs
end

"""Return a 2D scalar-field surface. Rendering requires a caller-loaded Makie backend."""
function surface(report::ScalarFieldAnalysis; xrange=(-5,5), yrange=(-5,5), samples::Integer=101,
        tangent_at=nothing, critical_markers::Bool=true)
    xs,ys,zs = _mv_grid(report,xrange,yrange,samples)
    figure=Makie.Figure(); axis=Makie.Axis3(figure[1,1]; xlabel=string(report.variables[1]),
        ylabel=string(report.variables[2]), zlabel="f", title=string(report.expression))
    Makie.surface!(axis,xs,ys,zs)
    if tangent_at !== nothing
        tangent=linearization(report,tangent_at)
        plane=[tangent.value + tangent.coefficients[1]*(x-tangent.base_point[1]) +
            tangent.coefficients[2]*(y-tangent.base_point[2]) for x in xs,y in ys]
        Makie.surface!(axis,xs,ys,plane; transparency=true,alpha=0.45,color=:orange)
    end
    if critical_markers
        px,py,pz=_mv_stationary_xyz(report,_mv_view_bounds(xrange,:xrange),_mv_view_bounds(yrange,:yrange))
        isempty(px) || Makie.scatter!(axis,px,py,pz; color=:red,markersize=12)
    end
    return figure
end

"""Return filled contours of a two-dimensional scalar field."""
function contour(report::ScalarFieldAnalysis; xrange=(-5,5),yrange=(-5,5),samples::Integer=101,
        levels=15,critical_markers::Bool=true)
    xs,ys,zs=_mv_grid(report,xrange,yrange,samples)
    figure=Makie.Figure(); axis=Makie.Axis(figure[1,1];xlabel=string(report.variables[1]),
        ylabel=string(report.variables[2]),title=string(report.expression),aspect=Makie.DataAspect())
    Makie.contourf!(axis,xs,ys,zs;levels)
    if critical_markers
        px,py,_=_mv_stationary_xyz(report,_mv_view_bounds(xrange,:xrange),_mv_view_bounds(yrange,:yrange))
        isempty(px) || Makie.scatter!(axis,px,py;color=:red,markersize=10)
    end
    return figure
end

"""Return unnormalized gradient arrows on a coarse grid (maximum 50×50)."""
function gradientplot(report::ScalarFieldAnalysis; xrange=(-5,5),yrange=(-5,5),samples::Integer=15,
        arrowscale::Real=1)
    report.dimension == 2 || throw(ArgumentError("gradient plots are available only in two dimensions"))
    xa,xb=_mv_view_bounds(xrange,:xrange); ya,yb=_mv_view_bounds(yrange,:yrange)
    count=_mv_samples(samples;maximum=50)
    scale=Float64(arrowscale)
    isfinite(scale) && scale>0 || throw(ArgumentError("arrowscale must be finite and positive"))
    xs=collect(range(xa,xb;length=count)); ys=collect(range(ya,yb;length=count))
    points=Makie.Point2f[]; vectors=Makie.Vec2f[]
    for x in xs,y in ys
        domain_contains(report.domain,(x,y)) === true || continue
        g=try gradient(report,(x,y)) catch; continue end
        all(isfinite,g) || continue
        point=Makie.Point2f(x,y); vector=Makie.Vec2f(scale*g[1],scale*g[2])
        all(isfinite,point) && all(isfinite,vector) || continue
        push!(points,point); push!(vectors,vector)
    end
    figure=Makie.Figure(); axis=Makie.Axis(figure[1,1];xlabel=string(report.variables[1]),
        ylabel=string(report.variables[2]),title="Gradient (unnormalized; scale=$scale)",aspect=Makie.DataAspect())
    isempty(points) || Makie.arrows2d!(axis,points,vectors)
    Makie.xlims!(axis,xa,xb); Makie.ylims!(axis,ya,yb)
    return figure
end

plot(report::ScalarFieldAnalysis; kwargs...) = surface(report; kwargs...)
