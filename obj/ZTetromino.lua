--[[	Author:	Milkmanjack
		Date:	3/13/13
		Z tetromino
]]

local Tetromino		= require("obj.Tetromino")
local ZTetromino	= Tetromino:clone()

function ZTetromino:initialize()
	self.pieces = {}
	self:addNewPiece(0,0)
	self:addNewPiece(32,0)
	self:setPivot(self:addNewPiece(32,32))
	self:addNewPiece(64,32)
end

return ZTetromino
