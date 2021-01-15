"""
    HullSearch(tolerance::Float64)

HullSearch, SGSV Combine HullReach, performs over-approximated reachability analysis to compute the over-approximated output reachable set for a network.

# Problem requirement
1. Network: any depth, any activation that is monotone
2. Input: `HPolytope`
3. Output: `HPolytope`

# Return
`BasicResult`

# Method
Search and Reachability

# Property
Sound but not complete.
"""
@with_kw struct HullTree
    tolerance::Float64 = 1.0
end

# This is the main function
function solve(solver::HullTree, problem::Problem)
    input = problem.input
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
                    if isborder(sections[i], problem.input)
                        push!(stack, sections[i])
                        #count += 1
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

#to determine whether x has intersection with any border of y
function isborder(x::Hyperrectangle, y::Hyperrectangle)
    x_lower, x_upper = low(x), high(x)
    y_lower, y_upper = low(y), high(y)
    for i in 1:lastindex(x_lower)
        if x_lower[i] == y_lower[i] || x_upper[i] == y_upper[i]
            return true
        end
    end
    return false
end

function forward_layer(solver::HullTree, L::Layer, input::Hyperrectangle)
    (W, b, act) = (L.weights, L.bias, L.activation)
    center = zeros(size(W, 1))
    gamma  = zeros(size(W, 1))
    for j in 1:size(W, 1)
        node = Node(W[j,:], b[j], act)
        center[j], gamma[j] = forward_node(solver, node, input)
    end
    return Hyperrectangle(center, gamma)
end

function forward_node(solver::HullTree, node::Node, input::Hyperrectangle)
    output    = node.w' * input.center + node.b
    deviation = sum(abs.(node.w) .* input.radius)
    βmax = node.act(output + deviation)
    βmin = node.act(output - deviation)
    return ((βmax + βmin)/2, (βmax - βmin)/2)
end
