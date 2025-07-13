using Test
using Servigest

# Tests for the application layer
module ApplicationTests

    # Test case for creating an order
    function test_create_order()
        # Setup
        order_data = (id = 1, description = "Fix the sink", client_id = 1)
        result = create_order(order_data)
        
        # Assertions
        @test result.id == 1
        @test result.description == "Fix the sink"
        @test result.client_id == 1
    end

    # Test case for assigning a technician
    function test_assign_technician()
        # Setup
        order_id = 1
        technician_id = 1
        result = assign_technician(order_id, technician_id)
        
        # Assertions
        @test result.order_id == order_id
        @test result.technician_id == technician_id
    end

    # Run all tests
    function run_all_tests()
        test_create_order()
        test_assign_technician()
    end

end

# Execute the tests when this file is run
if abspath(PROGRAM_FILE) == abspath(__FILE__)
    ApplicationTests.run_all_tests()
end