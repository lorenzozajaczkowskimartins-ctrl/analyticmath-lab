function Base.show(io::IO, report::VectorFieldAnalysis)
    print(io,"VectorFieldAnalysis(",report.input_dimension," → ",report.output_dimension,
        "; field_zeros=",report.field_zeros.status,
        ", conservative=",report.conservative.status,")")
end
function Base.show(io::IO, ::MIME"text/plain", report::VectorFieldAnalysis)
    println(io,"AnalyticMathLab — Vector Field Analysis")
    println(io,"  F(",join(string.(report.variables),", "),") = ",collect(report.components))
    println(io,"  Dimensions: ",report.input_dimension," → ",report.output_dimension)
    println(io,"  Domain: ",report.domain.status," (",report.domain.method,"); restrictions=",length(report.domain.restrictions))
    println(io,"  Jacobian: ",report.jacobian_expression)
    for (name,result) in (("Divergence",report.divergence),("Curl",report.curl),
            ("Conservative",report.conservative),("Potential",report.potential))
        println(io,"  ",name," [",result.status,"; ",result.method,"]: ",result.value)
    end
    println(io,"  Field zeros [",report.field_zeros.status,"; ",report.field_zeros.method,"]: ",length(report.field_zeros.value)," candidates (no stability claim)")
    for candidate in Iterators.take(report.field_zeros.value,8)
        println(io,"    ",candidate.point,"; residual=",candidate.residual_norm," ≤ ",candidate.residual_threshold)
    end
    length(report.field_zeros.value) > 8 && print(io,"    Further candidates are available in field_zeros.value.")
end
