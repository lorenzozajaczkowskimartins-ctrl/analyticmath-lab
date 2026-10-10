module M10DUserPackagingTests
using Test, TOML
const root=normpath(joinpath(@__DIR__,".."))
@testset "User examples declare backend imports" begin
    for folder in ("operators","inference","pinn")
        project=TOML.parsefile(joinpath(root,"examples",folder,"Project.toml"))
        @test haskey(project["deps"],"ForwardDiff")
        folder=="inference" && @test haskey(project["deps"],"Symbolics")
        for (dir,_,files) in walkdir(joinpath(root,"examples",folder)), file in files
            endswith(file,".jl") || continue
            code=read(joinpath(dir,file),String)
            @test !occursin(r"(?:using|import) AnalyticMathLab:\s*(?:ForwardDiff|Symbolics)",code)
            @test !occursin(r"AnalyticMathLab\.(?:ForwardDiff|Symbolics)",code)
        end
    end
end
@testset "Runtime paths and public example layout" begin
    for folder in ("src","ext"), (dir,_,files) in walkdir(joinpath(root,folder)), file in files
        endswith(file,".jl") || continue
        code=read(joinpath(dir,file),String)
        @test !occursin(r"/home/lorenzo|C:\\Users\\loren",code)
    end
    for file in ("one_system_many_methods.jl","one_system_learning.jl","one_system_plots.jl")
        code=read(joinpath(root,"examples","integration",file),String)
        @test !occursin(r"include\(.*(?:src/|test/)",code)
        @test !occursin(r"(?:AML|AnalyticMathLab)\._",code)
    end
end
end
