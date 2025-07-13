module Servigest

using .domain.entities
using .infrastructure.persistence

export crear_orden, asignar_tecnico

function crear_orden(cliente::Cliente, detalles::String)
    orden = OrdenTrabajo(cliente, detalles)
    # Aquí se podría agregar lógica adicional, como validaciones
    return orden
end

function asignar_tecnico(orden::OrdenTrabajo, tecnico::Tecnico)
    # Lógica para asignar un técnico a una orden de trabajo
    orden.tecnico = tecnico
    # Aquí se podría agregar lógica adicional, como notificaciones
end

end