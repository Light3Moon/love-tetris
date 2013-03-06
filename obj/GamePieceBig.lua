--[[	Author:	Milkmanjack
		Date:	3/6/13
		Big game piece.
]]

local GamePiece		= require("obj.GamePiece")
local GamePieceBig	= GamePiece:clone()
GamePieceBig.width	= 64
GamePieceBig.height	= 64
GamePieceBig.icon	= love.graphics.newImage("resources/piece_big.png")

return GamePieceBig
