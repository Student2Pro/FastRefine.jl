using FastRefine
using LazySets
import FastRefine: forward_network, forward_affine_map, ishull

nnet = read_nnet("nnet/86442.nnet")

delta = 0.3

solver3 = DimGrid(delta)

in_hyper = Hyperrectangle(fill(1.0, 8), fill(1.0, 8))
out_hyper = Hyperrectangle(fill(0.0, 2), fill(10.0, 2))
problem = Problem(nnet, in_hyper, out_hyper)

file = open("results/group3.txt", "a")
print(file, "Test Result of Group 3:\n\n")


#solver3

time3 = 0

for i = 1:1
    timed_result =@timed solve(solver3, problem)
    print(file, "DimGrid - test " * string(i) * " - Time: " * string(timed_result.time) * " s")
    print(file, " - Output: " * string(timed_result.value) * "\n")
    global time3 += timed_result.time
end

print(file, "Average time: " * string(time3/1) * " s\n\n")

close(file)
