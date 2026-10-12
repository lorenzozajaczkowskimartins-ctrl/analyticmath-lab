# Normal modes: diagonalizing coupled motion

[Learning path](index.md) · Previous: [mechanics](mechanics.md) · Next: [ODEs](odes.md)

Prerequisites: matrices, eigenvectors and harmonic motion. Difficulty: intermediate.
Dependencies: AnalyticMathLab and LinearAlgebra (declared stdlib).
Executable: [normal_modes.jl](scripts/normal_modes.jl). From the repository root:

```sh
julia +1.12.7 --project=. docs/tutorials/scripts/normal_modes.jl
```

## Model and independent solution

Use the unchanged [canonical oscillator](../../examples/integration/one_system_many_methods.jl):
ordered displacements $(q_1,q_2)$, unit mass and anchor stiffness, unit coupling.
All quantities and time are dimensionless. Its quadratic potential is

$$V=\tfrac12(q_1^2+q_2^2)+\tfrac12(q_2-q_1)^2=\tfrac12q^TKq,\quad
M=I,\quad K=\begin{pmatrix}2&-1\\-1&2\end{pmatrix}.$$

For constant symmetric mass/stiffness matrices and no damping,
$M\ddot q+Kq=0$. The complex ansatz $q=a e^{i\omega t}$ implies

$$Ka=\omega^2Ma.$$

The physical real motion is a real combination of sine/cosine mode amplitudes.
This is a generalized symmetric eigenproblem: ordinary eigenvectors of $K$ alone
are insufficient when $M\ne I$. Stable mass weighting requires positive-definite $M$.

Direct matrix multiplication verifies the symmetric and antisymmetric directions

$$a_s=\frac1{\sqrt2}(1,1)^T,\qquad a_a=\frac1{\sqrt2}(1,-1)^T,$$

with squared angular frequencies 1 and 3; the angular frequencies are $1,\sqrt3$.
Mass-normalized modes obey $\Phi^TM\Phi=I$ and express $q=\Phi z$.
Then each modal coordinate satisfies $\ddot z_i+\omega_i^2z_i=0$.

## Implementation and invariants

Supply small explicit matrices rather than constructing a high-dimensional symbolic
Hessian. Verify eigenpair residuals and mass orthogonality independently of AML's
own diagnostic fields. Eigenvector signs are arbitrary; compare directions modulo
sign, not literal entries. This spectrum is nondegenerate.

```julia
using AnalyticMathLab, LinearAlgebra

# The unchanged capstone's dimensionless mass and stiffness matrices.
K = [2.0 -1.0; -1.0 2.0]
M = [1.0 0.0; 0.0 1.0]
reference_modes = [1.0 1.0; 1.0 -1.0]/sqrt(2.0)
reference_eigenvalues = [1.0, 3.0]
@assert maximum(abs, K*reference_modes - M*reference_modes*Diagonal(reference_eigenvalues)) <= 1e-14
modes = normal_modes(K, M; equilibrium=(0, 0), max_memory_bytes=1024^2)
@assert modes.evidence.status == :heuristic && modes.evidence.value === true
@assert size(modes.mode_vectors) == (2, 2)
@assert maximum(abs, modes.eigenvalues - reference_eigenvalues) <= 1e-12
@assert maximum(abs, modes.frequencies - [1.0, sqrt(3.0)]) <= 1e-12
residual = maximum(abs, K*modes.mode_vectors - M*modes.mode_vectors*Diagonal(modes.eigenvalues))
orthogonality = maximum(abs, modes.mode_vectors'*M*modes.mode_vectors - I)
# Compare directions modulo eigenvector sign; each column is a distinct mode here.
alignment = abs.(diag(reference_modes'*M*modes.mode_vectors))
@assert residual <= 1e-12
@assert orthogonality <= 1e-12
@assert maximum(abs, alignment .- 1) <= 1e-12
@assert modes.classifications == [:oscillatory, :oscillatory]
println((squared_frequencies=modes.eigenvalues, angular_frequencies=modes.frequencies,
    residual=residual, mass_orthogonality=orthogonality, sign_independent_alignment=alignment))
println("NORMAL_MODES_OK")
```

## Verification and observed results

ANALYTICAL_REFERENCE: direct multiplication of the displayed reference directions
establishes the two eigenvalues, independently of AML's eigensolver.
NUMERICAL_COMPARISON: maximum absolute eigenvalue/frequency discrepancy,
eigenpair-entry residual, mass-orthogonality-entry discrepancy and sign-independent
alignment error are each checked at $10^{-12}$ (reference multiplication at $10^{-14}$).
EXAMPLE_EXECUTED: frequencies were `[1.0,1.7320508075688772]`, residual 0,
mass-orthogonality discrepancy $2.22\times10^{-16}$, and each direction's absolute
mass inner product with its reference was `0.9999999999999998`.
The modal evidence remains `:heuristic`: a floating-point full spectrum is not
an exact multiplicity or certified-error result.

For repeated eigenvalues, any mass-orthonormal basis of the degenerate eigenspace
is valid; compare subspaces, not unique shapes. SOURCE_INSPECTED: AML classifies
near-zero values using its recorded spectral threshold, labels negative values
`:unstable` with frequency `missing`, zero-classified values with frequency 0,
and positive values `:oscillatory`. A negative squared frequency corresponds to
exponential linear growth/decay, not a real oscillation. Numerical zero modes do
not by themselves identify translations, rotations or constraints.

## Limits and physical meaning

For a nonlinear mechanical model this method describes small perturbations about
a verified smooth equilibrium. Local oscillatory motion is not a proof of global
nonlinear stability. Nonzero damping needs a different eigenproblem; the present
mechanical adapter does not silently solve it.

SOURCE_INSPECTED: `normal_modes(K,M)` performs a full dense spectral analysis.
Sparse inputs do not choose a sparse eigensolver. `max_memory_bytes` is an
operation-specific estimate, not a peak process-RSS bound; adapter allocations
can precede the matrix preflight. No generic public partial-spectrum API is
available. Our $2\times2$ example uses a one-MiB estimate budget, not a stress test.

Continue to [numerical evolution](odes.md) and the
[integrated investigation](one-system-many-methods.md).
[Mechanics/mode contracts](../mechanics.md) ·
[Execution record](../../reports/m10d6/tutorial_implementation_report.md).
