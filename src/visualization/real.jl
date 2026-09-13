# Presentation helpers: consume stored certificates; never rerun analysis.
function _real_plot_curve(report, a, b, samples)
    xs = collect(range(a, b; length=samples))
    study = report.real_analysis
    if study === nothing || study.domain.status != :established
        return xs, [_plot_value(report, t) for t in xs]
    end
    boundaries = sort!(unique(Float64[t for i in study.domain.components
        for t in (i.left, i.right) if isfinite(t) && a <= t <= b]))
    append!(xs, boundaries)
    sort!(unique!(xs))
    ys = [domain_contains(study.domain, t) === true ? _plot_value(report, t) : NaN for t in xs]
    # Explicit boundary separators also handle nonrepresentable rational holes.
    for t in boundaries
        k = searchsortedfirst(xs, t)
        exact_boundary = any(i -> (!i.left_closed && Float64(i.left) == t) ||
            (!i.right_closed && Float64(i.right) == t), study.domain.components)
        exact_boundary && (ys[k] = NaN)
    end
    # Two included endpoints can border an unsampled forbidden open gap.
    # Insert a rendering separator, not an inferred/evaluated function value.
    for k in length(xs)-1:-1:1
        if isfinite(ys[k]) && isfinite(ys[k+1]) &&
           !any(i -> _ra_contains(i,xs[k]) && _ra_contains(i,xs[k+1]), study.domain.components)
            insert!(xs,k+1,xs[k])
            insert!(ys,k+1,NaN)
        end
    end
    return xs, ys
end

function _real_plot_points(report, a, b)
    points = Tuple{Float64,Float64}[]
    study = report.real_analysis
    function add(x, y)
        if x isa Real && y isa Real && isfinite(x) && isfinite(y) && a <= x <= b &&
           (study === nothing || domain_contains(study.domain, x) !== false)
            push!(points, (Float64(x), Float64(y)))
        end
    end
    for p in report.critical_points.points
        add(p.x, p.value)
    end
    if study !== nothing
        if study.roots.status in (:established, :heuristic) && study.roots.value isa AbstractVector
            for x in study.roots.value
                add(x, 0)
            end
        end
        for result in (study.extrema, study.inflections)
            result.status == :established || continue
            for p in result.value
                add(p.x, p.value)
            end
        end
    end
    unique!(points)
    return first.(points), last.(points)
end

_real_plot_asymptotes!(axis, ::Nothing, a, b) = nothing
function _real_plot_asymptotes!(axis, study::RealFunctionStudy, a, b)
    if study.asymptotes.status == :established
        data = study.asymptotes.value
        vertical = Float64[x for x in data.vertical if a <= x <= b]
        isempty(vertical) || Makie.vlines!(axis, vertical; color=:red, linestyle=:dash)
        horizontal = unique(Float64[p.value for p in data.horizontal if p.value isa Real && isfinite(p.value)])
        isempty(horizontal) || Makie.hlines!(axis, horizontal; color=:steelblue, linestyle=:dash)
        # Render each distinct line once even when established at both infinities.
        lines = unique([(p.slope, p.intercept) for p in data.slant
            if p.slope isa Real && p.intercept isa Real])
        for (m, c) in lines
            Makie.lines!(axis, [a,b], Float64[m*a+c,m*b+c]; color=:steelblue, linestyle=:dash)
        end
    end
    if study.continuity.status == :established && study.limits.status == :established
        for p in study.continuity.value.discontinuities
            p.classification == :removable && a <= p.x <= b || continue
            k = findfirst(l -> l.at == p.x && l.side == :both && l.kind == :finite, study.limits.value)
            k === nothing && continue
            y = study.limits.value[k].value
            y isa Real && isfinite(y) || continue
            Makie.scatter!(axis, [Float64(p.x)], [Float64(y)]; color=:white,
                           strokecolor=:red, strokewidth=2, markersize=12)
        end
    end
    nothing
end
