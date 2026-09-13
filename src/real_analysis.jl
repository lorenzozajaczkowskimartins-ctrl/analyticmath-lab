"""A mathematical value with explicit evidence (`:established` or `:unknown`)."""
struct PropertyResult{T}
    value::T
    status::Symbol
    method::Symbol
    notes::Vector{String}
end
_ra_proven(x) = PropertyResult(x, :established, :exact_algebra, String[])
_ra_unknown(note="Outside the certified algebraic class") = PropertyResult(nothing, :unknown, :unsupported, [note])

"""An interval with exact finite endpoints; only infinity uses floating-point values."""
struct RealInterval
    left::Real
    right::Real
    left_closed::Bool
    right_closed::Bool
end
struct RealDomain
    components::Vector{RealInterval}
    status::Symbol
    method::Symbol
    notes::Vector{String}
end
struct RealFunctionStudy{O,S} <: AbstractAnalysis
    original_expression::O
    simplified_expression::S
    domain::RealDomain
    roots::PropertyResult
    intercepts::PropertyResult
    sign::PropertyResult
    continuity::PropertyResult
    limits::PropertyResult
    monotonicity::PropertyResult
    extrema::PropertyResult
    concavity::PropertyResult
    inflections::PropertyResult
    asymptotes::PropertyResult
    symmetry::PropertyResult
end
const _RAQ = Rational{BigInt}
# Shared by parsing, domain constraints, derivatives, parity and limits.
# Reject projected work BEFORE dense allocation or BigInt multiplication.
struct _RABudgetExceeded <: Exception end
const _RA_MAX_DEGREE = 64
const _RA_MAX_BITS = 4096
const _RA_MAX_WORK = 200_000
const _RA_BUDGET_KEY = gensym(:real_analysis_budget)
function _ra_charge(n=1)
    budget=get(task_local_storage(),_RA_BUDGET_KEY,nothing)
    if budget!==nothing
        n <= budget[] || throw(_RABudgetExceeded())
        budget[]-=n
    end
    nothing
end
_ra_bits(x::Integer)=ndigits(x;base=2)
_ra_bits(x::Rational)=max(_ra_bits(numerator(x)),_ra_bits(denominator(x)))
function _ra_sizecheck(degree,bits)
    degree<=_RA_MAX_DEGREE && bits<=_RA_MAX_BITS || throw(_RABudgetExceeded())
    nothing
end
function _ra_polybits(p)
    _ra_sizecheck(length(p)-1,0)
    bits=maximum(_ra_bits,p)
    _ra_sizecheck(length(p)-1,bits)
    bits
end
# Iterative preflight bounds recursive walkers (including domain inference),
# wide calls and literal size before any recursive comparisons or copying.
function _ra_preflight(ast)
    pending=Tuple{Any,Int}[(ast,0)]; nodes=0
    while !isempty(pending)
        e,depth=pop!(pending); nodes+=1
        nodes<=512 && depth<=48 || throw(_RABudgetExceeded())
        if e isa Expr
            length(e.args)+nodes+length(pending)<=512 || throw(_RABudgetExceeded())
            append!(pending,((a,depth+1) for a in e.args))
        elseif e isa Union{Integer,Rational}
            _ra_sizecheck(0,_ra_bits(e))
        end
    end
end
_ra_poly(p) = begin
    _ra_polybits(p); _ra_charge(length(p))
    q = _RAQ.(p)
    while length(q)>1 && iszero(last(q)); pop!(q); end
    q
end
function _ra_add(a,b)
    _ra_sizecheck(max(length(a),length(b))-1,_ra_polybits(a)+_ra_polybits(b)+1)
    _ra_charge(max(length(a),length(b)))
    _ra_poly([get(a,i,0//1)+get(b,i,0//1) for i in 1:max(length(a),length(b))])
end
_ra_neg(a) = -a
function _ra_mul(a,b)
    terms=min(length(a),length(b))
    _ra_sizecheck(length(a)+length(b)-2,terms*(_ra_polybits(a)+_ra_polybits(b))+ndigits(terms;base=2))
    _ra_charge(length(a)*length(b))
    c=zeros(_RAQ,length(a)+length(b)-1)
    for i in eachindex(a), j in eachindex(b); c[i+j-1]+=a[i]*b[j]; end
    _ra_poly(c)
end
function _ra_eval(p,x)
    _ra_charge(length(p))
    # Numerical plotting/search keeps its floating arithmetic. Exact Horner
    # evaluation has a conservative numerator/denominator growth bound.
    if x isa Union{Integer,Rational}
        _ra_sizecheck(length(p)-1,length(p)*(_ra_polybits(p)+_ra_bits(x)+1))
    end
    foldr((a,b)->a+x*b,p;init=zero(_RAQ))
end
function _ra_diff(p)
    _ra_sizecheck(length(p)-1,_ra_polybits(p)+ndigits(length(p);base=2))
    _ra_charge(length(p))
    length(p)==1 ? _RAQ[0] : _ra_poly([i*p[i+1] for i in 1:length(p)-1])
end
struct _RARational
    n::Vector{_RAQ}
    d::Vector{_RAQ}
end
_ra_rat(n,d=[1]) = _RARational(_ra_poly(n),_ra_poly(d))
Base.:+(a::_RARational,b::_RARational)=_ra_rat(_ra_add(_ra_mul(a.n,b.d),_ra_mul(b.n,a.d)),_ra_mul(a.d,b.d))
Base.:-(a::_RARational)=_ra_rat(-a.n,a.d)
Base.:-(a::_RARational,b::_RARational)=a+(-b)
Base.:*(a::_RARational,b::_RARational)=_ra_rat(_ra_mul(a.n,b.n),_ra_mul(a.d,b.d))
Base.:/(a::_RARational,b::_RARational)=_ra_rat(_ra_mul(a.n,b.d),_ra_mul(a.d,b.n))
function _ra_derivative(a::_RARational)
    _ra_rat(_ra_add(_ra_mul(_ra_diff(a.n),a.d),-_ra_mul(a.n,_ra_diff(a.d))),_ra_mul(a.d,a.d))
end
_ra_ast(e::Expr)=e
_ra_ast(e::Symbol)=e
_ra_ast(e::Integer)=e
_ra_ast(e::Rational)=e
_ra_ast(e)=Symbolics.toexpr(e)
_ra_op(e)=e isa Expr && e.head==:call ? Symbol(string(e.args[1])) : nothing
function _ra_parse(e,v)
    e==v && return _ra_rat([0,1])
    e isa Union{Integer,Rational} && return _ra_rat([e])
    e isa Expr && e.head==:call || return nothing
    op=_ra_op(e); args=e.args[2:end]
    if op==:^ && length(args)==2 && args[2] isa Integer && -32<=args[2]<=32
        a=_ra_parse(args[1],v); a===nothing && return nothing
        k=args[2]; r=_ra_rat([1])
        for _ in 1:abs(k); r=r*a; end
        return k<0 ? _ra_rat([1])/r : r
    end
    op in (:+,:-,:*,:/,://) || return nothing
    aa=[_ra_parse(a,v) for a in args]
    any(isnothing,aa) && return nothing
    isempty(aa) && return nothing
    op==:+ && return foldl(+,aa)
    op==:* && return foldl(*,aa)
    op==:- && return length(aa)==1 ? -only(aa) : foldl(-,aa)
    length(aa)==2 || return nothing
    aa[1]/aa[2]
end
function _ra_divlinear(p,r)
    _ra_sizecheck(length(p)-1,length(p)*(_ra_polybits(p)+_ra_bits(r)+1))
    _ra_charge(length(p))
    q=zeros(_RAQ,length(p)-1); q[end]=p[end]
    for i in length(q)-1:-1:1; q[i]=p[i+1]+r*q[i+1]; end
    _ra_poly(q)
end
function _ra_divisors(n)
    n=abs(n); n>10^8 && return nothing
    d=BigInt[]
    for i in BigInt(1):isqrt(n)
        _ra_charge()
        if n%i==0; push!(d,i); i*i!=n && push!(d,n÷i); end
    end
    d
end
"""Complete real roots when rational factors leave at most a negative-discriminant quadratic.
No approximate root is promoted to an algebraic certificate.
"""
function _ra_roots(p)
    # Covers discriminants, denominator LCMs and integer clearing below.
    _ra_sizecheck(length(p)-1,4*length(p)*(_ra_polybits(p)+1))
    _ra_charge(length(p))
    p=copy(p); rr=_RAQ[]
    all(iszero,p) && return (rr,true,true)
    while length(p)>1
        if iszero(p[1]); push!(rr,0); p=p[2:end]; continue; end
        if length(p)==2; push!(rr,-p[1]/p[2]); break; end
        if length(p)==3
            disc=p[2]^2-4p[1]*p[3]
            disc<0 && break
            a=isqrt(numerator(disc)); b=isqrt(denominator(disc))
            a*a==numerator(disc) && b*b==denominator(disc) || return (sort!(unique(rr)),false,false)
            push!(rr,(-p[2]-a//b)/(2p[3]),(-p[2]+a//b)/(2p[3])); break
        end
        m=foldl(lcm,denominator.(p)); ints=numerator.(p.*m)
        aa=_ra_divisors(first(ints)); bb=_ra_divisors(last(ints))
        (aa===nothing || bb===nothing) && return (sort!(unique(rr)),false,false)
        root=nothing
        for a in aa, b in bb, s in (-1,1)
            r=s*a//b
            if iszero(_ra_eval(p,r)); root=r; break; end
        end
        root===nothing && return (sort!(unique(rr)),false,false)
        push!(rr,root); p=_ra_divlinear(p,root)
    end
    (sort!(unique(rr)),true,false)
end
_ra_contains(i::RealInterval,x)=(i.left<x || i.left_closed && i.left==x) && (x<i.right || i.right_closed && i.right==x)
_ra_contains(d::RealDomain,x)=any(i->_ra_contains(i,x),d.components)
_ra_sample(a,b)=a==-Inf ? (b==Inf ? 0//BigInt(1) : b-1) : b==Inf ? a+1 : (a+b)/2
function _ra_partition(r::_RARational,d::RealDomain; extra=_RAQ[])
    # No open cells exist on an empty or purely isolated domain. Do not
    # evaluate derivative denominators there (they need not be defined).
    all(i->i.left==i.right,d.components) && return NamedTuple[]
    nr,nok,_=_ra_roots(r.n); dr,dok,_=_ra_roots(r.d)
    nok && dok && !all(iszero,r.d) || return nothing
    out=NamedTuple[]
    for i in d.components
        cuts=sort!(unique(Real[i.left; filter(x->i.left<x<i.right,[nr;dr;extra]); i.right]))
        for j in 1:length(cuts)-1
            a,b=cuts[j:j+1]; t=_ra_sample(a,b)
            push!(out,(interval=RealInterval(a,b,false,false),sign=Int(sign(_ra_eval(r.n,t)/_ra_eval(r.d,t)))))
        end
    end
    out
end
# Compile only the same mathematical call vocabulary accepted by the domain
# walker. Source Expr is never passed to eval, including in heuristic mode.
function _ra_ast_callable(e,v)
    e==v && return identity
    e isa Union{Integer,Rational} && return _->e
    e isa Expr && e.head==:call || throw(ArgumentError("Unsupported numerical syntax"))
    operations=Dict(:+ => +, :- => -, :* => *, :/ => /, :// => /,
                    :^ => ^, :sqrt => sqrt, :log => log, :sin => sin,
                    :cos => cos, :exp => exp)
    f=get(operations,_ra_op(e),nothing)
    f===nothing && throw(ArgumentError("Unsupported numerical operation"))
    args=[_ra_ast_callable(a,v) for a in e.args[2:end]]
    t->f(map(g->g(t),args)...)
end
"""Bounded floating-point observations, never a complete zero-set certificate."""
function _ra_bounded_roots(original,variable,r,outer,d,interval)
    interval===nothing && return _ra_unknown()
    d.status==:established || return _ra_unknown("Root search requires an established original domain")
    interval isa Union{Tuple,AbstractVector} && length(interval)==2 &&
        all(t->t isa Real && isfinite(t),interval) && interval[1]<interval[2] ||
        return _ra_unknown("Root search requires two ordered finite real bounds")
    lo,hi=Float64.(interval)
    isfinite(lo) && isfinite(hi) && lo<hi || return _ra_unknown("Bounds are not representable in Float64")
    f=try
        if r!==nothing
            t->begin
                q=_ra_eval(r.n,t)/_ra_eval(r.d,t)
                outer==:sqrt ? sqrt(q) : outer==:log ? log(q) : q
            end
        elseif original isa Expr
            _ra_ast_callable(original,_ra_ast(variable))
        else
            Symbolics.build_function(original,variable;expression=Val(false))
        end
    catch err
        err isa Union{InterruptException,_RABudgetExceeded} && rethrow()
        return _ra_unknown("Unable to compile numerical root callable")
    end
    safe(t)=try
        y=f(t)
        y isa Real && isfinite(y) ? Float64(y) : NaN
    catch err
        err isa Union{InterruptException,_RABudgetExceeded} && rethrow()
        NaN
    end
    roots=Float64[]
    notes=["Float64 search restricted to [$lo, $hi] and the original domain; roots are approximate and completeness is not established. An empty search is not proof of absence."]
    for component in d.components
        a=max(lo,Float64(component.left)); b=min(hi,Float64(component.right))
        _ra_contains(component,a) || (a=nextfloat(a))
        _ra_contains(component,b) || (b=prevfloat(b))
        a<=b || continue
        candidates=try
            a==b ? (iszero(safe(a)) ? [a] : Float64[]) : Roots.find_zeros(safe,a,b)
        catch err
            err isa Union{InterruptException,_RABudgetExceeded} && rethrow()
            push!(notes,"A component search failed; observations may be incomplete.")
            Float64[]
        end
        for t in candidates
            lo<=t<=hi && _ra_contains(d,t) && isfinite(safe(t)) && abs(safe(t))<=sqrt(eps(Float64)) && push!(roots,t)
        end
    end
    PropertyResult(sort!(unique!(roots)),:heuristic,:bounded_root_search,notes)
end
include("real_analysis_domain.jl")
include("real_analysis_transforms.jl")
include("real_analysis_periodic.jl")

"""
    _real_analysis(expression, variable, first_derivative, second_derivative;
                   interval=nothing, original=expression)

Backend-independent global real-function certificate. Walk `original` before
simplifying: source Expr is inspected, never evaluated. Rational polynomials
use BigInt rational coefficients, rational-root factorization, and certified
quadratic residuals (negative discriminant or rational square discriminant).
Unresolved algebraic roots leave affected properties `:unknown`; no finite
floating-point approximation is promoted to proof. Exact cell representatives
establish signs only after complete root enumeration proves sign invariance.
Integer powers are bounded by 32, divisor enumeration by coefficients 10^8.
A shared conservative budget caps dense degree at 64, projected coefficient
bits at 4096, and cumulative algebraic work at 200_000 units. Source ASTs
are limited to 512 nodes and depth 48 before recursive walkers. These guards
also apply to domain, derivative and parity intermediates; exhaustion returns
an all-unknown study with method `:resource_budget`, without numerical fallback.

Also supports outer sqrt/log of these rational functions by chain-rule and
limit identities, and sin(variable) by exact periodic families. Unsupported
composed inequalities conservatively produce an unknown original domain.
The supplied derivatives are integration arguments; certificates independently
recompute rational derivatives. With an explicit finite `interval`, unresolved
roots may use a Float64 bounded search, only on an established original domain.
Such results carry `:heuristic` / `:bounded_root_search`, do not establish
completeness (including empty searches), and never certify other properties.
The interval does not truncate the exact global study.

Limits describe original-domain component boundaries and reachable infinities.
Extrema mean strict local extrema, including included one-sided sqrt endpoints;
constant plateaux have no strict extrema. Zero sets may be RealDomain, and sine
zero sets are PeriodicPointSet. Other finite values are exact rationals or
unevaluated Expr (sqrt/log), never executable presentation instructions.
"""
function _real_analysis(expression,variable,first_derivative,second_derivative; interval=nothing,original=expression)
    task_local_storage(_RA_BUDGET_KEY,Ref(_RA_MAX_WORK)) do
        try
            ast=_ra_ast(original); _ra_preflight(ast)
            _ra_analysis_impl(expression,variable,first_derivative,second_derivative,ast;interval,original)
        catch err
            err isa _RABudgetExceeded || rethrow()
            note="Conservative algebraic resource budget exceeded"
            d=RealDomain(RealInterval[],:unknown,:resource_budget,[note])
            u=PropertyResult(nothing,:unknown,:resource_budget,[note])
            # Do not simplify or launch a numerical fallback after exhaustion.
            RealFunctionStudy(original,expression,d,u,u,u,u,u,u,u,u,u,u,u)
        end
    end
end
function _ra_analysis_impl(expression,variable,first_derivative,second_derivative,ast;interval,original)
    v=_ra_ast(variable); r=_ra_parse(ast,v)
    outer=:identity
    if r===nothing && _ra_op(ast) in (:sqrt,:log) && length(ast.args)==2
        outer=_ra_op(ast); r=_ra_parse(ast.args[2],v)
    end
    d=_ra_domain(ast,v) # Preserve all original restrictions before any simplification.
    expression = expression isa Expr ? expression : Symbolics.simplify(expression)
    u=_ra_unknown()
    if d.status==:established && isempty(d.components)
        # Set-theoretic conclusions on a certified empty domain do not require
        # a rational formula or numerical search; parity is vacuously both.
        emptyproperty()=_ra_proven(NamedTuple[])
        return RealFunctionStudy(original,expression,d,_ra_proven(_RAQ[]),
            _ra_proven((x=_RAQ[],y=nothing)),emptyproperty(),
            _ra_proven((continuous_on_domain=true,discontinuities=NamedTuple[])),
            emptyproperty(),emptyproperty(),emptyproperty(),emptyproperty(),emptyproperty(),
            _ra_proven((vertical=Real[],horizontal=NamedTuple[],slant=NamedTuple[])),_ra_proven(:both))
    end
    if _ra_op(ast)==:sin && length(ast.args)==2 && ast.args[2]==v
        return _ra_sine_study(original,expression,d)
    end
    if r===nothing || d.status!=:established
        rootsresult=_ra_bounded_roots(original,variable,r,outer,d,interval)
        return RealFunctionStudy(original,expression,d,rootsresult,u,u,u,u,u,u,u,u,u,u)
    end
    zero_rat=outer==:log ? r-_ra_rat([1]) : r
    roots,complete,nonisolated=_ra_roots(zero_rat.n)
    filter!(t->_ra_contains(d,t),roots)
    rootsresult=complete ? _ra_proven(nonisolated ? d : roots) : _ra_bounded_roots(original,variable,r,outer,d,interval)
    signs=_ra_partition(zero_rat,d); d1=_ra_derivative(r); d2=_ra_derivative(d1)
    extra=_RAQ[]
    if outer!=:identity
        extra,ok,_=_ra_roots(r.n)
        ok || return RealFunctionStudy(original,expression,d,u,u,u,u,u,u,u,u,u,u,u)
        d2=outer==:sqrt ? _ra_rat([2])*r*d2-d1*d1 : r*d2-d1*d1
    end
    valueat(t)=_ra_exact_transform(outer,_ra_eval(r.n,t)/_ra_eval(r.d,t))
    p1=_ra_partition(d1,d;extra); p2=_ra_partition(d2,d;extra)
    monotonicity=p1===nothing ? u : _ra_proven([(interval=p.interval,direction=p.sign>0 ? :increasing : p.sign<0 ? :decreasing : :constant) for p in p1])
    concavity=p2===nothing ? u : _ra_proven([(interval=p.interval,direction=p.sign>0 ? :convex : p.sign<0 ? :concave : :affine) for p in p2])
    extrema=NamedTuple[]; inflections=NamedTuple[]
    if p1!==nothing
        for j in 1:length(p1)-1
            a,b=p1[j:j+1]; t=a.interval.right
            t==b.interval.left && _ra_contains(d,t) && a.sign*b.sign<0 && push!(extrema,(x=t,value=valueat(t),classification=a.sign<0 ? :minimum : :maximum))
        end
    end
    if p2!==nothing
        for j in 1:length(p2)-1
            a,b=p2[j:j+1]; t=a.interval.right
            t==b.interval.left && _ra_contains(d,t) && a.sign*b.sign<0 && push!(inflections,(x=t,value=valueat(t)))
        end
    end
    if outer==:sqrt && p1!==nothing
        for i in d.components, (t,side) in ((i.left,:right),(i.right,:left))
            isfinite(t) && _ra_contains(d,t) || continue
            j=findfirst(p-> side==:right ? p.interval.left==t : p.interval.right==t,p1)
            j===nothing && continue
            sg=p1[j].sign; sg==0 && continue
            cls=(side==:right ? sg>0 : sg<0) ? :minimum : :maximum
            push!(extrema,(x=t,value=valueat(t),classification=cls))
        end
    end
    reflected=_ra_rat([(-1)^(i-1)*r.n[i] for i in eachindex(r.n)],[(-1)^(i-1)*r.d[i] for i in eachindex(r.d)])
    parity=all(iszero,(r-reflected).n) ? :even : all(iszero,(r+reflected).n) ? :odd : :neither
    if outer!=:identity
        parity=all(iszero,(r-reflected).n) ? :even : outer==:log && all(iszero,(r*reflected-_ra_rat([1])).n) ? :odd : :neither
    elseif all(iszero,r.n)
        parity=:both
    end
    # A zero function on a finite original domain is also odd, even when
    # its algebraic extension is not identically zero (e.g. sqrt(-x^2)).
    zero_on_domain=nonisolated || all(i->i.left==i.right && iszero(_ra_eval(zero_rat.n,i.left)),d.components)
    zero_on_domain && (parity=:both)
    _ra_symmetric(d) || (parity=:neither)
    transform=outer==:identity ? identity : l->_ra_transform_limit(outer,l)
    limits,continuity,asymptotes=_ra_boundary_data(r,d;transform)
    outer==:sqrt && (asymptotes=_ra_sqrt_asymptotes(r,d,asymptotes))
    RealFunctionStudy(original,expression,d,rootsresult,complete ? _ra_proven((x=rootsresult.value,y=_ra_contains(d,0) ? valueat(0) : nothing)) : u,signs===nothing ? u : _ra_proven(signs),continuity,limits,monotonicity,p1===nothing ? u : _ra_proven(extrema),concavity,p2===nothing ? u : _ra_proven(inflections),asymptotes,_ra_proven(parity))
end
