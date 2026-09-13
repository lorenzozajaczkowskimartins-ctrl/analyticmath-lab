function Base.show(io::IO, interval::RealInterval)
    print(io, interval.left_closed ? '[' : '(', interval.left, ", ",
          interval.right, interval.right_closed ? ']' : ')')
end

function Base.show(io::IO, domain::RealDomain)
    print(io, "RealDomain[", domain.status, "; ", domain.method, "]: ")
    if domain.status != :established
        print(io, "unknown")
    elseif isempty(domain.components)
        print(io, "empty")
    else
        join(io, domain.components, " ∪ ")
    end
end

Base.show(io::IO, study::RealFunctionStudy) =
    print(io, "RealFunctionStudy(", study.original_expression, "; domain=", study.domain.status, ")")

function Base.show(io::IO, ::MIME"text/plain", study::RealFunctionStudy)
    println(io, "Real Function Study (original-domain aware)")
    println(io, "  Original: ", study.original_expression)
    println(io, "  Domain: ", study.domain)
    for note in study.domain.notes
        println(io, "    ", note)
    end
    for name in (:roots, :intercepts, :sign, :continuity, :limits, :monotonicity,
                 :extrema, :concavity, :inflections, :asymptotes, :symmetry)
        result = getproperty(study, name)
        print(io, "  ", name, " [", result.status, "; ", result.method, "]: ", result.value)
        for note in result.notes
            print(io, "\n    ", note)
        end
        println(io)
    end
end
