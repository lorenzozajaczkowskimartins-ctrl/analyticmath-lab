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
