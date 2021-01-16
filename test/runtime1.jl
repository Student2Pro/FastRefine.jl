using FastRefine
using LazySets
import FastRefine: forward_network, forward_affine_map, ishull

nnet = read_nnet("nnet/test3.nnet")

delta = 0.05

solver1 = MaxSens(delta)
solver2 = HullGrid(delta)
solver3 = DimGrid(delta)
solver4 = FastGrid(delta)

in_hyper = Hyperrectangle(fill(1.0, 3), fill(1.0, 3))
out_hyper = Hyperrectangle(fill(0.0, 2), fill(10.0, 2))
problem = Problem(nnet, in_hyper, out_hyper)

file = open("results/group1.txt", "a")
print(file, "Test Result of Group 1:\n\n")

#solver1

time1 = 0

#solve(solver1, problem)
for i = 1:1
    timed_result =@timed solve(solver1, problem)
    print(file, "MaxSens - test " * string(i) * " - Time: " * string(timed_result.time) * " s")
    print(file, " - Output: " * string(timed_result.value) * "\n")
    global time1 += timed_result.time
end

print(file, "Average time: " * string(time1/1) * " s\n\n")


#solver2

time2 = 0

#solve(solver2, problem)
for i = 1:1
    timed_result =@timed solve(solver2, problem)
    print(file, "HullGrid - test " * string(i) * " - Time: " * string(timed_result.time) * " s")
    print(file, " - Output: " * string(timed_result.value) * "\n")
    global time2 += timed_result.time
end

print(file, "Average time: " * string(time2/1) * " s\n\n")


#solver3

time3 = 0

#solve(solver3, problem)
for i = 1:1
    timed_result =@timed solve(solver3, problem)
    print(file, "DimGrid - test " * string(i) * " - Time: " * string(timed_result.time) * " s")
    print(file, " - Output: " * string(timed_result.value) * "\n")
    global time3 += timed_result.time
end

print(file, "Average time: " * string(time3/1) * " s\n\n")


#solver4

time4 = 0

#solve(solver4, problem)
for i = 1:1
    timed_result =@timed solve(solver4, problem)
    print(file, "FastGrid - test " * string(i) * " - Time: " * string(timed_result.time) * " s")
    print(file, " - Output: " * string(timed_result.value) * "\n")
    global time4 += timed_result.time
end

print(file, "Average time: " * string(time4/1) * " s\n\n")

close(file)
