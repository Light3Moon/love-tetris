--[[	Author:	Milkmanjack
		Date:	3/5/13
		This is the gameboard we'll load when the game starts up.
		Can do fancy animations here.
]]

local GameBoard				= require("obj.GameBoard")
local GamePiece				= require("obj.GamePiece")
local GamePieceBig			= require("obj.GamePieceBig")
local IntroGameBoard		= GameBoard:clone()
IntroGameBoard.fallSpeed	= 64*10
IntroGameBoard.animate		= true
IntroGameBoard.logo			= love.graphics.newImage("resources/love_outline.png")

function IntroGameBoard:initialize()
	GameBoard.initialize(self)
end

local nextX	= 0
local total	= 0
local last	= 0

function IntroGameBoard:draw(x,y)
	GameBoard.draw(self, x, y)
	if self.animate == false then
		love.graphics.draw(self.logo, x+64, y+32)
	end
end

function IntroGameBoard:update(t)
	total = total + t
	if (total >= last+0.05 or last == 0) and self.animate then
			local realX = nextX - (math.floor(nextX/10) * 10)

			-- skip
			if nextX == 63 then
				nextX = 65
			elseif nextX == 81 then
				nextX = 87
			end

			-- big pieces
			if nextX == 54 or nextX == 72 or nextX == 74 or nextX == 76 then
				local piece = GamePieceBig:new()
				piece:setX(realX*32)
				piece:setY(0)
				self:addPiece(piece)
				nextX = nextX+1
			else
				self:addNewPiece(realX*32,0)
			end
			last = total
			nextX = nextX+1
	end

	-- board is full. animation done.
	if #self:getPieces() >= 88 then
		self.animate = false
	end

	GameBoard.update(self, t)
end

return IntroGameBoard
