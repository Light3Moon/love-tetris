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
IntroGameBoard.logo			= love.graphics.newImage("resources/love_outline.png")

-- animation stuff
IntroGameBoard.animate		= true
IntroGameBoard.animateTime	= 0
IntroGameBoard.animateDelay	= 0.05
IntroGameBoard.animateLast	= 0
IntroGameBoard.nextX		= 0

-- movement control
--IntroGameBoard.moveSnapTo	= false
IntroGameBoard.moveDelay	= 0.05

function IntroGameBoard:initialize()
	GameBoard.initialize(self)
end

function IntroGameBoard:draw(x,y)
	GameBoard.draw(self, x, y)
end

function IntroGameBoard:update(t)
	if self.animate then
		self.animateTime = self.animateTime + t
		if self.animateDelay <= 0 or self.animateTime > self.animateLast + self.animateDelay then
			local realX = self.nextX - (math.floor(self.nextX/10) * 10)

			-- skip
			if self.nextX == 63 then
				self.nextX = 65
			elseif self.nextX == 81 then
				self.nextX = 87
			end

			-- big pieces
			if self.nextX == 54 or self.nextX == 72 or self.nextX == 74 or self.nextX == 76 then
				local piece = GamePieceBig:new()
				piece:setX(realX*32)
				piece:setY(0)
				self:addPiece(piece)
				self.nextX = self.nextX+1
			else
				self:addNewPiece(realX*32,0)
			end

			self.nextX = self.nextX + 1

			if self.animateDelay > 0 then
				self.animateLast = self.animateTime
			end

			-- board is full. animation done.
			if #self:getPieces() >= 88 then
				self.animate = false
			end
		end
	end

	self:gravity(t)
end

function IntroGameBoard:finishAnimation()
	while self.animate == true do
		self:update(0.016)
	end
end

return IntroGameBoard
