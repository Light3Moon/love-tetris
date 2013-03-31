--[[	Author:	Milkmanjack
		Date:	3/5/13
		Used to represent the game board.
]]

local Cloneable			= require("obj.Cloneable")
local GamePiece			= require("obj.GamePiece")
local GameBoard			= Cloneable.clone()
GameBoard.width			= 320
GameBoard.height		= 448
GameBoard.pieces		= nil
GameBoard.snappedPieces	= nil
GameBoard.fullRows		= nil
GameBoard.thud			= love.audio.newSource("resources/thud.ogg", "stream")

function GameBoard:initialize()
	self.pieces			= {}
	self.snappedPieces	= {}
	self.fullRows		= {}
end

function GameBoard:update(t)
	for i,v in ipairs(self:getPieces()) do
		v:update(t)
	end
end

function GameBoard:draw(x,y)
	for i,v in pairs(self:getPieces()) do
		v:draw(x+v:getX(), y+v:getY())
	end
end

-- check collision is a raw check against two two dimensional areas
function GameBoard:checkCollisionXYXY(x1,y1,w1,h1,x2,y2,w2,h2)
	-- thanks to Toadfish for this
	local dx = math.abs(x1 - x2)
	local dy = math.abs(y1 - y2)
	local width = x1 < x2 and w1 or w2
	local height = y1 < y2 and h1 or h2
	return (dx < width) and (dy < height)
end

function GameBoard:checkCollisionPieceXY(piece,x,y,w,h)
	return self:checkCollisionXYXY(piece:getX(), piece:getY(), piece:getWidth(), piece:getHeight(),
									x, y, w, h)
end

function GameBoard:checkCollisionPiecePiece(piece,piece2)
	return self:checkCollisionXYXY(piece:getX(), piece:getY(), piece:getWidth(), piece:getHeight(),
									piece2:getX(), piece2:getY(), piece2:getWidth(), piece2:getHeight())
end

-- collide is a check against a two dimensional area and any snapped pieces
function GameBoard:collideXY(x,y,width,height,xAccel,yAccel)
	xAccel = xAccel or 0
	yAccel = yAccel or 0
	for i,v in ipairs(self:getSnappedPieces()) do
		if self:checkCollisionXYXY(x+xAccel, y+yAccel, width, height,
			v:getX(), v:getY(), v:getWidth(), v:getHeight()) then
			return v
		end
	end

	return false
end

function GameBoard:collidePiece(piece,xAccel,yAccel)
	return self:collideXY(piece:getX(), piece:getY(), piece:getWidth(), piece:getHeight(), xAccel, yAccel)
end

function GameBoard:canPivotLeft(tetromino)
	for i,v in ipairs(tetromino:getPieces()) do
		local newX, newY = tetromino:getPivotPieceLeft(v)

		if self:collideXY(newX,newY,v:getWidth(),v:getHeight()) or
			newX < 0 or newX >= self:getWidth() or
			newY >= self:getHeight() then
			return false
		end
	end

	return true
end

function GameBoard:canPivotRight(tetromino)
	for i,v in ipairs(tetromino:getPieces()) do
		local newX, newY = tetromino:getPivotPieceRight(v)

		if self:collideXY(newX,newY,v:getWidth(),v:getHeight()) or
			newX < 0 or newX >= self:getWidth() or
			newY >= self:getHeight() then
			return false
		end
	end

	return true
end

function GameBoard:playThud()
	self.thud:stop()
	self.thud:play()
end

function GameBoard:getWidth()
	return self.width
end

function GameBoard:getHeight()
	return self.height
end

function GameBoard:dropPiece(piece,distance)
	local collision = self:collidePiece(piece, 0, distance)
	if collision then
		piece:setY(collision:getY()-piece:getHeight())
		self:snapPiece(piece)

	else
		local bottom = self:getHeight() - piece:getHeight()
		local newY = math.min(piece:getY()+distance, bottom)
		piece:setY(newY)
		if newY == bottom then
			self:snapPiece(piece)
		end
	end
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
			self:removeSnappedPiece(piece)
			return true
		end
	end

	return false
end

function GameBoard:snapPiece(piece)
	piece:snap()
	self:addSnappedPiece(piece)
	self:playThud()
end

function GameBoard:snapTetromino(tetromino)
	tetromino:snap()
	for i,v in ipairs(tetromino:getPieces()) do
		self:addSnappedPiece(v)
	end

	self:playThud()
end

function GameBoard:unsnapPiece(piece)
	piece:unsnap()
	self:removeSnappedPiece(piece)
end

function GameBoard:addSnappedPiece(piece)
	table.insert(self.snappedPieces, piece)
	if self:checkRow(piece:getY()) and not self:rowIsFull(piece:getY()) then
		self:flagFullRow(piece:getY())
	end

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

function GameBoard:getRowByY(y)
	local row = {}
	for i,v in ipairs(self:getSnappedPieces()) do
		if v:getY() == y then
			table.insert(row, v)
		end
	end

	return row
end

function GameBoard:checkRow(y)
	local width = 0
	for i,v in ipairs(self:getPieces()) do
		if v:getY() == y then
			width = width + v:getWidth()
		end
	end

	return width >= self:getWidth()
end

function GameBoard:rowIsFull(y)
	for i,v in ipairs(self.fullRows) do
		if v == y then
			return true
		end
	end
end

function GameBoard:getFullRows()
	return self.fullRows
end

function GameBoard:flagFullRow(y)
	table.insert(self.fullRows, y)
	table.sort(self.fullRows, function(a,b) if a < b then return true end return false end)
end

function GameBoard:flagEmptyRow(y)
	for i,v in ipairs(self.fullRows) do
		if v == y then
			table.remove(self.fullRows, i)
		end
	end
end

function GameBoard:clearRow(y)
	for i,v in ipairs(self:getRowByY(y)) do
		self:removePiece(v)
	end

	for i,v in ipairs(self:getSnappedPieces()) do
		if v:getY() < y then
			v.y = v.y + 32
		end
	end
end

function GameBoard:getPieces()
	return self.pieces
end

function GameBoard:getSnappedPieces()
	return self.snappedPieces
end

function GameBoard:clear()
	self.pieces			= {}
	self.snappedPieces	= {}
end

return GameBoard
