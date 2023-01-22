local simplifyWorkables = require("Hana/workableFinders/simplifyWorkables")
local findWorkables = require("Hana/workableFinders/findWorkables")
local Task = require("Hana/Task")

local loadedScripts = {}
local yields = table.create(100)
local taskObj = Task(yields, loadedScripts)


local function getCoroutineActiveness(co)
	return if coroutine.status(co) == "dead" then nil else true
end

local function start(scriptDirPath: string)
	assert(fs.isDir(scriptDirPath), "The given path isn't a dir")

	local shouldLoop = true
	local workables = simplifyWorkables(findWorkables(scriptDirPath))

	for _, workable: string in workables do
		loadedScripts[coroutine.create(require(workable:gsub(".luau", "")))] = true
	end

	-- we save a snapshot of the coroutines we currently imported from found workables
	-- so that coroutines created by the imported coroutines don't get ran by this code
	for loadedFunc in table.clone(loadedScripts) do
		coroutine.resume(loadedFunc, taskObj)
		loadedScripts[loadedFunc] = getCoroutineActiveness(loadedFunc)
	end

	while shouldLoop do
		local now = os.clock()
		for index, dataSet in yields do
			local timeYielded = now - dataSet[1]
			local loadedFunc = dataSet[3]

			if timeYielded >= dataSet[2] then
				yields[index] = nil

				coroutine.resume(loadedFunc, timeYielded, now)
				loadedScripts[loadedFunc] = getCoroutineActiveness(loadedFunc)
			end
		end

		shouldLoop = false
		for _ in loadedScripts do
			shouldLoop = true
			break
		end
	end
end

return {start = start, task = taskObj}