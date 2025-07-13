module Servigest

export create_order, assign_technician, Order, Technician, Client

# Initialization code can be added here

# Function to create a new order
function create_order(client::Client, technician::Technician, details::String)
    # Implementation will be in use_cases.jl
end

# Function to assign a technician to an order
function assign_technician(order::Order, technician::Technician)
    # Implementation will be in use_cases.jl
end

end