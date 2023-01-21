local function findWorkables(path: string)
	local Workables = {}
	for _, objPath in fs.readDir(path) do
		local joinedPath = string.format("%*/%*", path, objPath)

		if fs.isDir(joinedPath) then
			table.insert(Workables, findWorkables(joinedPath))
		else
			if objPath:match("%.work") then
				table.insert(Workables, joinedPath)
			end
		end
	end

	return Workables
end

local function simplifyWorkables(workables)
	local simplifiedWorkables = {}

	for _, objPath in workables do
		if type(objPath) == "table" then
			for _, entry in simplifyWorkables(objPath) do
				table.insert(simplifiedWorkables, entry)
			end
		else
			table.insert(simplifiedWorkables, objPath)
		end
	end

	return simplifiedWorkables
end

local function waitConst(yields)
	return function(yieldTime)
		local currentCo = coroutine.running()
		table.insert(yields, { os.clock(), yieldTime or 0, currentCo })
		return coroutine.yield()
	end
end

local function getCoroutineActiveness(co)
	return if coroutine.status(co) == "dead" then nil else true
end

local function start(scriptDirPath: string)
	assert(fs.isDir(scriptDirPath), "The given path isn't a dir")

	local shouldLoop = true
	local loadedScripts = {}
	local workables = simplifyWorkables(findWorkables(scriptDirPath))
	local yields = table.create(#workables)

	local wait = waitConst(yields)

	for _, workable: string in workables do
		loadedScripts[coroutine.create(require(workable:gsub(".luau", "")))] = true
	end

	for loadedFunc in loadedScripts do
		coroutine.resume(loadedFunc, wait)
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

return start