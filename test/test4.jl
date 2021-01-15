using FastRef
using LazySets
import FastRef: forward_network, forward_affine_map, ishull

nnet = read_nnet("nnet/mnist-20.nnet")
solver = DimTree(100.0)

in_hyper = Hyperrectangle(fill(1.0, 400), fill(1.0, 400))
out_hyper = Hyperrectangle(fill(0.0, 10), fill(10.0, 10))
problem = Problem(nnet, in_hyper, out_hyper)
timed_result =@timed solve(solver, problem)
print("FastTree - test")
print(" - Time: " * string(timed_result[2]) * " s")
print(" - Output: ")
print(timed_result[1].status)
print("\n")
