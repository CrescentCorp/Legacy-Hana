return function(yields, loadedScripts)
    local self = {}

    function self.wait(yieldTime: number)
        local currentCo = coroutine.running()
		table.insert(yields, { os.clock(), yieldTime or 0, currentCo })
		return coroutine.yield()
    end

    function self.spawn(fn, ...)
        local co = coroutine.create(fn)

        loadedScripts[co] = true
        coroutine.resume(co, ...)
    end

    function self.delay(time: number, fn)
        self.spawn(function()
            self.wait(time)
            fn()
        end)
    end

    function self.every(time, fn)
        self.spawn(function()
            while true do
                self.wait(time)
                fn()
            end
        end)
    end
    return self
end