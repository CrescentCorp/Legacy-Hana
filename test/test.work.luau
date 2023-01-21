return function(wait)
    print("I am test.work.luau")

    coroutine.wrap(function()
        print(wait(4), wait(2))
    end)()
end