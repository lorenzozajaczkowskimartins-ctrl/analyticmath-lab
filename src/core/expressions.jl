"""
    RealExpression
    @real_function expression

Pair an evaluated Symbolics expression with its original Julia syntax, captured
before Symbolics can cancel factors (for example `x/x`). Pass this object to
`analyze(captured, x)`. Use the same variable name in the syntax and in Symbolics.
Literal real constants and supported elementary operations can be analyzed;
unresolved local names or unsupported syntax produce unknown domain information.
This is syntax capture, not a string parser or evaluator of untrusted input.
The expression is evaluated once in the caller's scope, just as ordinary Julia.
"""
struct RealExpression{E,S}
    expression::E
    original::S
end

macro real_function(expression)
    return :(RealExpression($(esc(expression)), $(QuoteNode(expression))))
end

# Normalize representation only; domain vocabularies and safe evaluators remain
# subsystem-specific. Symbolics uses function objects as operators, source uses
# Symbols. Never eval captured syntax or recover restrictions from simplification.
_expression_ast(e::Expr) = e
_expression_ast(e::Symbol) = e
_expression_ast(e::Real) = e
_expression_ast(e::Symbolics.Num) = Symbolics.toexpr(e)
_expression_ast(e) = Symbolics.toexpr(e)
_expression_op(e::Expr) = e.head == :call ? Symbol(string(e.args[1])) : nothing
_expression_op(e) = nothing

# Existing internal spellings share the implementation; no public API aliases.
const _ra_ast = _expression_ast
const _mv_ast = _expression_ast
const _ra_op = _expression_op
const _mv_op = _expression_op
