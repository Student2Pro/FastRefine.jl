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

    l = low(problem.input)
    u = high(problem.input)

    (W, b) = (problem.network.layers[1].weights, problem.network.layers[1].bias)

    np = pyimport("numpy")

    q, e, p = np.linalg.svd(W)

    input = forward_affine_map(solver, W, b, problem.input)

    lower, upper = low(input), high(input)
    n_hypers_per_dim = BigInt.(max.(ceil.(Int, (upper-lower) / delta), 1))

    k_1 = size(W, 1)
    k_0 = size(W, 2)

    C_i = vcat( Array(Diagonal(ones(k_0))),
                Array(Diagonal(ones(k_0))),
                W,
                -W
    )

    d_i = zeros(2k_0+2k_1)

    kb = p[k_1+1:k_0,:] #kernel basis

    Al = zeros(k_0, k_0)
    Au = zeros(k_0, k_0)

    Cls = Array{Matrix,1}(undef, k_0)
    Cus = Array{Matrix,1}(undef, k_0)

    dl = zeros(k_1)
    du = zeros(k_1)

    for i in 1:k_0
        Cls[i] = zeros(k_1,k_0)
        Cus[i] = zeros(k_1,k_0)
        for j in 1:k_1
            if W[j,i] > 0
                Cls[i][j,:] = -W[j,:]
                Cus[i][j,:] = W[j,:]
            else
                Cls[i][j,:] = W[j,:]
                Cus[i][j,:] = -W[j,:]
            end
        end
    end

    Dls = zeros(k_0)
    Dus = zeros(k_0)

    for i in 1:k_0
        Dls[i] = np.linalg.det(vcat(kb, Cls[i]))
        Dus[i] = np.linalg.det(vcat(kb, Cus[i]))
    end

    bl = zeros(k_0)
    bu = zeros(k_0)
    kc = kb * center

    count4 = 0

    # preallocate work arrays
    local_lower, local_upper, CI = similar(lower), similar(lower), similar(lower)
    for i in 1:100#prod(n_hypers_per_dim)
        n = i
        for j in firstindex(CI):lastindex(CI)
            n, CI[j] = fldmod1(n, n_hypers_per_dim[j])
        end
        @. local_lower = lower + delta * (CI - 1)
        @. local_upper = min(local_lower + delta, upper)
        hyper = Hyperrectangle(low = local_lower, high = local_upper)

        d_i = vcat( high(problem.input),
                    -low(problem.input),
                    local_upper - b,
                    b - local_lower
        )

        if isempty(HPolytope(C_i, d_i)) == false
            inner = true
            for j in 1:k_0
                Al = vcat(kb, Cls[j])
                Au = vcat(kb, Cus[j])
                for k in k_1
                    if W[k,j] > 0
                        dl[k] = b[k] - local_lower[k]
                        du[k] = local_upper[k] - b[k]
                    else
                        dl[k] = local_upper[k] - b[k]
                        du[k] = b[k] - local_lower[k]
                    end
                end
                bl = vcat(kc, dl)
                bu = vcat(kc, du)
                Al[:,j] = bl
                Au[:,j] = bu
                if np.linalg.det(Al) <= l[j] || u[j] <= np.linalg.det(Au)
                    inner = false
                    break
                end
            end

            if !inner
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
