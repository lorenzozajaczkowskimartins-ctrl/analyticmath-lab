"""
A mechanics-to-M6 conversion retaining the source report, M6 system and cached
analysis, canonical state ordering, energy callable, and original-domain checks.
No new integrator or equilibrium/Jacobian analyzer is introduced.
"""
struct MechanicsDynamics{R,S,A,V,F,D,T} <: AbstractAnalysis
    source::R
    system::S
    analysis::A
    variables::V
    energy_value::F
    domain::D
    time::T
end

struct _MechanicsRHS{F}
    functions::F
end
(rhs::_MechanicsRHS)(u,t) = [f(u...,t) for f in rhs.functions]

function _mechanics_bound_report(r,parameters)
    isempty(parameters) && return r
    any(haskey(r.parameters,k) && !isequal(r.parameters[k],v) for (k,v) in parameters) &&
        throw(ArgumentError("cannot override parameters already substituted in a report"))
    b = merge(r.parameters,Dict(parameters))
    expression = RealExpression(r.expression,r.original_expression)
    if r isa LagrangianAnalysis
        s = r.system
        return analyze(LagrangianSystem(expression;coordinates=r.coordinates,velocities=r.velocities,
            time=r.time,parameters=b,nonzero=r.nonzero,
            rayleigh=RealExpression(s.rayleigh,s.original_rayleigh),
            forces=[RealExpression(f,o) for (f,o) in zip(s.forces,s.original_forces)]))
    end
    analyze(HamiltonianSystem(expression;coordinates=r.coordinates,momenta=r.momenta,
        time=r.time,parameters=b,nonzero=r.nonzero))
end

"""
    dynamics(report; parameters=Dict(), kwargs...)

Bind remaining parameters explicitly and reuse M6 analysis/integration. State
order is (q...,v...) or (q...,p...). Explicit time selects FirstOrderODE.
Original L/H, Rayleigh, force and nonzero restrictions remain in the domain.
"""
function dynamics(source::Union{LagrangianAnalysis,HamiltonianAnalysis};parameters=Dict(),kwargs...)
    r = _mechanics_bound_report(source,parameters)
    if r isa LagrangianAnalysis
        r.accelerations.status == :established || throw(ArgumentError("dynamics requires proven regularity and verified accelerations"))
        vars = (r.coordinates...,r.velocities...)
        field = [r.velocities...,r.accelerations.value...]
        originals = [r.original_expression,r.system.original_rayleigh,r.system.original_forces...]
    else
        vars = r.phase_variables
        field = r.phase_field
        originals = [r.original_expression]
    end
    allvars = (vars...,(r.time === nothing ? () : (r.time,))...)
    allowed = Set(_mv_ast.(allvars))
    all(Set(_mv_ast.(Symbolics.get_variables(e))) ⊆ allowed for e in [field...,r.energy]) ||
        throw(ArgumentError("bind every remaining mechanics parameter explicitly"))
    bindings = Dict(Symbol(_mv_ast(k))=>v for (k,v) in r.parameters)
    syntax = [_mc_substitute_ast(o,bindings) for o in originals]
    append!(syntax,[Expr(:call,:/,1,_mc_substitute_ast(_mc_original(a),bindings)) for a in r.nonzero])
    # Addition is only a domain carrier; it is never evaluated or substituted as RHS.
    carrier = Expr(:call,:+,syntax...,_mv_ast.(field)...,_mv_ast(r.energy))
    all(v->_mv_ast(v) in allowed,_mc_sourcevars!(Any[],carrier)) ||
        throw(ArgumentError("bind parameters retained only in original source syntax or assumptions"))
    domain = _mv_domain(carrier,allvars)
    energy = Symbolics.build_function(r.energy,allvars...;expression=Val{false})
    if r.time === nothing
        f = analyze(field,vars;original_expression=fill(carrier,length(vars)),kwargs...)
        system = AutonomousSystem(f)
        return MechanicsDynamics(source,system,analyze(system),vars,energy,domain,nothing)
    end
    isempty(kwargs) || throw(ArgumentError("autonomous analysis options cannot be used for explicit-time dynamics"))
    functions = [Symbolics.build_function(e,allvars...;expression=Val{false}) for e in field]
    system = FirstOrderODE(_MechanicsRHS(functions),length(vars);
        domain=(u,t)->domain_contains(domain,(u...,t)),labels=string.(vars))
    MechanicsDynamics(source,system,nothing,vars,energy,domain,r.time)
end
dynamics(s::Union{LagrangianSystem,HamiltonianSystem};kwargs...) = dynamics(analyze(s);kwargs...)

"""Delegate a converted mechanics problem to the existing M6 trajectory API."""
function trajectory(conversion::MechanicsDynamics,u0,tspan;kwargs...)
    target = conversion.analysis === nothing ? conversion.system : conversion.analysis
    return trajectory(target,u0,tspan;kwargs...)
end

function _mechanics_path_matches(conversion,path)
    if conversion.system isa AutonomousSystem
        rhs = path.problem.function_value
        return rhs isa _AutonomousRHS && rhs.field === conversion.system.field
    end
    return path.problem === conversion.system
end

function _mechanics_energy(conversion,u,t)
    point = conversion.time === nothing ? u : (u...,t)
    domain_contains(conversion.domain,point) === true ||
        throw(DomainError(point,"energy evaluation requires known original-domain membership"))
    return _finite_real(conversion.energy_value(point...))
end

"""
    energy_drift(conversion::MechanicsDynamics, path::TrajectoryResult)

Return heuristic saved-time energy samples and signed discrepancies from the
initial sample. These are numerical diagnostics, not conservation certificates
or rigorous integration error bounds. The path must belong to this conversion.
"""
function energy_drift(conversion::MechanicsDynamics,path::TrajectoryResult)
    _mechanics_path_matches(conversion,path) ||
        throw(ArgumentError("trajectory must originate from this mechanics conversion"))
    times = copy(path.solution.t)
    values = [_mechanics_energy(conversion,u,t) for (u,t) in zip(path.solution.u,times)]
    drift = [_finite_real(value-first(values)) for value in values]
    return PropertyResult((times=times,values=values,drift=drift,
        maximum_absolute_drift=maximum(abs,drift)),:heuristic,:saved_energy_samples,
        ["Numerical discrepancies, not a conservation proof or a rigorous error bound."])
end

function Base.show(io::IO,conversion::MechanicsDynamics)
    print(io,"MechanicsDynamics(states=",length(conversion.variables),", ",
        conversion.analysis === nothing ? "nonautonomous" : "autonomous", ")")
end
