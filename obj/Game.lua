--[[	Author:	Milkmanjack
		Date:	3/5/13
		Master game object.
]]

local Cloneable			= require("obj.Cloneable")
local IntroGameBoard	= require("obj.IntroGameBoard")
local GameState			= require("obj.GameState")
local Game				= Cloneable.clone()
Game.name				= "LOVE Tetris"
Game.version			= 0
Game.state				= -1
Game.board				= nil

function Game:initialize()
	self.board	= IntroGameBoard:new()
	self.state	= GameState.INITIAL
end

function Game:update(t)
	self.board:update(t)
end

function Game:draw()
	self.board:draw(160, 0)
end

function Game:update(t)
	self.board:update(t)
end

return Game
