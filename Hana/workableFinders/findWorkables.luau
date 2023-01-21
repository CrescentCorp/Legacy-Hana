type rawWorkables = {[number]: string | rawWorkables}

local function findWorkables(path: string): rawWorkables
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

return findWorkables