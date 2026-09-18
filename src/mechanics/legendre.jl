# Substitute syntax without simplifying away original exclusions. Never eval ASTs.
function _mc_substitute_ast(ast, bindings)
    ast = _mv_ast(ast)
    ast isa Symbol && return get(bindings,ast,ast)
    ast isa Expr || return ast
    ast.head == :call || return deepcopy(ast)
    Expr(:call,ast.args[1],(_mc_substitute_ast(a,bindings) for a in ast.args[2:end])...)
end

"""
    legendre_transform(lagrangian; momenta=nothing)

Verified affine momentum inversion only, with proven Hessian regularity and no
nonzero generalized/Rayleigh force. Unknown is not a constrained Hamiltonian.
Original source syntax is pulled back through the inverse velocity map.
"""
function legendre_transform(r::LagrangianAnalysis;momenta=nothing)
    r.regularity.value === true || return _mc_unknown("Legendre inversion requires proven regularity.")
    all(_mc_zero,r.forces) && all(v->_mc_zero(_mc_diff(r.rayleigh,v)),r.velocities) ||
        return _mc_unknown("Ordinary Hamiltonian conversion does not represent dissipative or forced dynamics.")
    all(_mc_zero(_mc_diff(w,v)) for w in r.hessian,v in r.velocities) ||
        return _mc_unknown("Only affine momentum-velocity maps are supported.")
    ps = momenta === nothing ? tuple((Symbolics.variable(gensym(:momentum)) for _ in r.coordinates)...) : _mc_variables(momenta)
    length(ps) == length(r.coordinates) || throw(DimensionMismatch("one momentum per coordinate is required"))
    _mc_variables((r.coordinates...,ps...,(r.time === nothing ? () : (r.time,))...))
    any(p->any(x->isequal(p,x),r.domain.variables),ps) &&
        throw(ArgumentError("new momenta must be distinct from existing variables and parameters"))
    b = [_mc_simp(r.momenta[i]-sum(r.hessian[i,j]*r.velocities[j] for j in eachindex(ps))) for i in eachindex(ps)]
    inverse = _mc_solve(r.hessian,collect(ps)-b,_mc_det(r.hessian))
    inverse.status == :established || return inverse
    substitutions = Dict(r.velocities .=> inverse.value)
    all(_mc_zero(Symbolics.substitute(r.momenta[i],substitutions)-ps[i]) for i in eachindex(ps)) ||
        return _mc_unknown("Momentum substitution did not verify.")
    H = _mc_simp(sum(ps[i]*inverse.value[i] for i in eachindex(ps))-Symbolics.substitute(r.expression,substitutions))
    _mc_zero(H-Symbolics.substitute(r.energy,substitutions)) || return _mc_unknown("Energy substitution did not verify.")
    syntax = Dict(Symbol(_mv_ast(k))=>_mv_ast(v) for (k,v) in substitutions)
    Lsource = _mc_substitute_ast(r.original_expression,syntax)
    original = Expr(:call,:-,Expr(:call,:+, (Expr(:call,:*,_mv_ast(ps[i]),_mv_ast(inverse.value[i])) for i in eachindex(ps))...),Lsource)
    # These terms vanish algebraically, but preserve the auxiliary input domains.
    for o in [r.system.original_rayleigh,r.system.original_forces...]
        original = Expr(:call,:+,original,Expr(:call,:*,0,_mc_substitute_ast(o,syntax)))
    end
    # Keep the symbolic certificate and pull back its captured source separately.
    nz = tuple((RealExpression(Symbolics.substitute(_mc_expr(a),substitutions),
        _mc_substitute_ast(_mc_original(a),syntax)) for a in r.nonzero)...)
    h = HamiltonianSystem(RealExpression(H,original);coordinates=r.coordinates,momenta=ps,
        time=r.time,parameters=r.parameters,nonzero=nz)
    _mc_proven(analyze(h),:verified_affine_legendre)
end
legendre_transform(s::LagrangianSystem;kwargs...) = legendre_transform(analyze(s);kwargs...)
