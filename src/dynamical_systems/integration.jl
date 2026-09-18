"""
    FirstOrderODE(f, dimension; domain=(u,t)->true, labels=...)

Numerical out-of-place first-order system `f(u,t)` returning a real vector.
State is always a vector, including scalar ODEs. Parameters may be captured in
`f`. The domain predicate is a caller contract and must return true to evaluate.
This object makes no autonomous equilibrium or smoothness claims.
"""
struct FirstOrderODE{F,D,L}
    function_value::F
    dimension::Int
    domain::D
    labels::L
    function FirstOrderODE(f, dimension::Integer; domain=(u,t)->true,
            labels=ntuple(i -> "u$i", max(0,min(dimension,32))))
        1 <= dimension <= 32 || throw(ArgumentError("between 1 and 32 states are supported"))
        length(labels) == dimension || throw(DimensionMismatch("one label is required per state"))
        names = tuple(string.(labels)...)
        new{typeof(f),typeof(domain),typeof(names)}(f,Int(dimension),domain,names)
    end
end

"""Numerical trajectory retaining its native SciML solution, problem and diagnostics."""
struct TrajectoryResult{S,P,L,D}
    solution::S
    problem::P
    labels::L
    diagnostics::D
end

# Retain field identity so phase views cannot attach unrelated solutions.
struct _AutonomousRHS{F}
    field::F
end
(rhs::_AutonomousRHS)(u,t) = evaluate(rhs.field,u)
function trajectory(report::DynamicalSystemAnalysis,u0,tspan;kwargs...)
    f = report.field
    problem = FirstOrderODE(_AutonomousRHS(f),report.dimension;
        domain=(u,t)->domain_contains(f.domain,u),labels=string.(report.variables))
    return trajectory(problem,u0,tspan;kwargs...)
end

function _ode_rhs(problem::FirstOrderODE, u, t)
    length(u) == problem.dimension || throw(DimensionMismatch("state dimension does not match the ODE"))
    all(x -> x isa Real && isfinite(x),u) && isfinite(t) ||
        throw(DomainError((u,t),"ODE state and time must be finite and real"))
    problem.domain(u,t) === true ||
        throw(DomainError((u,t),"ODE evaluation outside the known domain, or membership unresolved; integration stopped"))
    value = problem.function_value(u,t)
    value isa Union{Tuple,AbstractVector} && length(value) == problem.dimension ||
        throw(DimensionMismatch("ODE right-hand side must return one component per state"))
    all(x -> x isa Real && isfinite(x),value) ||
        throw(DomainError((u,t),"ODE right-hand side is not finite and real; integration stopped"))
    # The integrator uses Float64 states/times. Mixed constant and symbolic
    # components can produce Vector{Real}; normalize at this shared boundary.
    converted = Float64[value...]
    all(isfinite,converted) || throw(DomainError(value,"ODE right-hand side is not representable in Float64"))
    return converted
end

"""
    trajectory(problem, u0, tspan; algorithm=Tsit5(), abstol=1e-9, reltol=1e-7,
               saveat=nothing, dt=nothing, maxiters=100000)

Integrate with SciML, retaining its solution without copying solution arrays.
`saveat` forces steps on a direction-aware interval grid, retaining all adaptive
steps for native dense interpolation; output is not exclusively uniform. Its
Float64 grid must have distinct finite times and span at most 1,000,000 intervals.
Positive tolerances control the numerical solver, not rigorous solution error.
Known-invalid or unresolved RHS evaluation raises DomainError, including trial
stages: this is fail-fast, not a domain-boundary location algorithm. A finite
set of stages cannot certify the domain along the continuous interpolant.
"""
function trajectory(problem::FirstOrderODE, u0, tspan;
        algorithm=OrdinaryDiffEqTsit5.Tsit5(), abstol::Real=1e-9,reltol::Real=1e-7,
        saveat=nothing,dt=nothing,maxiters::Integer=100_000)
    initial = u0 isa Real ? [u0] : collect(u0)
    length(initial) == problem.dimension || throw(DimensionMismatch("initial state dimension does not match the ODE"))
    all(x -> x isa Real && isfinite(x),initial) || throw(DomainError(u0,"initial state must be finite and real"))
    length(tspan) == 2 || throw(ArgumentError("tspan must contain two endpoints"))
    times = tuple(Float64.(tspan)...)
    all(isfinite,times) && times[1] != times[2] || throw(ArgumentError("time endpoints must be distinct and finite"))
    a,r = Float64(abstol),Float64(reltol)
    all(x -> isfinite(x) && x > 0,(a,r)) || throw(ArgumentError("solver tolerances must be finite and positive"))
    maxiters > 0 || throw(ArgumentError("maxiters must be positive"))
    state = Float64.(initial)
    all(isfinite,state) || throw(DomainError(u0,"initial state must be representable in Float64"))
    _ode_rhs(problem,state,times[1])
    options = (abstol=a,reltol=r,maxiters=maxiters,dense=true,save_everystep=true,
        save_start=true,save_end=true)
    if saveat !== nothing
        saveat isa Real && isfinite(saveat) && saveat > 0 ||
            throw(ArgumentError("saveat must be a positive finite interval"))
        interval = Float64(saveat)
        isfinite(interval) && interval > 0 ||
            throw(ArgumentError("saveat must be finite and positive in Float64"))
        # Bound the backend's stop queue before constructing a potentially huge
        # range. This budget is independent of maxiters: early solver termination
        # must still return the native partial solution and its diagnostics.
        intervals = abs(times[2]-times[1])/interval
        isfinite(intervals) && intervals <= 1_000_000 ||
            throw(ArgumentError("saveat requires a finite time span and at most 1000000 intervals"))
        direction = times[2] > times[1] ? 1 : -1
        stops = times[1]:direction*interval:times[2]
        previous = times[1]
        for time in Iterators.drop(stops,1)
            isfinite(time) && direction*(time-previous) > 0 ||
                throw(ArgumentError("saveat grid points must be distinct and finite in Float64"))
            previous = time
        end
        # Saving interpolated saveat values corrupts the native dense history in
        # OrdinaryDiffEq. Force accepted steps at the grid instead, retaining
        # every adaptive step and its matching interpolation coefficients.
        options = merge(options,(tstops=stops,))
    end
    if dt !== nothing
        dt isa Real && isfinite(dt) && dt > 0 || throw(ArgumentError("dt must be a positive finite initial step magnitude"))
        options = merge(options,(dt=sign(times[2]-times[1])*Float64(dt),))
    end
    native = SciMLBase.ODEProblem{false}((u,p,t) -> _ode_rhs(problem,u,t),state,times)
    solution = SciMLBase.solve(native,algorithm;options...)
    diagnostics = (success=SciMLBase.successful_retcode(solution),
        completed=last(solution.t)==times[2],retcode=solution.retcode,
        algorithm=typeof(algorithm),abstol=a,reltol=r,final_time=last(solution.t),
        accepted_steps=solution.stats.naccept,rejected_steps=solution.stats.nreject,
        notes=("Numerical trajectory; tolerances are not rigorous error bounds.",))
    return TrajectoryResult(solution,problem,problem.labels,diagnostics)
end

function Base.show(io::IO, result::TrajectoryResult)
    print(io,"TrajectoryResult(dimension=",result.problem.dimension,", final_time=",
        result.diagnostics.final_time,", retcode=",result.diagnostics.retcode,")")
end
function Base.show(io::IO, ::MIME"text/plain", result::TrajectoryResult)
    show(io,result)
    print(io,"\n  Algorithm: ",result.diagnostics.algorithm,"\n  Accepted/rejected steps: ",
        result.diagnostics.accepted_steps," / ",result.diagnostics.rejected_steps,
        "\n  abstol=",result.diagnostics.abstol,", reltol=",result.diagnostics.reltol,
        " (not rigorous error bounds)")
end
