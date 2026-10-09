# Optional rendering gate, excluded from canonical; backend is chosen here by user.
module M10DFlagshipPlotTests
using Test, AnalyticMathLab, CairoMakie
const file=joinpath(@__DIR__,"..","examples","integration","one_system_plots.jl")
@testset "M10D4 optional flagship figures" begin
    @test isfile(file)
    if isfile(file)
        include(file)
        r=Base.invokelatest(OneSystemPlots.OneSystemManyMethods.investigate)
        CairoMakie.activate!()
        figures=OneSystemPlots.figures(r)
        @test keys(figures) == (:trajectory,:energy,:distance)
        # Do not magnify tiny integration drift into apparent order-one energy loss.
        energy_axis=OneSystemPlots.Makie.content(figures.energy[1,1])
        @test energy_axis.limits[][2] == (0.0,1.1*r.metrics.energy)
        output=ENV["AML_FLAGSHIP_PLOT_DIR"]
        mkpath(output)
        for (name,fig) in pairs(figures)
            path=joinpath(output,string(name)*".png")
            CairoMakie.save(path,fig)
            @test isfile(path) && filesize(path)>1000
            println("FIGURE ",path)
        end
    end
end
end
