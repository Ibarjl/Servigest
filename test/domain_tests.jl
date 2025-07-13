using Test
include("../src/domain/entities.jl")
include("../src/domain/business_rules.jl")

# Tests for the domain layer
@testset "Domain Tests" begin

    # Test for OrdenTrabajo entity
    @testset "OrdenTrabajo Tests" begin
        orden = OrdenTrabajo("1", "Descripción de la orden", "Cliente1", "Técnico1")
        @test orden.id == "1"
        @test orden.descripcion == "Descripción de la orden"
        @test orden.cliente == "Cliente1"
        @test orden.tecnico == "Técnico1"
    end

    # Test for Tecnico entity
    @testset "Tecnico Tests" begin
        tecnico = Tecnico("Técnico1", "Especialidad1")
        @test tecnico.nombre == "Técnico1"
        @test tecnico.especialidad == "Especialidad1"
    end

    # Test for Cliente entity
    @testset "Cliente Tests" begin
        cliente = Cliente("Cliente1", "Contacto1")
        @test cliente.nombre == "Cliente1"
        @test cliente.contacto == "Contacto1"
    end

    # Test for business rules
    @testset "Business Rules Tests" begin
        # Suponiendo que hay una función de validación en business_rules.jl
        @test is_valid_order(orden) == true  # Reemplazar con la función real
    end

end