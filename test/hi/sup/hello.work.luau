return function(task)
    print("I am hello.work.luau")

    task.every(3, function()
        print("I am printed every 3 seconds")
    end)
end