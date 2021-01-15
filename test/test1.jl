using FastRefine
using LazySets
import FastRefine: forward_network, forward_affine_map, ishull

nnet = read_nnet("nnet/86442.nnet")

delta = 0.4

solver3 = DimGrid(delta)

in_hyper = Hyperrectangle(fill(1.0, 8), fill(1.0, 8))
out_hyper = Hyperrectangle(fill(0.0, 2), fill(10.0, 2))
problem = Problem(nnet, in_hyper, out_hyper)

(W, b) = (problem.network.layers[1].weights, problem.network.layers[1].bias)
input1 = forward_affine_map(solver, W, b, problem.input)
lower, upper = low(input1), high(input1)
n_hypers_per_dim = BigInt.(max.(ceil.(Int, (upper-lower) / delta), 1))

C = vcat(W, -W)
d = vcat(upper-b, b-lower)

HP = HPolytope(C, d)

inter = intersection(in_hyper, HP)

a = isempty(inter)
