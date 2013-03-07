--[[	Author:	Milkmanjack
		Date:	3/5/13
		Master game object.
]]

local Cloneable			= require("obj.Cloneable")
local GameBoard			= require("obj.GameBoard")
local IntroGameBoard	= require("obj.IntroGameBoard")
local GameState			= require("obj.GameState")
local Game				= Cloneable.clone()
Game.name				= "LOVE Tetris"
Game.version			= 0
Game.state				= -1
Game.board				= nil
Game.playingBackground	= love.graphics.newImage("resources/playing_background.png")
Game.mainMenuOverlay	= love.graphics.newImage("resources/main_menu_overlay.png")
Game.logo				= love.graphics.newImage("resources/love_outline.png")

--- game running information
Game.currentPiece		= nil
Game.playTime			= 0

function Game:initialize()
	self.board	= IntroGameBoard:new()
	self.state	= GameState.INITIAL
end

function Game:draw()
	love.graphics.draw(self.playingBackground, 0, 0)
	self.board:draw(160, 0)
	if self.state == GameState.MAIN_MENU then
		self:drawMenu(160, 0)
	end
end

function Game:drawMenu()
	love.graphics.draw(self.mainMenuOverlay, 0, 0)
	love.graphics.draw(self.logo, 160+64, 32)
	local r,g,b,a = love.graphics.getColor()
	love.graphics.setColor(0, 0, 0, 255)
	local newGameX = 320-(font:getWidth("[press start to begin]")/2)
	love.graphics.print("[press start to begin]", newGameX, 32*4)
	love.graphics.setColor(r,g,b,a)
end

function Game:update(t)
	self.board:update(t)
	if self.state == GameState.INITIAL and self.board.animate == false then
		self.state = GameState.MAIN_MENU

	elseif self.state == GameState.PLAYING then
		self.playTime = self.playTime + t

		-- spawn a piece if there is no active one
		if self.currentPiece == nil or self.currentPiece:isSnapped() then
			self.currentPiece = self.board:addNewPiece(32*5,0)
		end
	end
end

function Game:keypressed(key)
	if key == "return" or key == "kpenter" then
		if self.state == GameState.INITIAL then
			self.board:finishAnimation()
		end

		if self.state == GameState.MAIN_MENU then
			self.state		= GameState.PLAYING
			self.board		= GameBoard:new()
		end
	end

	if key == "left" then
		if self.state == GameState.PLAYING then
			if self.currentPiece and not self.currentPiece:isSnapped() then
				self.currentPiece.x = math.max(self.currentPiece.x - 32, 0)
			end
		end
	end

	if key == "right" then
		if self.state == GameState.PLAYING then
			if self.currentPiece and not self.currentPiece:isSnapped() then
				self.currentPiece.x = math.min(self.currentPiece.x + 32, self.board:getWidth()-self.currentPiece:getWidth())
			end
		end
	end
end

return Game
