using Test, Lux, NeuralOperators, Optimization, OptimizationOptimisers, ComponentArrays, Zygote, ADTypes, Random
using AnalyticMathLab
using AnalyticMathLab: ForwardDiff
using Pkg
for (_,d) in Pkg.dependencies()
    d.name in ("Lux","NeuralOperators","SciMLBase","OrdinaryDiffEqTsit5","Optimization","ADTypes","Zygote","ComponentArrays","FFTW") && println(d.name," ",d.version)
end
@testset "Public operator backend probe" begin
    n=DeepONet(Lux.Dense(5=>3),Lux.Chain(Lux.Dense(2=>4,tanh),Lux.Dense(4=>3)))
    ps,st=Lux.setup(Xoshiro(19),n); ps=ComponentArray{Float64}(ps); st=Lux.testmode(st)
    b=rand(Xoshiro(20),5,4); q=rand(Xoshiro(21),2,6)
    y=first(Lux.apply(n,(b,q),ps,st))
    @test size(y)==(6,4)
    g=only(Zygote.gradient(p->sum(abs2,first(Lux.apply(n,(b,q),p,st))),ps))
    @test all(isfinite,g)
    @test all(isfinite,ForwardDiff.hessian(x->only(first(Lux.apply(n,(b[:,1:1],reshape(x,2,1)),ps,st))),q[:,1]))
    f=Optimization.OptimizationFunction((p,_)->sum(abs2,first(Lux.apply(n,(b,q),p,st))),ADTypes.AutoZygote())
    sol=Optimization.solve(Optimization.OptimizationProblem(f,ps),OptimizationOptimisers.Adam(0.01);maxiters=3)
    @test isfinite(sol.objective)
    # Probe only: fixed-grid Fourier model, no trained heat benchmark or public AML FNO API.
    fno=FourierNeuralOperator(tanh;chs=(1,4,4,4,1),modes=(3,))
    fp,fs=Lux.setup(Xoshiro(22),fno)
    out=first(Lux.apply(fno,rand(Xoshiro(23),Float32,16,1,2),fp,fs))
    @test size(out)==(16,1,2)
    @test all(isfinite,out)
end
