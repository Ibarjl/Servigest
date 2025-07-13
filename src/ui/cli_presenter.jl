module UIPresenter

export display_order, display_technician, display_client

function display_order(order)
    println("Order ID: ", order.id)
    println("Client: ", order.client.name)
    println("Technician: ", order.technician.name)
    println("Status: ", order.status)
    println("Description: ", order.description)
    println("Created At: ", order.created_at)
    println("Due Date: ", order.due_date)
    println("===================================")
end

function display_technician(technician)
    println("Technician ID: ", technician.id)
    println("Name: ", technician.name)
    println("Specialization: ", technician.specialization)
    println("Available: ", technician.available ? "Yes" : "No")
    println("===================================")
end

function display_client(client)
    println("Client ID: ", client.id)
    println("Name: ", client.name)
    println("Contact: ", client.contact)
    println("===================================")
end

end # module UIPresenter