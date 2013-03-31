--[[	Author:	Milkmanjack
		Date:	3/5/13
		Startup point for game.
]]

local Game			= require("obj.Game")
local GameState		= require("obj.GameState")
local currentGame	= Game:new()

font		= love.graphics.newFont("resources/dash_pixel-7.ttf", 20)
scoreFont	= love.graphics.newFont("resources/Square.ttf", 20)
love.graphics.setFont(font)
love.graphics.setBackgroundColor(80,0,0,255)
love.graphics.setCaption("LOVE Tetris")
love.graphics.setIcon(love.graphics.newImage("resources/piece.png"))

function love.draw()
	currentGame:draw()
end

function love.update(t)
	currentGame:update(t)
end

function love.keypressed(key)
	currentGame:keypressed(key)
end

function love.keyreleased(key)
	currentGame:keyreleased(key)
end
