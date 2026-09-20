"""Local EL coefficients in `M*δq̈ + C*δq̇ + K*δq = 0`.

Matrices retain symbolic/exact coefficients. `evidence` establishes a usable
linearization only after both equilibrium and original open smooth domain checks.
An unsupported check returns `:unknown`, never an implicit domain extension.
"""
struct MechanicalLinearization <: AbstractAnalysis
    source::LagrangianAnalysis
    equilibrium::Tuple
    mass_matrix
    damping_matrix
    stiffness_matrix
    residual
    domain::MultivariateDomain
    equilibrium_evidence::PropertyResult
    domain_evidence::PropertyResult
    evidence::PropertyResult
    metadata::NamedTuple
end

"""
    linearize_mechanics(report, equilibrium; parameters=Dict())

Differentiate the stored Euler–Lagrange residual with respect to acceleration,
velocity and coordinate, then evaluate at `(equilibrium,0,0)`. Equilibrium is
checked by an exact simplified-zero identity (no residual tolerance). Parameters
are bound with the bridge's no-override contract. Explicit-time reports and
unbound source-domain parameters remain structured unknown. Formal matrices are
retained even when their applicability is unknown. No dynamics solver is run.
"""
function linearize_mechanics(source::LagrangianAnalysis,equilibrium;parameters=Dict())
    n = length(source.coordinates)
    equilibrium isa Union{Tuple,AbstractVector} || throw(ArgumentError("equilibrium must be a tuple or vector"))
    length(equilibrium) == n || throw(DimensionMismatch("equilibrium dimension must match coordinates"))
    all(x->x isa Real && !(x isa Symbolics.Num) && isfinite(x),equilibrium) ||
        throw(ArgumentError("equilibrium coordinates must be finite real constants"))
    r = _mechanics_bound_report(source,parameters)
    q,v,a = r.coordinates,r.velocities,r.acceleration_symbols
    bindings = Dict(Symbol(_mv_ast(k))=>val for (k,val) in r.parameters)
    originals = [r.original_expression,r.system.original_rayleigh,r.system.original_forces...]
    syntax = [_mc_substitute_ast(o,bindings) for o in originals]
    append!(syntax,[Expr(:call,:/,1,_mc_substitute_ast(_mc_original(x),bindings)) for x in r.nonzero])
    carrier = Expr(:call,:+,syntax...)
    vars = (q...,v...)
    domain = _mv_domain(carrier,vars)
    point = (equilibrium...,zeros(Int,n)...)
    membership = domain_contains(domain,point)
    smooth = _mv_smooth((domain=domain,variables=vars,original_expression=carrier),point)
    subs = Dict{Any,Any}(q .=> equilibrium)
    merge!(subs,Dict(v .=> zeros(Int,n)),Dict(a .=> zeros(Int,n)))
    function at(e)
        # Never evaluate derivatives at a known excluded point. Unresolved
        # symbolic parameters can still retain useful formal local coefficients.
        membership === false && return e
        x = try
            _mc_simp(Symbolics.substitute(e,subs;fold=Val(true)))
        catch err
            err isa DomainError || rethrow()
            return e
        end
        value = x isa Symbolics.Num ? Symbolics.value(x) : x
        value isa Real && !(value isa Symbolics.Num) ? value : x
    end
    M = [at(_mc_diff(r.equations[i],a[j])) for i in 1:n,j in 1:n]
    C = [at(_mc_diff(r.equations[i],v[j])) for i in 1:n,j in 1:n]
    K = [at(_mc_diff(r.equations[i],q[j])) for i in 1:n,j in 1:n]
    residual = at.(r.equations)
    eq = all(_mc_zero,residual) ? _mc_proven(true,:exact_equilibrium_residual) :
        _mc_unknown("Zero equilibrium EL residual was not established.")

    dom = smooth ? _mc_proven(true,:original_smooth_neighborhood) :
        _mc_unknown("Original domain or open smooth neighborhood is unresolved or excluded; bind remaining parameters.")
    evidence = r.time !== nothing ? _mc_unknown("Explicit-time mechanical linearization is unsupported.") :
        eq.status == :established && dom.status == :established ?
            _mc_proven(true,:local_euler_lagrange_derivatives) : _mc_unknown("Equilibrium and original smooth domain must both be established.")
    MechanicalLinearization(r,tuple(equilibrium...),M,C,K,residual,domain,eq,dom,evidence,
        (coordinates=q,velocities=v,parameters=copy(r.parameters),representation=:coordinate_displacements))
end
linearize_mechanics(s::LagrangianSystem,equilibrium;kwargs...) = linearize_mechanics(analyze(s),equilibrium;kwargs...)

"""Undamped generalized modes, with independent evidence and diagnostics.

`mode_vectors` are coordinate columns Φ; `weighted_vectors` are Euclidean
orthonormal columns U=M^(1/2)Φ. `reconstruction` is the reconstructed stiffness
M^(1/2) U diag(λ) U' M^(1/2). `eigenvalues` retain raw signed λ=ω²;
negative modes have `missing` frequencies, not fabricated real oscillations.
Unknown reports have `nothing` numerical fields, not an empty certified spectrum.
"""
struct NormalModeAnalysis <: AbstractAnalysis
    source
    equilibrium
    mass_matrix
    stiffness_matrix
    eigenvalues
    frequencies
    mode_vectors
    weighted_vectors
    mass_sqrt
    mass_inverse_sqrt
    dynamical_matrix
    normalization::Symbol
    representation::Symbol
    reconstruction
    degeneracies
    zero_modes
    classifications
    evidence::PropertyResult
    metadata::NamedTuple
end

function _nm_unknown(K,M,equilibrium,metadata,note;source=nothing)
    NormalModeAnalysis(source,equilibrium,M,K,nothing,nothing,nothing,nothing,
        nothing,nothing,nothing,:mass_orthonormal,:coordinate_displacements,
        nothing,nothing,nothing,nothing,_mc_unknown(note),metadata)
end

function _nm_numeric(A)
    out = Matrix{Float64}(undef,size(A))
    for i in eachindex(A)
        x = A[i] isa Symbolics.Num ? Symbolics.value(A[i]) : A[i]
        x isa Real && !(x isa Symbolics.Num) || return nothing
        y = try Float64(x) catch; return nothing end
        isfinite(y) || return nothing
        iszero(y) && !iszero(x) && return nothing
        out[i] = y
    end
    out
end

function _nm_symmetrize(A)
    B = copy(A)
    for j in axes(A,2), i in firstindex(A,1):j-1
        a,b = A[i,j],A[j,i]
        # Preserve diagonal/equal subnormals; avoid overflow for opposite signs.
        midpoint = a == b ? a : signbit(a) == signbit(b) ? a+(b-a)/2 : a/2+b/2
        B[i,j] = B[j,i] = midpoint
    end
    B
end

function _nm_matrix_evidence(A)
    symbolic = any(x->x isa Symbolics.Num,A)
    exact = all(x->x isa Union{Integer,Rational},A)
    method = symbolic ? :symbolic_input : exact ? :exact_input : :numerical_input
    PropertyResult(nothing,:established,method,
        ["Describes supplied coefficients only, not a proof of equilibrium or exact spectral values."])
end

"""
    normal_modes(K, M; equilibrium=nothing, metadata=NamedTuple(),
                 atol=1e-10, rtol=1e-8)

Generic finite real symmetric K and symmetric positive-definite M. Full masses
are supported via the principal symmetric square root, not elementwise scaling.
Computations deliberately use Float64 LAPACK and are `:heuristic`, even when the
inputs are exact. No molecular-dynamics dependency or integration is involved.

Symmetry is accepted when the infinity-norm discrepancy is at most
`atol + rtol*opnorm(A,Inf)`; accepted inputs are symmetrized. Mass positivity
requires successful Cholesky and eigenvalues above `n*eps(Float64)*maximum(abs,μ)`;
unresolved numerical rank (including very ill-conditioned SPD matrices) is unknown.
Spectral zeros use `abs(λ) <= atol + rtol*maximum(abs,λ)`.
Values below minus this threshold are unstable (`frequency=missing`); tiny signed
values within it are numerical zero modes, NOT certified exact zero eigenvalues.
Degenerate groups use the same spectral threshold relative to the first member
of each group. Raw eigenvalues are never clamped. Vectors inside a degenerate
subspace are nonunique. All thresholds and numerical residuals are metadata.
"""
function normal_modes(K::AbstractMatrix,M::AbstractMatrix;equilibrium=nothing,
        metadata=NamedTuple(),atol::Real=1e-10,rtol::Real=1e-8)
    n = size(K,1)
    size(K) == size(M) == (n,n) && n > 0 || throw(DimensionMismatch("K and M must be equal nonempty square matrices"))
    all(x->isfinite(x) && x>=0,(atol,rtol)) || throw(ArgumentError("tolerances must be finite and nonnegative"))
    at,rt = Float64(atol),Float64(rtol)
    all(isfinite,(at,rt)) || throw(ArgumentError("tolerances must be representable as Float64"))
    if equilibrium !== nothing
        equilibrium isa Union{Tuple,AbstractVector} && length(equilibrium)==n || throw(DimensionMismatch("equilibrium dimension differs"))
        all(x->x isa Real && !(x isa Symbolics.Num) && isfinite(x),equilibrium) || throw(ArgumentError("equilibrium must be finite real"))
        equilibrium = tuple(equilibrium...)
    end
    meta = merge(metadata isa NamedTuple ? deepcopy(metadata) : NamedTuple(),
        (user=deepcopy(metadata),arithmetic=:Float64,atol=at,rtol=rt,
         matrix_evidence=(mass=_nm_matrix_evidence(M),stiffness=_nm_matrix_evidence(K)),
         reconstruction_convention=:a_equals_mass_inverse_sqrt_times_e,
         zero_mode_categories=Dict{Int,Symbol}()))
    unknown(note) = _nm_unknown(copy(K),copy(M),equilibrium,meta,note)
    Kn,Mn = _nm_numeric(K),_nm_numeric(M)
    (Kn === nothing || Mn === nothing) && return unknown("Bind all parameters to finite Float64-representable real coefficients.")
    ks,ms = LinearAlgebra.opnorm(Kn,Inf),LinearAlgebra.opnorm(Mn,Inf)
    kt,mt = at+rt*ks,at+rt*ms
    all(isfinite,(ks,ms,kt,mt)) || return unknown("Nonfinite symmetry scale or threshold.")
    LinearAlgebra.opnorm(Kn-Kn',Inf) <= kt || return unknown("Stiffness matrix is not symmetric within tolerance.")
    LinearAlgebra.opnorm(Mn-Mn',Inf) <= mt || return unknown("Mass matrix is not symmetric within tolerance.")
    Kn,Mn = _nm_symmetrize(Kn),_nm_symmetrize(Mn)
    LinearAlgebra.isposdef(LinearAlgebra.Symmetric(Mn)) || return unknown("Mass Cholesky factorization did not establish positive definiteness.")
    mass = LinearAlgebra.eigen(LinearAlgebra.Symmetric(Mn))
    mass_threshold = n*eps(Float64)*maximum(abs,mass.values)
    all(x->isfinite(x) && x>mass_threshold,mass.values) || return unknown("Mass positivity/numerical rank is unresolved; singular, indefinite or numerically ill-conditioned masses are unsupported.")
    S = mass.vectors*LinearAlgebra.Diagonal(sqrt.(mass.values))*mass.vectors'
    B = mass.vectors*LinearAlgebra.Diagonal(inv.(sqrt.(mass.values)))*mass.vectors'
    D = B*Kn*B
    all(isfinite,D) || return unknown("Nonfinite mass-weighted dynamical matrix.")
    D = _nm_symmetrize(D)
    modes = LinearAlgebra.eigen(LinearAlgebra.Symmetric(D))
    λ,U = modes.values,modes.vectors
    all(isfinite,λ) || return unknown("Nonfinite spectrum.")
    threshold = at+rt*maximum(abs,λ)
    isfinite(threshold) || return unknown("Nonfinite spectral threshold.")
    classes = [abs(x)<=threshold ? :zero : x<0 ? :unstable : :oscillatory for x in λ]
    frequencies = Union{Missing,Float64}[c == :unstable ? missing : c == :zero ? 0.0 : sqrt(x) for (x,c) in zip(λ,classes)]
    Φ = B*U
    reconstructed = S*U*LinearAlgebra.Diagonal(λ)*U'*S
    groups = Vector{Int}[]
    for i in eachindex(λ)
        if isempty(groups) || abs(λ[i]-λ[first(last(groups))])>threshold
            push!(groups,[i])
        else
            push!(last(groups),i)
        end
    end
    degeneracy = filter(x->length(x)>1,groups)
    residual = LinearAlgebra.norm(Kn*Φ-Mn*Φ*LinearAlgebra.Diagonal(λ))
    orthogonality = LinearAlgebra.norm(Φ'*Mn*Φ-LinearAlgebra.I)
    reconstruction_residual = LinearAlgebra.norm(reconstructed-Kn)
    all(isfinite,(residual,orthogonality,reconstruction_residual)) || return unknown("Nonfinite eigenpair diagnostics.")
    meta = merge(meta,(spectral_threshold=threshold,mass_rank_threshold=mass_threshold,symmetry_thresholds=(stiffness=kt,mass=mt),
        eigenpair_residual=residual,mass_orthogonality_residual=orthogonality,
        reconstruction_residual=reconstruction_residual,))
    evidence = PropertyResult(true,:heuristic,:mass_weighted_symmetric_eigensolve,
        ["Float64 eigensolve; tolerances classify numerical zeros and degeneracy, not exact multiplicities or certified errors."])
    NormalModeAnalysis(nothing,equilibrium,copy(M),copy(K),λ,frequencies,Φ,U,S,B,D,
        :mass_orthonormal,:coordinate_displacements,reconstructed,degeneracy,
        findall(==(:zero),classes),classes,evidence,meta)
end

"""
    normal_modes(linearization; metadata=NamedTuple(), atol=1e-10, rtol=1e-8)
    normal_modes(report, equilibrium; parameters=Dict(), kwargs...)

Undamped modes only: the local C matrix must simplify identically to zero, not
merely fall below a numerical tolerance. Nonzero damping/gyroscopic terms need a
different quadratic eigenproblem and return unknown. Unverified equilibrium or
source smoothness likewise returns unknown without invoking a solver.
"""
function normal_modes(l::MechanicalLinearization;metadata=NamedTuple(),kwargs...)
    meta = merge(l.metadata,metadata isa NamedTuple ? metadata : (user=metadata,))
    if l.evidence.status != :established || !all(_mc_zero,l.damping_matrix)
        note = l.evidence.status != :established ? "Mechanical linearization is not established on the original smooth domain." :
            "Nonzero damping or gyroscopic matrix: undamped normal modes are unsupported."
        return _nm_unknown(l.stiffness_matrix,l.mass_matrix,l.equilibrium,meta,note;source=l)
    end
    r = normal_modes(l.stiffness_matrix,l.mass_matrix;equilibrium=l.equilibrium,metadata=meta,kwargs...)
    NormalModeAnalysis(l,r.equilibrium,r.mass_matrix,r.stiffness_matrix,r.eigenvalues,
        r.frequencies,r.mode_vectors,r.weighted_vectors,r.mass_sqrt,r.mass_inverse_sqrt,
        r.dynamical_matrix,r.normalization,r.representation,r.reconstruction,
        r.degeneracies,r.zero_modes,r.classifications,r.evidence,r.metadata)
end
function normal_modes(r::Union{LagrangianAnalysis,LagrangianSystem},equilibrium;parameters=Dict(),kwargs...)
    normal_modes(linearize_mechanics(r,equilibrium;parameters=parameters);kwargs...)
end

"""
    cartesian_mass_matrix(masses, d)

Return `Diagonal(repeat(masses; inner=d))`, preserving numeric element type.
Ordering is particle-major: `(x₁,y₁,…,x₂,y₂,…)`. Every mass must be a finite,
strictly positive real constant, and `d` a positive integer. No symbolic positivity
assumption is inferred. Inputs are copied. No geometry, force field or MD engine
is implied by this small linear-algebra helper.
"""
function cartesian_mass_matrix(masses,d)
    masses isa Union{Tuple,AbstractVector} && !isempty(masses) || throw(ArgumentError("masses must be a nonempty tuple or vector"))
    d isa Integer && !(d isa Bool) && d>0 || throw(ArgumentError("Cartesian dimension must be a positive integer"))
    all(x->x isa Real && !(x isa Symbolics.Num) && isfinite(x) && x>0,masses) ||
        throw(ArgumentError("masses must be finite strictly positive real constants"))
    d <= typemax(Int) ÷ length(masses) || throw(ArgumentError("Cartesian matrix dimension overflows Int"))
    LinearAlgebra.Diagonal(repeat(collect(masses);inner=Int(d)))
end
