module CLIController

using Servigest.Application
using Servigest.UI.CLI

function start()
    println("Bienvenido al Sistema de Ordenes de Trabajo")
    while true
        println("Seleccione una opción:")
        println("1. Crear Orden de Trabajo")
        println("2. Asignar Técnico")
        println("3. Salir")
        
        option = readline()
        
        if option == "1"
            crear_orden()
        elseif option == "2"
            asignar_tecnico()
        elseif option == "3"
            println("Saliendo del sistema...")
            break
        else
            println("Opción no válida. Intente de nuevo.")
        end
    end
end

function crear_orden()
    println("Ingrese los detalles de la orden de trabajo:")
    # Aquí se pueden agregar más detalles para la creación de la orden
    # Lógica para crear la orden usando el caso de uso correspondiente
end

function asignar_tecnico()
    println("Ingrese el ID de la orden y el ID del técnico:")
    # Aquí se pueden agregar más detalles para la asignación del técnico
    # Lógica para asignar el técnico usando el caso de uso correspondiente
end

end # module CLIController