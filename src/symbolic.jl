"""
    analyze(expression::Real, variable::Symbolics.Num;
            interval=nothing, residual_tolerance=1e-8)

Construct a structured analysis of a scalar symbolic expression or real constant.
Compute derivatives and reusable numerical callables using Symbolics. Unbound
parameters are rejected. With a finite increasing `interval=(a,b)`, search for
stationary points numerically using Roots (Float64). This assumes a smooth real
function on the interval, does not infer the domain, and can miss roots, corners,
and singularities. No interval means no search, rather than a guessed domain.
Classification uses only the second-derivative test and is not a proof of extrema.
Numerical domain errors propagate; results are never silently marked complete.
"""
function analyze(expression::Real, variable::Symbolics.Num;
                 interval=nothing, residual_tolerance::Real=1e-8)
    variables = Symbolics.get_variables(variable)
    length(variables) == 1 && isequal(Symbolics.Num(only(variables)), variable) ||
        throw(ArgumentError("variable must be a single symbolic variable"))
    all(v -> isequal(Symbolics.Num(v), variable), Symbolics.get_variables(expression)) ||
        throw(ArgumentError("expression must not contain unbound parameters or other variables"))
    differential = Symbolics.Differential(variable)
    first = Symbolics.expand_derivatives(differential(expression))
    second = Symbolics.expand_derivatives(differential(first))
    numerical = (
        function_value=Symbolics.build_function(expression, variable; expression=Val{false}),
        first_derivative=Symbolics.build_function(first, variable; expression=Val{false}),
        second_derivative=Symbolics.build_function(second, variable; expression=Val{false}),
    )
    critical = _critical_points(numerical, first, interval, residual_tolerance)
    return FunctionAnalysis(expression, variable, first, second, numerical, critical)
end
