"""Render stored total objective history only; no training or new loss evaluation."""
function lossplot(h::PINNHistory)
    isempty(h.entries) && throw(ArgumentError("no recorded training history to plot"))
    fig=Makie.Figure(size=(900,500))
    ax=Makie.Axis(fig[1,1];xlabel="Backend iteration",ylabel="Training objective",
        title="PINN training history — not solution error")
    Makie.lines!(ax,[e.iteration for e in h.entries],[e.objective for e in h.entries])
    Makie.Label(fig[2,1],h.truncated ?
        "History capacity reached; later records omitted. Low loss is not physical validation." :
        "Low training loss is not proof of a correct physical solution.")
    fig
end
function lossplot(r::PINNTrainingResult)
    r.history===nothing && throw(ArgumentError("training history was not requested"))
    lossplot(r.history)
end
