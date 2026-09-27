"""Stored PINN construction, retaining the original symbolic system and native backends.
All objects are read-only by convention. Construction evidence is not solution evidence.
"""
struct PINNProblem <: AbstractAnalysis
    system
    independent_variables
    dependent_variables
    domains
    equations
    boundary_conditions
    networks
    network_mapping
    initial_parameters
    initial_states
    strategy
    discretization
    symbolic_discretization
    optimization_problem
    backend_metadata
    loss_components
    provenance
    evidence::PropertyResult
end

"""Bounded scalar training observations; no parameter snapshots.
Entries retain backend iteration, objective and optionally unweighted component costs.
When capacity is exhausted, retain the first entries and set `truncated=true`.
"""
mutable struct PINNHistory <: AbstractAnalysis
    entries::Vector{NamedTuple}
    stride::Int
    capacity::Int
    truncated::Bool
    function PINNHistory(;stride::Integer=10,capacity::Integer=1000)
        stride>0 || throw(ArgumentError("history stride must be positive"))
        capacity>0 || throw(ArgumentError("history capacity must be positive"))
        new(NamedTuple[],Int(stride),Int(capacity),false)
    end
end

"""Training result: optimizer termination is separate from unestablished physical accuracy.
`parameters` are the native optimization vector; `network_parameters` are Lux containers
in unique-network order. The backend solution and actual optimization problem remain exposed.
"""
struct PINNTrainingResult <: AbstractAnalysis
    problem::PINNProblem
    optimization_problem
    solution
    backend_solution
    parameters
    network_parameters
    states
    history
    losses::PropertyResult
    termination
    optimizer
    provenance
    evidence::PropertyResult
    notes::Vector{String}
end

function _pinn_extension()
    ext=Base.get_extension(@__MODULE__,:AnalyticMathLabPINNExt)
    ext===nothing && throw(ArgumentError("Load Lux, NeuralPDE, ModelingToolkit and Optimization to activate the optional AnalyticMathLab PINN extension; see docs/scientific_ml.md."))
    ext
end

"""Build a genuine Lux dense model. Requires the optional PINN extension."""
pinn_network(args...;kwargs...)=_pinn_extension().pinn_network(args...;kwargs...)
"""Construct a PINN from a ModelingToolkit PDESystem using explicit network, strategy, RNG and AD choice."""
pinn_problem(args...;kwargs...)=_pinn_extension().pinn_problem(args...;kwargs...)
"""Train with Optimization.jl; `maxiters` is required. Low training loss is not proof of a correct physical solution."""
train(p::PINNProblem,optimizer;kwargs...)=_pinn_extension().train(p,optimizer;kwargs...)
"""Explicit continuation from trained parameters, not an automatic optimizer schedule."""
train(r::PINNTrainingResult,optimizer;kwargs...)=_pinn_extension().train(r,optimizer;kwargs...)
"""Evaluate in stored independent-variable order. Vector in → dependent-variable vector;
matrix (coordinates × points) in → matrix (dependent variables × points) out.
"""
predict(r::PINNTrainingResult,x)=_pinn_extension().predict(r,x)

"""Inspect retained scientific and backend objects, without discretizing or training again."""
function pinn_inspect(p::PINNProblem)
    (system=p.system,independent_variables=p.independent_variables,
        dependent_variables=p.dependent_variables,domains=p.domains,equations=p.equations,
        boundary_conditions=p.boundary_conditions,networks=p.networks,
        network_mapping=p.network_mapping,initial_parameters=p.initial_parameters,
        initial_states=p.initial_states,strategy=p.strategy,discretization=p.discretization,
        symbolic_discretization=p.symbolic_discretization,optimization_problem=p.optimization_problem,
        backend_metadata=p.backend_metadata,loss_components=p.loss_components,
        provenance=p.provenance,evidence=p.evidence)
end
function pinn_inspect(r::PINNTrainingResult)
    (construction=pinn_inspect(r.problem),optimization_problem=r.optimization_problem,
        solution=r.solution,backend_solution=r.backend_solution,parameters=r.parameters,
        network_parameters=r.network_parameters,states=r.states,history=r.history,
        losses=r.losses,termination=r.termination,optimizer=r.optimizer,
        provenance=r.provenance,evidence=r.evidence)
end

function lossplot end
