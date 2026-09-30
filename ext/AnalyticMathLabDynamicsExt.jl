module AnalyticMathLabDynamicsExt
using AnalyticMathLab, Lux, Optimization
using AnalyticMathLab: ForwardDiff, SciMLBase, OrdinaryDiffEqTsit5
const AML = AnalyticMathLab

function network_output(m,u,n)
    y, nextstate = Lux.apply(m.network,u,m.parameters,m.state)
    isequal(nextstate,m.state) || throw(ArgumentError("stateful training networks are unsupported; use Lux.testmode"))
    y isa AbstractVector && length(y)==n || throw(DimensionMismatch("network output must have $n components"))
    all(isfinite,y) || throw(DomainError(y,"nonfinite network output"))
    y
end
function AML.learned_energy(m::AML.HamiltonianNN,u)
    length(u)==length(m.mechanics.phase_variables) || throw(DimensionMismatch("canonical state dimension mismatch"))
    only(network_output(m,u,1))
end
AML.aligned_energy(m::AML.HamiltonianNN,u;reference) = AML.learned_energy(m,u)-AML.learned_energy(m,reference)
function AML.learned_vector_field(m::AML.HamiltonianNN,u,t=0.)
    m.mechanics.symplectic_matrix * ForwardDiff.gradient(x->AML.learned_energy(m,x),u)
end
function AML.dynamics_objective(m::AML.HamiltonianNN,data::AML.DerivativeData)
    sum(sum(abs2,AML.learned_vector_field(m,data.states[:,i])-data.derivatives[:,i]) for i in axes(data.states,2))/length(data.states)
end
function AML.learned_correction(m::AML.UDEProblem,u,t=0.)
    length(u)==m.known.dimension || throw(DimensionMismatch("state dimension mismatch"))
    y=network_output(m,u,length(m.correction_indices))
    [let j=findfirst(==(i),m.correction_indices); j===nothing ? zero(eltype(y)) : y[j] end for i in 1:m.known.dimension]
end
function AML.learned_vector_field(m::AML.UDEProblem,u,t=0.)
    m.known.domain(u,t) === true || throw(DomainError(u,"outside known ODE domain"))
    known=m.known.function_value(u,t)
    length(known)==m.known.dimension || throw(DimensionMismatch("known RHS dimension mismatch"))
    all(isfinite,known) || throw(DomainError(known,"nonfinite known RHS"))
    collect(known) + AML.learned_correction(m,u,t)
end
function AML.dynamics_objective(m::AML.UDEProblem,data::AML.TrajectoryData;
        algorithm=OrdinaryDiffEqTsit5.Tsit5(),abstol=1e-9,reltol=1e-7,maxiters=10000)
    size(data.states,1)==m.known.dimension || throw(DimensionMismatch("trajectory dimension mismatch"))
    # Promote the initial condition to the parameter AD type, without Float64
    # conversion in the M6 presentation boundary. SciML owns differentiation.
    z=zero(first(AML.learned_correction(m,data.states[:,1],first(data.times))))
    initial=data.states[:,1] .+ z
    prob=SciMLBase.ODEProblem{false}((u,p,t)->AML.learned_vector_field(m,u,t),initial,(first(data.times),last(data.times)))
    sol=SciMLBase.solve(prob,algorithm;saveat=data.times,save_start=true,save_end=true,save_everystep=false,
        abstol,reltol,maxiters)
    SciMLBase.successful_retcode(sol) && last(sol.t)==last(data.times) || throw(ErrorException("training trajectory did not complete: $(sol.retcode)"))
    sum(abs2,Array(sol)-data.states)/length(data.states)
end
replace_parameters(m::AML.HamiltonianNN,p)=AML.HamiltonianNN(m.mechanics,m.network,p,m.state)
replace_parameters(m::AML.UDEProblem,p)=AML.UDEProblem(m.known,m.network,p,m.state;correction_indices=m.correction_indices)
function AML.train(m::Union{AML.HamiltonianNN,AML.UDEProblem},data;
        initial_parameters::AbstractVector,reconstruct,optimizer,maxiters::Integer=100,
        history_limit::Integer=100,objective_options=NamedTuple())
    1<=maxiters<=10000 || throw(ArgumentError("maxiters must be between 1 and 10000"))
    1<=history_limit<=10000 || throw(ArgumentError("history_limit must be between 1 and 10000"))
    !isempty(initial_parameters) && all(isfinite,initial_parameters) || throw(ArgumentError("finite nonempty parameters required"))
    loss=(v,_)->AML.dynamics_objective(replace_parameters(m,reconstruct(v)),data;objective_options...)
    history=Float64[]
    callback=(state,l)->begin
        length(history)==history_limit && popfirst!(history)
        push!(history,Float64(l)); false
    end
    initial_loss=loss(initial_parameters,nothing)
    fun=Optimization.OptimizationFunction(loss,Optimization.AutoForwardDiff())
    problem=Optimization.OptimizationProblem(fun,copy(initial_parameters))
    solution=Optimization.solve(problem,optimizer;maxiters,callback)
    fitted=replace_parameters(m,reconstruct(solution.u))
    solver=m isa AML.UDEProblem ? merge((algorithm=OrdinaryDiffEqTsit5.Tsit5(),abstol=1e-9,reltol=1e-7,maxiters=10000),objective_options) : nothing
    provenance=(training_kind=m isa AML.HamiltonianNN ? :derivatives : :trajectory,
        training_data=data,initial_parameters=copy(initial_parameters),
        initial_loss=Float64(initial_loss),final_loss=Float64(loss(solution.u,nothing)),
        maxiters=maxiters,history_limit=history_limit,optimizer=typeof(optimizer),
        differentiation=:ForwardDiff,objective_options=objective_options,solver=solver,
        global_correctness=:unknown,reference_used_in_objective=false,
        evidence=AML.PropertyResult(nothing,:unknown,:global_physics_not_established,
            ["Optimizer termination and data fit do not establish correct governing physics."]),
        limitations=["Local training evidence does not establish global identifiability or extrapolation accuracy.",
            m isa AML.HamiltonianNN ? "H and H + C generate the same canonical dynamics; absolute energy is unidentifiable." :
                "A learned correction is not symbolic discovery; trajectory fit does not establish governing-law correctness."])
    AML.DynamicsTrainingResult(fitted,solution,history,provenance)
end
function AML.predict(m::Union{AML.HamiltonianNN,AML.UDEProblem},u0,tspan;kwargs...)
    n=m isa AML.HamiltonianNN ? length(m.mechanics.phase_variables) : m.known.dimension
    labels=m isa AML.HamiltonianNN ? string.(m.mechanics.phase_variables) : m.known.labels
    ode=AML.FirstOrderODE((u,t)->AML.learned_vector_field(m,u,t),n;labels)
    AML.trajectory(ode,u0,tspan;kwargs...)
end
AML.predict(r::AML.DynamicsTrainingResult,u0,tspan;kwargs...)=AML.predict(r.model,u0,tspan;kwargs...)
end
