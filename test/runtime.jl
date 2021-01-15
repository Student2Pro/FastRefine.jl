using FastRefine
using LazySets
import FastRefine: forward_network, forward_affine_map, ishull

nnet = read_nnet("nnet/86442.nnet")

delta = 0.25

solver1 = MaxSens(delta)
solver2 = HullGrid(delta)
solver3 = DimGrid(delta)
solver4 = FastGrid(delta)
solver5 = SpeGuid(delta)
solver6 = HullTree(delta)
solver7 = DimTree(delta)
solver8 = FastTree(delta)

in_hyper = Hyperrectangle(fill(1.0, 8), fill(1.0, 8))
out_hyper = Hyperrectangle(fill(0.0, 2), fill(10.0, 2))
problem = Problem(nnet, in_hyper, out_hyper)

#solver1

time1 = 0

solve(solver1, problem)
for i = 1:10
    timed_result =@timed solve(solver1, problem)
    print("MaxSens - test " * string(i) * " - Time: " * string(timed_result.time) * " s")
    print(" - Output: " * string(timed_result.value) * "\n")
    global time1 += timed_result.time
end

print("Average time: " * string(time1/10) * " s\n\n")


#solver2

time2 = 0

solve(solver2, problem)
for i = 1:10
    timed_result =@timed solve(solver2, problem)
    print("HullGrid - test " * string(i) * " - Time: " * string(timed_result.time) * " s")
    print(" - Output: " * string(timed_result.value) * "\n")
    global time2 += timed_result.time
end

print("Average time: " * string(time2/10) * " s\n\n")


#solver3

time3 = 0

solve(solver3, problem)
for i = 1:10
    timed_result =@timed solve(solver3, problem)
    print("DimGrid - test " * string(i) * " - Time: " * string(timed_result.time) * " s")
    print(" - Output: " * string(timed_result.value) * "\n")
    global time3 += timed_result.time
end

print("Average time: " * string(time3/10) * " s\n\n")


#solver4

time4 = 0

solve(solver4, problem)
for i = 1:10
    timed_result =@timed solve(solver4, problem)
    print("FastGrid - test " * string(i) * " - Time: " * string(timed_result.time) * " s")
    print(" - Output: " * string(timed_result.value) * "\n")
    global time4 += timed_result.time
end

print("Average time: " * string(time4/10) * " s\n\n")


#solver5

time5 = 0

solve(solver5, problem)
for i = 1:10
    timed_result =@timed solve(solver5, problem)
    print("SpeGuid - test " * string(i) * " - Time: " * string(timed_result.time) * " s")
    print(" - Output: " * string(timed_result.value) * "\n")
    global time5 += timed_result.time
end

print("Average time: " * string(time5/10) * " s\n\n")


#solver6

time6 = 0

solve(solver6, problem)
for i = 1:10
    timed_result =@timed solve(solver6, problem)
    print("HullTree - test " * string(i) * " - Time: " * string(timed_result.time) * " s")
    print(" - Output: " * string(timed_result.value) * "\n")
    global time6 += timed_result.time
end

print("Average time: " * string(time6/10) * " s\n\n")


#solver7

time7 = 0

solve(solver7, problem)
for i = 1:10
    timed_result =@timed solve(solver7, problem)
    print("DimTree - test " * string(i) * " - Time: " * string(timed_result.time) * " s")
    print(" - Output: " * string(timed_result.value) * "\n")
    global time7 += timed_result.time
end

print("Average time: " * string(time7/10) * " s\n\n")


#solver8

time8 = 0

solve(solver8, problem)
for i = 1:10
    timed_result =@timed solve(solver8, problem)
    print("FastTree - test " * string(i) * " - Time: " * string(timed_result.time) * " s")
    print(" - Output: " * string(timed_result.value) * "\n")
    global time8 += timed_result.time
end

print("Average time: " * string(time8/10) * " s\n\n")
