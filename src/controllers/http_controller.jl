module HttpController

using HTTP
using JSON
using Servigest.Application

# Define a function to handle incoming HTTP requests
function handle_request(req::HTTP.Request)
    # Parse the request path and method
    path = req.target
    method = req.method

    # Route the request based on the path and method
    if method == "POST" && path == "/ordenes"
        # Create a new order
        order_data = JSON.parse(String(req.body))
        result = create_order(order_data)
        return HTTP.Response(201, JSON.json(result))
    elseif method == "GET" && startswith(path, "/ordenes/")
        # Get order details
        order_id = parse(Int, split(path, "/")[3])
        result = get_order(order_id)
        return HTTP.Response(200, JSON.json(result))
    else
        return HTTP.Response(404, "Not Found")
    end
end

# Function to start the HTTP server
function start_server(port::Int)
    HTTP.serve(handle_request, "0.0.0.0", port)
end

end # module HttpController