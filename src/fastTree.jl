@with_kw struct FastTree
    tolerance::Float64 = 1.0
end

# This is the main function

function solve(solver::FastTree, problem::Problem)
    center = problem.input.center
    radius = problem.input.radius[1]
    (W, b) = (problem.network.layers[1].weights, problem.network.layers[1].bias)

    input = forward_affine_map(solver, W, b, problem.input)
    lower, upper = low(input), high(input)
    local_lower, local_upper = similar(lower), similar(lower)

    np = pyimport("numpy")
    q, e, p = np.linalg.svd(W)

    k_1 = size(W, 1)
    k_0 = size(W, 2)

    C = vcat(W, -W)
    d = zeros(2k_1)

    hps = Array{Hyperplane, 1}(undef, k_0-k_1)

    for i in k_1+1:k_0
        hps[i-k_1] = Hyperplane(p[i,:], dot(p[i,:], center))
    end

    S = hps[1]
    if k_0-k_1 > 1
        for i in 2:k_0-k_1
            S = intersection(S, hps[i])
        end
    end

    stack = Vector{Hyperrectangle}(undef, 0)
    push!(stack, input)
    #count = 1
    while !isempty(stack)
        interval = popfirst!(stack)
        reach = forward_network(solver, problem.network, interval)
        if issubset(reach, problem.output)
            continue
        else
            if get_largest_width(interval) > solver.tolerance
                sections = bisect(interval)
                for i in 1:2
                    local_lower = low(sections[i])
                    local_upper = high(sections[i])

                    d = vcat(local_upper - b, b - local_lower)
                    P_i = HPolyhedron(C, d)

                    inter = intersection(problem.input, P_i)

                    if isempty(inter) == false
                        O_i = box_approximation(intersection(P_i, S))
                        inner = true
                        for j in 1:k_0
                            if low(O_i)[j] ≤ low(problem.input)[j]
                                inner = false
                                break
                            end

                            if high(problem.input)[j] ≤ high(O_i)[j]
                                inner = false
                                break
                            end
                        end
                        if inner == false
                            push!(stack, sections[i])
                            #count += 1
                        end
                    end
                end
            else
                return BasicResult(:violated)
            end
        end
    end
    #print("\n$(count)\n")
    return BasicResult(:holds)
end

function forward_network(solver::FastTree, nnet::Network, input::Hyperrectangle)
    layers = nnet.layers
    act = layers[1].activation
    reach = Hyperrectangle(low = act.(low(input)), high = act.(high(input)))

    for i in 2:length(layers)
        reach = forward_layer(solver, layers[i], reach)
    end
    return reach
end

function forward_layer(solver::FastTree, L::Layer, input::Hyperrectangle)
    (W, b, act) = (L.weights, L.bias, L.activation)
    center = zeros(size(W, 1))
    gamma  = zeros(size(W, 1))
    for j in 1:size(W, 1)
        node = Node(W[j,:], b[j], act)
        center[j], gamma[j] = forward_node(solver, node, input)
    end
    return Hyperrectangle(center, gamma)
end

function forward_node(solver::FastTree, node::Node, input::Hyperrectangle)
    output    = node.w' * input.center + node.b
    deviation = sum(abs.(node.w) .* input.radius)
    βmax = node.act(output + deviation)
    βmin = node.act(output - deviation)
    return ((βmax + βmin)/2, (βmax - βmin)/2)
end

function forward_affine_map(solver::FastTree, W::Matrix, b::Vector, input::Hyperrectangle)
    center = W * input.center + b
    radius = abs.(W) * input.radius
    return Hyperrectangle(center, radius)
end

#to determine whether
function ishull(x::Hyperrectangle, y::Hyperrectangle, W::Matrix, b::Vector)
    center = y.center
    radius = y.radius[1]
    k_1 = size(W, 1) #length(lower)
    #I = zeros(k_1, k_1) #Identity matrix
    #IN = zeros(k_1, k_1) #negative Identity matrix
    #for k = 1:k_1
        #I[k, k] = 1.0
        #IN[k, k] = -1.0
    #end
    #Hi
    #C_1 = vcat(I, IN)
    C_1 = vcat(Diagonal(ones(k_1)), -Diagonal(ones(k_1)))
    d_1 = vcat(high(x), -low(x))
    #Pi
    C = C_1 * W #size(2k_1, k_0)
    d = d_1 - C_1 * b #size(2k_1)

    #print("C: ")
    #println(C)
    #print("d: ")
    #println(d)

    inter = true #if the intersection of Pi and the input set is empty
    for l = 1:length(d)
        sum = 0.0
        for m = 1:size(C, 2)
            if C[l,m] > 0
                sum += low(y, m) * C[l,m]
            elseif C[l,m] < 0.0
                sum += high(y, m) * C[l,m]
            end
        end
        if sum > d[l]
            inter = false
            break
        end
    end

    if inter
        hull = false #if Hi is a hull of Z, or if Pi and center of the input set are close
        for l = 1:length(d)
            #print(l)
            #print(" distance: ")
            #println(distance(center, C[l,:], d[l]))
            #print("radius: ")
            #println(radius)
            if distance(center, C[l,:], d[l]) > radius
                return true
            end
        end
    end
    return false
end
