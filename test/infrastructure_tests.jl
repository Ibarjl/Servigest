using Test
using Servigest

# Tests for the infrastructure layer

# Test SQLite repository
@testset "SQLite Repository Tests" begin
    # Initialize the SQLite repository
    sqlite_repo = SQLiteRepository("test.db")

    # Test creating an order
    order = OrdenTrabajo("1", "Test Order", "Pending")
    sqlite_repo.create_order(order)
    @test sqlite_repo.get_order("1") == order

    # Test updating an order
    updated_order = OrdenTrabajo("1", "Updated Order", "Completed")
    sqlite_repo.update_order(updated_order)
    @test sqlite_repo.get_order("1") == updated_order

    # Test deleting an order
    sqlite_repo.delete_order("1")
    @test sqlite_repo.get_order("1") == nothing
end

# Test Memory repository
@testset "Memory Repository Tests" begin
    # Initialize the memory repository
    memory_repo = MemoryRepository()

    # Test creating an order
    order = OrdenTrabajo("1", "Test Order", "Pending")
    memory_repo.create_order(order)
    @test memory_repo.get_order("1") == order

    # Test updating an order
    updated_order = OrdenTrabajo("1", "Updated Order", "Completed")
    memory_repo.update_order(updated_order)
    @test memory_repo.get_order("1") == updated_order

    # Test deleting an order
    memory_repo.delete_order("1")
    @test memory_repo.get_order("1") == nothing
end

# Additional tests for services can be added here
