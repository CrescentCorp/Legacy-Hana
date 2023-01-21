type rawWorkables = {[number]: string | rawWorkables}

local function simplifyWorkables(workables: rawWorkables): {string}
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

return simplifyWorkables