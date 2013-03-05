--[[	Author:	Milkmanjack
		Date:	3/5/13
		Startup point for game.
]]

local Game	= require("obj.Game")
currentGame	= Game:new(true)

function love.draw()
	currentGame:draw()
end

function love.update(t)
	currentGame:update(t)
end

