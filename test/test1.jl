using FastRef
using LazySets
import FastRef: forward_network, forward_affine_map

center = fill(1.0, 10)
radius = fill(1.0, 10)
inputSet = Hyperrectangle(center, radius)

nnet = read_nnet("nnet/test10.nnet")
solver1 = MaxSens(2.0, true)
solver2 = FastGrid(2.0)

(W, b) = (nnet.layers[1].weights, nnet.layers[1].bias)

outputSet1 = forward_network(solver1, nnet, inputSet)

z = forward_affine_map(solver2, W, b, inputSet)
outputSet2 = forward_network(solver2, nnet, z)

println(outputSet1)
println(outputSet2)
