# ===================================
# SCRIPT DE CONFIGURACIÓN DEL SISTEMA RF DASHBOARD
# ===================================

using Pkg

# Función para instalar paquetes necesarios
function install_rf_dashboard_dependencies()
    println("🔧 Instalando dependencias del RF Dashboard...")
    
    required_packages = [
        "LibPQ",      # PostgreSQL
        "HTTP",       # Servidor web
        "JSON",       # Manejo de JSON
        "Dates",      # Manejo de fechas
        "Plots",      # Para gráficos (opcional)
        "PlotlyJS"    # Para gráficos interactivos (opcional)
    ]
    
    for pkg in required_packages
        try
            println("📦 Instalando $pkg...")
            Pkg.add(pkg)
            println("✅ $pkg instalado correctamente")
        catch e
            println("❌ Error instalando $pkg: $e")
        end
    end
    
    println("🎉 Instalación de dependencias completada!")
end

# Función para verificar la conexión a la base de datos
function test_database_connection()
    println("🔍 Verificando conexión a la base de datos...")
    
    # Configuración de ejemplo - AJUSTA ESTOS VALORES
    config = Dict(
        "host" => "localhost",
        "port" => 5432,
        "dbname" => "servigest_rf",
        "user" => "postgres",
        "password" => "tu_password"
    )
    
    try
        conn_string = "host=$(config["host"]) port=$(config["port"]) dbname=$(config["dbname"]) user=$(config["user"]) password=$(config["password"])"
        conn = LibPQ.Connection(conn_string)
        
        # Probar consulta simple
        result = execute(conn, "SELECT COUNT(*) as total FROM componentes_rf")
        total_components = first(result).total
        
        println("✅ Conexión exitosa!")
        println("📊 Total de componentes en la BD: $total_components")
        
        close(conn)
        return true
        
    catch e
        println("❌ Error de conexión: $e")
        println("💡 Revisa la configuración de la base de datos")
        return false
    end
end

# Función para crear la estructura de directorios
function setup_directory_structure()
    println("📁 Creando estructura de directorios...")
    
    directories = [
        "templates",      # Para archivos HTML
        "static",         # Para CSS, JS, imágenes
        "reports",        # Para reportes generados
        "backups",        # Para backups de datos
        "charts",         # Para gráficos generados
        "logs"            # Para logs del sistema
    ]
    
    for dir in directories
        if !isdir(dir)
            mkdir(dir)
            println("✅ Directorio creado: $dir")
        else
            println("ℹ️  Directorio ya existe: $dir")
        end
    end
end

# Función para crear archivos de configuración
function create_config_files()
    println("⚙️  Creando archivos de configuración...")
    
    # Archivo de configuración de base de datos
    db_config = """
# Configuración de Base de Datos RF
[database]
host = "localhost"
port = 5432
dbname = "servigest_rf"
user = "postgres"
password = "tu_password"

[server]
port = 8080
host = "localhost"

[system]
max_components_display = 50
backup_interval_hours = 24
log_level = "INFO"
"""
    
    if !isfile("config.toml")
        write("config.toml", db_config)
        println("✅ Archivo de configuración creado: config.toml")
    else
        println("ℹ️  Archivo de configuración ya existe: config.toml")
    end
    
    # Script de inicio
    startup_script = """
#!/usr/bin/env julia

# Script de inicio del RF Dashboard
# Ejecutar con: julia startup.jl

include("rf_dashboard.jl")

println("🚀 Iniciando RF Dashboard...")
println("📍 Servidor disponible en http://localhost:8080")

# Iniciar servidor
serve_rf_dashboard(8080)
"""
    
    if !isfile("startup.jl")
        write("startup.jl", startup_script)
        println("✅ Script de inicio creado: startup.jl")
    else
        println("ℹ️  Script de inicio ya existe: startup.jl")
    end
end

# Función para verificar la estructura de la base de datos
function verify_database_structure()
    println("🔍 Verificando estructura de la base de datos...")
    
    required_tables = [
        "categorias_componentes",
        "fabricantes",
        "proveedores", 
        "componentes_rf",
        "equipos_rf",
        "historial_reparaciones",
        "calibraciones"
    ]
    
    try
        conn_string = "host=localhost port=5432 dbname=servigest_rf user=postgres password=tu_password"
        conn = LibPQ.Connection(conn_string)
        
        for table in required_tables
            try
                result = execute(conn, "SELECT COUNT(*) FROM $table")
                count = first(result)[1]
                println("✅ Tabla $table: $count registros")
            catch e
                println("❌ Tabla $table no encontrada o error: $e")
            end
        end
        
        close(conn)
        
    catch e
        println("❌ Error verificando estructura: $e")
    end
end

# Función principal de configuración
function setup_rf_dashboard()
    println("🎯 CONFIGURACIÓN DEL SISTEMA RF DASHBOARD")
    println("=" ^ 50)
    
    # Paso 1: Instalar dependencias
    install_rf_dashboard_dependencies()
    println()
    
    # Paso 2: Crear estructura de directorios
    setup_directory_structure()
    println()
    
    # Paso 3: Crear archivos de configuración
    create_config_files()
    println()
    
    # Paso 4: Verificar conexión a BD
    if test_database_connection()
        println()
        
        # Paso 5: Verificar estructura de BD
        verify_database_structure()
    end
    
    println()
    println("🎉 CONFIGURACIÓN COMPLETADA!")
    println()
    println("📋 PRÓXIMOS PASOS:")
    println("1. Edita config.toml con los datos de tu base de datos")
    println("2. Guarda el template HTML como templates/servigest_template.html") 
    println("3. Ejecuta: julia startup.jl")
    println()
    println("🌐 URLs disponibles:")
    println("   - Dashboard: http://localhost:8080/dashboard")
    println("   - API Critical: http://localhost:8080/api/critical-inventory")
    println("   - API Calibration: http://localhost:8080/api/calibration-schedule")
    println("   - API Repairs: http://localhost:8080/api/pending-repairs")
end

# Función para generar datos de prueba
function generate_test_data()
    println("🧪 Generando datos de prueba...")
    
    try
        conn_string = "host=localhost port=5432 dbname=servigest_rf user=postgres password=tu_password"
        conn = LibPQ.Connection(conn_string)
        
        # Insertar algunos componentes de prueba adicionales
        test_components = [
            ("TEST-001", "Componente de Prueba 1", 1, 1, "Componente para testing", 100.0, 1000.0, 1.0, 5.0, -40, 85, 50, 10.0, 1.5, 25.50, 10, 5, "TEST-01"),
            ("TEST-002", "Componente de Prueba 2", 2, 2, "Otro componente para testing", 200.0, 2000.0, 2.0, 3.3, -20, 70, 50, 15.0, 1.3, 35.75, 5, 3, "TEST-02")
        ]
        
        for comp in test_components
            try
                execute(conn, """
                    INSERT INTO componentes_rf 
                    (codigo_parte, nombre, id_categoria, id_fabricante, descripcion, 
                     frecuencia_min_mhz, frecuencia_max_mhz, potencia_max_w, voltaje_operacion_v,
                     temperatura_min_c, temperatura_max_c, impedancia_ohm, ganancia_db, vswr_max,
                     precio_usd, stock_actual, stock_minimo, ubicacion_almacen)
                    VALUES (\$1, \$2, \$3, \$4, \$5, \$6, \$7, \$8, \$9, \$10, \$11, \$12, \$13, \$14, \$15, \$16, \$17, \$18)
                    ON CONFLICT (codigo_parte) DO NOTHING
                """, comp)
                println("✅ Componente de prueba insertado: $(comp[1])")
            catch e
                println("ℹ️  Componente $(comp[1]) ya existe o error: $e")
            end
        end
        
        close(conn)
        println("🎉 Datos de prueba generados!")
        
    catch e
        println("❌ Error generando datos de prueba: $e")
    end
end

# Función para limpiar el sistema
function cleanup_rf_dashboard()
    println("🧹 Limpiando archivos temporales...")
    
    temp_files = ["*.log", "reports/*.tmp", "backups/*.tmp"]
    
    for pattern in temp_files
        try
            for file in glob(pattern)
                rm(file)
                println("🗑️  Eliminado: $file")
            end
        catch e
            # Ignorar errores de archivos no encontrados
        end
    end
    
    println("✅ Limpieza completada!")
end

# ===================================
# FUNCIONES DE UTILIDAD
# ===================================

# Función para mostrar el estado del sistema
function system_status()
    println("📊 ESTADO DEL SISTEMA RF DASHBOARD")
    println("=" ^ 40)
    
    # Verificar paquetes
    required_packages = ["LibPQ", "HTTP", "JSON", "Dates"]
    for pkg in required_packages
        try
            eval(Meta.parse("using $pkg"))
            println("✅ Paquete $pkg: OK")
        catch
            println("❌ Paquete $pkg: NO INSTALADO")
        end
    end
    
    # Verificar archivos
    required_files = ["config.toml", "startup.jl"]
    for file in required_files
        if isfile(file)
            println("✅ Archivo $file: OK")
        else
            println("❌ Archivo $file: NO ENCONTRADO")
        end
    end
    
    # Verificar directorios
    required_dirs = ["templates", "static", "reports", "backups"]
    for dir in required_dirs
        if isdir(dir)
            println("✅ Directorio $dir: OK")
        else
            println("❌ Directorio $dir: NO ENCONTRADO")
        end
    end
    
    # Verificar conexión BD
    if test_database_connection()
        println("✅ Base de datos: OK")
    else
        println("❌ Base de datos: ERROR")
    end
end

# ===================================
# EJECUCIÓN
# ===================================

if abspath(PROGRAM_FILE) == @__FILE__
    println("🎯 RF Dashboard Setup")
    println("Selecciona una opción:")
    println("1. Configuración completa")
    println("2. Solo instalar dependencias")
    println("3. Solo verificar conexión BD")
    println("4. Generar datos de prueba")
    println("5. Estado del sistema")
    println("6. Limpiar archivos temporales")
    
    print("Opción (1-6): ")
    option = readline()
    
    if option == "1"
        setup_rf_dashboard()
    elseif option == "2"
        install_rf_dashboard_dependencies()
    elseif option == "3"
        test_database_connection()
    elseif option == "4"
        generate_test_data()
    elseif option == "5"
        system_status()
    elseif option == "6"
        cleanup_rf_dashboard()
    else
        println("❌ Opción no válida")
    end
end