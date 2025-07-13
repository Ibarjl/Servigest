module MemoryRepository

using .Ports  # Import the ports module for the repository interface
using .Entities  # Import the entities module for the domain structs

# In-memory storage for orders
const orders_storage = Dict{Int, OrdenTrabajo}()

# Implementation of the AbstractOrderRepository interface
struct InMemoryOrderRepository <: AbstractOrderRepository
end

function (repo::InMemoryOrderRepository)::Void
    # Constructor for the in-memory repository
end

function (repo::InMemoryOrderRepository, order::OrdenTrabajo)::Void
    orders_storage[order.id] = order
end

function (repo::InMemoryOrderRepository, id::Int)::Union{Nothing, OrdenTrabajo}
    return get(orders_storage, id, nothing)
end

function (repo::InMemoryOrderRepository)::Vector{OrdenTrabajo}
    return values(orders_storage)
end

function (repo::InMemoryOrderRepository, id::Int)::Void
    delete!(orders_storage, id)
end

end  # module MemoryRepository