module Servigest

export OrdenTrabajo, Tecnico, Cliente

# Definición de la estructura de datos para Orden de Trabajo
struct OrdenTrabajo
    id::Int
    cliente::Cliente
    tecnico::Tecnico
    descripcion::String
    estado::String
end

# Definición de la estructura de datos para Técnico
struct Tecnico
    id::Int
    nombre::String
    especialidad::String
end

# Definición de la estructura de datos para Cliente
struct Cliente
    id::Int
    nombre::String
    contacto::String
end

end