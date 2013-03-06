--[[	Author:	Milkmanjack
		Date:	3/5/13
		Startup point for game.
]]

local Game			= require("obj.Game")
local currentGame	= Game:new()
love.graphics.setFont(love.graphics.newFont(25))
love.graphics.setColor(0,0,0,255)
love.graphics.setColorMode("replace")
love.graphics.setBackgroundColor(80,0,0,255)
love.graphics.setCaption("Love Tetris")
love.graphics.setIcon(love.graphics.newImage("resources/piece.png"))

function love.draw()
	currentGame:draw()
end

function love.update(t)
	currentGame:update(t)
end

