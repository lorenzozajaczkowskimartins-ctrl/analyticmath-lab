using AnalyticMathLab, Documenter

root = realpath(joinpath(@__DIR__, ".."))
@assert realpath(dirname(dirname(pathof(AnalyticMathLab)))) == root
println("Julia: ", VERSION)
println("Project: ", Base.active_project())
println("AML source: ", pathof(AnalyticMathLab))
println("Documenter: ", pkgversion(Documenter))
for name in (:AnalyticMathLabMollyExt, :AnalyticMathLabPINNExt,
             :AnalyticMathLabInferenceExt, :AnalyticMathLabDynamicsExt,
             :AnalyticMathLabSurrogateExt)
    @assert Base.get_extension(AnalyticMathLab, name) === nothing
end
println("Optional AML extensions loaded: 0")

makedocs(
    root=@__DIR__, source="src", build="build",
    sitename="AnalyticMathLab.jl — Public API Reference",
    modules=[AnalyticMathLab],
    # Manual entries are checked independently against exports.json. This disables
    # only docstring-completeness checking, not warnings or reference resolution.
    checkdocs=:none, doctest=false, warnonly=false, remotes=nothing,
    # One consolidated 40-export experimental page exceeds the default 100 KiB
    # advisory threshold. Keep its original family ownership and enforce the
    # default 200 KiB hard limit independently below and in reference_check.py.
    # The complete 179-entry search index has a measured, finite 640 KiB budget.
    format=Documenter.HTML(prettyurls=false, edit_link=nothing, repolink=nothing,
        size_threshold_ignore=["reference/scientific-ml.md"],
        search_size_threshold_warn=640*1024),
    pages=[
        "Home" => "index.md",
        "Public reference" => [
            "Index and family ownership" => "reference/index.md",
            "Evidence atoms and capture" => "reference/core.md",
            "Scalar functions and domains" => "reference/scalar.md",
            "Derivatives and scalar fields" => "reference/derivatives.md",
            "Vector calculus" => "reference/vector.md",
            "Dynamics and trajectories" => "reference/dynamics.md",
            "Mechanics and modes" => "reference/mechanics.md",
            "Atomistic data" => "reference/atomistic.md",
            "Statistics and diagnostics" => "reference/statistics.md",
            "Transport" => "reference/transport.md",
            "Scientific comparisons" => "reference/comparison.md",
            "Experimental scientific computation" => "reference/scientific-ml.md",
            "Datasets and scaling" => "reference/datasets.md",
            "Scientific views" => "reference/plots.md",
            "Qualified evidence inspection" => "reference/evidence.md",
        ],
        "API boundaries" => "guides/api-boundaries.md",
    ],
)

build = joinpath(@__DIR__, "build")
@assert filesize(joinpath(build,"reference","scientific-ml.html")) <= 200*1024
@assert filesize(joinpath(build,"search_index.js")) <= 640*1024

# Documenter 1.19 emits deployment-time siteinfo.js and ../versions.js links
# even for makedocs-only builds. This standalone manual has no deployed versions.
# Supply explicit local configuration and keep both scripts inside build/.
write(joinpath(build,"siteinfo.js"), "var DOCUMENTER_VERSION_SELECTOR_DISABLED = true;\n")
write(joinpath(build,"versions.js"), "var DOC_VERSIONS = [];\n")
for (dir, _, files) in walkdir(build)
    for file in files
        endswith(file,".html") || continue
        path = joinpath(dir,file)
        relative = replace(relpath(joinpath(build,"versions.js"),dir), '\\'=>'/')
        html = read(path,String)
        write(path, replace(html, r"src=\"[^\"]*versions\.js\"" => "src=\"$relative\""))
    end
end

# Repository resources are raw, build-only copies, not second authoritative docs.
# Explicit HTML resource links are checked by reference_check.py after packaging.
for (dir, _, files) in walkdir(joinpath(@__DIR__, "src"))
    for file in files
        endswith(file, ".md") || continue
        for match in eachmatch(r"href=\"[^\"]*repository/([^\"#]+)\"", read(joinpath(dir,file),String))
            relative = match.captures[1]
            isabspath(relative) && error("Absolute resource path is forbidden")
            relative = normpath(relative)
            startswith(relative,"..") && error("Resource traversal is forbidden")
            origin = realpath(joinpath(root, relative))
            startswith(origin, root * "/") || error("Resource escapes checkout")
            isfile(origin) || error("Missing repository resource: $relative")
            target = normpath(joinpath(build, "repository", relative))
            startswith(target, joinpath(build,"repository") * "/") || error("Resource target escapes build")
            mkpath(dirname(target))
            cp(origin, target; force=true)
        end
    end
end
println("DOCUMENTER_BUILD_COMPLETE")
