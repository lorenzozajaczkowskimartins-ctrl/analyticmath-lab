"""Controlled fixed-end chain, not a generic sparse generalized eigensolver.
Run: julia --project=examples/scaling examples/scaling/partial_modes.jl
The optional environment directly declares ArnoldiMethod 0.4; root deps unchanged.
"""
module ControlledModes
using LinearAlgebra, Random, ArnoldiMethod

# Analytic Hessian action for E(q)=sum((q[i+1]-q[i])²)/2 with fixed endpoints,
# plus offset*sum(q²)/2. No n×n Hessian storage, no symbolic HVP claim.
struct ChainAction <: AbstractMatrix{Float64}
    n::Int
    offset::Float64
end
Base.size(A::ChainAction)=(A.n,A.n)
Base.getindex(A::ChainAction,i::Int,j::Int)= i==j ? 2+A.offset : abs(i-j)==1 ? -1.0 : 0.0
function LinearAlgebra.mul!(y,A::ChainAction,x)
    length(x)==length(y)==A.n || throw(DimensionMismatch("chain action length"))
    Base.mightalias(x,y) && throw(ArgumentError("chain mul! needs distinct input/output"))
    for i in eachindex(y)
        y[i]=(2+A.offset)*x[i]-(i>1 ? x[i-1] : 0.0)-(i<A.n ? x[i+1] : 0.0)
    end
    y
end
struct InverseAction{F} <: AbstractMatrix{Float64}
    factor::F
    n::Int
end
Base.size(A::InverseAction)=(A.n,A.n)
LinearAlgebra.mul!(y,A::InverseAction,x)=ldiv!(y,A.factor,x)

"""Lowest k modes of a fixed-end unit-spring chain with diagonal positive masses.
A=M^(-1/2) K M^(-1/2); shift below its Gershgorin lower bound; maintained
ArnoldiMethod operates on a structured shift-inverse action. H itself is never
dense. O(n*maxdim + n*k + maxdim²) storage. Float64 heuristic, no completeness
or global degeneracy claim; this irreducible chain has simple eigenvalues.
Signed eigenvalues retained; threshold uses a full-operator norm bound (not the
largest returned eigenvalue), explicitly distinct from dense spectral threshold.
"""
function partial_chain(n::Integer;k::Integer=4,masses=nothing,offset::Real=0.,
        max_memory_bytes::Integer=512*1024^2,tol::Real=1e-11,restarts::Integer=100)
    1<=k<n || throw(ArgumentError("require 1 <= k < n"))
    isfinite(offset) && isfinite(tol) && tol>0 || throw(ArgumentError("finite offset and positive tolerance required"))
    max_memory_bytes>0 || throw(ArgumentError("positive memory budget required"))
    maxdim=min(n,max(20,3k)); mindim=min(n,max(10,k))
    estimate=big(8)*(4big(n)*maxdim+8big(n)*k+30big(n)+10big(maxdim)^2)
    estimate<=max_memory_bytes || throw(ArgumentError("partial chain n=$n k=$k estimates $estimate bytes; exceeds max_memory_bytes=$max_memory_bytes"))
    m=masses===nothing ? ones(n) : Float64.(masses)
    length(m)==n || throw(DimensionMismatch("mass count"))
    mass_threshold=n*eps(Float64)*maximum(m)
    all(x->isfinite(x) && x>mass_threshold,m) || throw(ArgumentError("finite positive numerically resolved diagonal masses required"))
    b=inv.(sqrt.(m)); d=(2+Float64(offset))./m; e=-b[1:end-1].*b[2:end]
    lower=Inf; scale=0.
    for i in 1:n
        radius=(i>1 ? abs(e[i-1]) : 0.)+(i<n ? abs(e[i]) : 0.)
        lower=min(lower,d[i]-radius); scale=max(scale,abs(d[i])+radius)
    end
    all(isfinite,(lower,scale)) || throw(ArgumentError("nonfinite weighted coefficients"))
    shift=lower-max(1.0/n^2,eps(Float64)*max(1.,abs(lower)))
    factor=lu(Tridiagonal(copy(e),d.-shift,copy(e)))
    inverse=InverseAction(factor,Int(n))
    schur,history=partialschur(inverse;nev=Int(k),which=:LM,tol=tol,
        mindim=Int(mindim),maxdim=Int(maxdim),restarts=Int(restarts),v1=randn(MersenneTwister(710),n))
    history.converged || error("ArnoldiMethod backend did not converge; no partial result certified")
    mu,U=partialeigen(schur)
    all(isreal,mu) && all(isreal,U) || error("unexpected complex spectrum for symmetric chain")
    lambda=shift .+ inv.(real.(mu)); order=sortperm(lambda)[1:k]
    lambda=lambda[order]; U=real.(U[:,order]); phi=b.*U
    threshold=1e-10+1e-8*scale
    classes=[abs(x)<=threshold ? :zero : x<0 ? :unstable : :oscillatory for x in lambda]
    frequencies=Union{Missing,Float64}[c==:unstable ? missing : c==:zero ? 0. : sqrt(x) for (x,c) in zip(lambda,classes)]
    (eigenvalues=lambda,mode_vectors=phi,frequencies=frequencies,classifications=classes,
        metadata=(converged=history.converged,spectrum=:partial,backend=:ArnoldiMethod,
            shift=shift,estimated_bytes=estimate,spectral_threshold=threshold,
            threshold_scale=:full_operator_infinity_norm_bound,degeneracy=:not_inferred,
            representation=:matrix_free_H_and_structured_shift_inverse))
end
end

if !isdefined(@__MODULE__,:ScaleHarness)
    include("harness.jl")
end
using .ScaleHarness, .ControlledModes, LinearAlgebra, AnalyticMathLab

function partial_modes_main(;budget=budget_from_env())
    rows=NamedTuple[]
    sizes=budget.level==0 ? (40,150,600,3000) : budget.level==1 ? (150,600,3000,15000,30000) : (600,3000,15000,30000,100000)
    for n in sizes
        estimate=8big(n)*(4*20+8*4+30)+8*10*20^2
        oracle=[4sin(j*pi/(2(n+1)))^2 for j in 1:4]
        check=r->begin
            @assert maximum(abs.(r.eigenvalues-oracle))<1e-8
            A=ControlledModes.ChainAction(n,0.); y=zeros(n); err=0.
            for j in 1:4
                x=view(r.mode_vectors,:,j); mul!(y,A,x)
                err=max(err,norm(y-r.eigenvalues[j]*x))
            end
            @assert err<1e-8
            @assert norm(r.mode_vectors'*r.mode_vectors-I)<1e-7
            err
        end
        measure!(rows,budget,"partial_modes",n,estimate,
            ()->ControlledModes.partial_chain(n;max_memory_bytes=budget.max_memory);
            check=check,output_count=r->length(r.eigenvalues),algorithm="ArnoldiMethod shift-inverse; matrix-free chain Hessian")
        report("partial_modes",rows,budget)
    end
    rows
end
abspath(PROGRAM_FILE)==(@__FILE__) && partial_modes_main()
