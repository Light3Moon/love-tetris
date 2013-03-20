--[[	Author:	Milkmanjack
		Date:	3/20/13
		I tetromino (the long one)
]]

local Tetromino		= require("obj.Tetromino")
local ITetromino	= Tetromino:clone()

function ITetromino:initialize()
	self.pieces = {}
	self:addNewPiece(0,0)
	self:addNewPiece(0,32)
	self:setPivot(self:addNewPiece(0,64))
	self:addNewPiece(0,96)
end

return ITetromino
