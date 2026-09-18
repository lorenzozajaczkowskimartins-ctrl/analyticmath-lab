# Formal mechanics identities hold on the smooth locus of preserved source domains.
_mc_simp(x) = Symbolics.simplify(Symbolics.simplify_fractions(x); expand=true)
_mc_zero(x) = iszero(_mc_simp(x))
_mc_diff(x, v) = _mc_simp(Symbolics.expand_derivatives(Symbolics.Differential(v)(x)))
_mc_expr(x::RealExpression) = x.expression
_mc_expr(x) = x
_mc_original(x::RealExpression) = x.original
_mc_original(x) = x
_mc_proven(x, method=:exact_symbolic_identity) = PropertyResult(x,:established,method,["Formal identity on the smooth original locus, subject to explicit assumptions."])
_mc_unknown(note) = PropertyResult(nothing,:unknown,:unsupported,[note])
_mc_identity(x) = _mc_zero(x) ? _mc_proven(true) : _mc_unknown("No exact zero identity established.")
function _mc_variables(xs)
    xs isa Union{Tuple,AbstractVector} && !isempty(xs) || throw(ArgumentError("an ordered nonempty tuple/vector is required"))
    vs = tuple(xs...)
    for v in vs
        v isa Symbolics.Num && _mv_ast(v) isa Symbol || throw(ArgumentError("independent variables must be scalar symbolic names"))
    end
    length(unique(vs)) == length(vs) || throw(ArgumentError("variables must be distinct"))
    vs
end
function _mc_inputs(q, v, t, parameters, nonzero)
    q, v = _mc_variables(q), _mc_variables(v)
    length(q) == length(v) || throw(DimensionMismatch("coordinate and conjugate dimensions differ"))
    _mc_variables((q...,v..., (t === nothing ? () : (t,))...))
    bindings = Dict{Any,Any}(parameters)
    for (k,val) in bindings
        _mc_variables((k,))
        any(x->isequal(k,x),(q...,v...,t)) && throw(ArgumentError("state/time variables cannot be parameter bindings"))
        val isa Real && !(val isa Symbolics.Num) && isfinite(val) || throw(ArgumentError("parameter bindings must be finite real constants"))
    end
    nz = tuple(nonzero...)
    for a in nz
        _mc_zero(Symbolics.substitute(_mc_expr(a),bindings)) && throw(ArgumentError("nonzero assumption contradicts bindings"))
    end
    q,v,bindings,nz
end
function _mc_domain(originals, vars)
    domains = [_mv_domain(o,vars) for o in originals]
    restrictions = tuple((r for d in domains for r in d.restrictions)...)
    status = all(d->d.status == :established,domains) ? :established : isempty(restrictions) ? :unknown : :partial
    MultivariateDomain(restrictions,vars,status,:original_syntax_constraints,[n for d in domains for n in d.notes])
end
function _mc_allvars(expressions, states)
    vars = Any[states...]
    for e in expressions, v in Symbolics.get_variables(_mc_expr(e))
        nv = Symbolics.Num(v)
        any(x->isequal(nv,x),vars) || push!(vars,nv)
    end
    tuple(vars...)
end
function _mc_sourcevars!(vars,ast)
    ast = _mv_ast(ast)
    if ast isa Symbol
        v = Symbolics.variable(ast)
        any(x->isequal(v,x),vars) || push!(vars,v)
    elseif ast isa Expr && ast.head == :call
        for a in ast.args[2:end]
            _mc_sourcevars!(vars,a)
        end
    end
    vars
end
function _mc_source_domain(originals,vars,bindings,nonzero)
    sources = Any[originals...]
    append!(sources,[Expr(:call,:/,1,_mv_ast(_mc_original(a))) for a in nonzero])
    names = Any[vars...]
    for original in sources
        _mc_sourcevars!(names,original)
    end
    for key in keys(bindings)
        any(x->isequal(key,x),names) || push!(names,key)
    end
    _mc_domain(sources,tuple(names...))
end
struct LagrangianSystem
    expression
    original_expression
    coordinates::Tuple
    velocities::Tuple
    time
    rayleigh
    forces::Vector
    original_rayleigh
    original_forces::Vector
    parameters::Dict
    nonzero::Tuple
    domain::MultivariateDomain
end
function LagrangianSystem(L;coordinates,velocities,time=nothing,rayleigh=0,forces=nothing,parameters=Dict(),nonzero=())
    q,v,b,nz = _mc_inputs(coordinates,velocities,time,parameters,nonzero)
    fs = forces === nothing ? fill(0,length(q)) : collect(forces)
    length(fs) == length(q) || throw(DimensionMismatch("one generalized force per coordinate is required"))
    originals = [_mc_original(L),_mc_original(rayleigh),_mc_original.(fs)...]
    vars = _mc_allvars([L,rayleigh,fs...],(q...,v...,(time === nothing ? () : (time,))...))

    LagrangianSystem(Symbolics.substitute(_mc_expr(L),b),originals[1],q,v,time,
        Symbolics.substitute(_mc_expr(rayleigh),b),[Symbolics.substitute(_mc_expr(f),b) for f in fs],
        originals[2],_mc_original.(fs),b,nz,_mc_source_domain(originals,vars,b,nz))
end
struct LagrangianAnalysis <: AbstractAnalysis
    system::LagrangianSystem
    expression
    original_expression
    domain::MultivariateDomain
    coordinates::Tuple
    velocities::Tuple
    time
    parameters::Dict
    nonzero::Tuple
    rayleigh
    forces::Vector
    momenta::Vector
    hessian::Matrix
    acceleration_symbols::Tuple
    equations::Vector
    regularity::PropertyResult
    accelerations::PropertyResult
    energy
    energy_rate
    energy_conservation::PropertyResult
    cyclic::Vector
    evidence::NamedTuple
end
# Nonzero certificates deliberately do not assume positivity of masses or parameters.
function _mc_nonzero(x, assumptions)
    x = _mc_simp(x)
    _mc_zero(x) && return false
    any(a -> _mc_zero(x-a) || _mc_zero(x+a),assumptions) && return true
    ast = _mv_ast(x)
    ast isa Real && return isfinite(ast) && !iszero(ast)
    ast isa Expr && ast.head == :call || return nothing
    op = _mv_op(ast)
    raw = Symbolics.unwrap(x)
    args = Symbolics.arguments(raw)
    if op in (:*, :/)
        all(a->_mc_nonzero(Symbolics.Num(a),assumptions) === true,args) && return true
    elseif op == :^ && length(args)==2 && _mv_ast(Symbolics.Num(args[2])) isa Integer
        _mc_nonzero(Symbolics.Num(args[1]),assumptions) === true && return true
    end
    nothing
end
# Fraction-free elimination computes a polynomial determinant, with exact row swaps.
function _mc_det(A)
    n = size(A,1)
    n == 0 && return 1
    B = Any[A[i,j] for i in 1:n,j in 1:n]
    sign, previous = 1, 1
    for k in 1:n-1
        pivot = findfirst(i -> !_mc_zero(B[i,k]),k:n)
        pivot === nothing && return 0
        row = k+pivot-1
        if row != k
            B[k,:],B[row,:] = copy(B[row,:]),copy(B[k,:])
            sign = -sign
        end
        for i in k+1:n,j in k+1:n
            B[i,j] = _mc_simp((B[k,k]*B[i,j]-B[i,k]*B[k,j])/previous)
        end
        previous = B[k,k]
        for i in k+1:n
            B[i,k] = 0
        end
    end
    _mc_simp(sign*B[n,n])
end
# Adjugate inversion avoids introducing pivot exclusions beyond det(A) != 0.
function _mc_solve(A,b,detA)
    n = length(b)
    x = [_mc_simp(sum((-1)^(i+j)*_mc_det(A[setdiff(1:n,[j]),setdiff(1:n,[i])])*b[j] for j in 1:n)/detA) for i in 1:n]
    all(_mc_zero(sum(A[i,j]*x[j] for j in 1:n)-b[i]) for i in 1:n) ? _mc_proven(x,:verified_linear_solve) : _mc_unknown("Linear solve residual did not simplify to zero.")
end
function analyze(s::LagrangianSystem)
    q,v,L = s.coordinates,s.velocities,s.expression
    n = length(q)
    p = [_mc_diff(L,vi) for vi in v]
    W = [_mc_diff(p[i],v[j]) for i in 1:n,j in 1:n]
    a = tuple((Symbolics.variable(gensym(:acceleration)) for _ in 1:n)...)
    drift = [_mc_simp((s.time === nothing ? 0 : _mc_diff(p[i],s.time))+sum(_mc_diff(p[i],q[j])*v[j] for j in 1:n)-_mc_diff(L,q[i])+_mc_diff(s.rayleigh,v[i])-s.forces[i]) for i in 1:n]
    eq = [_mc_simp(sum(W[i,j]*a[j] for j in 1:n)+drift[i]) for i in 1:n]
    determinant = _mc_det(W)
    nz = [Symbolics.substitute(_mc_expr(x),s.parameters) for x in s.nonzero]
    regular = _mc_nonzero(determinant,nz)
    reg = regular === nothing ? _mc_unknown("Velocity Hessian determinant is not proven nonzero; provide explicit nonzero assumptions.") : _mc_proven(regular,:exact_determinant)
    acc = regular === true ? _mc_solve(W,-drift,determinant) : _mc_unknown(regular === false ? "Singular velocity Hessian; no unconstrained dynamics or Legendre inversion." : "Regularity is unproven.")
    E = _mc_simp(sum(v[i]*p[i] for i in 1:n)-L)
    rate = _mc_simp(sum(v[i]*(s.forces[i]-_mc_diff(s.rayleigh,v[i])) for i in 1:n)-(s.time === nothing ? 0 : _mc_diff(L,s.time)))
    cyclic = [(coordinate=q[i],momentum=p[i],conservation=_mc_identity(s.forces[i]-_mc_diff(s.rayleigh,v[i]))) for i in 1:n if _mc_zero(_mc_diff(L,q[i]))]
    conservation = _mc_identity(rate)
    LagrangianAnalysis(s,L,s.original_expression,s.domain,q,v,s.time,s.parameters,s.nonzero,s.rayleigh,s.forces,p,W,a,eq,reg,acc,E,rate,conservation,cyclic,(regularity=reg,energy_conservation=conservation))
end
generalized_momenta(r::LagrangianAnalysis) = r.momenta
velocity_hessian(r::LagrangianAnalysis) = r.hessian
euler_lagrange(r::LagrangianAnalysis) = r.equations
energy_function(r::LagrangianAnalysis) = r.energy
cyclic_coordinates(r::LagrangianAnalysis) = r.cyclic
for f in (:generalized_momenta,:velocity_hessian,:euler_lagrange,:energy_function,:cyclic_coordinates)
    @eval $f(s::LagrangianSystem) = $f(analyze(s))
end
