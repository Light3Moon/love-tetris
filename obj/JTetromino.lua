--[[	Author:	Milkmanjack
		Date:	3/14/13
		T tetromino
]]

local Tetromino		= require("obj.Tetromino")
local TTetromino	= Tetromino:clone()

function TTetromino:initialize()
	self.pieces = {}
	self:addNewPiece(0,0)
	self:setPivot(self:addNewPiece(0,32))
	self:addNewPiece(0,64)
	self:addNewPiece(-32,32)
end

return TTetromino
