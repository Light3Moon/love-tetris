--[[	Author:	Milkmanjack
		Date:	3/5/13
		Allows for pretend inheritance between objects.
]]

local Cloneable	= {}

-- create a new instance of this cloneable instance.
function Cloneable.new(parent, init)
	local instance = {}
	setmetatable(instance, {__index=parent or Cloneable})

	-- should we initialize (only in cases where we're making an active instance)
	if init then
		instance:initialize()
	end

	return instance
end

function Cloneable:initialize()
end

return Cloneable
