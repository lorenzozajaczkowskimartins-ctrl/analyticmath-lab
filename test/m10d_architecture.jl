module M10DArchitectureTests
using Test, AnalyticMathLab
import TOML

@testset "M10D classified export ownership" begin
    root = dirname(@__DIR__)
    document = read(joinpath(root, "docs", "m10d_architecture_inventory.md"), String)
    rows = filter(line -> occursin(r"^\| F\d{2} ", line), split(document, '\n'))
    classifications = ("PUBLIC_STABLE", "PUBLIC_EXPERIMENTAL", "INTERNAL",
        "REDUNDANT", "RENAME_BEFORE_1_0", "REMOVE_BEFORE_1_0")
    @test length(rows) == 36
    owned = Symbol[]
    for row in rows
        columns = split(row, '|')
        classification = last(split(strip(columns[2])))
        @test classification in classifications
        classification == "INTERNAL" && continue
        append!(owned, Symbol.(strip.(split(columns[3], ','))))
    end
    @test length(owned) == length(unique(owned))
    @test Set(owned) == setdiff(Set(names(AnalyticMathLab)), Set([:AnalyticMathLab]))
    @test all(isdefined(AnalyticMathLab, name) for name in owned)
    @test all(!startswith(string(name), "_") for name in owned)
    @test length(methods(analyze)) == 11
    @test all(method.module === AnalyticMathLab for method in methods(analyze))
    project = TOML.parsefile(joinpath(root, "Project.toml"))
    @test length(project["extensions"]) == 5
    for (name, triggers) in project["extensions"]
        deps = triggers isa String ? [triggers] : triggers
        @test all(haskey(project["weakdeps"], dep) for dep in deps)
        @test Base.get_extension(AnalyticMathLab, Symbol(name)) === nothing
    end
end

@testset "M10D examples use package registration" begin
    root = dirname(@__DIR__)
    violations = String[]
    for directory in ("examples", "notebooks")
        for (dir, _, files) in walkdir(joinpath(root, directory)), file in files
            endswith(file, ".jl") || continue
            path = joinpath(dir, file)
            text = read(path, String)
            if occursin(r"Base\.include\s*\(", text) ||
                    occursin(r"include\([^\n]*[\"/]src[/\"]", text)
                push!(violations, relpath(path, root))
            end
        end
    end
    @test isempty(violations)
    @test isdefined(AnalyticMathLab, :_scale_ode_problem)
    @test :_scale_ode_problem ∉ names(AnalyticMathLab)
end

@testset "M10D ordinary notebook uses public validation" begin
    notebook = joinpath(@__DIR__, "..", "notebooks", "mechanics_addendum.jl")
    @test !occursin("AnalyticMathLab._mc_zero", read(notebook, String))
end
end
