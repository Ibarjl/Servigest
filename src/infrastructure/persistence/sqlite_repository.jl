module SQLiteRepository

using SQLite

# Define the SQLite database connection
const DB_PATH = "workorder_system.db"

# Function to initialize the database and create necessary tables
function initialize_db()
    db = SQLite.DB(DB_PATH)
    
    # Create tables if they do not exist
    SQLite.execute(db, """
    CREATE TABLE IF NOT EXISTS OrdenTrabajo (
        id INTEGER PRIMARY KEY,
        descripcion TEXT,
        estado TEXT
    )
    """)
    
    SQLite.execute(db, """
    CREATE TABLE IF NOT EXISTS Tecnico (
        id INTEGER PRIMARY KEY,
        nombre TEXT,
        especialidad TEXT
    )
    """)
    
    SQLite.execute(db, """
    CREATE TABLE IF NOT EXISTS Cliente (
        id INTEGER PRIMARY KEY,
        nombre TEXT,
        contacto TEXT
    )
    """)
    
    SQLite.close(db)
end

# Function to create a new order
function create_order(descripcion::String, estado::String)
    db = SQLite.DB(DB_PATH)
    SQLite.execute(db, "INSERT INTO OrdenTrabajo (descripcion, estado) VALUES (?, ?)", (descripcion, estado))
    SQLite.close(db)
end

# Function to retrieve all orders
function get_orders()
    db = SQLite.DB(DB_PATH)
    orders = SQLite.Query(db, "SELECT * FROM OrdenTrabajo") do row
        (row.id, row.descripcion, row.estado)
    end
    SQLite.close(db)
    return collect(orders)
end

# Function to update an order's status
function update_order_status(id::Int, new_estado::String)
    db = SQLite.DB(DB_PATH)
    SQLite.execute(db, "UPDATE OrdenTrabajo SET estado = ? WHERE id = ?", (new_estado, id))
    SQLite.close(db)
end

# Function to delete an order
function delete_order(id::Int)
    db = SQLite.DB(DB_PATH)
    SQLite.execute(db, "DELETE FROM OrdenTrabajo WHERE id = ?", id)
    SQLite.close(db)
end

end # module SQLiteRepository