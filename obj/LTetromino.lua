--[[	Author:	Milkmanjack
		Date:	3/14/13
		L tetromino
]]

local Tetromino		= require("obj.Tetromino")
local LTetromino	= Tetromino:clone()

function LTetromino:initialize()
	self.pieces = {}
	self:addNewPiece(0,0)
	self:setPivot(self:addNewPiece(0,32))
	self:addNewPiece(0,64)
	self:addNewPiece(32,64)
end

return LTetromino
