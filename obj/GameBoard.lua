--[[	Author:	Milkmanjack
		Date:	3/5/13
		Used to represent the game board.
]]

local Cloneable		= require("obj.Cloneable")
local GameBoard		= Cloneable:new()
GameBoard.entities	= nil

function GameBoard:initialize()
	self.entities = {}
end

function GameBoard:update(t)
end

function GameBoard:draw(x,y)
end

return GameBoard
