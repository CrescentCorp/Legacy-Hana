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

        return co
    end

    function self.delay(time: number, fn)
        return self.spawn(function()
            self.wait(time)
            fn()
        end)
    end

    function self.every(time, fn)
        return self.spawn(function()
            while true do
                self.wait(time)
                fn()
            end
        end)
    end

    function self.close(co)
        loadedScripts[co] = nil
        coroutine.close(co)
    end
    return self
end