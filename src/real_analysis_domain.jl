"""Membership in a certified original domain, or `nothing` if not established."""
domain_contains(d::RealDomain,x::Real)=d.status==:established ? _ra_contains(d,x) : nothing
function _ra_constraints!(out,e,v)
    (e==v || e isa Union{Integer,Rational}) && return true
    e isa Expr && e.head==:call || return false
    op=_ra_op(e); aa=e.args[2:end]
    op in (:+,:-,:*,:/,://,:^,:sqrt,:log,:sin,:cos,:exp) || return false
    all(a->_ra_constraints!(out,a,v),aa) || return false
    constraint=nothing
    if op in (:/,://)
        length(aa)==2 || return false
        constraint=(aa[2],:nonzero)
    elseif op==:^
        length(aa)==2 && aa[2] isa Integer || return false
        aa[2]<0 && (constraint=(aa[1],:nonzero))
    elseif op in (:sqrt,:log)
        length(aa)==1 || return false
        constraint=(aa[1],op==:sqrt ? :nonnegative : :positive)
    end
    if constraint!==nothing
        r=_ra_parse(constraint[1],v); r===nothing && return false
        push!(out,(r,constraint[2]))
    end
    true
end
function _ra_domain(ast,v)
    constraints=Tuple{_RARational,Symbol}[]
    _ra_constraints!(constraints,ast,v) || return RealDomain(RealInterval[],:unknown,:unsupported,["Unsupported original-domain constraint"])
    cuts=_RAQ[]
    for (r,_) in constraints, p in (r.n,r.d)
        rr,ok,_=_ra_roots(p)
        ok || return RealDomain(RealInterval[],:unknown,:unsupported,["Incomplete algebraic boundary roots"])
        append!(cuts,rr)
    end
    sort!(unique!(cuts))
    allowed(t)=all(constraints) do (r,kind)
        den=_ra_eval(r.d,t); iszero(den) && return false
        val=_ra_eval(r.n,t)/den
        kind==:positive ? val>0 : kind==:nonnegative ? val>=0 : !iszero(val)
    end
    endpoints=Real[-Inf;cuts;Inf]; pieces=RealInterval[]
    for j in 1:length(endpoints)-1
        a,b=endpoints[j:j+1]
        allowed(_ra_sample(a,b)) && push!(pieces,RealInterval(a,b,isfinite(a)&&allowed(a),isfinite(b)&&allowed(b)))
    end
    for t in cuts
        allowed(t) && !any(i->_ra_contains(i,t),pieces) && push!(pieces,RealInterval(t,t,true,true))
    end
    sort!(pieces;by=i->i.left); merged=RealInterval[]
    for i in pieces
        if !isempty(merged) && merged[end].right==i.left && (merged[end].right_closed||i.left_closed)
            p=pop!(merged); push!(merged,RealInterval(p.left,i.right,p.left_closed,i.right_closed))
        else
            push!(merged,i)
        end
    end
    RealDomain(merged,:established,:exact_algebra,String[])
end
function _ra_symmetric(d)
    a=d.components
    all(zip(a,reverse(a))) do (i,j)
        i.left == -j.right && i.right == -j.left && i.left_closed==j.right_closed && i.right_closed==j.left_closed
    end
end
_ra_limit(kind,value=nothing)=(kind=kind,value=value)
function _ra_limit_rational(r,t,side)
    all(iszero,r.d) && return _ra_limit(:does_not_exist)
    all(iszero,r.n) && return _ra_limit(:finite,zero(_RAQ))
    if isinf(t)
        degree=length(r.n)-length(r.d); coefficient=last(r.n)/last(r.d)
        degree<0 && return _ra_limit(:finite,zero(_RAQ))
        degree==0 && return _ra_limit(:finite,coefficient)
        s=sign(coefficient)*(t<0 && isodd(degree) ? -1 : 1)
        return _ra_limit(s>0 ? :positive_infinity : :negative_infinity)
    end
    n=copy(r.n); d=copy(r.d); order=0
    while length(n)>1 && iszero(_ra_eval(n,t)); n=_ra_divlinear(n,t); order+=1; end
    while length(d)>1 && iszero(_ra_eval(d,t)); d=_ra_divlinear(d,t); order-=1; end
    c=_ra_eval(n,t)/_ra_eval(d,t)
    order>0 && return _ra_limit(:finite,zero(_RAQ))
    order==0 && return _ra_limit(:finite,c)
    s=sign(c)*(side==:left && isodd(order) ? -1 : 1)
    _ra_limit(s>0 ? :positive_infinity : :negative_infinity)
end
function _ra_approaches(d,t,side)
    t==-Inf && return any(i->i.left==-Inf,d.components)
    t==Inf && return any(i->i.right==Inf,d.components)
    side==:left ? any(i->i.left<t<=i.right,d.components) : any(i->i.left<=t<i.right,d.components)
end
function _ra_boundary_data(r,d; transform=identity)
    boundaries=sort!(unique(Real[i.left for i in d.components] ∪ Real[i.right for i in d.components]))
    limits=NamedTuple[]; discontinuities=NamedTuple[]; vertical=Real[]; horizontal=NamedTuple[]; slant=NamedTuple[]
    for t in boundaries
        if isinf(t)
            l=transform(_ra_limit_rational(r,t,:both)); push!(limits,(at=t,side=:both,l...))
            side=t<0 ? :negative_infinity : :positive_infinity
            if l.kind==:finite
                push!(horizontal,(side=side,value=l.value))
            elseif transform===identity && length(r.n)==length(r.d)+1
                slope=last(r.n)/last(r.d)
                intercept=(r.n[end-1]-slope*get(r.d,length(r.d)-1,0//1))/last(r.d)
                push!(slant,(side=side,slope=slope,intercept=intercept))
            end
            continue
        end
        sides=[_ra_approaches(d,t,s) ? transform(_ra_limit_rational(r,t,s)) : _ra_limit(:does_not_exist) for s in (:left,:right)]
        for (s,l) in zip((:left,:right),sides); push!(limits,(at=t,side=s,l...)); end
        both=sides[1]==sides[2] ? sides[1] : _ra_limit(:does_not_exist)
        push!(limits,(at=t,side=:both,both...))
        pole=any(l->l.kind in (:positive_infinity,:negative_infinity),sides)
        pole && push!(vertical,t)
        if !_ra_contains(d,t)
            cls=pole ? :pole : all(l->l.kind==:finite,sides) && sides[1]==sides[2] ? :removable : :boundary
            push!(discontinuities,(x=t,classification=cls))
        end
    end
    (_ra_proven(limits),_ra_proven((continuous_on_domain=true,discontinuities=discontinuities)),_ra_proven((vertical=vertical,horizontal=horizontal,slant=slant)))
end
