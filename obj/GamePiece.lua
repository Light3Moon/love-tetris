--[[	Author:	Milkmanjack
		Date:	3/5/13
		Represents game pieces.
]]

local Cloneable		= require("obj.Cloneable")
local GamePiece		= Cloneable.clone()
GamePiece.x			= 0
GamePiece.y			= 0
GamePiece.weight	= 32
GamePiece.height	= 32
GamePiece.snapped	= false
GamePiece.icon		= love.graphics.newImage("resources/piece.png")

function GamePiece:update(t)
end

function GamePiece:draw(x,y)
	love.graphics.draw(self.icon, x, y)
end

function GamePiece:getX()
	return self.x
end

function GamePiece:getY()
	return self.y
end

function GamePiece:getWidth()
	return self.width
end

function GamePiece:getHeight()
	return self.height
end

function GamePiece:getLoc()
	return self:getX(), self:getY()
end

function GamePiece:setX(x)
	self.x = x
end

function GamePiece:setY(y)
	self.y = y
end

function GamePiece:setLoc(x,y)
	self:setX(x)
	self:setY(y)
end

function GamePiece:snap()
	self.snapped = true
end

function GamePiece:unsnap()
	self.snapped = false
end

function GamePiece:isSnapped()
	return self.snapped
end

return GamePiece
