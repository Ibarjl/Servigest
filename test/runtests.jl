using Test

# Include the test files for each layer
include("domain_tests.jl")
include("application_tests.jl")
include("infrastructure_tests.jl")

# Run all tests
@testset "All Tests" begin
    include("domain_tests.jl")
    include("application_tests.jl")
    include("infrastructure_tests.jl")
end