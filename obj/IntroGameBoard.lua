--[[	Author:	Milkmanjack
		Date:	3/5/13
		This is the gameboard we'll load when the game starts up.
		Can do fancy animations here.
]]

local GameBoard				= require("obj.GameBoard")
local GamePiece				= require("obj.GamePiece")
local GamePieceBig			= require("obj.GamePieceBig")
local IntroGameBoard		= GameBoard:clone()
IntroGameBoard.fallSpeed	= 320*2

-- random piece drop info
IntroGameBoard.lastPiece	= nil
IntroGameBoard.rows			= nil

function IntroGameBoard:validRows()
	local rows = {}
	for i,v in ipairs(self.rows) do
		if v < 10 then
			table.insert(rows, i)
		end
	end

	return rows
end

function IntroGameBoard:update(t)
	if (not self.lastPiece or self.lastPiece:isSnapped()) then
		local validRows = self:validRows()
		local x = validRows[math.ceil(math.random() * #validRows)]
		self.lastPiece = self:addNewPiece((x-1)*32, 0)
		self.rows[x] = self.rows[x] + 1
	end

	-- board is full. clear it.
	if #self:getPieces() >= 100 then
		self:clear()
		self.lastPiece = nil
	end

	self:gravity(t)
end

function IntroGameBoard:initialize()
	GameBoard.initialize(self)
	self.rows = {0,0,0,0,0,0,0,0,0,0}
end

function IntroGameBoard:playThud()
	-- no thud
end

return IntroGameBoard
