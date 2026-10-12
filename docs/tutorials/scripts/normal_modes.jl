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
