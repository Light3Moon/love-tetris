--[[	Author:	Milkmanjack
		Date:	3/5/13
		Used to represent the game board.
]]

local Cloneable			= require("obj.Cloneable")
local GamePiece			= require("obj.GamePiece")
local GameBoard			= Cloneable.clone()
GameBoard.width			= 320
GameBoard.height		= 320
GameBoard.fallSpeed		= 32 -- 32 pixels per second
GameBoard.pieces		= nil
GameBoard.snappedPieces	= nil

function GameBoard:initialize()
	self.pieces			= {}
	self.snappedPieces	= {}
end

function GameBoard:update(t)
	for i,v in pairs(self:getPieces()) do
		if not v:isSnapped() then
			-- check for a collision with a snapped pieces
			local collisionWith = self:getCollision(v, t*32, t*32)
			if collisionWith then
				v.y = collisionWith:getY()-32
				v:snap()
				self:addSnappedPiece(v)

			-- just drop
			else
				v.y = math.min(v.y + (t*self.fallSpeed), self:getHeight()-32)
				if v.y == self:getHeight()-32 then
					v:snap()
					self:addSnappedPiece(v)
				end
			end
		end
	end
end

function GameBoard:getCollision(piece,xAccel,yAccel)
	-- too lazy to write proper collision here
	for i,v in pairs(self:getSnappedPieces()) do
		if piece:getY()+piece:getHeight() > v.y and piece.x == v.x then
			return v
		end
	end

	return false
end

function GameBoard:draw(x,y)
	for i,v in pairs(self:getPieces()) do
		v:draw(x+v:getX(), y+v:getY())
	end
end

function GameBoard:getWidth()
	return self.width
end

function GameBoard:getHeight()
	return self.height
end

function GameBoard:addNewPiece(x,y)
	local piece = GamePiece:new()
	piece:setLoc(x,y)
	self:addPiece(piece)
	return piece
end

function GameBoard:addPiece(piece)
	table.insert(self.pieces, piece)
	return true
end

function GameBoard:removePiece(piece)
	for i,v in ipairs(self.pieces) do
		if v == piece then
			table.remove(self.pieces, i)
			return true
		end
	end

	return false
end

function GameBoard:addSnappedPiece(piece)
	table.insert(self.snappedPieces, piece)
	return true
end

function GameBoard:removeSnappedPiece(piece)
	for i,v in ipairs(self.snappedPieces) do
		if v == piece then
			table.remove(self.snappedPieces, i)
			return true
		end
	end

	return false
end

function GameBoard:getPieces()
	return self.pieces
end

function GameBoard:getSnappedPieces()
	return self.snappedPieces
end

function GameBoard:clear()
	self:initialize() -- clears pieces and snapped pieces
end

return GameBoard
