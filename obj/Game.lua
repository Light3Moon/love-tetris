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
Game.logo				= love.graphics.newImage("resources/logo.png")

--- game running information
Game.startTime			= 0
Game.playTime			= 0
Game.currentPiece		= nil

function Game:initialize()
	self.startTime	= love.timer.getMicroTime()
	self.board		= IntroGameBoard:new()
	self.state		= GameState.MAIN_MENU
end

function Game:draw()
	love.graphics.draw(self.playingBackground, 0, 0)
	self.board:draw(160, 0)
	if self.state == GameState.MAIN_MENU then
		self:drawMenu(160, 0)
	end
end

function Game:drawMenu()
	local r,g,b,a = love.graphics.getColor()
	local menuAlpha = math.min((love.timer.getMicroTime()-self.startTime)*(255/2), 255)
	love.graphics.setColor(255,255,255,menuAlpha)
	love.graphics.draw(self.mainMenuOverlay, 0, 0)
	love.graphics.draw(self.logo, 224, 16)
	love.graphics.setColor(0, 0, 0, menuAlpha)
	love.graphics.print("press ENTER to begin", 190, 128)
	love.graphics.setColor(r,g,b,a)
end

function Game:update(t)
	self.board:update(t)
	if self.state == GameState.PLAYING then
		self.playTime = self.playTime + t

		-- spawn a piece if there is no active one
		if self.currentPiece == nil or self.currentPiece:isSnapped() then
			self.currentPiece = self.board:addNewPiece(160,0)
		end
	end
end

function Game:keypressed(key)
	if key == "return" or key == "kpenter" then
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

	if key == "escape" then
		if self.state == GameState.PLAYING then
			self.currentPiece	= nil
			self.playTime		= 0
			self:initialize()
		end
	end
end

return Game
