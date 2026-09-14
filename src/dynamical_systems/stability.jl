"""Jacobian and diagnostic spectrum with a separately scoped local claim."""
struct LocalStabilityAnalysis{M,E}
    matrix::M
    eigenvalues::E
    stability::PropertyResult{Symbol}
end

_ds_unknown(note, method=:unsupported) = PropertyResult(:inconclusive,:unknown,method,[note])
function _ds_rational(x)
    v = _mv_concrete(_vf_simplify(x))
    v isa Integer && return BigInt(v)//BigInt(1)
    v isa Rational && return BigInt(numerator(v))//BigInt(denominator(v))
    return nothing
end

function _ds_sign_class(signs)
    positive = any(>(0),signs); negative = any(<(0),signs)
    positive && return negative ? :saddle : :unstable
    all(<(0),signs) && return :locally_asymptotically_stable
    return :inconclusive
end

# Only rational arithmetic proves signs. No rounded eigensolver result is exact.
function _ds_exact_class(A, f)
    n = size(A,1)
    Q = _ds_rational.(A)
    any(isnothing,Q) && return nothing
    if all(i == j || iszero(Q[i,j]) for i in 1:n, j in 1:n)
        return _ds_sign_class([sign(Q[i,i]) for i in 1:n]), :exact_diagonal
    elseif n == 2
        tr = Q[1,1]+Q[2,2]
        det = Q[1,1]*Q[2,2]-Q[1,2]*Q[2,1]
        det < 0 && return :saddle, :exact_trace_determinant
        det > 0 && tr < 0 && return :locally_asymptotically_stable, :exact_trace_determinant
        (det > 0 && tr > 0 || iszero(det) && tr > 0) && return :unstable, :exact_trace_determinant
        affine = all(isempty(Symbolics.get_variables(e)) for e in f.jacobian_expression)
        if det > 0 && iszero(tr) && affine && f.domain.status == :established && isempty(f.domain.restrictions)
            return :center, :exact_linear_system
        end
        return :inconclusive, :exact_trace_determinant
    end
    return nothing
end

function _ds_local(f,z,status,atol,rtol)
    _vf_smooth(f,z.point) || return LocalStabilityAnalysis(nothing,ComplexF64[],
        _ds_unknown("Original expression has no supported open smooth neighborhood.",:smoothness_gate))
    # Substitute into the stored Jacobian, rather than differentiate again.
    substitutions = Dict(zip(f.variables,z.point))
    A = try
        status == :established ?
            map(e -> _mv_concrete(_vf_simplify(Symbolics.substitute(e,substitutions))), f.jacobian_expression) :
            jacobian(f,z.point)
    catch err
        err isa InterruptException && rethrow()
        return LocalStabilityAnalysis(nothing,ComplexF64[],_ds_unknown(
            "Jacobian evaluation unavailable: " * sprint(showerror,err),:unrepresentable_jacobian))
    end
    eigs = try
        B = Float64.(A)
        all(isfinite,B) || throw(DomainError(B,"unrepresentable Jacobian"))
        values = LinearAlgebra.eigvals(B)
        all(isfinite,values) || throw(DomainError(values,"unrepresentable spectrum"))
        values
    catch err
        err isa InterruptException && rethrow()
        return LocalStabilityAnalysis(A,ComplexF64[],_ds_unknown(
            "Numerical spectrum unavailable; no signs inferred: " * sprint(showerror,err),:unrepresentable_spectrum))
    end
    exact = status == :established ? _ds_exact_class(A,f) : nothing
    if exact !== nothing
        cls,method = exact
        evidence = cls == :inconclusive ? _ds_unknown("Nonhyperbolic linearization does not decide nonlinear local stability.",method) :
            PropertyResult(cls,:established,method,["Local classification at an exact verified equilibrium on the original smooth domain; no global attraction claim."])
        return LocalStabilityAnalysis(A,eigs,evidence)
    end
    scale = max(maximum(abs,eigs),1.0)
    threshold = atol + rtol*scale
    isfinite(threshold) || return LocalStabilityAnalysis(A,eigs,
        _ds_unknown("Classification threshold overflowed; no signs inferred.",:numerical_eigenvalues))
    signs = map(v -> real(v) > threshold ? 1 : real(v) < -threshold ? -1 : 0,eigs)
    cls = _ds_sign_class(signs)
    notes = ["Local numerical linearization only; eigenvalue real-part threshold = $threshold.",
        status == :established ? "Exact equilibrium, but numerical spectrum is not a sign proof." :
        "At an approximate equilibrium: residual acceptance gives no root-position or stability guarantee."]
    evidence = PropertyResult(cls,cls == :inconclusive ? :unknown : :heuristic,:numerical_eigenvalues,notes)
    return LocalStabilityAnalysis(A,eigs,evidence)
end
