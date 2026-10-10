module M10DUserInputTests
using Test, AnalyticMathLab, Unitful

function refusal(f, kind, fragments)
    err=try f(); nothing catch e; e end
    @test err isa kind
    message=sprint(showerror,err)
    for fragment in fragments
        @test occursin(fragment,message)
    end
end

@testset "User dataset schema mistakes" begin
    sample=ScientificSample(:run,[1.],reshape([0.,1.],1,:),[1.,2.];split=:training)
    options=(kind=:surrogate,family=:line,input_names=(:a,),coordinate_names=(:t,),
        domain=(inputs=[0. 2.],coordinates=[0. 1.]),reference=(kind=:analytical,),
        units=(inputs=("dimensionless",),coordinates=("dimensionless",),output="dimensionless"),
        grid=:explicit,rng=:deterministic)
    @test ScientificDataset([sample];options...).samples[1].values==[1.,2.]
    refusal(()->ScientificDataset([sample];merge(options,(reference=NamedTuple(),))...),
        ArgumentError,("reference","kind"))
    refusal(()->ScientificDataset([sample];merge(options,(domain=(inputs=[0. 2.],),))...),
        ArgumentError,("domain","coordinates"))
    refusal(()->ScientificDataset([sample];merge(options,(domain=(coordinates=[0. 1.],),))...),
        ArgumentError,("domain","inputs"))
end
@testset "User observable mistakes and conservative units" begin
    refusal(()->ObservableSeries([1.,2.,3.];times=[0.,1.]),DimensionMismatch,
        ("3", "2", "time coordinate"))
    refusal(()->ObservableSeries([1.,2.];name="energy"),ArgumentError,("name", "Symbol"))
    refusal(()->statistical_summary(ObservableSeries(Any[1.,2u"m"])),ArgumentError,
        ("units", "unknown"))
    refusal(()->running_statistics(ObservableSeries(Any[1u"m",2u"s"])),ArgumentError,
        ("dimensions",))
    refusal(()->ObservableSeries([1.,2.];times=Any[0.,1u"s"]),ArgumentError,
        ("times", "units"))
    @test statistical_summary(ObservableSeries(Any[1u"m",200u"cm"])).value.mean ≈ 1.5u"m"
    @test statistical_summary(ObservableSeries([missing,1.])).status==:unknown
    @test statistical_summary(ObservableSeries([1+im])).status==:unknown
end
@testset "User missing optional backend guidance" begin
    refusal(()->pinn_network(1,1),ArgumentError,
        ("Lux", "NeuralPDE", "ModelingToolkit", "Optimization", "SymbolicIndexingInterface"))
    # An opaque model container is sufficient to request the absent operation;
    # no scientific validity or backend construction is claimed by this fixture.
    model=HamiltonianNN(nothing,nothing,nothing,nothing)
    refusal(()->learned_energy(model,[0.,0.]),ArgumentError,("Lux", "Optimization"))
    refusal(()->learned_vector_field(model,[0.,0.]),ArgumentError,("Lux", "Optimization"))
end
end
