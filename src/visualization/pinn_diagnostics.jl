# Stored results only. No backend activation, evaluation, resampling or training.
function _pinn_map!(slot,X,values,variables,title)
    d=size(X,1)
    d<=2 || throw(ArgumentError("plots require an explicit stored one/two-dimensional slice"))
    layout=Makie.GridLayout(slot)
    ax=Makie.Axis(layout[1,1];title,xlabel=d==0 ? "Sample" : string(variables[1]),
        ylabel=d==2 ? string(variables[2]) : "Value")
    if d<2
        Makie.scatter!(ax,d==0 ? collect(eachindex(values)) : vec(X[1,:]),values)
    else
        xs=sort(unique(X[1,:])); ys=sort(unique(X[2,:]))
        unique_points=length(Set(Tuple(c) for c in eachcol(X)))
        if length(xs)*length(ys)==length(values)==unique_points && length(xs)>1 && length(ys)>1
            z=fill(NaN,length(xs),length(ys))
            for k in eachindex(values)
                z[searchsortedfirst(xs,X[1,k]),searchsortedfirst(ys,X[2,k])]=values[k]
            end
            obj=Makie.heatmap!(ax,xs,ys,z)
        else
            obj=Makie.scatter!(ax,X[1,:],X[2,:];color=values,markersize=9)
        end
        Makie.Colorbar(layout[1,2],obj)
    end
    ax
end

function residualplot(a::PINNAnalysis;equation::Integer=1)
    r=a.residuals[equation]
    r.values===nothing && throw(ArgumentError("this residual was not evaluated"))
    fig=Makie.Figure(size=(900,650))
    _pinn_map!(fig[1,1],r.points.coordinates,r.values,r.variables,
        "Signed $(r.role) residual — equation $equation")
    Makie.Label(fig[2,1],"Small sampled residuals do not prove global PDE correctness.")
    fig
end
function errorplot(a::PINNAnalysis;variable::Integer=1)
    ref=a.reference.value
    ref===nothing && throw(ArgumentError("reference comparison unavailable"))
    fig=Makie.Figure(size=(900,650))
    _pinn_map!(fig[1,1],ref.points.coordinates,vec(ref.absolute_error[variable,:]),
        ref.variables,"Sampled absolute reference error — $(ref.dependent_variables[variable])")
    Makie.Label(fig[2,1],"Reference trust is caller-supplied; sampled error is not a global bound.")
    fig
end
function collocationplot(a::PINNAnalysis;equation::Integer=1)
    b=a.collocation_metadata.blocks[equation]
    size(b.coordinates,1)<=2 || throw(ArgumentError("select a one/two-dimensional block"))
    fig=Makie.Figure(size=(900,650))
    X=b.coordinates; d=size(X,1)
    ax=Makie.Axis(fig[1,1];xlabel=d==0 ? "Sample" : string(b.variables[1]),
        ylabel=d<2 ? "Collocation point" : string(b.variables[2]),title="Returned collocation snapshot — equation $equation")
    Makie.scatter!(ax,d==0 ? [1.] : vec(X[1,:]),d<2 ? zeros(size(X,2)) : vec(X[2,:]))
    Makie.Label(fig[2,1],"Snapshot only: resampling history and domain coverage are not established.")
    fig
end
function losscomponentsplot(a::PINNAnalysis)
    l=a.loss_diagnostics
    fig=Makie.Figure(size=(900,600))
    ax=Makie.Axis(fig[1,1];xlabel="Backend cost index (PDE / BC / additional)",
        ylabel="Unweighted training cost",title="Stored loss components — not physical error")
    Makie.barplot!(ax,collect(eachindex(l.components)),l.components)
    Makie.Label(fig[2,1],"BC/IC share backend costs. Adaptive weight evolution is not available.")
    fig
end

"""Stored reference, prediction, absolute error and signed residual; no evaluation."""
function pinnplot(a::PINNAnalysis;variable::Integer=1,equation::Integer=1)
    ref=a.reference.value
    ref===nothing && throw(ArgumentError("reference comparison unavailable"))
    r=a.residuals[equation]
    r.values===nothing && throw(ArgumentError("this residual was not evaluated"))
    fig=Makie.Figure(size=(1250,950))
    X=ref.points.coordinates; vars=ref.variables
    _pinn_map!(fig[1,1],X,vec(ref.reference[variable,:]),vars,"Supplied reference")
    _pinn_map!(fig[1,2],X,vec(ref.prediction[variable,:]),vars,"Stored PINN prediction")
    _pinn_map!(fig[2,1],X,vec(ref.absolute_error[variable,:]),vars,"Absolute reference error")
    _pinn_map!(fig[2,2],r.points.coordinates,r.values,r.variables,"Signed $(r.role) residual — equation $equation")
    Makie.Label(fig[3,1:2],"Reference trust is caller-supplied. Small sampled residuals do not prove global PDE correctness.")
    fig
end
