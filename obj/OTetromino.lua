--[[	Author:	Milkmanjack
		Date:	3/20/13
		O tetromino (the square one)
]]

local Tetromino		= require("obj.Tetromino")
local OTetromino	= Tetromino:clone()

function OTetromino:initialize()
	self.pieces = {}
	self:addNewPiece(0,0)
	self:addNewPiece(32,0)
	self:setPivot(self:addNewPiece(0,32))
	self:addNewPiece(32,32)
end

function OTetromino:getPivotPieceLeft(piece)
	return piece:getX(), piece:getY()
end

function OTetromino:getPivotPieceRight(piece)
	return piece:getX(), piece:getY()
end

return OTetromino
