return function(wait)
    print("I am hello.work.luau")

    while true do
        print(wait(6))
        print("I waited 6 seconds")
        break
    end
end