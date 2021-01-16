using FastRefine
using LazySets
import FastRefine: forward_network, forward_affine_map, ishull

nnet = read_nnet("nnet/test3.nnet")

delta = 0.05

solver = DimTree(delta)

in_hyper = Hyperrectangle(fill(1.0, 3), fill(1.0, 3))
out_hyper = Hyperrectangle(fill(0.0, 2), fill(10.0, 2))
problem = Problem(nnet, in_hyper, out_hyper)

#=
(W, b) = (problem.network.layers[1].weights, problem.network.layers[1].bias)
input = forward_affine_map(solver, W, b, problem.input)
lower, upper = low(input), high(input)
n_hypers_per_dim = BigInt.(max.(ceil.(Int, (upper-lower) / delta), 1))
=#

file = open("results/group5.txt", "a")
print(file, "Test Result of Group 5:\n\n")

#solver4

time4 = 0

for i = 1:1
    timed_result =@timed solve(solver, problem)
    print(file, "DimTree - test " * string(i) * " - Time: " * string(timed_result.time) * " s")
    print(file, " - Output: " * string(timed_result.value) * "\n")
    global time4 += timed_result.time
end

print(file, "Average time: " * string(time4/1) * " s\n\n")

close(file)
