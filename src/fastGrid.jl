@with_kw struct FastGrid
    resolution::Float64 = 1.0
    #tight::Bool         = false
end

# This is the main function
function solve(solver::FastGrid, problem::Problem) #original
    result = true
    delta = solver.resolution

    center = problem.input.center
    radius = problem.input.radius[1]

    (W, b) = (problem.network.layers[1].weights, problem.network.layers[1].bias)

    np = pyimport("numpy")
    q, e, p = np.linalg.svd(W)

    input = forward_affine_map(solver, W, b, problem.input)

    lower, upper = low(input), high(input)
    n_hypers_per_dim = BigInt.(max.(ceil.(Int, (upper-lower) / delta), 1))

    k_1 = size(W, 1)
    k_0 = size(W, 2)

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

    C = vcat(W, -W)
    d = zeros(2k_1)

    #kb = p[k_1+1:k_0,:] #kernel basis
    #kc = kb * center

    #= Al = zeros(k_0, k_0)
    Au = zeros(k_0, k_0)

    dl = zeros(k_1)
    du = zeros(k_1)

    bl = zeros(k_0)
    bu = zeros(k_0)

    pl = zeros(k_0)
    pu = zeros(k_0) =#

    #count3 = BigInt(0)
    count4 = BigInt(0)
    #println("All: " * string(prod(n_hypers_per_dim)) * " - " * string(prod(n_hypers_per_dim.-2)))

    # preallocate work arrays
    local_lower, local_upper, CI = similar(lower), similar(lower), similar(lower)
    for i in 1:prod(n_hypers_per_dim)
        n = i
        for j in firstindex(CI):lastindex(CI)
            n, CI[j] = fldmod1(n, n_hypers_per_dim[j])
        end
        @. local_lower = lower + delta * (CI - 1)
        @. local_upper = min(local_lower + delta, upper)
        hyper = Hyperrectangle(low = local_lower, high = local_upper)

        d = vcat(local_upper - b, b - local_lower)

        P_i = HPolyhedron(C, d)

        inter = intersection(problem.input, P_i)

        if isempty(inter) == false
            #count3 += 1
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
                reach = forward_network(solver, problem.network, hyper)
                count4 += 1
                if !issubset(reach, problem.output)
                    result = false
                end
            end
        end
    end

    println("Verified: " * string(count4))

    if result
        return BasicResult(:holds)
    end
    return BasicResult(:violated)
end

function forward_network(solver::FastGrid, nnet::Network, input::Hyperrectangle)
    layers = nnet.layers
    act = layers[1].activation
    reach = Hyperrectangle(low = act.(low(input)), high = act.(high(input)))

    for i in 2:length(layers)
        reach = forward_layer(solver, layers[i], reach)
    end
    return reach
end

# This function is called by forward_network
function forward_layer(solver::FastGrid, L::Layer, input::Hyperrectangle)
    (W, b, act) = (L.weights, L.bias, L.activation)
    center = zeros(size(W, 1))
    gamma  = zeros(size(W, 1))
    for j in 1:size(W, 1)
        node = Node(W[j,:], b[j], act)
        center[j], gamma[j] = forward_node(solver, node, input)
    end
    return Hyperrectangle(center, gamma)
end

function forward_affine_map(solver::FastGrid, W::Matrix, b::Vector, input::Hyperrectangle)
    center = W * input.center + b
    radius = abs.(W) * input.radius
    return Hyperrectangle(center, radius)
end

function forward_node(solver::FastGrid, node::Node, input::Hyperrectangle)
    output    = node.w' * input.center + node.b
    deviation = sum(abs.(node.w) .* input.radius)
    β    = node.act(output)  # TODO expert suggestion for variable name. beta? β? O? x?
    βmax = node.act(output + deviation)
    βmin = node.act(output - deviation)
    return ((βmax + βmin)/2, (βmax - βmin)/2)
    #if solver.tight
        #return ((βmax + βmin)/2, (βmax - βmin)/2)
    #else
        #return (β, max(abs(βmax - β), abs(βmin - β)))
    #end
end

#distance of point to hyperPlane cx = d
function distance(point::Vector, c::Vector, d::Real)
    if length(point) == length(c)
        return abs(sum(point .* c) - d)/sqrt(sum(abs2.(c)))
    else
        error("Dimesion dismatch for point and constraint")
    end
end
