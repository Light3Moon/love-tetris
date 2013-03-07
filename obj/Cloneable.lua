--[[	Author:	Milkmanjack
		Date:	3/5/13
		Allows for pretend inheritance between objects.
]]

local Cloneable	= {}

-- create a class-style clone of a Cloneable.
-- if init is true, initialize as an instance-style clone.
function Cloneable.clone(parent, init)
	local instance = {}
	setmetatable(instance, {__index=parent or Cloneable})

	-- should we initialize?
	-- (only in cases where we're making an active instance)
	if init then
		instance:initialize()
	end

	return instance
end

-- shortcut for creating an instance-style clone.
function Cloneable.new(parent)
	return Cloneable.clone(parent, true)
end

function Cloneable:initialize()
end

return Cloneable
