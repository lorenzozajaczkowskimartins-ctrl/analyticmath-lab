module AnalyticMathLabMollyExt
import AnalyticMathLab as AML
import Molly
import LinearAlgebra
import Unitful

# A lazy view of atom types; never allocate an O(N) metadata copy implicitly.
struct AtomTypes{A} <: AbstractVector{Any}
    atoms::A
end
Base.size(a::AtomTypes)=size(a.atoms)
Base.getindex(a::AtomTypes,i::Int)=a.atoms[i].atom_type
Base.IndexStyle(::Type{<:AtomTypes})=IndexLinear()

function require_cpu(sys)
    Molly.is_on_gpu(sys) && throw(ArgumentError("M8A scalar analysis does not support GPU systems; explicitly transfer upstream if desired."))
    # Fail closed for device or unknown array wrappers, before scalar access.
    all(a->a isa Array,(sys.coords,sys.velocities,sys.atoms,sys.masses)) ||
        throw(ArgumentError("M8A Molly adapter requires CPU Array storage; no implicit host copies are made."))
end
function boundary_record(b)
    if b isa Union{Molly.CubicBoundary,Molly.RectangularBoundary}
        L=b.side_lengths
        all(isinf,L) && return (kind=:open,)
        all(isfinite,L) && return (kind=:orthorhombic,lengths=L)
    end
    (kind=:unsupported,backend_type=string(typeof(b)))
end

"""
    atomistic_snapshot(sys::Molly.System; observables=false, time=nothing, copy_data=false, n_threads=1)

Borrow CPU coordinates, velocities, cached masses and atom-type metadata. Replacing
System fields does not retarget this snapshot. Mutating borrowed arrays is visible.
`observables=true` explicitly computes configured Molly energy/forces at step zero;
time is metadata only, not an interaction step. No integrator or force engine is
implemented here. Backend failures propagate. Infinite/mixed or triclinic geometry
is not silently represented as fully periodic. copy_data=true owns particle data.
"""
function AML.atomistic_snapshot(sys::Molly.System;observables=false,time=nothing,copy_data=false,n_threads=1)
    require_cpu(sys)
    b=sys.boundary
    boundary=boundary_record(b)
    # Molly's image search assumes wrapped coordinates; wrap temporary vectors
    # through its own geometry API, leaving every borrowed array untouched.
    distance=(a,c)->LinearAlgebra.norm(Molly.vector(Molly.wrap_coords(a,b),Molly.wrap_coords(c,b),b))
    AML.AtomisticSnapshot(sys.coords;velocities=sys.velocities,masses=Molly.masses(sys),
        species=AtomTypes(sys.atoms),dimension=Molly.AtomsBase.n_dimensions(b),boundary,time,copy_data,
        provenance=(source=:Molly,version=pkgversion(Molly),storage=copy_data ? :owned : :borrowed,
            units=sys.energy_units==Unitful.NoUnits ? :unknown : :unitful,
            species=:atom_type,observable_step=observables ? 0 : nothing),
        potential_energy=observables ? Molly.potential_energy(sys;n_threads) : nothing,
        forces=observables ? Molly.forces(sys;n_threads) : nothing,distance)
end

"""
    atomistic_trajectory(sys::Molly.System; fixed_box=false, times=nothing,
                         coordinate_logger=sys.loggers.coords,
                         velocity_logger=get(sys.loggers,:velocities,nothing))

Lazy view of existing CPU logger frames, without collecting coordinate history.
Requires explicit `fixed_box=true`: caller asserts that box, masses, species and
particle ordering stayed fixed for the entire selected history. Molly does not
record box history or global times. Supply actual times; no dt/stride inference is
made (simulate! restarts local steps on every call). Matching strides/counts do not
prove logger synchronization: caller must use loggers from the same calls.
Standard Molly loggers already copied coordinates while logging; this adapter does
not copy them again. View length is captured; existing frame mutations remain visible.
"""
function AML.atomistic_trajectory(sys::Molly.System;fixed_box=false,times=nothing,
        coordinate_logger=get(sys.loggers,:coords,nothing),velocity_logger=get(sys.loggers,:velocities,nothing))
    require_cpu(sys)
    fixed_box===true || throw(ArgumentError("Explicit fixed_box=true assertion required; historical boxes are not stored by Molly coordinate loggers."))
    coordinate_logger isa Molly.GeneralObservableLogger && coordinate_logger.observable===Molly.coordinates_wrapper ||
        throw(ArgumentError("A Molly CoordinatesLogger is required."))
    coords=values(coordinate_logger)
    vel=if velocity_logger===nothing
        nothing
    else
        velocity_logger isa Molly.GeneralObservableLogger && velocity_logger.observable===Molly.velocities_wrapper ||
            throw(ArgumentError("velocity_logger must be a Molly VelocitiesLogger or nothing."))
        velocity_logger.n_steps==coordinate_logger.n_steps || throw(ArgumentError("Coordinate and velocity logger strides differ."))
        length(values(velocity_logger))==length(coords) || throw(DimensionMismatch("Logger frame counts differ."))
        values(velocity_logger)
    end
    if times!==nothing
        length(times)==length(coords) || throw(DimensionMismatch("Time count differs from frame count."))
        all(AML._at_finite,times) && issorted(times) || throw(ArgumentError("Explicit times must be finite and nondecreasing."))
    end
    s=AML.atomistic_snapshot(sys)
    frame(i)=AML.AtomisticSnapshot(coords[i];velocities=vel===nothing ? nothing : vel[i],
        masses=s.masses,species=s.species,dimension=s.dimension,boundary=s.boundary,
        time=times===nothing ? nothing : times[i],distance=s.distance,provenance=s.provenance)
    AML.AtomisticTrajectoryView(length(coords),frame;times,
        provenance=(source=:Molly,version=pkgversion(Molly),stride=coordinate_logger.n_steps,
            fixed_box=:caller_asserted,fixed_particles=:caller_asserted,times=times===nothing ? :unknown : :caller_supplied,
            storage=:borrowed_logger_frames))
end

"""Borrow a captured-length view of a stored Molly scalar logger. Explicit times
are caller-supplied global times; stride alone never implies dt. Temperature is
the logged backend convention 2K/(df*k), not recomputed using current metadata.
The caller must ensure scalar and coordinate loggers share simulation calls.
"""
function AML.observable_series(logger::Molly.GeneralObservableLogger;times=nothing,
        interval=nothing,index_time=false,provenance=NamedTuple())
    name=if logger.observable===Molly.total_energy_wrapper
        :total_energy
    elseif logger.observable===Molly.potential_energy_wrapper
        :potential_energy
    elseif logger.observable===Molly.kinetic_energy_wrapper
        :kinetic_energy
    elseif logger.observable===Molly.temperature_wrapper
        :temperature
    else
        throw(ArgumentError("Only stored Molly energy/temperature scalar loggers are supported."))
    end
    metadata=merge(provenance,(source=:Molly,version=pkgversion(Molly),stride=logger.n_steps,
        storage=:borrowed_logger_values,temperature_convention=name==:temperature ? :Molly_backend_df : :not_applicable,
        historical_dof=:not_stored,synchronization=:caller_responsibility))
    AML.ObservableSeries(view(values(logger),1:length(values(logger)));times,interval,index_time,name,provenance=metadata)
end
end
