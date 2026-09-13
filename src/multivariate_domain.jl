"""One original-syntax restriction on a multivariate scalar field."""
struct MultivariateRestriction{E}
    expression::E
    relation::Symbol
end

"""Conservative original domain represented by evaluable syntax restrictions."""
struct MultivariateDomain{R,V}
    restrictions::R
    variables::V
    status::Symbol
    method::Symbol
    notes::Vector{String}
end

function _mv_collect_restrictions!(out, ast, variable_names)
    ast isa Real && return isfinite(ast)
    ast isa Symbol && return ast in variable_names
    ast isa Expr && ast.head == :call || return false
    op = _mv_op(ast)
    args = ast.args[2:end]
    children = [_mv_collect_restrictions!(out, a, variable_names) for a in args]
    op in (:+, :-, :*, :/, ://, :^, :sqrt, :log, :sin, :cos, :exp, :abs) || return false
    if op in (:/, ://)
        length(args) == 2 || return false
        push!(out, MultivariateRestriction(args[2], :nonzero))
    elseif op == :^
        length(args) == 2 && args[2] isa Integer && -32 <= args[2] <= 32 || return false
        args[2] < 0 && push!(out, MultivariateRestriction(args[1], :nonzero))
    elseif op == :sqrt
        length(args) == 1 || return false
        push!(out, MultivariateRestriction(args[1], :nonnegative))
    elseif op == :log
        length(args) == 1 || return false
        push!(out, MultivariateRestriction(args[1], :positive))
    end
    return all(children)
end

function _mv_domain(original, variables)
    ast = _mv_ast(original)
    try
        _ra_preflight(ast)
    catch err
        err isa _RABudgetExceeded || rethrow()
        return MultivariateDomain((), variables, :unknown, :resource_budget, [sprint(showerror, err)])
    end
    restrictions = MultivariateRestriction[]
    names = Set(Symbol(_mv_ast(v)) for v in variables)
    if !_mv_collect_restrictions!(restrictions, ast, names)
        status = isempty(restrictions) ? :unknown : :partial
        return MultivariateDomain(tuple(restrictions...), variables, status, :unsupported,
            ["Unsupported original syntax; only captured exclusions can be rejected."])
    end
    return MultivariateDomain(tuple(restrictions...), variables, :established,
        :original_syntax_constraints, String[])
end

function _mv_eval_ast(ast, names, values)
    ast isa Integer && return BigInt(ast)
    ast isa Rational && return _RAQ(ast)
    ast isa Real && return ast
    if ast isa Symbol
        k = findfirst(==(ast), names)
        k === nothing && throw(ArgumentError("unbound name in original syntax"))
        value = values[k]
        return value isa Integer ? BigInt(value) : value isa Rational ? _RAQ(value) : value
    end
    ast isa Expr && ast.head == :call || throw(ArgumentError("unsupported syntax"))
    op = _mv_op(ast)
    args = [_mv_eval_ast(a, names, values) for a in ast.args[2:end]]
    all(x -> x isa Real && isfinite(x), args) || throw(DomainError(args, "nonfinite intermediate in domain constraint"))
    # Exact integer inputs must not wrap at machine precision. Bound growth
    # before arithmetic, including constraints inside partial-domain syntax.
    if op == :^
        length(args) == 2 && args[2] isa Integer && -32 <= args[2] <= 32 ||
            throw(ArgumentError("unsupported domain exponent"))
    end
    if all(x -> x isa Union{Integer,Rational}, args)
        bits = sum(_ra_bits, args; init=0) + length(args)
        op == :^ && (bits *= max(1,abs(args[2])))
        _ra_sizecheck(0,bits)
        op in (:/, ://) && return _RAQ(args[1]) / _RAQ(args[2])
        op == :^ && return _RAQ(args[1]) ^ args[2]
    end
    operations = Dict{Symbol,Any}(:+ => +, :- => -, :* => *, :/ => /, :// => /,
        :^ => ^, :sqrt => sqrt, :log => log, :sin => sin, :cos => cos,
        :exp => exp, :abs => abs)
    f = get(operations, op, nothing)
    f === nothing && throw(ArgumentError("unsupported operation"))
    return f(args...)
end

"""Return `true`/`false` for known multivariate domains, or `nothing` if unknown."""
function domain_contains(domain::MultivariateDomain, point::Union{Tuple,AbstractVector})
    length(point) == length(domain.variables) || throw(DimensionMismatch("point dimension does not match the domain"))
    all(x -> x isa Real && isfinite(x), point) || return false
    domain.status in (:established, :partial) || return nothing
    names = Symbol[_mv_ast(v) for v in domain.variables]
    unresolved = domain.status != :established
    for restriction in domain.restrictions
        value = try
            _mv_eval_ast(restriction.expression, names, point)
        catch err
            err isa InterruptException && rethrow()
            unresolved = true
            continue
        end
        value isa Real && isfinite(value) || return false
        ok = restriction.relation == :nonzero ? !iszero(value) :
             restriction.relation == :positive ? value > 0 : value >= 0
        ok || return false
    end
    return unresolved ? nothing : true
end