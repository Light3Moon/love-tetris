--[[	Author:	Milkmanjack
		Date:	3/30/12
		Extends table library a bit.
]]

function table.copy(t)
	local c = {}
	for i,v in pairs(t) do
		c[i] = v
	end

	return c
end

function table.safePairs(t)
	return pairs(table.copy(t))
end

function table.safeIPairs(t)
	return ipairs(table.copy(t))
end