# Shared bounded rational-polynomial engine for real and separable scalar-field analysis.
# Historical _ra names are internal, not a dependency on RealFunctionStudy.
# This budget does not cover caller expression construction or Symbolics compilation.
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
