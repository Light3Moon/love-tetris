--[[	Author:	Milkmanjack
		Date:	3/5/13
		This is the gameboard we'll load when the game starts up.
		Can do fancy animations here.
]]

local GameBoard				= require("obj.GameBoard")
local GamePiece				= require("obj.GamePiece")
local IntroGameBoard		= GameBoard:clone()
IntroGameBoard.fallSpeed	= 32*10

function IntroGameBoard:initialize()
	GameBoard.initialize(self)
end

local nextX	= 0
local total	= 0
local last	= 0

function IntroGameBoard:draw(x,y)
	GameBoard.draw(self, x, y)
end

function IntroGameBoard:update(t)
	total = total + t
	if (total >= last+0.5 or last == 0 or (love.keyboard.isDown("down") and total >= last+0.1)) and #self:getPieces() < 100 then
			self:addNewPiece(nextX*32,0)
			last = total
			nextX = (nextX+1 >= 10) and 0 or nextX+1
	end

	GameBoard.update(self, t)
end

return IntroGameBoard
