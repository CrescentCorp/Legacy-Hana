return function(task)
    print("I am hello.work.luau")

    local products = {}

    local co = task.every(1, function()
        local product = #products + 1
        table.insert(products, product)
        print("produced", product)
    end)

    local lastProduct = 0
    local co2 = task.every(2, function()
        lastProduct += 2
        print("consumed", products[lastProduct - 2] ,products[lastProduct - 1])
    end)

    
end