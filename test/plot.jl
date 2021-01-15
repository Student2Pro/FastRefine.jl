using LazySets, Polyhedra, Makie, LinearAlgebra

inputSet = Hyperrectangle(low=zeros(3), high=ones(3))

W = [1.8 -4 -2; 1.7 6 -8]

eigenvector = [1.0 0.25 0.4]
#big box
Cb = vcat(Array(Diagonal(ones(3))), Array(-Diagonal(ones(3))))
db = vcat(2*ones(3), 1*ones(3))

#small box / input LazySets
di = vcat(ones(3), zeros(3))

#project plane
C = vcat(Cb, eigenvector, -eigenvector)
d = vcat(db, 0.825, -0.825)
proj_plane = HPolytope(C, d)
#inputSet in front of project plane
infr = HPolytope(vcat(Cb, -eigenvector), vcat(di, -0.825)) #lightpink

#inputSet behind project plane
inbe = HPolytope(vcat(Cb, eigenvector), vcat(di, 0.825)) #lightpink3

#inter proj input
d1 = vcat(di, 0.825, -0.825)
inter = HPolytope(C, d1)

#q1
Cq = vcat(Array(Diagonal(ones(2))), Array(-Diagonal(ones(2))))
dq1 = [1, 6, 0, -5]

#q2
dq2 = [1, 4, 0, -3]

#q3
dq3 = [1, 1, 0, 0]

#p1
Cp = Cq * W

p1if = HPolytope(vcat(Cb, Cp, -eigenvector), vcat(db, dq1, -0.825)) #cyan
p1be = HPolytope(vcat(Cb, Cp, eigenvector), vcat(db, dq1, 0.825)) #cyan3
p1inter = HPolytope(vcat(Cb, Cp, eigenvector, -eigenvector), vcat(db, dq1, 0.825, -0.825))

p2if = HPolytope(vcat(Cb, Cp, -eigenvector), vcat(db, dq2, -0.825))
p2be = HPolytope(vcat(Cb, Cp, eigenvector), vcat(db, dq2, 0.825))
p2inter = HPolytope(vcat(Cb, Cp, eigenvector, -eigenvector), vcat(db, dq2, 0.825, -0.825))
p2in = HPolytope(vcat(Cb, Cp), vcat(di, dq2))

p3if = HPolytope(vcat(Cb, Cp, -eigenvector), vcat(db, dq3, -0.825))
p3be = HPolytope(vcat(Cb, Cp, eigenvector), vcat(db, dq3, 0.825))
p3inter = HPolytope(vcat(Cb, Cp, eigenvector, -eigenvector), vcat(db, dq3, 0.825, -0.825))
p3inf = HPolytope(vcat(Cb, Cp, -eigenvector), vcat(di, dq3, -0.825))
p3inb = HPolytope(vcat(Cb, Cp, eigenvector), vcat(di, dq3, 0.825))

scene1 = plot3d(proj_plane, color=:dodgerblue)

scene1 = plot3d!(inbe, color=:lightpink3)
scene1 = plot3d!(infr, color=:lightpink)
scene1 = plot3d!(inter, color=:dodgerblue4)
scene1 = plot3d!(p1be, color=:cyan3)
scene1 = plot3d!(p1if, color=:cyan)
scene1 = plot3d!(p1inter, color=:red)

scene1 = plot3d(proj_plane, color=:dodgerblue)

scene1 = plot3d!(inbe, color=:lightpink3)
scene1 = plot3d!(infr, color=:lightpink)
scene1 = plot3d!(inter, color=:dodgerblue4)
scene1 = plot3d!(p2be, color=:cyan3)
scene1 = plot3d!(p2if, color=:cyan)
scene1 = plot3d!(p2inter, color=:red)
scene1 = plot3d!(p2in, color=:yellow)

#

scene1 = plot3d(proj_plane, color=:dodgerblue)

scene1 = plot3d!(inbe, color=:lightpink3)
scene1 = plot3d!(p3be, color=:cyan3)
scene1 = plot3d!(p3inb, color=:yellow3)


scene1 = plot3d!(infr, color=:lightpink)
scene1 = plot3d!(inter, color=:dodgerblue4)
scene1 = plot3d!(p3if, color=:cyan)
scene1 = plot3d!(p3inf, color=:yellow)
scene1 = plot3d!(p3inter, color=:red)


#save("plot.png", scene)
