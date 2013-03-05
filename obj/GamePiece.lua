--[[	Author:	Milkmanjack
		Date:	3/5/13
		Represents game pieces.
]]

local Cloneable		= require("obj.Cloneable")
local GamePiece		= Cloneable:new()
GamePiece.x			= 0
GamePiece.y			= 0
GamePiece.icon		= love.graphics.newImage("resources/piece.png")

function GamePiece:update(t)
end

function GamePiece:draw(x,y)
	local r,g,b,a = love.graphics.getColor()
	love.graphics.setColor(255,255,255,a)
	love.graphics.rectangle("fill",x,y,16,16)
	love.graphics.setColor(r,g,b,a)
	love.graphics.draw(self.icon, x, y)
end

return GamePiece
