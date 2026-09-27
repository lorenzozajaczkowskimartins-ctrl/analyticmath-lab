### A Pluto.jl notebook ###
# Executable with: julia +release --project=. notebooks/trajectory_comparison.jl
# No simulation: explicitly supplied synthetic data -> M8B -> stored M8C results.
using AnalyticMathLab, Unitful

# Dataset construction and ALL M8B computations happen before comparison.
times=(0:7)u"ps"
series_a=ObservableSeries([1.,4.,2.,3.,7.,5.,2.,4.]u"J";
    name=:total_energy,times,provenance=(dataset=:synthetic_A,ensemble=:NVE))
series_b=ObservableSeries([2.,6.,3.,5.,8.,4.,3.,6.]u"J";
    name=:total_energy,times,provenance=(dataset=:synthetic_B,ensemble=:NVE))
# A metadata-only trajectory demonstrates high-level composition. Its frames must
# never be read because the requested observables are supplied explicitly.
frames=AtomisticTrajectoryView(length(times),i->error("No frame access required");times)
report_a=analyze(frames;series=(energy=series_a,),correlations=(:energy,),window=1,maxlag=3)
report_b=analyze(frames;series=(energy=series_b,),correlations=(:energy,),window=1,maxlag=3)
short_b=autocorrelation(series_b;maxlag=2)
kinetic=ObservableSeries(series_b.values;name=:kinetic_energy,times)
kinetic_summary=statistical_summary(kinetic)

# M8C starts here. These calls only consume existing results and metadata.
runs=compare_runs(report_a,report_b;components=(:summaries,:correlations),labels=("A","B"))
mean_comparison=runs.components[:summaries][:energy]
unknown_uncertainty=runs.components[:correlations][:energy]
@assert mean_comparison.compatibility.status==:compatible
@assert unknown_uncertainty.difference.value!==nothing
@assert unknown_uncertainty.uncertainty.value===nothing

# Conditional illustration: the assertion is explicit, not inferred from labels.
# These synthetic sequences are not evidence of independently sampled simulations.
conditional=compare(unknown_uncertainty.a,unknown_uncertainty.b;independence=:independent)
@assert conditional.uncertainty.value!==nothing
incompatible=compare(mean_comparison.a,ComparisonInput(kinetic_summary;series=kinetic))
@assert incompatible.compatibility.status==:incompatible

ac_a=ComparisonInput(report_a.correlations[:energy].value.correlation;series=series_a,label="A")
ac_b=ComparisonInput(report_b.correlations[:energy].value.correlation;series=series_b,label="B")
curve=compare(ac_a,ac_b)
refused=compare(ac_a,ComparisonInput(short_b;series=series_b,label="B shorter lag range"))
@assert curve.compatibility.status==:compatible
@assert refused.compatibility.status==:incompatible
@assert refused.difference.value===nothing
@assert Base.get_extension(AnalyticMathLab,:AnalyticMathLabMollyExt)===nothing

# Caller selects the static backend AFTER all comparison computations.
using CairoMakie
CairoMakie.activate!()
out=isempty(ARGS) ? joinpath(@__DIR__,"output") : first(ARGS)
mkpath(out)
save(joinpath(out,"m8c_overlay.png"),comparisonplot(curve))
save(joinpath(out,"m8c_difference.png"),differenceplot(curve))
save(joinpath(out,"m8c_conditional_uncertainty.png"),differenceplot(conditional))
save(joinpath(out,"m8c_refused_alignment.png"),comparisonplot(refused))
println("M8C: compatible mean B-A = ",mean_comparison.difference.value)
println("Default propagated uncertainty = ",unknown_uncertainty.uncertainty.status)
println("Conditional independent-estimator SE = ",conditional.uncertainty.value)
println("Identity mismatch = ",incompatible.compatibility.status,
    "; unequal grids = ",refused.compatibility.status)
println("Saved four static comparison figures to ",abspath(out))
