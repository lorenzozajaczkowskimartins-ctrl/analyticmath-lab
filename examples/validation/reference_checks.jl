"""Internal example/test reference gate, not a public AML theorem prover.

Substitute a symbolic-compatible callable into the ACTUAL declared equations and
conditions, differentiate with Symbolics (independent of NeuralPDE loss lowering),
and evaluate both sides on explicit points. Boundary calls retain their declared
arguments. This is finite sampled consistency only, even when simplification
happens to yield zero. Unknown/non-numeric substitutions fail closed.
"""
module ReferenceChecks
using AnalyticMathLab: PropertyResult
import Symbolics

function replace_fields(expression, reference, ivs, dvs)
    ops = [Symbolics.operation(Symbolics.unwrap(d)) for d in dvs]
    replacements = Dict{Any,Any}()
    function visit(node)
        raw = Symbolics.unwrap(node)
        Symbolics.iscall(raw) || return
        op = Symbolics.operation(raw)
        index = findfirst(o -> isequal(o,op),ops)
        args = Symbolics.arguments(raw)
        if index !== nothing
            # Benchmarks here use the full ordered coordinate list for each field.
            length(args) == length(ivs) || throw(ArgumentError("partial-coordinate fields are unsupported by this audit gate"))
            values = reference(Symbolics.Num.(args))
            length(values) == length(dvs) || throw(DimensionMismatch("reference output order/dimension must match declared fields"))
            replacements[Symbolics.Num(raw)] = values[index]
        else
            foreach(visit,args)
        end
    end
    visit(expression)
    # Ordinary substitute deliberately treats Differential applications as opaque.
    Symbolics.expand_derivatives(Symbolics.substitute_in_deriv(expression,replacements))
end

function check_reference(reference, ivs, dvs, equations, conditions, points;
        atol, rtol, parameters=Dict())
    isempty(points) && throw(ArgumentError("explicit nonempty reference sample required"))
    isempty(equations) && throw(ArgumentError("governing equations required"))
    isfinite(atol) && atol>0 && isfinite(rtol) && rtol>=0 || throw(ArgumentError("explicit finite tolerances required"))
    length(reference(first(points))) == length(dvs) || throw(DimensionMismatch("reference output dimension mismatch"))
    maximum_residual = 0.0
    for (kind, identities) in ((:equation,equations),(:condition,conditions))
        for (i, identity) in enumerate(identities)
            lhs = replace_fields(identity.lhs,reference,ivs,dvs)
            rhs = replace_fields(identity.rhs,reference,ivs,dvs)
            for point in points
                length(point)==length(ivs) || throw(DimensionMismatch("reference coordinate dimension mismatch"))
                substitutions = merge(Dict(zip(ivs,point)),parameters)
                numeric(expr) = try
                    Float64(Symbolics.value(Symbolics.substitute(expr,substitutions;fold=Val(true))))
                catch
                    throw(ArgumentError("unresolved $kind $i after reference substitution"))
                end
                left,right = numeric(lhs),numeric(rhs)
                residual = abs(left-right)
                isfinite(residual) && residual <= atol + rtol*max(abs(left),abs(right)) ||
                    throw(ArgumentError("inconsistent reference: $kind $i at $point, residual=$residual"))
                maximum_residual = max(maximum_residual,residual)
            end
        end
    end
    PropertyResult((equation_count=length(equations),condition_count=length(conditions),
        sample_count=length(points),maximum_residual=maximum_residual,atol=atol,rtol=rtol),
        :heuristic,:sampled_reference_substitution,
        ["Actual declared equations and conditions checked at finite explicit points only.",
         "Requires symbolic-compatible full-coordinate reference fields; not a continuum proof."])
end
end
