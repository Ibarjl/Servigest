# Work Order System

## Overview
The Work Order System is a Julia-based application designed to manage work orders, technicians, and clients. It follows a layered architecture, separating concerns into distinct layers: Domain, Application, Infrastructure, Controllers, and User Interface.

## Project Structure
- **src/**: Contains the source code for the application.
  - **domain/**: Defines the core entities and business rules.
  - **application/**: Implements use cases and defines interfaces for infrastructure.
  - **infrastructure/**: Contains data persistence and external services.
  - **controllers/**: Manages user input and output for different interfaces.
  - **ui/**: Handles presentation logic for CLI and web interfaces.
  
- **test/**: Contains tests for various layers of the application to ensure functionality and reliability.

- **Project.toml**: Lists the dependencies and package information for the project.

- **Manifest.toml**: Contains resolved dependencies for reproducibility.

## Getting Started

### Prerequisites
- Julia 1.x or higher
- Required packages as specified in `Project.toml`

### Installation
1. Clone the repository:
   ```
   git clone <repository-url>
   cd Servigest
   ```

2. Activate the project environment:
   ```
   julia --project=.
   ```

3. Install dependencies:
   ```
   using Pkg
   Pkg.instantiate()
   ```

### Running the Application
To run the application, you can use the command-line interface:
```
julia --project=. src/controllers/cli_controller.jl
```

### Running Tests
To run the tests, execute:
```
julia --project=. test/runtests.jl
```

## Usage
- Create work orders, assign technicians, and manage clients through the CLI or web interface.
- Follow the prompts in the CLI for user-friendly interaction.

## Contributing
Contributions are welcome! Please fork the repository and submit a pull request for any enhancements or bug fixes.

## License
This project is licensed under the MIT License. See the LICENSE file for details.





# 📡 Sistema RF Dashboard - Servigest

Sistema completo de gestión de inventario y equipos de radiofrecuencia desarrollado en **Julia** con interfaz web moderna.

## 🚀 Características Principales

- **Dashboard Web Interactivo** con diseño moderno usando Tailwind CSS
- **Gestión Completa de Inventario** de componentes RF
- **Control de Equipos RF** con seguimiento de calibraciones
- **Historial de Reparaciones** y costos de mantenimiento
- **APIs REST** para integración con otros sistemas
- **Reportes Automáticos** de inventario crítico
- **Base de Datos PostgreSQL** optimizada para RF

## 📋 Requisitos Previos

- **Julia 1.8+** instalado
- **PostgreSQL** instalado y configurado
- Navegador web moderno
- Conexión a internet (para cargar Tailwind CSS)

## 🛠️ Instalación Rápida

### 1. Configurar Base de Datos

```sql
-- Crear base de datos
CREATE DATABASE servigest_rf;

-- Ejecutar el script SQL proporcionado
\i base_datos_rf.sql
```

### 2. Configurar Sistema Julia

```julia
# Ejecutar script de configuración
julia rf_setup.jl
```

Selecciona opción **1** para configuración completa.

### 3. Configurar Conexión

Edita el archivo `config.toml`:

```toml
[database]
host = "tu_servidor"
port = 5432
dbname = "servigest_rf"
user = "tu_usuario"
password = "tu_password"
```

### 4. Iniciar Sistema

```bash
julia startup.jl
```

El dashboard estará disponible en: **http://localhost:8080**

## 🌐 URLs Disponibles

| Endpoint | Descripción |
|----------|-------------|
| `/dashboard` | Dashboard principal |
| `/api/critical-inventory` | Inventario crítico (JSON) |
| `/api/calibration-schedule` | Equipos para calibrar (JSON) |
| `/api/pending-repairs` | Reparaciones pendientes (JSON) |
| `/api/maintenance-report` | Reporte de costos (JSON) |
| `/api/equipment-stats` | Estadísticas de equipos (JSON) |

## 📊 Funciones Principales

### Gestión de Inventario

```julia
# Obtener resumen de inventario
conn = connect_rf_database()
summary = get_inventory_summary_from_db(conn)

# Componentes críticos
critical = get_critical_inventory(conn)

# Generar reporte
generate_critical_inventory_report("reporte.txt")
```

### Control de Equipos

```julia
# Equipos que necesitan calibración
calibration