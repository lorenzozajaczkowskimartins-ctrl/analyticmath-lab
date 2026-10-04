# Bounded symbolic/AD ladder. All derivative entries are constructed explicitly.
# Symbolics phase timings isolate AML's backend; AML scalar analysis is measured
# separately at <=20 coordinates (its contract caps independent variables at 32).
using AnalyticMathLab, Symbolics, ForwardDiff, LinearAlgebra
if !isdefined(@__MODULE__,:ScaleHarness)
    include("harness.jl")
end
using .ScaleHarness

function symbolic_mechanics_main(;budget=budget_from_env())
    rows=NamedTuple[]
    sizes=budget.level==0 ? (5,10,20) : (5,10,20,50,100)
    for n in sizes
        # Bounded polynomial family, not an estimate for arbitrary expression DAGs.
        estimate=4096big(2n)^2
        estimate>budget.max_memory && begin
            measure!(rows,budget,"symbolic_construction",n,estimate,()->error("preflight"))
            report("symbolic_mechanics_scaling",rows,budget); continue
        end
        q=[Symbolics.variable(Symbol("q",i)) for i in 1:n]
        v=[Symbolics.variable(Symbol("v",i)) for i in 1:n]
        K=SymTridiagonal(fill(2.,n),fill(-1.,n-1)); x=collect(range(-.2,.2;length=n))
        energy(z)=sum(z.^2)+sum(z.^4)/4-sum(z[1:end-1].*z[2:end])
        Eref=Ref{Any}(); Href=Ref{Any}(); Jref=Ref{Any}()
        savephase(name,f,ref;check=x->0.,count=x->length(string(x)))=measure!(rows,budget,name,n,estimate,
            ()->(ref[]=f());check=check,output_count=count,algorithm="Symbolics dense explicit; output_count=printed expression chars")
        savephase("symbolic_construction",()->energy(q),Eref;
            check=e->begin y=Float64(Symbolics.value(Symbolics.substitute(e,Dict(q.=>x);fold=Val(true)))); @assert y≈energy(x); abs(y-energy(x)) end)
        savephase("hessian_differentiation",()->Symbolics.hessian(Eref[],q;simplify=false),Href)
        H=K+Diagonal(3x.^2); Hraw=Href[]
        savephase("hessian_simplification",()->Symbolics.simplify.(Hraw),Href;
            check=h->begin y=Float64.(Symbolics.value.(Symbolics.substitute.(h,Ref(Dict(q.=>x));fold=Val(true)))); @assert y≈H; norm(y-H) end)
        # First-order mechanical field (v, -Kq-q³), Jacobian has explicit zero blocks.
        field=[v; -2q+vcat(0,q[1:end-1])+vcat(q[2:end],0)-q.^3]
        state=[q;v]; point=[x;zeros(n)]
        oracle=[zeros(n,n) Matrix{Float64}(I,n,n); -Matrix(H) zeros(n,n)]
        savephase("jacobian_differentiation",()->Symbolics.jacobian(field,state;simplify=false),Jref)
        Jraw=Jref[]
        savephase("jacobian_simplification",()->Symbolics.simplify.(Jraw),Jref)
        for (label,expression,variables,p,expected) in (("hessian",Href[],q,x,Matrix(H)),("jacobian",Jref[],state,point,oracle))
            callable=Ref{Any}()
            measure!(rows,budget,label*"_function_generation",n,estimate,
                ()->(callable[]=first(Symbolics.build_function(expression,variables;expression=Val(false))));
                algorithm="Symbolics runtime-generated callable; excludes first invocation")
            measure!(rows,budget,label*"_callable_evaluation",n,estimate,()->callable[](p);
                check=y->begin @assert y≈expected; norm(y-expected) end,output_count=length,
                algorithm="warmup_seconds=first-call compilation+execution; elapsed_seconds=warmed evaluation")
        end
        measure!(rows,budget,"AD_hessian",n,estimate,()->ForwardDiff.hessian(energy,x);
            check=y->begin @assert y≈H; norm(y-H) end,output_count=length,algorithm="ForwardDiff dense Hessian")
        rhs=z->[z[n+1:2n];-K*z[1:n]-z[1:n].^3]
        measure!(rows,budget,"AD_jacobian",n,estimate,()->ForwardDiff.jacobian(rhs,point);
            check=y->begin @assert y≈oracle; norm(y-oracle) end,output_count=length,algorithm="ForwardDiff dense Jacobian")
        if n<=20
            measure!(rows,budget,"AML_scalar_analysis",n,estimate,()->analyze(Eref[],Tuple(q));
                check=r->begin y=AnalyticMathLab.hessian(r,x); @assert y≈H; norm(y-H) end,
                output_count=r->length(AnalyticMathLab.hessian(r)),algorithm="AML combined symbolic analysis; phase separation above is backend-only")
        end
        report("symbolic_mechanics_scaling",rows,budget)
    end
    rows
end
abspath(PROGRAM_FILE)==(@__FILE__) && symbolic_mechanics_main()
