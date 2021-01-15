module FastRefine

using LazySets, LazySets.Approximations
using Polyhedra, CDDLib

using LinearAlgebra
using Parameters
using Interpolations # only for PiecewiseLinear
using PyCall

import LazySets: dim, HalfSpace # necessary to avoid conflict with Polyhedra

using Requires

using Base.Threads

include("activation.jl")
include("network.jl")
include("problem.jl")
include("util.jl")

function __init__()
  @require Flux="587475ba-b771-5e3f-ad9e-33799f191a9c" include("flux.jl")
end

export
    Solver,
    Network,
    AbstractActivation,
    #PolytopeComplement,
    #complement,
    # NOTE: not sure if exporting these is a good idea as far as namespace conflicts go:
    # ReLU,
    # Max,
    # Id,
    GeneralAct,
    PiecewiseLinear,
    LinearPieces,
    PiecewiseLinearActivation,
    Problem,
    Result,
    BasicResult,
    CounterExampleResult,
    AdversarialResult,
    ReachabilityResult,
    read_nnet,
    solve,
    forward_network,
    check_inclusion

export solve

include("reachability.jl")

include("maxSens.jl")
include("hullGrid.jl")
include("dimGrid.jl")
include("fastGrid.jl")

include("speGuid.jl")
include("hullTree.jl")
include("dimTree.jl")
include("fastTree.jl")

export MaxSens, HullGrid, DimGrid
export FastGrid
export SpeGuid, HullTree, DimTree
export FastTree

end
