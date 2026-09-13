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
