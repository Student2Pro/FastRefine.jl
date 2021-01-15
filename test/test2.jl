using FastRef
using LazySets
import FastRef: forward_network, forward_affine_map, ishull

center = fill(1.0, 400)
radius = fill(1.0, 400)
inputSet = Hyperrectangle(center, radius)

nnet = read_nnet("nnet/mnist-20.nnet")
solver1 = MaxSens(2.0, true)
solver2 = FastGrid(2.0)

(W, b) = (nnet.layers[1].weights, nnet.layers[1].bias)

#outputSet1 = forward_network(solver1, nnet, inputSet)

z = forward_affine_map(solver2, W, b, inputSet)
#outputSet2 = forward_network(solver2, nnet, z)

c = W * center + b
r = z.radius .* 0.03

z1 = Hyperrectangle(c, r)

print("z: ")
println(z)

#println(c)

#print("z1: ")
#println(z1)

println(ishull(z1, inputSet, W, b))
