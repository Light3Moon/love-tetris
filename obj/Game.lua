--[[	Author:	Milkmanjack
		Date:	3/5/13
		Master game object.
]]

local Cloneable	= require("obj.Cloneable")
local GameBoard	= require("obj.GameBoard")
local GameState	= require("obj.GameState")
local Game		= Cloneable:new()
Game.name		= "LOVE Tetris"
Game.version	= 0
Game.state		= -1
Game.board		= nil

function Game:initialize()
	self.board	= GameBoard:new(true)
	self.state	= GameState.INITIAL
end

function Game:update(t)
end

local background	= love.graphics.newImage("resources/main_menu_background.png")
function Game:draw()
	love.graphics.draw(background,0,0)
end

function Game:update(t)
end

return Game
