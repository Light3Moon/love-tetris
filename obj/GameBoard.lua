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

-- gravity control
GameBoard.moveSnapTo	= true
GameBoard.moveDelay		= 1
GameBoard.moveTime		= 0
GameBoard.moveLast		= 0

function GameBoard:initialize()
	self.pieces			= {}
	self.snappedPieces	= {}
end

function GameBoard:update(t)
	self:gravity(t)
end

function GameBoard:gravity(t)
	self.moveTime = self.moveTime + t
	if not self.moveSnapTo or self.moveTime > self.moveLast + self.moveDelay then
		self.moveLast = self.moveTime
		local distance = self.moveSnapTo and 32 or t*self.fallSpeed
		for i,v in pairs(self:getPieces()) do
			if not v:isSnapped() then
				-- check for a collision with a snapped pieces
				local collisionWith = self:collide(v, 0, distance)
				if collisionWith then
					v.y = collisionWith:getY()-v:getHeight()
					v:snap()
					self:addSnappedPiece(v)

				-- simple fall
				else
					v.y = math.min(v.y + distance, self:getHeight()-v:getHeight())
					if v.y == self:getHeight()-v:getHeight() then
						v:snap()
						self:addSnappedPiece(v)
					end
				end
			end
		end
	end
end

function GameBoard:checkCollision(piece,piece2,xAccel,yAccel)
	-- thanks to Toadfish for this
	local dx = math.abs(piece:getX()+xAccel - piece2:getX())
	local dy = math.abs(piece:getY()+yAccel - piece2:getY())
	local width = piece:getX()+xAccel < piece2:getX() and piece:getWidth() or piece2:getWidth()
	local height = piece:getY()+yAccel < piece2:getY() and piece:getHeight() or piece2:getHeight()
	return (dx < width) and (dy < height)
end

function GameBoard:collide(piece,xAccel,yAccel)
	for i,v in ipairs(self:getSnappedPieces()) do
		if self:checkCollision(piece, v, xAccel, yAccel) then
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
