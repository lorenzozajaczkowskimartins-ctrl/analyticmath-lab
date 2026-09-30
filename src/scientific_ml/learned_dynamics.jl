"""Derivative observations, columns are states in canonical `(q...,p...)` order."""
struct DerivativeData{X,Y}
    states::X
    derivatives::Y
    function DerivativeData(x::AbstractMatrix,y::AbstractMatrix)
        size(x)==size(y) || throw(DimensionMismatch("states and derivatives must have equal sizes"))
        !isempty(x) && all(isfinite,x) && all(isfinite,y) || throw(ArgumentError("finite nonempty observations required"))
        new{typeof(x),typeof(y)}(x,y)
    end
end
"""One observed trajectory; training uses only these states and observation times."""
struct TrajectoryData{T,Y}
    times::T
    states::Y
    function TrajectoryData(t::AbstractVector,y::AbstractMatrix)
        length(t)==size(y,2) || throw(DimensionMismatch("one state column per time required"))
        length(t)>=2 && size(y,1)>0 && all(isfinite,t) && all(isfinite,y) && all(diff(t).>0) ||
            throw(ArgumentError("finite states and strictly increasing times required"))
        new{typeof(t),typeof(y)}(t,y)
    end
end
"""Scalar Lux Hamiltonian with the M7 canonical structure, not its analytic energy as a training target."""
struct HamiltonianNN{A,N,P,S}
    mechanics::A
    network::N
    parameters::P
    state::S
end
"""Known M6 ODE plus a separately inspectable Lux correction on selected components."""
struct UDEProblem{O,N,P,S,I}
    known::O
    network::N
    parameters::P
    state::S
    correction_indices::I
    function UDEProblem(known::FirstOrderODE,network,parameters,state; correction_indices=Tuple(1:known.dimension))
        ids=Tuple(correction_indices)
        !isempty(ids) && all(i->i isa Integer && 1<=i<=known.dimension,ids) && length(unique(ids))==length(ids) ||
            throw(ArgumentError("correction indices must be unique valid components"))
        new{typeof(known),typeof(network),typeof(parameters),typeof(state),typeof(ids)}(known,network,parameters,state,ids)
    end
end
"""Native optimizer result, explicit fitted Lux container/state and bounded objective history."""
struct DynamicsTrainingResult{M,S,H,P}
    model::M
    solution::S
    history::H
    provenance::P
end
function learned_energy end
function learned_vector_field end
function learned_correction end
function dynamics_objective end
function aligned_energy end
