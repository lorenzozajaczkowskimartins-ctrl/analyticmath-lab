"""
    analyze(expression::Real, variable::Symbolics.Num;
            interval=nothing, residual_tolerance=1e-8,
            residual_rtol=0, residual_scale=1)

Construct a structured analysis of a scalar symbolic expression or real constant.
Compute derivatives and reusable numerical callables using Symbolics. Unbound
parameters are rejected. With a finite increasing `interval=(a,b)`, search for
stationary points numerically using Roots (Float64). This assumes a smooth real
function on the interval, does not infer the domain, and can miss roots, corners,
and singularities. No interval means no search, rather than a guessed domain.
Classification uses only the second-derivative test and is not a proof of extrema.
Numerical domain errors propagate; results are never silently marked complete.
Candidates pass when `abs(f′(x)) <= residual_tolerance + residual_rtol * residual_scale`.
The scale must be finite and positive and is supplied in derivative units by the
caller; no scale is inferred. Relative tolerance is finite and nonnegative.
This residual check is not a bound on root-location error. Defaults preserve
Milestone 1 acceptance and classification.

The independent global `report.real_analysis` records evidence-aware original
domain and qualitative properties. Use `@real_function` to capture syntax before
symbolic construction erases restrictions. `original_expression` may alternatively
provide trusted matching source syntax; it is inspected, not evaluated as code.
The stored domain does not change the legacy numerical search/evaluation contract.
"""
function analyze(expression::Real, variable::Symbolics.Num;
                 interval=nothing, residual_tolerance::Real=1e-8,
                 residual_rtol::Real=0, residual_scale::Real=1,
                 original_expression=expression)
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
    critical = _critical_points(numerical, first, interval, residual_tolerance,
                                residual_rtol, residual_scale)
    study = _real_analysis(expression, variable, first, second;
                           interval, original=original_expression)
    return FunctionAnalysis(expression, variable, first, second, numerical, critical, study)
end

analyze(captured::RealExpression, variable::Symbolics.Num; kwargs...) =
    analyze(captured.expression, variable; original_expression=captured.original, kwargs...)
