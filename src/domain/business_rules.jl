module Servigest_Domain_BusinessRules

using .Entities

# Validates if the order can be created based on business rules
function validate_order_creation(order::OrdenTrabajo, cliente::Cliente, tecnico::Tecnico)
    if ismissing(cliente) || ismissing(tecnico)
        throw(ArgumentError("Cliente and Tecnico must be provided"))
    end

    if order.fecha_inicio > order.fecha_fin
        throw(ArgumentError("La fecha de inicio no puede ser posterior a la fecha de fin"))
    end

    # Add more business rules as needed
    return true
end

# Validates if a technician can be assigned to an order
function validate_technician_assignment(order::OrdenTrabajo, tecnico::Tecnico)
    if order.estado != "Pendiente"
        throw(ArgumentError("El técnico solo puede ser asignado a órdenes pendientes"))
    end

    # Add more validation rules as needed
    return true
end

# Function to transition the state of an order
function transition_order_state(order::OrdenTrabajo, new_state::String)
    valid_states = ["Pendiente", "En Progreso", "Completada", "Cancelada"]
    
    if !(new_state in valid_states)
        throw(ArgumentError("Estado inválido: $new_state"))
    end

    order.estado = new_state
    return order
end

end