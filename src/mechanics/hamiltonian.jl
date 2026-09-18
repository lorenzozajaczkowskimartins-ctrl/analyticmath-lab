"""Canonical Hamiltonian with ordered independent coordinates and momenta."""
struct HamiltonianSystem
    expression
    original_expression
    coordinates::Tuple
    momenta::Tuple
    time
    parameters::Dict
    nonzero::Tuple
    domain::MultivariateDomain
end
function HamiltonianSystem(H;coordinates,momenta,time=nothing,parameters=Dict(),nonzero=())
    q,p,b,nz = _mc_inputs(coordinates,momenta,time,parameters,nonzero)
    vars = _mc_allvars([H],(q...,p...,(time === nothing ? () : (time,))...))

    original = _mc_original(H)
    HamiltonianSystem(Symbolics.substitute(_mc_expr(H),b),original,q,p,time,b,nz,
        _mc_source_domain([original],vars,b,nz))
end

"""Formal canonical equations on the smooth original locus; not an integrator."""
struct HamiltonianAnalysis <: AbstractAnalysis
    system::HamiltonianSystem
    expression
    original_expression
    domain::MultivariateDomain
    coordinates::Tuple
    momenta::Tuple
    phase_variables::Tuple
    time
    parameters::Dict
    nonzero::Tuple
    phase_field::Vector
    equations::Vector
    symplectic_matrix::Matrix
    energy
    energy_conservation::PropertyResult
    evidence::NamedTuple
end
function analyze(s::HamiltonianSystem)
    q,p,H = s.coordinates,s.momenta,s.expression
    n = length(q)
    field = [_mc_diff.(Ref(H),p)...,(-_mc_diff(H,qi) for qi in q)...]
    J = [i <= n && j == i+n ? 1 : i > n && j == i-n ? -1 : 0 for i in 1:2n,j in 1:2n]
    conservation = _mc_identity(s.time === nothing ? 0 : _mc_diff(H,s.time))
    HamiltonianAnalysis(s,H,s.original_expression,s.domain,q,p,(q...,p...),s.time,
        s.parameters,s.nonzero,field,copy(field),J,H,conservation,(energy_conservation=conservation,))
end
hamilton_equations(r::HamiltonianAnalysis) = copy(r.phase_field)
energy_function(r::HamiltonianAnalysis) = r.energy
hamilton_equations(s::HamiltonianSystem) = hamilton_equations(analyze(s))
energy_function(s::HamiltonianSystem) = energy_function(analyze(s))

"""Formal canonical bracket {A,B}; source restrictions of observables are not certified."""
function poisson_bracket(r::HamiltonianAnalysis,A,B)
    A,B = Symbolics.substitute(_mc_expr(A),r.parameters),Symbolics.substitute(_mc_expr(B),r.parameters)
    _mc_simp(sum(_mc_diff(A,q)*_mc_diff(B,p)-_mc_diff(A,p)*_mc_diff(B,q)
        for (q,p) in zip(r.coordinates,r.momenta)))
end
poisson_bracket(s::HamiltonianSystem,A,B) = poisson_bracket(analyze(s),A,B)
"""Formal total observable derivative partial_t(A) + {A,H}."""
function observable_derivative(r::HamiltonianAnalysis,A)
    A = Symbolics.substitute(_mc_expr(A),r.parameters)
    _mc_simp((r.time === nothing ? 0 : _mc_diff(A,r.time))+poisson_bracket(r,A,r.expression))
end
observable_derivative(s::HamiltonianSystem,A) = observable_derivative(analyze(s),A)
"""Negative stored scalar-field gradient; restricted to that report's smooth locus."""
force_from_potential(r::ScalarFieldAnalysis) = -gradient(r)
