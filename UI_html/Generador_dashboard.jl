using Dates
using LibPQ  # Para PostgreSQL
using JSON   # Para manejo de JSON en APIs
using HTTP   # Para servidor web
# using MySQL  # Para MySQL - descomenta si usas MySQL
# using SQLite  # Para SQLite - descomenta si usas SQLite

# Función para conectar a la base de datos RF
function connect_rf_database()
    # Configuración de conexión - AJUSTA ESTOS VALORES
    conn_string = "host=localhost port=5432 dbname=servigest_rf user=postgres password=tu_password"
    
    try
        conn = LibPQ.Connection(conn_string)
        println("✅ Conexión exitosa a la base de datos RF")
        return conn
    catch e
        println("❌ Error conectando a la base de datos: $e")
        return nothing
    end
end

# Función para procesar el template HTML con datos dinámicos de la BD RF
function generate_dashboard(template_path::String, output_path::String)
    # Leer el template HTML
    template_content = read(template_path, String)
    
    # Conectar a la base de datos
    conn = connect_rf_database()
    if conn === nothing
        println("❌ No se pudo conectar a la base de datos")
        return
    end
    
    try
        # ============================================
        # OBTENER DATOS DINÁMICOS DE LA BD RF
        # ============================================
        
        # Resumen de inventario desde la base de datos
        inventory_summary = get_inventory_summary_from_db(conn)
        
        # Lista de componentes desde la base de datos
        components_list = get_components_from_db(conn)
        
        # Obtener listas únicas para filtros
        unique_component_types = get_unique_component_types(conn)
        unique_brands = get_unique_brands(conn)
        
        # URLs de gráficos (puedes generar estos con Plots.jl o PlotlyJS.jl)
        trend_chart_url = generate_trend_chart(conn)
        pareto_chart_url = generate_pareto_chart(conn)
        
        # ============================================
        # REEMPLAZAR PLACEHOLDERS
        # ============================================
        
        # Reemplazar datos de resumen
        template_content = replace(template_content, "TOTAL_INVENTARIO_PLACEHOLDER" => string(inventory_summary["total_inventario"]))
        template_content = replace(template_content, "EN_STOCK_PLACEHOLDER" => string(inventory_summary["en_stock"]))
        template_content = replace(template_content, "BAJO_STOCK_PLACEHOLDER" => string(inventory_summary["bajo_stock"]))
        template_content = replace(template_content, "SIN_STOCK_PLACEHOLDER" => string(inventory_summary["sin_stock"]))
        
        # Generar opciones para dropdowns
        component_types_options = join(["""<option value="$tipo">$tipo</option>""" for tipo in unique_component_types], "\n                                ")
        brands_options = join(["""<option value="$marca">$marca</option>""" for marca in unique_brands], "\n                                ")
        
        template_content = replace(template_content, "COMPONENT_TYPES_OPTIONS_PLACEHOLDER" => component_types_options)
        template_content = replace(template_content, "BRANDS_OPTIONS_PLACEHOLDER" => brands_options)
        
        # Generar filas de la tabla
        table_rows = generate_table_rows(components_list)
        template_content = replace(template_content, "COMPONENTS_TABLE_ROWS_PLACEHOLDER" => table_rows)
        
        # Reemplazar URLs de gráficos
        template_content = replace(template_content, "TREND_CHART_URL_PLACEHOLDER" => trend_chart_url)
        template_content = replace(template_content, "PARETO_CHART_URL_PLACEHOLDER" => pareto_chart_url)
        
        # Escribir el archivo final
        write(output_path, template_content)
        
        println("✅ Dashboard RF generado exitosamente en: $output_path")
        
    finally
        # Cerrar conexión
        close(conn)
    end
end

# ============================================
# FUNCIONES PARA CONSULTAS A LA BD RF
# ============================================

# Obtener resumen de inventario desde la BD
function get_inventory_summary_from_db(conn)
    try
        # Consulta para obtener resumen de inventario
        query = """
        SELECT 
            COUNT(*) as total_inventario,
            SUM(CASE WHEN stock_actual > stock_minimo THEN 1 ELSE 0 END) as en_stock,
            SUM(CASE WHEN stock_actual <= stock_minimo AND stock_actual > 0 THEN 1 ELSE 0 END) as bajo_stock,
            SUM(CASE WHEN stock_actual = 0 THEN 1 ELSE 0 END) as sin_stock
        FROM componentes_rf
        """
        
        result = execute(conn, query)
        row = first(result)
        
        return Dict(
            "total_inventario" => row.total_inventario,
            "en_stock" => row.en_stock,
            "bajo_stock" => row.bajo_stock,
            "sin_stock" => row.sin_stock
        )
    catch e
        println("❌ Error obteniendo resumen de inventario: $e")
        return Dict(
            "total_inventario" => 0,
            "en_stock" => 0, 
            "bajo_stock" => 0,
            "sin_stock" => 0
        )
    end
end

# Obtener lista de componentes desde la BD
function get_components_from_db(conn)
    try
        query = """
        SELECT 
            c.codigo_parte,
            c.nombre,
            f.nombre as marca,
            c.stock_actual,
            c.precio_usd,
            c.fecha_adquisicion,
            CASE 
                WHEN c.stock_actual = 0 THEN 'Sin Stock'
                WHEN c.stock_actual <= c.stock_minimo THEN 'Bajo Stock'
                ELSE 'En Stock'
            END as estado_stock,
            cat.nombre as categoria
        FROM componentes_rf c
        JOIN fabricantes f ON c.id_fabricante = f.id_fabricante
        JOIN categorias_componentes cat ON c.id_categoria = cat.id_categoria
        ORDER BY c.codigo_parte
        LIMIT 50  -- Limitar resultados para el dashboard
        """
        
        result = execute(conn, query)
        components = []
        
        for row in result
            push!(components, Dict(
                "codigo_parte" => row.codigo_parte,
                "nombre" => row.nombre,
                "marca" => row.marca,
                "stock_actual" => row.stock_actual,
                "precio_usd" => row.precio_usd,
                "fecha_adquisicion" => row.fecha_adquisicion,
                "estado_stock" => row.estado_stock,
                "categoria" => row.categoria
            ))
        end
        
        return components
    catch e
        println("❌ Error obteniendo componentes: $e")
        return []
    end
end

# Obtener tipos únicos de componentes
function get_unique_component_types(conn)
    try
        query = "SELECT DISTINCT nombre FROM categorias_componentes ORDER BY nombre"
        result = execute(conn, query)
        return [row.nombre for row in result]
    catch e
        println("❌ Error obteniendo tipos de componentes: $e")
        return ["Semiconductores RF", "Componentes Pasivos", "Conectores RF"]
    end
end

# Obtener marcas únicas
function get_unique_brands(conn)
    try
        query = "SELECT DISTINCT nombre FROM fabricantes ORDER BY nombre"
        result = execute(conn, query)
        return [row.nombre for row in result]
    catch e
        println("❌ Error obteniendo marcas: $e")
        return ["Analog Devices", "Mini-Circuits", "Keysight"]
    end
end

# Generar gráfico de tendencias (placeholder)
function generate_trend_chart(conn)
    try
        # Aquí puedes generar gráficos reales con Plots.jl
        # Por ahora devolvemos URL de placeholder
        query = """
        SELECT 
            DATE_TRUNC('month', hr.fecha_inicio) as mes,
            COUNT(*) as reparaciones
        FROM historial_reparaciones hr
        WHERE hr.fecha_inicio >= CURRENT_DATE - INTERVAL '12 months'
        GROUP BY DATE_TRUNC('month', hr.fecha_inicio)
        ORDER BY mes
        """
        
        # result = execute(conn, query)
        # Aquí podrías generar un gráfico real y guardar la imagen
        
        return "https://lh3.googleusercontent.com/aida-public/AB6AXuDQq10j6fD4Ua5i_2q2r7H2_X7x6y5F9r4e5K6A7N8r0w0c9T1g0d5X1_L6a3s4J5K6I7_U8v8n7p4l3l3h2f1k_i4m1g5o3c4n5e6"
    catch e
        println("❌ Error generando gráfico de tendencias: $e")
        return "https://lh3.googleusercontent.com/aida-public/AB6AXuDQq10j6fD4Ua5i_2q2r7H2_X7x6y5F9r4e5K6A7N8r0w0c9T1g0d5X1_L6a3s4J5K6I7_U8v8n7p4l3l3h2f1k_i4m1g5o3c4n5e6"
    end
end

# Generar gráfico de Pareto de fallas
function generate_pareto_chart(conn)
    try
        # Consulta para obtener problemas más comunes
        query = """
        SELECT 
            problema_reportado,
            COUNT(*) as frecuencia
        FROM historial_reparaciones
        WHERE problema_reportado IS NOT NULL
        GROUP BY problema_reportado
        ORDER BY COUNT(*) DESC
        LIMIT 10
        """
        
        # result = execute(conn, query)
        # Aquí podrías generar un gráfico de Pareto real
        
        return "https://lh3.googleusercontent.com/aida-public/AB6AXuC7r8Q9P0_L1o2k3i4j5l6m7n8p9q0r1s2t3u4v5w6x7y8z9a0b1c2d3e4f5g6h7i8j9k0l1m2n3o4p5"
    catch e
        println("❌ Error generando gráfico de Pareto: $e")
        return "https://lh3.googleusercontent.com/aida-public/AB6AXuC7r8Q9P0_L1o2k3i4j5l6m7n8p9q0r1s2t3u4v5w6x7y8z9a0b1c2d3e4f5g6h7i8j9k0l1m2n3o4p5"
    end
end

# Función para generar las filas de la tabla de componentes RF
function generate_table_rows(components_list::Vector{Dict})
    rows = String[]
    
    for component in components_list
        # Determinar clase CSS según el estado
        status_class = if component["estado_stock"] == "En Stock"
            "bg-green-100 text-green-800"
        elseif component["estado_stock"] == "Bajo Stock"
            "bg-orange-100 text-orange-800"
        else
            "bg-red-100 text-red-800"
        end
        
        # Formatear fecha si existe
        fecha_formateada = if component["fecha_adquisicion"] !== nothing
            Dates.format(component["fecha_adquisicion"], "yyyy-mm-dd")
        else
            "N/A"
        end
        
        # Generar fila HTML
        row = """
                            <tr class="bg-white border-b hover:bg-gray-50 cursor-pointer">
                                <td class="px-6 py-4 font-medium text-gray-900">$(component["codigo_parte"])</td>
                                <td class="px-6 py-4">$(component["nombre"])</td>
                                <td class="px-6 py-4">$(component["marca"])</td>
                                <td class="px-6 py-4">$(component["stock_actual"])</td>
                                <td class="px-6 py-4">\$(component["precio_usd"])</td>
                                <td class="px-6 py-4">$fecha_formateada</td>
                                <td class="px-6 py-4">
                                    <span class="$status_class text-xs font-medium mr-2 px-2.5 py-0.5 rounded-full">$(component["estado_stock"])</span>
                                </td>
                            </tr>"""
        
        push!(rows, row)
    end
    
    return join(rows, "\n")
end

# ============================================
# FUNCIONES ESPECIALIZADAS PARA RF
# ============================================

# Obtener componentes críticos (usando la vista inventario_critico)
function get_critical_inventory(conn)
    try
        query = "SELECT * FROM inventario_critico LIMIT 10"
        result = execute(conn, query)
        return [Dict(
            "codigo_parte" => row.codigo_parte,
            "nombre" => row.nombre,
            "categoria" => row.categoria,
            "deficit" => row.deficit,
            "costo_reposicion" => row.costo_reposicion
        ) for row in result]
    catch e
        println("❌ Error obteniendo inventario crítico: $e")
        return []
    end
end

# Obtener equipos que necesitan calibración próxima
function get_equipment_needing_calibration(conn)
    try
        query = """
        SELECT 
            numero_serie,
            modelo,
            f.nombre as fabricante,
            ubicacion,
            responsable,
            proxima_calibracion,
            (proxima_calibracion - CURRENT_DATE) as dias_restantes
        FROM equipos_rf e
        JOIN fabricantes f ON e.id_fabricante = f.id_fabricante
        WHERE calibracion_requerida = true 
        AND proxima_calibracion <= CURRENT_DATE + INTERVAL '30 days'
        ORDER BY proxima_calibracion
        """
        
        result = execute(conn, query)
        return [Dict(
            "numero_serie" => row.numero_serie,
            "modelo" => row.modelo,
            "fabricante" => row.fabricante,
            "ubicacion" => row.ubicacion,
            "responsable" => row.responsable,
            "proxima_calibracion" => row.proxima_calibracion,
            "dias_restantes" => row.dias_restantes
        ) for row in result]
    catch e
        println("❌ Error obteniendo equipos para calibración: $e")
        return []
    end
end

# Obtener reparaciones pendientes
function get_pending_repairs(conn)
    try
        query = """
        SELECT 
            r.id_reparacion,
            e.numero_serie,
            e.modelo,
            r.fecha_inicio,
            r.tecnico_asignado,
            r.problema_reportado,
            (CURRENT_DATE - r.fecha_inicio) as dias_transcurridos
        FROM historial_reparaciones r
        JOIN equipos_rf e ON r.id_equipo = e.id_equipo
        WHERE r.fecha_fin IS NULL
        ORDER BY r.fecha_inicio
        """
        
        result = execute(conn, query)
        return [Dict(
            "numero_serie" => row.numero_serie,
            "modelo" => row.modelo,
            "fecha_inicio" => row.fecha_inicio,
            "tecnico_asignado" => row.tecnico_asignado,
            "problema_reportado" => row.problema_reportado,
            "dias_transcurridos" => row.dias_transcurridos
        ) for row in result]
    catch e
        println("❌ Error obteniendo reparaciones pendientes: $e")
        return []
    end
end

# Generar reporte de costos de mantenimiento
function generate_maintenance_cost_report(conn, fecha_inicio::Date, fecha_fin::Date)
    try
        query = """
        SELECT 
            e.numero_serie,
            e.modelo,
            f.nombre as fabricante,
            COUNT(r.id_reparacion) as total_reparaciones,
            COALESCE(SUM(r.costo_reparacion), 0) as costo_total,
            COALESCE(AVG(r.costo_reparacion), 0) as costo_promedio
        FROM equipos_rf e
        JOIN fabricantes f ON e.id_fabricante = f.id_fabricante
        LEFT JOIN historial_reparaciones r ON e.id_equipo = r.id_equipo
            AND r.fecha_inicio BETWEEN $(1) AND $(2)
        GROUP BY e.id_equipo, e.numero_serie, e.modelo, f.nombre
        HAVING COUNT(r.id_reparacion) > 0
        ORDER BY costo_total DESC
        """
        
        result = execute(conn, query, [fecha_inicio, fecha_fin])
        return [Dict(
            "numero_serie" => row.numero_serie,
            "modelo" => row.modelo,
            "fabricante" => row.fabricante,
            "total_reparaciones" => row.total_reparaciones,
            "costo_total" => row.costo_total,
            "costo_promedio" => round(row.costo_promedio, digits=2)
        ) for row in result]
    catch e
        println("❌ Error generando reporte de costos: $e")
        return []
    end
end

# Obtener estadísticas de equipos por estado
function get_equipment_status_stats(conn)
    try
        query = """
        SELECT 
            estado,
            COUNT(*) as cantidad_equipos,
            ROUND(AVG(valor_usd), 2) as valor_promedio,
            SUM(valor_usd) as valor_total
        FROM equipos_rf 
        GROUP BY estado
        ORDER BY cantidad_equipos DESC
        """
        
        result = execute(conn, query)
        return [Dict(
            "estado" => row.estado,
            "cantidad_equipos" => row.cantidad_equipos,
            "valor_promedio" => row.valor_promedio,
            "valor_total" => row.valor_total
        ) for row in result]
    catch e
        println("❌ Error obteniendo estadísticas de equipos: $e")
        return []
    end
end

# ============================================
# USO DEL CÓDIGO
# ============================================

# Para generar el dashboard:
# generate_dashboard("servigest_template.html", "dashboard_rf.html")

# Para uso con servidor web (usando HTTP.jl):
using HTTP

# Servidor web especializado para el sistema RF
function serve_rf_dashboard(port::Int=8080)
    function handle_request(req::HTTP.Request)
        conn = connect_rf_database()
        if conn === nothing
            return HTTP.Response(500, "Error de conexión a la base de datos")
        end
        
        try
            if req.target == "/" || req.target == "/dashboard"
                # Dashboard principal
                template_content = read("servigest_template.html", String)
                
                # Obtener datos frescos de la BD RF
                inventory_summary = get_inventory_summary_from_db(conn)
                components_list = get_components_from_db(conn)
                unique_component_types = get_unique_component_types(conn)
                unique_brands = get_unique_brands(conn)
                
                # Procesar template...
                processed_content = process_template_in_memory(template_content, inventory_summary, components_list, unique_component_types, unique_brands)
                
                return HTTP.Response(200, ["Content-Type" => "text/html"], processed_content)
                
            elseif req.target == "/api/critical-inventory"
                # API endpoint para inventario crítico
                critical_items = get_critical_inventory(conn)
                return HTTP.Response(200, ["Content-Type" => "application/json"], JSON.json(critical_items))
                
            elseif req.target == "/api/calibration-schedule"
                # API endpoint para equipos que necesitan calibración
                calibration_items = get_equipment_needing_calibration(conn)
                return HTTP.Response(200, ["Content-Type" => "application/json"], JSON.json(calibration_items))
                
            elseif req.target == "/api/pending-repairs"
                # API endpoint para reparaciones pendientes
                pending_repairs = get_pending_repairs(conn)
                return HTTP.Response(200, ["Content-Type" => "application/json"], JSON.json(pending_repairs))
                
            elseif startswith(req.target, "/api/maintenance-report")
                # API endpoint para reporte de costos de mantenimiento
                # Ejemplo: /api/maintenance-report?start=2024-01-01&end=2024-12-31
                query_params = parse_query_params(req.target)
                fecha_inicio = Date(get(query_params, "start", "2024-01-01"))
                fecha_fin = Date(get(query_params, "end", "2024-12-31"))
                
                report = generate_maintenance_cost_report(conn, fecha_inicio, fecha_fin)
                return HTTP.Response(200, ["Content-Type" => "application/json"], JSON.json(report))
                
            elseif req.target == "/api/equipment-stats"
                # API endpoint para estadísticas de equipos
                stats = get_equipment_status_stats(conn)
                return HTTP.Response(200, ["Content-Type" => "application/json"], JSON.json(stats))
                
            else
                return HTTP.Response(404, "Página no encontrada")
            end
            
        finally
            close(conn)
        end
    end
    
    HTTP.serve(handle_request, "localhost", port)
    println("🚀 Servidor RF Dashboard corriendo en http://localhost:$port")
    println("📊 Endpoints disponibles:")
    println("   - http://localhost:$port/dashboard")
    println("   - http://localhost:$port/api/critical-inventory")
    println("   - http://localhost:$port/api/calibration-schedule")
    println("   - http://localhost:$port/api/pending-repairs")
    println("   - http://localhost:$port/api/maintenance-report")
    println("   - http://localhost:$port/api/equipment-stats")
end

# Función auxiliar para procesar template en memoria
function process_template_in_memory(template_content, inventory_summary, components_list, unique_component_types, unique_brands)
    # Reemplazar placeholders (mismo código que generate_dashboard pero sin escribir archivo)
    processed = replace(template_content, "TOTAL_INVENTARIO_PLACEHOLDER" => string(inventory_summary["total_inventario"]))
    processed = replace(processed, "EN_STOCK_PLACEHOLDER" => string(inventory_summary["en_stock"]))
    processed = replace(processed, "BAJO_STOCK_PLACEHOLDER" => string(inventory_summary["bajo_stock"]))
    processed = replace(processed, "SIN_STOCK_PLACEHOLDER" => string(inventory_summary["sin_stock"]))
    
    component_types_options = join(["""<option value="$tipo">$tipo</option>""" for tipo in unique_component_types], "\n                                ")
    brands_options = join(["""<option value="$marca">$marca</option>""" for marca in unique_brands], "\n                                ")
    
    processed = replace(processed, "COMPONENT_TYPES_OPTIONS_PLACEHOLDER" => component_types_options)
    processed = replace(processed, "BRANDS_OPTIONS_PLACEHOLDER" => brands_options)
    
    table_rows = generate_table_rows(components_list)
    processed = replace(processed, "COMPONENTS_TABLE_ROWS_PLACEHOLDER" => table_rows)
    
    # URLs de gráficos por defecto
    processed = replace(processed, "TREND_CHART_URL_PLACEHOLDER" => "https://lh3.googleusercontent.com/aida-public/AB6AXuDQq10j6fD4Ua5i_2q2r7H2_X7x6y5F9r4e5K6A7N8r0w0c9T1g0d5X1_L6a3s4J5K6I7_U8v8n7p4l3l3h2f1k_i4m1g5o3c4n5e6")
    processed = replace(processed, "PARETO_CHART_URL_PLACEHOLDER" => "https://lh3.googleusercontent.com/aida-public/AB6AXuC7r8Q9P0_L1o2k3i4j5l6m7n8p9q0r1s2t3u4v5w6x7y8z9a0b1c2d3e4f5g6h7i8j9k0l1m2n3o4p5")
    
    return processed
end

# Función auxiliar para parsear parámetros de query
function parse_query_params(url::String)
    params = Dict{String, String}()
    if contains(url, "?")
        query_string = split(url, "?")[2]
        for param in split(query_string, "&")
            if contains(param, "=")
                key, value = split(param, "=")
                params[key] = value
            end
        end
    end
    return params
end

# ============================================
# FUNCIONES DE UTILIDAD PARA REPORTES
# ============================================

# Generar reporte completo de inventario crítico
function generate_critical_inventory_report(output_file::String="critical_inventory_report.txt")
    conn = connect_rf_database()
    if conn === nothing
        return
    end
    
    try
        critical_items = get_critical_inventory(conn)
        
        open(output_file, "w") do file
            write(file, "REPORTE DE INVENTARIO CRÍTICO - COMPONENTES RF\n")
            write(file, "=" ^ 60 * "\n")
            write(file, "Fecha del reporte: $(Dates.format(Dates.today(), "yyyy-mm-dd"))\n\n")
            
            for item in critical_items
                write(file, "Código: $(item["codigo_parte"])\n")
                write(file, "Componente: $(item["nombre"])\n")
                write(file, "Categoría: $(item["categoria"])\n")
                write(file, "Déficit: $(item["deficit"]) unidades\n")
                write(file, "Costo de reposición: \$$(item["costo_reposicion"])\n")
                write(file, "-" ^ 40 * "\n")
            end
        end
        
        println("✅ Reporte de inventario crítico generado: $output_file")
    finally
        close(conn)
    end
end

# Función para backup de datos críticos
function backup_critical_data()
    conn = connect_rf_database()
    if conn === nothing
        return
    end
    
    try
        timestamp = Dates.format(Dates.now(), "yyyy-mm-dd_HH-MM-SS")
        
        # Backup de componentes críticos
        critical_components = get_critical_inventory(conn)
        
        # Backup de equipos que necesitan calibración
        calibration_needed = get_equipment_needing_calibration(conn)
        
        # Backup de reparaciones pendientes
        pending_repairs = get_pending_repairs(conn)
        
        backup_data = Dict(
            "timestamp" => timestamp,
            "critical_components" => critical_components,
            "calibration_needed" => calibration_needed,
            "pending_repairs" => pending_repairs
        )
        
        backup_file = "rf_backup_$timestamp.json"
        open(backup_file, "w") do file
            JSON.print(file, backup_data, 2)  # Pretty print with indentation
        end
        
        println("✅ Backup de datos críticos generado: $backup_file")
        
    finally
        close(conn)
    end
end

# ============================================
# EJEMPLOS DE USO
# ============================================

"""
Ejemplos de uso del sistema:

# 1. Generar dashboard estático
generate_dashboard("servigest_template.html", "dashboard_rf.html")

# 2. Iniciar servidor web
serve_rf_dashboard(8080)

# 3. Generar reportes
generate_critical_inventory_report()
backup_critical_data()

# 4. Consultar datos específicos
conn = connect_rf_database()
critical_items = get_critical_inventory(conn)
equipment_needing_calibration = get_equipment_needing_calibration(conn)
close(conn)

# 5. APIs REST disponibles:
# GET /api/critical-inventory
# GET /api/calibration-schedule  
# GET /api/pending-repairs
# GET /api/maintenance-report?start=2024-01-01&end=2024-12-31
# GET /api/equipment-stats
"""

# Para correr el servidor:
# serve_rf_dashboard()