--[[	Author:	Milkmanjack
		Date:	3/13/13
		Represents tetrominoes.
]]

local Cloneable		= require("obj.Cloneable")
local GamePiece		= require("obj.GamePiece")
local Tetromino		= Cloneable.clone()
Tetromino.pieces	= nil
Tetromino.pivot		= nil
Tetromino.snapped	= false

function Tetromino:initialize()
	self.pieces = {}
end

function Tetromino:snap()
	self.snapped = true
	for i,v in ipairs(self.pieces) do
		v:snap()
	end
end

function Tetromino:isSnapped()
	return self.snapped == true
end

function Tetromino:addNewPiece(x,y)
	local piece = GamePiece:new()
	piece:setX(x)
	piece:setY(y)
	self:addPiece(piece)
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

function Tetromino:setPositionRelativeTo(x,y)
	local centerX, centerY = self:getPivot():getX(), self:getPivot():getY()
	for i,v in ipairs(self:getPieces()) do
		local relativeX, relativeY = v:getX()-centerX, v:getY()-centerY
		v:setX(x+relativeX)
		v:setY(y+relativeY)
	end
end

function Tetromino:getPivot()
	return self.pivot
end

function Tetromino:getPieces()
	return self.pieces
end

-- gets the new X,Y location of a piece after pivoting left
-- this is for exporting pivot logic to other functions (like checking for collision)
function Tetromino:getPivotPieceLeft(piece)
	local centerX, centerY = self.pivot:getX(), self.pivot:getY()
	local xOffset, yOffset = piece:getX() - centerX, piece:getY() - centerY
	return centerX+yOffset, centerY-xOffset
end

-- gets the new X,Y location of a piece after pivoting right
function Tetromino:getPivotPieceRight(piece)
	local centerX, centerY = self.pivot:getX(), self.pivot:getY()
	local xOffset, yOffset = piece:getX() - centerX, piece:getY() - centerY
	return centerX-yOffset, centerY+xOffset
end

function Tetromino:pivotLeft()
	local centerX, centerY = self.pivot:getX(), self.pivot:getY()
	for i,v in ipairs(self:getPieces()) do
		if v ~= self.pivot then
			local newX, newY = self:getPivotPieceLeft(v)
			v:setX(newX)
			v:setY(newY)
		end
	end

	local pivotX, pivotY = self:getPivotPieceLeft(self.pivot)
	self.pivot:setX(pivotX)
	self.pivot:setY(pivotY)
end

function Tetromino:pivotRight()
	for i,v in ipairs(self:getPieces()) do
		if v ~= self:getPivot() then
			local newX, newY = self:getPivotPieceRight(v)
			v:setX(newX)
			v:setY(newY)
		end
	end

	local pivotX, pivotY = self:getPivotPieceRight(self.pivot)
	self.pivot:setX(pivotX)
	self.pivot:setY(pivotY)
end

return Tetromino
