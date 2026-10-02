# M9D backend decision record

Starting commit: `037c3baafe8df7fe578a2d34182b84b41f030d37` (unchanged M9C).

## Public ecosystem, inspected rather than inferred from tutorials

The resolver installed NeuralOperators 0.7.3 into `examples/operators`, alongside
Lux 1.31.4 and Optimization 5.9.1. The installed source at
`NeuralOperators/src/models/deeponet.jl` defines `DeepONet(branch,trunk)` as a Lux
wrapper. A branch matrix (sensors × functions) and trunk matrix (coordinates ×
queries) yield queries × functions. This orientation is part of AML's tests.

Sources:
- https://github.com/SciML/NeuralOperators.jl
- https://raw.githubusercontent.com/SciML/NeuralOperators.jl/main/Project.toml
- https://docs.sciml.ai/NeuralOperators/stable/api/
- https://docs.sciml.ai/NeuralOperators/stable/models/fno/

The stable documentation still includes older environments and a stale
three-argument DeepONet signature. Installed 0.7.3 source, actual execution, and
its two-network constructor take precedence.

Lux owns dense networks, initialization, parameter/state handling and forward
application. NeuralOperators owns the DeepONet branch/trunk combination.
Optimization owns optimization and AD dispatch. AML owns scientific dataset
contracts, train-only scaling, prediction adapters, split-specific diagnostics
and provenance. No neural framework, optimizer, FFT or PDE solver is implemented
in AML.

FNO exists in the maintained backend and uses established FFTW/AbstractFFTs
infrastructure. Its public layout is spatial axes × channels × batch, not the
DeepONet coordinate-query layout. The documentation's accelerated training route
uses Reactant/Enzyme. Availability is not evidence of compatibility with this
milestone's CPU/AD route or Dirichlet heat representation. M9D's required path is
DeepONet; an FNO research/comparison framework is not a completion requirement.

The retained `examples/operators/backend_probe.jl` passed six checks: DeepONet
output orientation, parameter gradients, coordinate Hessian and short native
optimization, plus FNO forward shape/finiteness at `(16,1,2)`. The initial FNO
probe needed five channel entries (`chs=(1,4,4,4,1)`), as required by installed
source. This is forward availability evidence only: no FNO heat training,
accuracy/residual validation or discretization transfer is claimed. The AML
operator adapter deliberately accepts DeepONet only; FNO is deferred.

M6 remains the native SciML ODE boundary; M7 canonical structures and M8 stored
trajectory/unit semantics are unchanged. M9C ObservationSet represents one
observed trajectory, not a family of function-valued inputs. M9D therefore uses
separate family objects, while reusing `train`, `predict`, `analyze`,
`PropertyResult` and M9B `sampled_summary` conventions.
