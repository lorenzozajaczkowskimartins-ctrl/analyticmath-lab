"""The exact set `{offset + k*period : k ∈ ℤ}`. Symbol/Expr values are unevaluated exact syntax."""
struct PeriodicPointSet{O,P}
    offset::O
    period::P
end
"""All integer translates by `period` of an interval with exact symbolic endpoints."""
struct PeriodicIntervalSet{L,R,P}
    left::L
    right::R
    period::P
    left_closed::Bool
    right_closed::Bool
end
function _ra_sine_study(original,expression,d)
    prove(v)=PropertyResult(v,:established,:analytic_identity,["Classical sine/cosine identities; k ranges over all integers"])
    pi=:π; twopi=:(2*π); halfpi=:(π/2); threehalfpi=:(3*π/2)
    points=PeriodicPointSet(0,pi)
    positive=PeriodicIntervalSet(0,pi,twopi,false,false)
    negative=PeriodicIntervalSet(pi,twopi,twopi,false,false)
    increasing=PeriodicIntervalSet(:(-π/2),halfpi,twopi,false,false)
    decreasing=PeriodicIntervalSet(halfpi,threehalfpi,twopi,false,false)
    RealFunctionStudy(original,expression,d,prove(points),prove((x=points,y=0//1)),
        prove([(interval=positive,sign=1),(interval=negative,sign=-1)]),
        prove((continuous_on_domain=true,discontinuities=NamedTuple[])),
        prove([(at=t,side=:both,kind=:does_not_exist,value=nothing) for t in (-Inf,Inf)]),
        prove([(interval=increasing,direction=:increasing),(interval=decreasing,direction=:decreasing)]),
        prove([(x=PeriodicPointSet(halfpi,twopi),value=1//1,classification=:maximum),(x=PeriodicPointSet(threehalfpi,twopi),value=-1//1,classification=:minimum)]),
        prove([(interval=positive,direction=:concave),(interval=negative,direction=:convex)]),
        prove([(x=points,value=0//1)]),
        prove((vertical=Real[],horizontal=NamedTuple[],slant=NamedTuple[])),prove(:odd))
end
