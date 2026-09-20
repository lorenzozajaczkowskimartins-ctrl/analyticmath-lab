using Test
using AnalyticMathLab
using Unitful

@testset "RDF mixtures, units, streaming and unsupported data" begin
    snap(p;kw...) = AnalyticMathLab.AtomisticSnapshot(p;kw...)
    rdf=AnalyticMathLab.radial_distribution
    b=(kind=:orthorhombic,lengths=[10.,10.,10.])
    s=snap([[0.,0.,0.],[1.,0.,0.],[3.,0.,0.]];boundary=b,species=[:A,:A,:B])
    r=rdf(s;edges=[0.,2.,5.],species=(:A,:B))
    @test r.counts == [0,2]
    @test r.expected_counts ≈ 2 .* (4π/3) .* [8,117] ./ 1000
    @test rdf(s;edges=[0.,2.,5.],species=(:A,:A)).counts == [1,0]
    @test rdf(s;edges=[0.,5.1]).rdf.status == :unknown
    @test rdf(s;edges=[0.,5.],species=(:Z,:Z)).rdf.status == :unknown
    @test rdf(snap(s.positions;boundary=b);edges=[0.,5.],species=(:A,:B)).rdf.status == :unknown
    for boundary in ((kind=:open,),(kind=:triclinic,),(kind=:unsupported,))
        @test rdf(snap(s.positions;boundary);edges=[0.,5.]).rdf.status == :unknown
    end
    @test rdf(snap(Vector{Float64}[];dimension=3,boundary=b);edges=[0.,5.]).rdf.status == :unknown
    @test_throws ArgumentError rdf(s;edges=[0.,0.,1.])
    @test_throws ArgumentError rdf(s;edges=[0.,NaN])
    su=snap([[0.,0.],[1.,0.]].*u"nm";boundary=(kind=:orthorhombic,lengths=[10.,10.].*u"nm"))
    ru=rdf(su;edges=[0.,10.,20.].*u"Å")
    @test ru.counts == [0,1]
    @test ru.expected_counts ≈ π .* [1,3] ./ 100
    @test ru.units.radius == "Å"
    @test AnalyticMathLab.coordination(su;cutoff=10u"Å").value.counts == [1,1]
    calls=Int[]
    t=AnalyticMathLab.AtomisticTrajectoryView(3,i->begin
        push!(calls,i)
        snap(s.positions[1:i];boundary=b)
    end)
    rt=rdf(t;edges=[0.,5.],frames=[1,3])
    @test rt.rdf.status == :heuristic # singleton frame adds zero expected pairs
    @test calls == [1,3]
    @test rt.frame_count == 2
    @test rt.pair_populations == [0,3]
    @test rt.counts == [3]
    @test rt.expected_counts ≈ [3*(4π/3)*125/1000]
    @test rdf(t;edges=[0.,5.],frames=Int[]).rdf.status == :unknown
    @test_throws ArgumentError rdf(t;edges=[0.,5.],frames=[4])
    nd=Ref(0)
    sc=snap([[0.,0.],[9.,0.],[5.,0.]];boundary=(kind=:orthorhombic,lengths=[10.,10.]),
        distance=(a,b)->begin nd[]+=1; 1. end)
    @test rdf(sc;edges=[0.,2.]).counts == [3]
    @test nd[] == 3
    @test rdf(snap([[0.,0.],[9.,0.]];boundary=sc.boundary);edges=[0.,2.]).counts == [1]
    mixed=AtomisticTrajectoryView(2,i->i==1 ? s : sc)
    @test rdf(mixed;edges=[0.,2.]).rdf.status == :unknown
    # Independent normalization checks for same species and changing volume.
    aa=rdf(s;edges=[0.,2.,5.],species=(:A,:A))
    @test aa.expected_counts ≈ (4π/3).*[8,117]./1000
    doubled=snap(s.positions;boundary=(kind=:orthorhombic,lengths=[20.,20.,20.]))
    varying=AtomisticTrajectoryView(2,i->i==1 ? s : doubled)
    pooled=rdf(varying;edges=[0.,5.])
    @test pooled.expected_counts ≈ [3*(4π/3)*125*(1/1000+1/8000)]
    @test pooled.counts==[6]
    @test_throws Unitful.DimensionError rdf(su;edges=[0.,2.].*u"ps")
end
const RDFLab = AnalyticMathLab

@testset "Snapshot coordination" begin
    @test isdefined(RDFLab,:coordination)
    if isdefined(RDFLab,:coordination)
        s=RDFLab.AtomisticSnapshot([[0.,0.],[1.,0.],[3.,0.]];
            species=[:A,:A,:B],boundary=(kind=:orthorhombic,lengths=[10.,10.]))
        c=RDFLab.coordination(s;cutoff=2.)
        @test c.value.counts == [1,2,1]
        @test c.value.mean ≈ 4/3
        @test c.status == :heuristic
        @test RDFLab.coordination(s;cutoff=2.,species=(:A,:B)).value.counts == [0,1]
        @test RDFLab.coordination(s;cutoff=2.,species=(:A,:A)).value.counts == [1,1]
        @test RDFLab.coordination(s;cutoff=2.,species=(:C,:A)).status == :unknown
        @test RDFLab.coordination(s;cutoff=-1.).status == :unknown
    end
end

@testset "RDF finite-N shells and boundaries" begin
    @test isdefined(RDFLab, :radial_distribution)
    if isdefined(RDFLab, :radial_distribution)
        s = RDFLab.AtomisticSnapshot([[0.,0.],[1.,0.],[3.,0.]];
            boundary=(kind=:orthorhombic,lengths=[10.,10.]))
        r = RDFLab.radial_distribution(s;edges=[0.,1.,2.,3.])
        @test r isa RDFLab.RadialDistributionAnalysis
        @test r.rdf.status == :heuristic
        @test r.counts == [0,1,2] # left closed, final edge inclusive
        @test r.expected_counts ≈ 3π .* [1.,3.,5.] ./ 100
        @test r.rdf.value ≈ r.counts ./ r.expected_counts
        @test r.centers == [0.5,1.5,2.5]
        @test r.frame_count == 1
        @test r.pair_populations == [3]
    end
end
