"""An autonomous ODE x′ = F(x), retaining one reusable square field report."""
struct AutonomousSystem{F<:VectorFieldAnalysis}
    field::F
    function AutonomousSystem(field::F) where {F<:VectorFieldAnalysis}
        field.input_dimension == field.output_dimension ||
            throw(DimensionMismatch("an autonomous system requires a square vector field"))
        new{F}(field)
    end
end
AutonomousSystem(F, variables; kwargs...) = AutonomousSystem(analyze(F, variables; kwargs...))

"""Structural evidence only; no trajectory or global stability claim."""
struct DynamicalSystemAnalysis{S,F,V,D,E<:PropertyResult,N<:PropertyResult} <: AbstractAnalysis
    system::S
    field::F
    variables::V
    dimension::Int
    domain::D
    equilibria::E
    nullclines::N
end

struct Equilibrium{P,V,L}
    point::P
    value::V
    residual_norm::Float64
    residual_threshold::Float64
    status::Symbol
    method::Symbol
    domain_valid::Union{Bool,Nothing}
    local_analysis::L
end

function analyze(system::AutonomousSystem; classification_atol::Real=1e-10, classification_rtol::Real=1e-8)
    atol, rtol = Float64(classification_atol), Float64(classification_rtol)
    all(t -> isfinite(t) && t >= 0, (atol,rtol)) ||
        throw(ArgumentError("classification tolerances must be finite and nonnegative"))
    f = system.field
    evidence = f.field_zeros
    records = [Equilibrium(copy(z.point), copy(z.value), z.residual_norm, z.residual_threshold,
        evidence.status, evidence.method, domain_contains(f.domain,z.point),
        _ds_local(f,z,evidence.status,atol,rtol)) for z in evidence.value]
    eq = PropertyResult(records,evidence.status,evidence.method,copy(evidence.notes))
    nc = f.input_dimension == 2 ? PropertyResult(
        [(component=i, equation=f.components[i] ~ 0, domain=f.domain) for i in 1:2],
        :established,:implicit_component_equations,
        ["Implicit equations restricted to the original domain; no curve solving or regularity claim."]) :
        _vf_unknown("Implicit nullclines are supported only in two dimensions.")
    return DynamicalSystemAnalysis(system,f,f.variables,f.input_dimension,f.domain,eq,nc)
end

"""Return copied equilibrium evidence, including residual and local diagnostics."""
equilibria(r::DynamicalSystemAnalysis) = deepcopy(r.equilibria)
"""Return copied implicit nullcline evidence."""
nullclines(r::DynamicalSystemAnalysis) = deepcopy(r.nullclines)
"""Return copied local analyses, in equilibrium order."""
stability(r::DynamicalSystemAnalysis) = deepcopy([e.local_analysis for e in r.equilibria.value])
evaluate(r::DynamicalSystemAnalysis, p::Union{Tuple,AbstractVector}) = evaluate(r.field,p)
jacobian(r::DynamicalSystemAnalysis) = jacobian(r.field)
jacobian(r::DynamicalSystemAnalysis, p::Union{Tuple,AbstractVector}) = jacobian(r.field,p)
linearization(r::DynamicalSystemAnalysis, p::Union{Tuple,AbstractVector}) = linearization(r.field,p)
