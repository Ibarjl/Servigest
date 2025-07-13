-- ===================================
-- BASE DE DATOS DE COMPONENTES Y EQUIPOS RF - POSTGRESQL
-- ===================================

-- Crear tipos ENUM personalizados
CREATE TYPE tipo_equipo_enum AS ENUM (
    'Transmisor', 'Receptor', 'Transceptor', 'Analizador', 
    'Generador', 'Medidor', 'Amplificador', 'Antena', 'Otro'
);

CREATE TYPE estado_equipo_enum AS ENUM (
    'Operativo', 'En reparación', 'Fuera de servicio', 'En calibración'
);

CREATE TYPE estado_reparacion_enum AS ENUM (
    'En progreso', 'Completada', 'Pendiente de partes', 'Cancelada'
);

CREATE TYPE prioridad_enum AS ENUM (
    'Baja', 'Media', 'Alta', 'Crítica'
);

CREATE TYPE resultado_calibracion_enum AS ENUM (
    'Aprobado', 'Rechazado', 'Aprobado con ajustes'
);

-- Tabla de categorías de componentes
CREATE TABLE categorias_componentes (
    id_categoria SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    descripcion TEXT
);

-- Tabla de fabricantes
CREATE TABLE fabricantes (
    id_fabricante SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    pais VARCHAR(50),
    sitio_web VARCHAR(255),
    telefono VARCHAR(20),
    email VARCHAR(100)
);

-- Tabla de proveedores
CREATE TABLE proveedores (
    id_proveedor SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    contacto VARCHAR(100),
    telefono VARCHAR(20),
    email VARCHAR(100),
    direccion TEXT,
    tiempo_entrega_dias INTEGER
);

-- Tabla de componentes RF
CREATE TABLE componentes_rf (
    id_componente SERIAL PRIMARY KEY,
    codigo_parte VARCHAR(50) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    id_categoria INTEGER REFERENCES categorias_componentes(id_categoria),
    id_fabricante INTEGER REFERENCES fabricantes(id_fabricante),
    descripcion TEXT,
    frecuencia_min_mhz DECIMAL(10,3),
    frecuencia_max_mhz DECIMAL(10,3),
    potencia_max_w DECIMAL(8,3),
    voltaje_operacion_v DECIMAL(6,2),
    temperatura_min_c INTEGER,
    temperatura_max_c INTEGER,
    impedancia_ohm DECIMAL(8,2),
    ganancia_db DECIMAL(6,2),
    vswr_max DECIMAL(4,2),
    precio_usd DECIMAL(8,2),
    stock_actual INTEGER DEFAULT 0,
    stock_minimo INTEGER DEFAULT 1,
    ubicacion_almacen VARCHAR(50),
    datasheet_url VARCHAR(255),
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de equipos RF
CREATE TABLE equipos_rf (
    id_equipo SERIAL PRIMARY KEY,
    numero_serie VARCHAR(50) UNIQUE NOT NULL,
    modelo VARCHAR(100) NOT NULL,
    id_fabricante INTEGER REFERENCES fabricantes(id_fabricante),
    tipo_equipo tipo_equipo_enum,
    frecuencia_min_mhz DECIMAL(10,3),
    frecuencia_max_mhz DECIMAL(10,3),
    potencia_salida_w DECIMAL(8,3),
    voltaje_alimentacion_v DECIMAL(6,2),
    consumo_corriente_a DECIMAL(6,3),
    fecha_adquisicion DATE,
    estado estado_equipo_enum,
    ubicacion VARCHAR(100),
    responsable VARCHAR(100),
    valor_usd DECIMAL(10,2),
    manual_url VARCHAR(255),
    calibracion_requerida BOOLEAN DEFAULT FALSE,
    proxima_calibracion DATE,
    notas TEXT
);

-- Tabla de historial de reparaciones
CREATE TABLE historial_reparaciones (
    id_reparacion SERIAL PRIMARY KEY,
    id_equipo INTEGER REFERENCES equipos_rf(id_equipo),
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    tecnico_asignado VARCHAR(100),
    problema_reportado TEXT,
    diagnostico TEXT,
    solucion_aplicada TEXT,
    componentes_reemplazados TEXT,
    costo_reparacion DECIMAL(8,2),
    tiempo_reparacion_horas DECIMAL(5,1),
    estado_reparacion estado_reparacion_enum,
    prioridad prioridad_enum
);

-- Tabla de relación componentes usados en reparaciones
CREATE TABLE componentes_usados_reparacion (
    id SERIAL PRIMARY KEY,
    id_reparacion INTEGER REFERENCES historial_reparaciones(id_reparacion),
    id_componente INTEGER REFERENCES componentes_rf(id_componente),
    cantidad_usada INTEGER
);

-- Tabla de calibraciones
CREATE TABLE calibraciones (
    id_calibracion SERIAL PRIMARY KEY,
    id_equipo INTEGER REFERENCES equipos_rf(id_equipo),
    fecha_calibracion DATE NOT NULL,
    tecnico VARCHAR(100),
    laboratorio VARCHAR(100),
    certificado_numero VARCHAR(50),
    resultado resultado_calibracion_enum,
    tolerancia_cumplida BOOLEAN,
    proxima_fecha DATE,
    costo DECIMAL(8,2),
    observaciones TEXT
);

-- ===================================
-- DATOS DE EJEMPLO
-- ===================================

-- Insertar categorías de componentes
INSERT INTO categorias_componentes (nombre, descripcion) VALUES
('Semiconductores RF', 'Transistores, diodos y circuitos integrados para RF'),
('Componentes Pasivos', 'Resistores, capacitores, inductores para aplicaciones RF'),
('Conectores RF', 'Conectores coaxiales y adaptadores'),
('Cables RF', 'Cables coaxiales y guías de onda'),
('Filtros RF', 'Filtros pasa banda, pasa bajo, pasa alto'),
('Amplificadores', 'Amplificadores de potencia y bajo ruido'),
('Mezcladores', 'Mezcladores y multiplicadores de frecuencia'),
('Osciladores', 'Osciladores controlados por voltaje y cristal'),
('Antenas', 'Antenas direccionales y omnidireccionales'),
('Atenuadores', 'Atenuadores fijos y variables');

-- Insertar fabricantes
INSERT INTO fabricantes (nombre, pais, sitio_web, telefono, email) VALUES
('Analog Devices', 'Estados Unidos', 'www.analog.com', '+1-781-329-4700', 'support@analog.com'),
('Mini-Circuits', 'Estados Unidos', 'www.minicircuits.com', '+1-718-934-4500', 'sales@minicircuits.com'),
('Keysight Technologies', 'Estados Unidos', 'www.keysight.com', '+1-800-829-4444', 'contact@keysight.com'),
('Rohde & Schwarz', 'Alemania', 'www.rohde-schwarz.com', '+49-89-4129-0', 'info@rohde-schwarz.com'),
('Qorvo', 'Estados Unidos', 'www.qorvo.com', '+1-336-664-5000', 'support@qorvo.com'),
('NXP Semiconductors', 'Países Bajos', 'www.nxp.com', '+31-40-272-9999', 'support@nxp.com'),
('Skyworks Solutions', 'Estados Unidos', 'www.skyworksinc.com', '+1-781-376-3000', 'info@skyworksinc.com'),
('Infineon Technologies', 'Alemania', 'www.infineon.com', '+49-89-234-0', 'info@infineon.com'),
('Pasternack', 'Estados Unidos', 'www.pasternack.com', '+1-949-261-1920', 'sales@pasternack.com'),
('Amphenol RF', 'Estados Unidos', 'www.amphenolrf.com', '+1-203-265-8900', 'info@amphenolrf.com');

-- Insertar proveedores
INSERT INTO proveedores (nombre, contacto, telefono, email, direccion, tiempo_entrega_dias) VALUES
('Digi-Key Electronics', 'Juan Pérez', '+1-800-344-4539', 'juan.perez@digikey.com', '701 Brooks Avenue South, Thief River Falls, MN', 2),
('Mouser Electronics', 'María García', '+1-800-346-6873', 'maria.garcia@mouser.com', '1000 N Main St, Mansfield, TX', 3),
('Arrow Electronics', 'Carlos López', '+1-303-824-4000', 'carlos.lopez@arrow.com', '9201 E Dry Creek Rd, Centennial, CO', 5),
('Avnet', 'Ana Rodríguez', '+1-480-643-2000', 'ana.rodriguez@avnet.com', '2211 S 47th St, Phoenix, AZ', 7),
('Richardson RFPD', 'Luis Martínez', '+1-630-208-2700', 'luis.martinez@richardsonrfpd.com', '40W267 Keslinger Rd, LaFox, IL', 4);

-- Insertar componentes RF
INSERT INTO componentes_rf (codigo_parte, nombre, id_categoria, id_fabricante, descripcion, frecuencia_min_mhz, frecuencia_max_mhz, potencia_max_w, voltaje_operacion_v, temperatura_min_c, temperatura_max_c, impedancia_ohm, ganancia_db, vswr_max, precio_usd, stock_actual, stock_minimo, ubicacion_almacen) VALUES
('ADL5202', 'Amplificador de Ganancia Variable', 6, 1, 'Amplificador de ganancia variable de 400 MHz a 4 GHz', 400, 4000, 0.1, 5.0, -40, 85, 50, 20.5, 1.5, 24.50, 15, 5, 'A-01-03'),
('ERA-3SM+', 'Amplificador Bajo Ruido', 6, 2, 'Amplificador monolítico de bajo ruido DC-8 GHz', 0.01, 8000, 0.02, 5.0, -55, 85, 50, 13.0, 2.0, 8.95, 25, 10, 'A-01-05'),
('PE4302', 'Atenuador Digital', 10, 5, 'Atenuador digital de 6 bits, 9 kHz a 4 GHz', 0.009, 4000, 0.5, 5.0, -40, 85, 50, -31.5, 1.4, 12.75, 8, 3, 'B-02-01'),
('ADF4351', 'Sintetizador PLL', 8, 1, 'Sintetizador de frecuencia PLL con VCO integrado', 35, 4400, 0.01, 3.3, -40, 85, 50, 0, 1.5, 18.90, 12, 5, 'C-03-02'),
('SKY13271-313LF', 'Switch RF', 1, 7, 'Switch SP4T de 50 MHz a 4 GHz', 50, 4000, 1.0, 2.7, -40, 85, 50, -0.7, 1.3, 3.25, 30, 15, 'A-01-08'),
('SMA-F-CONN', 'Conector SMA Hembra', 3, 10, 'Conector SMA hembra para montaje en panel', 0, 18000, 5, 0, -65, 155, 50, 0, 1.15, 2.85, 50, 20, 'D-04-01'),
('RG-58-CABLE', 'Cable Coaxial RG-58', 4, 9, 'Cable coaxial RG-58 50 ohm por metro', 0, 1000, 0.2, 0, -40, 80, 50, 0, 1.5, 1.20, 100, 50, 'E-05-01'),
('BPF-2400', 'Filtro Pasa Banda 2.4 GHz', 5, 2, 'Filtro pasa banda centrado en 2.4 GHz', 2300, 2500, 1.0, 0, -40, 85, 50, -2.5, 1.5, 15.60, 10, 5, 'B-02-03'),
('LNA-1000', 'Amplificador LNA 1 GHz', 6, 4, 'Amplificador de bajo ruido para 1 GHz', 800, 1200, 0.05, 12.0, -40, 85, 50, 25.0, 1.8, 45.30, 6, 3, 'A-01-06'),
('VCO-5800', 'Oscilador VCO 5.8 GHz', 8, 6, 'Oscilador controlado por voltaje para 5.8 GHz', 5600, 6000, 0.01, 5.0, -40, 85, 50, 5.0, 1.2, 28.75, 4, 2, 'C-03-04'),
('BALUN-1500', 'Balun 1:4 1.5 GHz', 2, 2, 'Transformador balun 1:4 para 1.5 GHz', 800, 1500, 2.0, 0, -55, 125, 50, -0.5, 1.3, 12.40, 8, 4, 'B-02-05'),
('MIXER-2000', 'Mezclador DBM 2 GHz', 7, 1, 'Mezclador doble balanceado para 2 GHz', 1500, 2500, 0.02, 0, -40, 85, 50, -6.5, 1.8, 35.60, 5, 2, 'C-03-06'),
('CRYSTAL-10M', 'Cristal de Cuarzo 10 MHz', 8, 6, 'Oscilador de cristal de precisión 10 MHz', 10, 10, 0.001, 5.0, -20, 70, 50, 0, 1.1, 8.75, 20, 10, 'C-03-01'),
('PATCH-2.4G', 'Antena Patch 2.4 GHz', 9, 9, 'Antena patch direccional para 2.4 GHz', 2400, 2485, 0, 0, -40, 85, 50, 8.5, 1.5, 28.90, 12, 6, 'D-04-03'),
('SPLITTER-4WAY', 'Divisor de Potencia 4 Vías', 2, 2, 'Divisor de potencia 4 vías 800-2500 MHz', 800, 2500, 20, 0, -55, 85, 50, -6.0, 1.4, 45.20, 7, 3, 'B-02-07');

-- Insertar equipos RF
INSERT INTO equipos_rf (numero_serie, modelo, id_fabricante, tipo_equipo, frecuencia_min_mhz, frecuencia_max_mhz, potencia_salida_w, voltaje_alimentacion_v, consumo_corriente_a, fecha_adquisicion, estado, ubicacion, responsable, valor_usd, calibracion_requerida, proxima_calibracion) VALUES
('KS001234', 'E5071C', 3, 'Analizador', 300, 20000, 0.001, 110, 2.5, '2023-01-15', 'Operativo', 'Lab-RF-01', 'Carlos Méndez', 25000.00, TRUE, '2025-01-15'),
('RS005678', 'FSW26', 4, 'Analizador', 2, 26500, 0.001, 230, 3.2, '2022-06-20', 'Operativo', 'Lab-RF-02', 'Ana Torres', 75000.00, TRUE, '2024-12-20'),
('KS009876', 'N5181B', 3, 'Generador', 9, 3000, 1.0, 110, 1.8, '2023-03-10', 'En calibración', 'Lab-RF-03', 'Miguel Santos', 18000.00, TRUE, '2024-09-10'),
('ADI002345', 'AD-FMCOMMS5', 1, 'Transceptor', 70, 6000, 0.01, 12, 2.0, '2023-08-05', 'Operativo', 'Desarrollo-01', 'Laura Vega', 3500.00, FALSE, NULL),
('RS007890', 'NRP-Z11', 4, 'Medidor', 10, 8000, 0, 15, 0.5, '2022-11-30', 'Operativo', 'Lab-RF-01', 'Carlos Méndez', 4200.00, TRUE, '2025-05-30'),
('MC003456', 'ZHL-100W-52+', 2, 'Amplificador', 0.8, 1000, 100, 28, 12.0, '2023-05-18', 'En reparación', 'Taller-RF', 'Pedro Ruiz', 2800.00, FALSE, NULL),
('ANT001122', 'HG2458U', 9, 'Antena', 2400, 2500, 0, 0, 0, '2023-02-28', 'Operativo', 'Azotea-Norte', 'Luis Herrera', 150.00, FALSE, NULL),
('TX004455', 'BLF188XR', 8, 'Transmisor', 88, 108, 300, 50, 8.5, '2022-12-15', 'Operativo', 'Transmisor-FM', 'Roberto Silva', 1200.00, TRUE, '2024-12-15'),
('RX006677', 'RTL-SDR', 1, 'Receptor', 24, 1766, 0, 5, 0.3, '2023-07-12', 'Operativo', 'Desarrollo-02', 'Sandra Morales', 25.00, FALSE, NULL),
('OSC008899', 'SG382', 1, 'Generador', 0.001, 2025, 0.013, 110, 1.2, '2023-04-25', 'Operativo', 'Lab-RF-02', 'Ana Torres', 8500.00, TRUE, '2025-04-25'),
('SA012345', 'FSV3030', 4, 'Analizador', 10, 30000, 0.001, 230, 2.8, '2024-01-20', 'Operativo', 'Lab-RF-04', 'Elena Ruiz', 42000.00, TRUE, '2025-01-20'),
('AMP005566', 'ZVA-183+', 2, 'Amplificador', 10, 18000, 1, 15, 3.5, '2023-09-12', 'Operativo', 'Lab-RF-03', 'Miguel Santos', 1850.00, FALSE, NULL);

-- Insertar historial de reparaciones
INSERT INTO historial_reparaciones (id_equipo, fecha_inicio, fecha_fin, tecnico_asignado, problema_reportado, diagnostico, solucion_aplicada, componentes_reemplazados, costo_reparacion, tiempo_reparacion_horas, estado_reparacion, prioridad) VALUES
(6, '2024-06-15', '2024-06-18', 'Pedro Ruiz', 'Amplificador no enciende', 'Fusible quemado y regulador de voltaje dañado', 'Reemplazar fusible F1 y regulador U3', 'Fusible 10A, LM7805', 45.20, 4.5, 'Completada', 'Media'),
(3, '2024-07-01', NULL, 'Miguel Santos', 'Deriva de frecuencia fuera de especificación', 'Oscilador de referencia inestable', 'Enviar a calibración externa', 'Ninguno', 350.00, 0, 'En progreso', 'Alta'),
(5, '2024-05-10', '2024-05-12', 'Carlos Méndez', 'Lectura errática de potencia', 'Sensor de potencia descalibrado', 'Recalibración del sensor', 'Ninguno', 180.00, 8.0, 'Completada', 'Media'),
(8, '2024-03-20', '2024-03-22', 'Roberto Silva', 'Potencia de salida reducida', 'Transistor de salida degradado', 'Reemplazar transistor Q15', 'BLF188XR', 125.80, 3.2, 'Completada', 'Alta'),
(1, '2024-08-05', '2024-08-07', 'Ana Torres', 'Error en medición de S11', 'Conector de entrada dañado', 'Reemplazar conector SMA', 'SMA-F-CONN', 28.50, 2.1, 'Completada', 'Baja'),
(11, '2024-06-25', NULL, 'Elena Ruiz', 'Ruido excesivo en mediciones', 'Investigando origen del ruido', 'En diagnóstico', 'Pendiente', 0.00, 12.5, 'En progreso', 'Media'),
(12, '2024-07-10', '2024-07-12', 'Miguel Santos', 'Ganancia fuera de especificación', 'Transistor de entrada degradado', 'Reemplazar Q2 y recalibrar', 'ERA-3SM+', 85.40, 6.2, 'Completada', 'Baja');

-- Insertar componentes usados en reparaciones
INSERT INTO componentes_usados_reparacion (id_reparacion, id_componente, cantidad_usada) VALUES
(5, 6, 1),  -- SMA-F-CONN para reparación 5
(7, 2, 1);  -- ERA-3SM+ para reparación 7

-- Insertar calibraciones
INSERT INTO calibraciones (id_equipo, fecha_calibracion, tecnico, laboratorio, certificado_numero, resultado, tolerancia_cumplida, proxima_fecha, costo, observaciones) VALUES
(1, '2024-01-15', 'Carlos Méndez', 'Lab Certificado XYZ', 'CAL-2024-0115', 'Aprobado', TRUE, '2025-01-15', 450.00, 'Calibración anual completa'),
(2, '2023-12-20', 'Ana Torres', 'Metrología Nacional', 'MN-2023-1220', 'Aprobado', TRUE, '2024-12-20', 850.00, 'Calibración trazable'),
(5, '2024-05-30', 'Carlos Méndez', 'Lab Certificado XYZ', 'CAL-2024-0530', 'Aprobado con ajustes', TRUE, '2025-05-30', 220.00, 'Ajuste menor en ganancia'),
(8, '2023-12-15', 'Roberto Silva', 'Servicio Keysight', 'KS-2023-1215', 'Aprobado', TRUE, '2024-12-15', 380.00, 'Servicio oficial del fabricante'),
(10, '2024-04-25', 'Ana Torres', 'Lab Certificado XYZ', 'CAL-2024-0425', 'Aprobado', TRUE, '2025-04-25', 320.00, 'Frecuencia y amplitud verificadas'),
(11, '2024-01-20', 'Elena Ruiz', 'Metrología Nacional', 'MN-2024-0120', 'Aprobado', TRUE, '2025-01-20', 650.00, 'Calibración inicial del equipo');

-- ===================================
-- VISTAS ÚTILES PARA TÉCNICOS
-- ===================================

-- Vista de componentes con bajo stock
CREATE VIEW componentes_bajo_stock AS
SELECT 
    c.codigo_parte,
    c.nombre,
    cat.nombre AS categoria,
    f.nombre AS fabricante,
    c.stock_actual,
    c.stock_minimo,
    c.ubicacion_almacen,
    c.precio_usd
FROM componentes_rf c
JOIN categorias_componentes cat ON c.id_categoria = cat.id_categoria
JOIN fabricantes f ON c.id_fabricante = f.id_fabricante
WHERE c.stock_actual <= c.stock_minimo;

-- Vista de equipos que requieren calibración próxima
CREATE VIEW equipos_calibracion_proxima AS
SELECT 
    e.numero_serie,
    e.modelo,
    f.nombre AS fabricante,
    e.tipo_equipo,
    e.ubicacion,
    e.responsable,
    e.proxima_calibracion,
    (e.proxima_calibracion - CURRENT_DATE) AS dias_restantes
FROM equipos_rf e
JOIN fabricantes f ON e.id_fabricante = f.id_fabricante
WHERE e.calibracion_requerida = TRUE 
AND e.proxima_calibracion <= (CURRENT_DATE + INTERVAL '30 days');

-- Vista de reparaciones pendientes
CREATE VIEW reparaciones_pendientes AS
SELECT 
    r.id_reparacion,
    e.numero_serie,
    e.modelo,
    r.fecha_inicio,
    r.tecnico_asignado,
    r.problema_reportado,
    r.estado_reparacion,
    r.prioridad,
    (CURRENT_DATE - r.fecha_inicio) AS dias_transcurridos
FROM historial_reparaciones r
JOIN equipos_rf e ON r.id_equipo = e.id_equipo
WHERE r.estado_reparacion IN ('En progreso', 'Pendiente de partes');

-- Vista resumen de costos de reparación por equipo
CREATE VIEW resumen_costos_reparacion AS
SELECT 
    e.numero_serie,
    e.modelo,
    f.nombre AS fabricante,
    COUNT(r.id_reparacion) AS total_reparaciones,
    COALESCE(SUM(r.costo_reparacion), 0) AS costo_total,
    COALESCE(AVG(r.costo_reparacion), 0) AS costo_promedio,
    COALESCE(SUM(r.tiempo_reparacion_horas), 0) AS tiempo_total_horas
FROM equipos_rf e
JOIN fabricantes f ON e.id_fabricante = f.id_fabricante
LEFT JOIN historial_reparaciones r ON e.id_equipo = r.id_equipo
GROUP BY e.id_equipo, e.numero_serie, e.modelo, f.nombre;

-- Vista de equipos por estado
CREATE VIEW equipos_por_estado AS
SELECT 
    estado,
    COUNT(*) AS cantidad_equipos,
    ROUND(AVG(valor_usd), 2) AS valor_promedio
FROM equipos_rf 
GROUP BY estado
ORDER BY cantidad_equipos DESC;

-- Vista de inventario crítico
CREATE VIEW inventario_critico AS
SELECT 
    c.codigo_parte,
    c.nombre,
    cat.nombre AS categoria,
    c.stock_actual,
    c.stock_minimo,
    (c.stock_minimo - c.stock_actual) AS deficit,
    c.precio_usd,
    (c.precio_usd * (c.stock_minimo - c.stock_actual)) AS costo_reposicion
FROM componentes_rf c
JOIN categorias_componentes cat ON c.id_categoria = cat.id_categoria
WHERE c.stock_actual < c.stock_minimo
ORDER BY deficit DESC;

-- ===================================
-- FUNCIONES ÚTILES
-- ===================================

-- Función para calcular el próximo mantenimiento preventivo
CREATE OR REPLACE FUNCTION calcular_proximo_mantenimiento(fecha_ultimo_mantenimiento DATE, tipo_equipo tipo_equipo_enum)
RETURNS DATE AS $$
BEGIN
    CASE tipo_equipo
        WHEN 'Analizador', 'Generador' THEN
            RETURN fecha_ultimo_mantenimiento + INTERVAL '12 months';
        WHEN 'Medidor' THEN
            RETURN fecha_ultimo_mantenimiento + INTERVAL '6 months';
        WHEN 'Amplificador', 'Transmisor' THEN
            RETURN fecha_ultimo_mantenimiento + INTERVAL '3 months';
        ELSE
            RETURN fecha_ultimo_mantenimiento + INTERVAL '12 months';
    END CASE;
END;
$$ LANGUAGE plpgsql;

-- Función para generar reporte de utilización de componentes
CREATE OR REPLACE FUNCTION reporte_uso_componentes(fecha_inicio DATE, fecha_fin DATE)
RETURNS TABLE(
    codigo_parte VARCHAR(50),
    nombre VARCHAR(100),
    total_usado BIGINT,
    costo_total NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.codigo_parte,
        c.nombre,
        SUM(cur.cantidad_usada) as total_usado,
        SUM(cur.cantidad_usada * c.precio_usd) as costo_total
    FROM componentes_rf c
    JOIN componentes_usados_reparacion cur ON c.id_componente = cur.id_componente
    JOIN historial_reparaciones hr ON cur.id_reparacion = hr.id_reparacion
    WHERE hr.fecha_inicio BETWEEN fecha_inicio AND fecha_fin
    GROUP BY c.id_componente, c.codigo_parte, c.nombre
    ORDER BY total_usado DESC;
END;
$$ LANGUAGE plpgsql;

-- ===================================
-- ÍNDICES PARA OPTIMIZACIÓN
-- ===================================

CREATE INDEX idx_componentes_categoria ON componentes_rf(id_categoria);
CREATE INDEX idx_componentes_fabricante ON componentes_rf(id_fabricante);
CREATE INDEX idx_componentes_stock ON componentes_rf(stock_actual, stock_minimo);
CREATE INDEX idx_equipos_estado ON equipos_rf(estado);
CREATE INDEX idx_equipos_calibracion ON equipos_rf(proxima_calibracion);
CREATE INDEX idx_reparaciones_estado ON historial_reparaciones(estado_reparacion);
CREATE INDEX idx_reparaciones_fecha ON historial_reparaciones(fecha_inicio);
CREATE INDEX idx_reparaciones_tecnico ON historial_reparaciones(tecnico_asignado);
CREATE INDEX idx_calibraciones_fecha ON calibraciones(fecha_calibracion);
CREATE INDEX idx_equipos_tipo ON equipos_rf(tipo_equipo);

-- ===================================
-- TRIGGERS PARA AUTOMATIZACIÓN
-- ===================================

-- Trigger para actualizar stock cuando se usan componentes
CREATE OR REPLACE FUNCTION actualizar_stock_componente()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE componentes_rf 
    SET stock_actual = stock_actual - NEW.cantidad_usada
    WHERE id_componente = NEW.id_componente;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_actualizar_stock
    AFTER INSERT ON componentes_usados_reparacion
    FOR EACH ROW EXECUTE FUNCTION actualizar_stock_componente();

-- Trigger para registrar fecha de finalización de reparación
CREATE OR REPLACE FUNCTION actualizar_fecha_fin_reparacion()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.estado_reparacion = 'Completada' AND OLD.estado_reparacion != 'Completada' THEN
        NEW.fecha_fin = CURRENT_DATE;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_fecha_fin_reparacion
    BEFORE UPDATE ON historial_reparaciones
    FOR EACH ROW EXECUTE FUNCTION actualizar_fecha_fin_reparacion();

-- ===================================
-- CONSULTAS DE EJEMPLO ÚTILES
-- ===================================

-- Comentarios con consultas de ejemplo
/*
-- Consulta: Equipos que necesitan calibración en los próximos 30 días
SELECT * FROM equipos_calibracion_proxima;

-- Consulta: Componentes más utilizados en reparaciones
SELECT * FROM reporte_uso_componentes('2024-01-01', '2024-12-31');

-- Consulta: Técnicos más activos
SELECT 
    tecnico_asignado,
    COUNT(*) as reparaciones_realizadas,
    AVG(tiempo_reparacion_horas) as tiempo_promedio
FROM historial_reparaciones 
WHERE fecha_fin IS NOT NULL
GROUP BY tecnico_asignado 
ORDER BY reparaciones_realizadas DESC;

-- Consulta: Equipos con mayor costo de mantenimiento
SELECT 
    e.numero_serie,
    e.modelo,
    SUM(r.costo_reparacion) as costo_total_reparaciones
FROM equipos_rf e
LEFT JOIN historial_reparaciones r ON e.id_equipo = r.id_equipo
GROUP BY e.id_equipo, e.numero_serie, e.modelo
ORDER BY costo_total_reparaciones DESC NULLS LAST;
*/