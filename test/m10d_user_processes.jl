# Test-internal process isolation. Each script has its own explicit imports.
module M10DUserProcessTests
using Test
const workflows=("load","student","physicist","research","dataset","atomistic")
@testset "Fresh-process public stranger workflows" begin
    project=dirname(Base.active_project())
    for name in workflows
        script=joinpath(@__DIR__,"stranger",name*".jl")
        mktempdir() do cwd
            # Keep normal Julia package lookup; no LOAD_PATH injection. The active
            # Pkg.test sandbox supplies every explicitly declared direct import.
            command=Cmd(`$(Base.julia_cmd()) --startup-file=no --project=$project $script`;dir=cwd)
            command=addenv(command,"DISPLAY"=>nothing,"WAYLAND_DISPLAY"=>nothing)
            mktemp() do path,io
                process=run(pipeline(ignorestatus(command),stdout=io,stderr=io))
                flush(io); output=read(path,String)
                println("FRESH_PROCESS ",name," exit=",process.exitcode)
                print(output); flush(stdout)
                @test success(process)
                @test occursin("STRANGER_PASS "*name,output)
            end
        end
    end
end
end
