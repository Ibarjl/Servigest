module AbstractOrderRepository

    abstract type AbstractOrderRepository end

    function create_order(repo::AbstractOrderRepository, order)
        error("create_order not implemented")
    end

    function get_order(repo::AbstractOrderRepository, order_id)
        error("get_order not implemented")
    end

    function update_order(repo::AbstractOrderRepository, order)
        error("update_order not implemented")
    end

    function delete_order(repo::AbstractOrderRepository, order_id)
        error("delete_order not implemented")
    end

end