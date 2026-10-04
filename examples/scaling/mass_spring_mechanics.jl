# Fixed-end mass-spring chain: AML symbolic -> M/K -> modes -> dynamics.
# Small symbolic tiers deliberately stop before expensive exact adjugate solves.
# Larger tiers use the known structured chain and SciML, not generic symbolic HVP.
using AnalyticMathLab, Symbolics, LinearAlgebra, SciMLBase, OrdinaryDiffEqTsit5
if !isdefined(@__MODULE__,:ControlledModes)
    include("partial_modes.jl")
end
using .ScaleHarness
function mass_spring_mechanics_main(;budget=budget_from_env())
    rows=NamedTuple[]
    for n in (3,5)
        estimate=4096big(n)^4
        if estimate>budget.max_memory
            measure!(rows,budget,"Lagrangian_construction",n,estimate,()->error("must refuse"))
            report("mass_spring_mechanics",rows,budget)
            continue
        end
        q=[Symbolics.variable(Symbol("q",i)) for i in 1:n]
        v=[Symbolics.variable(Symbol("v",i)) for i in 1:n]
        L=sum(v.^2)/2-sum(q.^2)+sum(q[1:end-1].*q[2:end])
        holder=Ref{Any}()
        measure!(rows,budget,"Lagrangian_construction",n,estimate,
            ()->(holder[]=LagrangianSystem(L;coordinates=Tuple(q),velocities=Tuple(v)));
            output_count=r->length(string(r.expression)),algorithm="AML original symbolic Lagrangian")
        lag=holder[]
        measure!(rows,budget,"Euler_Lagrange_analysis",n,estimate,()->(holder[]=analyze(lag));
            check=r->begin @assert r.accelerations.status==:established; 0. end,
            output_count=r->length(string(r.equations)),algorithm="AML exact derivatives and adjugate solve")
        analysis=holder[]
        K=SymTridiagonal(fill(2.,n),fill(-1.,n-1))
        measure!(rows,budget,"mechanical_linearization",n,estimate,()->(holder[]=linearize_mechanics(analysis,zeros(n)));
            check=r->begin @assert r.evidence.status==:established; @assert r.stiffness_matrix≈K; @assert r.mass_matrix≈Matrix{Float64}(I,n,n); 0. end,
            output_count=r->length(r.stiffness_matrix),algorithm="AML EL derivatives M C K")
        linear=holder[]
        measure!(rows,budget,"symbolic_to_full_modes",n,24dense_bytes(n,n),()->normal_modes(linear);
            check=r->begin err=maximum(abs.(r.eigenvalues-[4sin(j*pi/(2(n+1)))^2 for j in 1:n])); @assert err<1e-10; err end,
            output_count=r->length(r.eigenvalues),algorithm="AML full normal_modes after established linearization")
        d=dynamics(analysis); a=[sin(i*pi/(n+1)) for i in 1:n]; w=2sin(pi/(2(n+1)))
        measure!(rows,budget,"AML_symbolic_dynamics",n,estimate,
            ()->trajectory(d,[a;zeros(n)],(0.,2.);abstol=1e-10,reltol=1e-10);
            check=r->begin @assert r.diagnostics.success && r.diagnostics.completed; err=norm(r.solution(2.)-[a*cos(2w);-w*a*sin(2w)]); @assert err<1e-7; err end,
            output_count=r->length(r.solution.u),algorithm="AML bridge; native Tsit5; analytic single-mode trajectory oracle")
        report("mass_spring_mechanics",rows,budget)
    end
    for n in (budget.level==0 ? (150,600) : (600,3000))
        estimate=1024big(n)
        # Preflight before state allocation; bounded example sizes, not auto extreme.
        if estimate>budget.max_memory
            measure!(rows,budget,"structured_chain_dynamics",n,estimate,()->error("must refuse"))
            report("mass_spring_mechanics",rows,budget)
            continue
        end
        A=ControlledModes.ChainAction(n,0.); j=max(1,n÷3)
        a=[sin(i*j*pi/(n+1)) for i in 1:n]; w=2sin(j*pi/(2(n+1)))
        function rhs!(du,u,p,t)
            copyto!(view(du,1:n),view(u,n+1:2n))
            mul!(view(du,n+1:2n),A,view(u,1:n)); view(du,n+1:2n).*= -1
            nothing
        end
        problem=SciMLBase.ODEProblem(rhs!,[a;zeros(n)],(0.,2.))
        measure!(rows,budget,"structured_chain_dynamics",n,estimate,
            ()->SciMLBase.solve(problem,Tsit5();abstol=1e-9,reltol=1e-9,saveat=0.:.5:2.,save_everystep=false,dense=false);
            check=r->begin
                @assert SciMLBase.successful_retcode(r)
                err=norm(r.u[end]-[a*cos(2w);-w*a*sin(2w)])/norm(a)
                @assert err<1e-7 && length(r.u)==5
                energy(u)=begin
                    y=similar(a); mul!(y,A,view(u,1:n))
                    (dot(view(u,n+1:2n),view(u,n+1:2n))+dot(view(u,1:n),y))/2
                end
                @assert abs(energy(r.u[end])/energy(r.u[1])-1)<1e-7
                err
            end,output_count=r->length(r.u)*2n,algorithm="SciML in-place matrix-free quadratic Hessian action; five saved states")
        measure!(rows,budget,"structured_chain_partial_modes",n,8big(n)*142+32000,
            ()->ControlledModes.partial_chain(n;max_memory_bytes=budget.max_memory);
            check=r->begin err=maximum(abs.(r.eigenvalues-[4sin(j*pi/(2(n+1)))^2 for j in 1:4])); @assert err<1e-8; err end,
            output_count=r->length(r.eigenvalues),algorithm="ArnoldiMethod controlled structured chain")
        report("mass_spring_mechanics",rows,budget)
    end
    rows
end
abspath(PROGRAM_FILE)==(@__FILE__) && mass_spring_mechanics_main()
