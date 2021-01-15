@with_kw struct DimGrid
    resolution::Float64 = 1.0
    #tight::Bool         = false
end

# This is the main function
function solve(solver::DimGrid, problem::Problem) #original
    result = true
    delta = solver.resolution

    center = problem.input.center
    radius = problem.input.radius[1]

    (W, b) = (problem.network.layers[1].weights, problem.network.layers[1].bias)

    input = forward_affine_map(solver, W, b, problem.input)

    lower, upper = low(input), high(input)
    n_hypers_per_dim = BigInt.(max.(ceil.(Int, (upper-lower) / delta), 1))

    k_1 = size(W, 1)
    k_0 = size(W, 2)
#=
    C_i = vcat( Array(Diagonal(ones(k_0))),
                Array(Diagonal(ones(k_0))),
                W,
                -W
    )
=#
    C = vcat(w, -W)

    d = zeros(2k_1)

    #d_i = zeros(2k_0+2k_1)

    count3 = BigInt(0)
    println("All: " * string(prod(n_hypers_per_dim)))

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
#=
        d_i = vcat( high(problem.input),
                    -low(problem.input),
                    local_upper - b,
                    b - local_lower
        )
=#
        d = vcat(local_upper - b, b - local_lower)

        inter = intersection(problem.input, HPolytope(C, d))

        if isempty(HPolytope(C_i, d_i)) == false
            reach = forward_network(solver, problem.network, hyper)
            count3 += 1
            if !issubset(reach, problem.output)
                result = false
            end
        end
    end

    println("Verified: " * string(count3))

    if result
        return BasicResult(:holds)
    end
    return BasicResult(:violated)
end

function forward_network(solver::DimGrid, nnet::Network, input::Hyperrectangle)
    layers = nnet.layers
    act = layers[1].activation
    reach = Hyperrectangle(low = act.(low(input)), high = act.(high(input)))

    for i in 2:length(layers)
        reach = forward_layer(solver, layers[i], reach)
    end
    return reach
end

# This function is called by forward_network
function forward_layer(solver::DimGrid, L::Layer, input::Hyperrectangle)
    (W, b, act) = (L.weights, L.bias, L.activation)
    center = zeros(size(W, 1))
    gamma  = zeros(size(W, 1))
    for j in 1:size(W, 1)
        node = Node(W[j,:], b[j], act)
        center[j], gamma[j] = forward_node(solver, node, input)
    end
    return Hyperrectangle(center, gamma)
end

function forward_affine_map(solver::DimGrid, W::Matrix, b::Vector, input::Hyperrectangle)
    center = W * input.center + b
    radius = abs.(W) * input.radius
    return Hyperrectangle(center, radius)
end

function forward_node(solver::DimGrid, node::Node, input::Hyperrectangle)
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
