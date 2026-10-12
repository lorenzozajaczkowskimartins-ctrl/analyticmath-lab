# Documentation-only binding inspection, not scientific execution.
using AnalyticMathLab, Documenter, TOML
const AML = AnalyticMathLab
root = realpath(joinpath(@__DIR__, ".."))
@assert VERSION == v"1.12.7"
@assert realpath(dirname(dirname(pathof(AML)))) == root
symbols = split(read(ARGS[1], String), '\n'; keepempty=false)
records = Dict{String,Any}[]
for name in symbols
    symbol = Symbol(name)
    value = getfield(AML, symbol)
    kind = startswith(name, "@") ? "macro" : value isa Type ?
        (isabstracttype(Base.unwrap_unionall(value)) ? "abstract type" : "type / constructors") :
        value isa Function ? "generic function" : "constant / value"
    binding = Base.Docs.Binding(AML, symbol)
    registered = haskey(Base.Docs.meta(AML), binding)
    qualified = name in ("scientific_metadata", "scientific_origin")
    @assert Base.isexported(AML,symbol) == !qualified
    push!(records, Dict("symbol"=>name, "kind"=>kind,
        "module_local_docstring_registered"=>registered,
        "fields"=>value isa Type && !isabstracttype(Base.unwrap_unionall(value)) ?
            collect(string.(fieldnames(Base.unwrap_unionall(value)))) : String[],
        "mutable_outer"=>value isa Type ? ismutabletype(Base.unwrap_unionall(value)) : false))
end
TOML.print(stdout, Dict("julia_version"=>string(VERSION),
    "active_project"=>Base.active_project(), "aml_source"=>pathof(AML),
    "documenter_version"=>string(pkgversion(Documenter)), "bindings"=>records))
println("# BINDING_INSPECTION_COMPLETE")
