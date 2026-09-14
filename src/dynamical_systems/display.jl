function Base.show(io::IO, r::DynamicalSystemAnalysis)
    print(io,"DynamicalSystemAnalysis(dimension=",r.dimension,", equilibria=",r.equilibria.status,")")
end
function Base.show(io::IO, ::MIME"text/plain", r::DynamicalSystemAnalysis)
    println(io,"AnalyticMathLab — DynamicalSystemAnalysis")
    println(io,"  Dimension: ",r.dimension,"; original domain: ",r.domain.status)
    for (variable,component) in zip(r.variables,r.field.components)
        println(io,"    ",variable,"′ = ",component)
    end
    println(io,"  equilibria: ",length(r.equilibria.value)," candidates [",r.equilibria.status,"; ",r.equilibria.method,"]")
    for e in Iterators.take(r.equilibria.value,8)
        s = e.local_analysis.stability
        println(io,"    ",e.point,": residual=",e.residual_norm,"; domain valid=",e.domain_valid)
        println(io,"      eigenvalues (numerical): ",e.local_analysis.eigenvalues)
        println(io,"      ",s.value," [",s.status,"; ",s.method,"] — local, not global")
    end
    length(r.equilibria.value)>8 && println(io,"    Further candidates are stored in equilibria.value.")
    println(io,"  nullclines: ",r.nullclines.status," (",r.nullclines.method,")")
    r.nullclines.value === nothing || for c in r.nullclines.value
        println(io,"    ",c.equation," on the original domain")
    end
end
