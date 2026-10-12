# Scientific FAQ index

[Home](Home)

All 90 reconciled questions have one authoritative answer. The original wording and Q IDs are preserved; cross-links do not create second answers. Use browser search for Q066 or a subject term. P0/P1 are audit priorities, not maturity classifications.

## Getting Started

- [Q001 — How do I install AML from this checkout?](Getting-Started#user-content-q001) (P1)
- [Q002 — What can I use after only using AnalyticMathLab?](Getting-Started#user-content-q002) (P1)
- [Q003 — Why does the first import take time?](Getting-Started#user-content-q003) (P1)
- [Q004 — Which example should I run first?](Getting-Started#user-content-q004) (P1)
- [Q005 — Do I need to force Julia or BLAS to one thread?](Getting-Started#user-content-q005) (P1)

## Calculus and Symbolics

- [Q006 — Why did simplifying x/x lose the exclusion at zero?](Calculus-and-Symbolics#user-content-q006) (P1)
- [Q007 — Does evaluate enforce the original real domain?](Calculus-and-Symbolics#user-content-q007) (P1)
- [Q008 — Why are some exact roots unknown?](Calculus-and-Symbolics#user-content-q008) (P1)
- [Q009 — Does an empty stationary search prove there are no critical points?](Calculus-and-Symbolics#user-content-q009) (P1)
- [Q010 — Can I analyze a Julia function or a string?](Calculus-and-Symbolics#user-content-q010) (P1)

## Linear Algebra

- [Q011 — Does AML provide general-purpose matrix analysis?](Linear-Algebra#user-content-q011) (P1)
- [Q012 — Why does normal_modes take stiffness before mass?](Linear-Algebra#user-content-q012) (P1)
- [Q013 — Does sparse matrix input imply a sparse eigensolver?](Linear-Algebra#user-content-q013) (P1)
- [Q014 — What do zero, negative and degenerate modes mean?](Linear-Algebra#user-content-q014) (P1)
- [Q015 — Does a Hessian at a snapshot establish equilibrium?](Linear-Algebra#user-content-q015) (P1)

## Vector Calculus

- [Q016 — Can vector fields be rectangular maps?](Vector-Calculus#user-content-q016) (P1)
- [Q017 — Why does curl return unknown outside supported dimensions?](Vector-Calculus#user-content-q017) (P1)
- [Q018 — Why is zero curl not enough to certify a potential?](Vector-Calculus#user-content-q018) (P1)
- [Q019 — How are numerical derivatives at a corner refused?](Vector-Calculus#user-content-q019) (P1)
- [Q020 — Does linearization prove anything away from its base point?](Vector-Calculus#user-content-q020) (P1)

## Numerical Methods

- [Q021 — Are derivative comparison errors certified bounds?](Numerical-Methods#user-content-q021) (P1)
- [Q022 — Why can a smaller finite-difference step be worse?](Numerical-Methods#user-content-q022) (P1)
- [Q023 — What does missing relative error mean at a zero reference?](Numerical-Methods#user-content-q023) (P1)
- [Q024 — Why is observed convergence order missing?](Numerical-Methods#user-content-q024) (P1)
- [Q025 — Which tolerance accepts a stationary candidate?](Numerical-Methods#user-content-q025) (P1)

## Differential Equations

- [Q026 — What does a successful trajectory solve establish?](Differential-Equations#user-content-q026) (P1)
- [Q027 — Can FirstOrderODE be passed directly to analyze?](Differential-Equations#user-content-q027) (P1)
- [Q028 — Does saveat authorize interpolation in stored-data bridges?](Differential-Equations#user-content-q028) (P1)
- [Q029 — Why are state and time converted to Float64?](Differential-Equations#user-content-q029) (P1)
- [Q030 — Are domain callbacks rigorous boundary tracking?](Differential-Equations#user-content-q030) (P1)

## Mechanics and Dynamics

- [Q031 — Which coordinate and momentum order does AML use?](Mechanics-and-Dynamics#user-content-q031) (P1)
- [Q032 — When can AML establish a Legendre transform?](Mechanics-and-Dynamics#user-content-q032) (P1)
- [Q033 — Does sampled energy drift prove conservation?](Mechanics-and-Dynamics#user-content-q033) (P1)
- [Q034 — Why do imaginary eigenvalues not decide nonlinear stability?](Mechanics-and-Dynamics#user-content-q034) (P1)
- [Q035 — How do I compare analytical and numerical descriptions of one system?](Mechanics-and-Dynamics#user-content-q035) (P1)

## Trajectories

- [Q036 — How do I select a stored component without guessing physical identity?](Trajectories#user-content-q036) (P1)
- [Q037 — Is saved sample spacing the integrator time step?](Trajectories#user-content-q037) (P1)
- [Q038 — Are stored trajectory frames copied or lazy?](Trajectories#user-content-q038) (P1)
- [Q039 — Why does comparing two stored results refuse missing context?](Trajectories#user-content-q039) (P1)
- [Q040 — Does diagnose recompute missing analyses?](Trajectories#user-content-q040) (P1)

## Atomistic Computing

- [Q041 — Can I inspect particle data without Molly?](Atomistic-Computing#user-content-q041) (P1)
- [Q042 — Why does a Molly trajectory require explicit historical assertions?](Atomistic-Computing#user-content-q042) (P1)
- [Q043 — What happens when a Molly system has no stored loggers?](Atomistic-Computing#user-content-q043) (P1)
- [Q044 — What boundary and distance information is needed for RDF?](Atomistic-Computing#user-content-q044) (P1)
- [Q045 — Is analyze_potential an MD force engine?](Atomistic-Computing#user-content-q045) (P1)

## Statistics

- [Q046 — Why does a moment summary not report an IID standard error?](Statistics#user-content-q046) (P1)
- [Q047 — Do blocking and autocorrelation prove stationarity?](Statistics#user-content-q047) (P1)
- [Q048 — Why are missing or nonfinite observations not silently filtered?](Statistics#user-content-q048) (P1)
- [Q049 — What time scale and fit-window assumptions are needed to interpret a diffusion estimate?](Statistics#user-content-q049) (P1)
- [Q050 — Does comparing compatible runs establish independence?](Statistics#user-content-q050) (P1)

## Scientific Datasets

- [Q051 — Which dataset fields must I declare explicitly?](Scientific-Datasets#user-content-q051) (P1)
- [Q052 — Why must scalar targets be reshaped for scaling?](Scientific-Datasets#user-content-q052) (P1)
- [Q053 — How do I avoid train/validation normalization leakage?](Scientific-Datasets#user-content-q053) (P1)
- [Q054 — Does a reference kind label certify its quality?](Scientific-Datasets#user-content-q054) (P1)
- [Q055 — Does a numerical trajectory become analytical ground truth when converted?](Scientific-Datasets#user-content-q055) (P1)

## Scientific Machine Learning

- [Q056 — Does low PINN loss establish PDE correctness?](Scientific-Machine-Learning#user-content-q056) (P1)
- [Q057 — Why does the learning model require explicit RNG provenance?](Scientific-Machine-Learning#user-content-q057) (P1)
- [Q058 — Are learned corrections symbolic discoveries?](Scientific-Machine-Learning#user-content-q058) (P1)
- [Q059 — What does the one-step oscillator learning example demonstrate?](Scientific-Machine-Learning#user-content-q059) (P1)
- [Q060 — Is local sensitivity the same as global identifiability?](Scientific-Machine-Learning#user-content-q060) (P1)

## Units and Precision

- [Q061 — Does a unit string convert numerical data?](Units-and-Precision#user-content-q061) (P0)
- [Q062 — Can compatible Unitful lengths be combined in statistics?](Units-and-Precision#user-content-q062) (P0)
- [Q063 — Why is unknown unit metadata not dimensionless?](Units-and-Precision#user-content-q063) (P0)
- [Q064 — Which paths really preserve BigFloat precision?](Units-and-Precision#user-content-q064) (P0)
- [Q065 — Are complex inputs or integers supported everywhere?](Units-and-Precision#user-content-q065) (P0)

## Memory and Performance

- [Q066 — Why was my 3000 x 3000 Hessian rejected, and what can I do?](Memory-and-Performance#user-content-q066) (P0)
- [Q067 — Is there a global AML memory-budget setter?](Memory-and-Performance#user-content-q067) (P0)
- [Q068 — Does a dense matrix size estimate include temporary storage?](Memory-and-Performance#user-content-q068) (P0)
- [Q069 — Which limits are internal rather than public configuration?](Memory-and-Performance#user-content-q069) (P0)
- [Q070 — Are maintainer scaling scripts supported matrix-free APIs?](Memory-and-Performance#user-content-q070) (P0)
- [Q086 — Which pair-output limits are public, and does RDF remove quadratic work?](Memory-and-Performance#user-content-q086) (P1)
- [Q087 — Does prediction batch_size bound the returned output or training memory?](Memory-and-Performance#user-content-q087) (P1)
- [Q088 — Which histories retain earliest entries and which retain the most recent?](Memory-and-Performance#user-content-q088) (P1)
- [Q089 — When does summary_only avoid output arrays, and are public iterators one-pass?](Memory-and-Performance#user-content-q089) (P1)
- [Q090 — What provenance is intentionally omitted with source_retention=:descriptor?](Memory-and-Performance#user-content-q090) (P1)

## Scientific Evidence and Provenance

- [Q071 — What do value, status, method and notes mean?](Scientific-Evidence-and-Provenance#user-content-q071) (P0)
- [Q072 — Is unknown evidence the same as false or zero?](Scientific-Evidence-and-Provenance#user-content-q072) (P0)
- [Q073 — Does provenance identity affect scientific value equality?](Scientific-Evidence-and-Provenance#user-content-q073) (P0)
- [Q074 — Can I use an origin token as a persistent reproducibility hash?](Scientific-Evidence-and-Provenance#user-content-q074) (P0)
- [Q075 — Why is ancestry unavailable on an isolated PropertyResult?](Scientific-Evidence-and-Provenance#user-content-q075) (P0)

## Optional Extensions

- [Q076 — Which exact packages activate each optional extension?](Optional-Extensions#user-content-q076) (P0)
- [Q077 — Why does a plain Lux surrogate require NeuralOperators?](Optional-Extensions#user-content-q077) (P0)
- [Q078 — Can I import AML before its optional backends?](Optional-Extensions#user-content-q078) (P0)
- [Q079 — Will AML choose an available backend automatically?](Optional-Extensions#user-content-q079) (P0)
- [Q080 — Does AML import activate CairoMakie?](Optional-Extensions#user-content-q080) (P0)

## Troubleshooting

- [Q081 — Why is analyze not defined for my input type?](Troubleshooting#user-content-q081) (P0)
- [Q082 — Why is transform ambiguous after importing another library?](Troubleshooting#user-content-q082) (P0)
- [Q083 — Why is a plot region blank even though sampling looks finite?](Troubleshooting#user-content-q083) (P0)
- [Q084 — Can I fix a refusal by changing an internal constant?](Troubleshooting#user-content-q084) (P0)
- [Q085 — What must I retain before mutating a borrowed array?](Troubleshooting#user-content-q085) (P0)
