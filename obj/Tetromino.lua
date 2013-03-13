--[[	Author:	Milkmanjack
		Date:	3/13/13
		Represents tetrominoes.
]]

local Cloneable		= require("obj.Cloneable")
local GamePiece		= require("obj.GamePiece")
local Tetromino		= Cloneable.clone()
Tetromino.pieces	= nil
Tetromino.pivot		= nil

function Tetromino:initialize()
	self.pieces = {}
end

function Tetromino:addNewPiece(x,y)
	local piece = GamePiece:new()
	piece:setX(x)
	piece:setY(y)
	return piece
end

function Tetromino:addPiece(piece)
	table.insert(self.pieces, piece)
	return piece
end

function Tetromino:setPivot(piece)
	self.pivot = piece
	return piece
end

function Tetromino:getPieces()
	return self.pieces
end

function Tetromino:pivotLeft()
	local centerX, centerY = self.pivot:getX(), self.pivot:getY()
	for i,v in ipairs(self:getPieces()) do
		local xOffset, yOffset = v:getX() - centerX, v:getY() - centerY
		v:setX(centerX+yOffset)
		v:setY(centerY-xOffset)
	end
end

function Tetromino:pivotRight()
	local centerX, centerY = self.pivot:getX(), self.pivot:getY()
	for i,v in ipairs(self:getPieces()) do
		local xOffset, yOffset = v:getX() - centerX, v:getY() - centerY
		v:setX(centerX-yOffset)
		v:setY(centerY+xOffset)
	end
end
