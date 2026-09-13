function _ra_exact_transform(op,q)
    op==:identity && return q
    if op==:sqrt
        a=isqrt(numerator(q)); b=isqrt(denominator(q))
        a*a==numerator(q) && b*b==denominator(q) && return a//b
    elseif op==:log
        q==1 && return zero(_RAQ)
    end
    Expr(:call,op,q)
end
function _ra_transform_limit(op,l)
    l.kind==:positive_infinity && return l
    l.kind==:finite || return _ra_limit(l.kind==:negative_infinity ? :does_not_exist : l.kind)
    l.value<0 && return _ra_limit(:does_not_exist)
    op==:log && iszero(l.value) && return _ra_limit(:negative_infinity)
    _ra_limit(:finite,_ra_exact_transform(op,l.value))
end
function _ra_sqrt_asymptotes(r,d,result)
    lines=NamedTuple[]
    if length(r.n)==length(r.d)+2 && last(r.n)/last(r.d)>0
        a=last(r.n)/last(r.d)
        b=(r.n[end-1]-a*get(r.d,length(r.d)-1,0//1))/last(r.d)
        root=_ra_exact_transform(:sqrt,a)
        for t in (-Inf,Inf)
            _ra_approaches(d,t,:both) || continue
            sg=t<0 ? -1 : 1
            slope=root isa Real ? sg*root : Expr(:call,:*,sg,root)
            intercept=root isa Real ? sg*b/(2root) : Expr(:call,:/,sg*b,Expr(:call,:*,2,root))
            push!(lines,(side=t<0 ? :negative_infinity : :positive_infinity,slope=slope,intercept=intercept))
        end
    end
    _ra_proven((vertical=result.value.vertical,horizontal=result.value.horizontal,slant=lines))
end
