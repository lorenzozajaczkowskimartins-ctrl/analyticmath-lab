module HarmonicTutorial
using AnalyticMathLab

# Dimensionless unit-frequency oscillator; ordered state (q,v).
problem = FirstOrderODE((u, t) -> [u[2], -u[1]], 2; labels=("q", "v"))
path = trajectory(problem, [1.0, 0.0], (0.0, 2.0);
    abstol=1e-10, reltol=1e-10, saveat=0.125, dt=0.125)
@assert path.diagnostics.success && path.diagnostics.completed
@assert path.labels == ("q", "v")
times = path.solution.t
states = hcat(path.solution.u...)
@assert size(states) == (2, length(times))
@assert first(times) == 0.0 && last(times) == 2.0
@assert all(diff(times) .> 0)
requested = collect(0.0:0.125:2.0)
@assert all(t -> t in times, requested)
reference = hcat(([cos(t), -sin(t)] for t in times)...)
state_error = maximum(abs, states - reference)
@assert state_error <= 1e-8
# A separate query uses the retained native interpolant, not stored-only extraction.
query = 0.37
interpolation_error = maximum(abs, path.solution(query) - [cos(query), -sin(query)])
@assert interpolation_error <= 1e-8
println((saved_samples=length(times), requested_stops=length(requested),
    accepted=path.diagnostics.accepted_steps, rejected=path.diagnostics.rejected_steps,
    max_saved_state_error=state_error, interpolation_query=query,
    interpolation_error=interpolation_error, labels=path.labels))
println("ODES_OK")
end
