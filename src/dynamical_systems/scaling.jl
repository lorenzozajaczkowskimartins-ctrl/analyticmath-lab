# Internal Float64, native SciML boundary for controlled large-state experiments.
# The legacy FirstOrderODE/trajectory contract (including its 32-state limit) is
# intentionally untouched. This is not a public symbolic/mechanics bridge.
struct _ScaleODERHS{F,D}
    f!::F
    domain::D
    dimension::Int
end
function (rhs::_ScaleODERHS)(du,u,p,t)
    length(u) == length(du) == rhs.dimension || throw(DimensionMismatch("ODE state dimension changed"))
    all(isfinite,u) && isfinite(t) || throw(DomainError(t,"ODE state/time must be finite"))
    rhs.domain(u,t) === true || throw(DomainError(t,"ODE domain membership false or unresolved"))
    # Detect unwritten components as well as explicit nonfinite derivatives.
    fill!(du,NaN)
    rhs.f!(du,u,p,t)
    all(isfinite,du) || throw(DomainError(t,"ODE derivative must be fully written and finite"))
    return nothing
end

"""
    _scale_ode_problem(f!, u0, tspan; p=nothing, domain=(u,t)->true)

Internal native in-place Float64 ODEProblem. Owns one copy of the initial state;
validates the initial derivative and checks state, domain and derivative at every
stage without allocating a new derivative vector. The caller fills all of `du`.
Storage policy, tolerances, stepping, and ensembles remain native SciML options.
Checks cannot certify the domain between evaluated stages, nor detect underflow
already performed inside the caller's Float64 RHS. No dimension cap or solver.
"""
function _scale_ode_problem(f!,u0::AbstractVector,tspan; p=nothing,domain=(u,t)->true)
    isempty(u0) && throw(ArgumentError("state must not be empty"))
    all(x->x isa Real && isfinite(x),u0) || throw(DomainError(u0,"state must be finite and real"))
    state = Float64.(u0)
    all(isfinite,state) && all(i->iszero(u0[i]) || !iszero(state[i]),eachindex(state)) ||
        throw(DomainError(u0,"state not representable in Float64"))
    length(tspan) == 2 || throw(ArgumentError("two time endpoints required"))
    all(x->x isa Real && isfinite(x),tspan) || throw(ArgumentError("finite real times required"))
    times = (Float64(tspan[1]),Float64(tspan[2]))
    all(isfinite,times) && times[1] != times[2] || throw(ArgumentError("distinct finite Float64 times required"))
    rhs = _ScaleODERHS(f!,domain,length(state))
    rhs(similar(state),state,p,first(times))
    return SciMLBase.ODEProblem{true}(rhs,state,times,p)
end
