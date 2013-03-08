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
Game.runTime			= 0
Game.stateTime			= 0
Game.currentPiece		= nil

function Game:initialize()
	self:startMainMenu()
end

function Game:draw()
	love.graphics.draw(self.playingBackground, 0, 0)
	self.board:draw(160, 0)

	if self.state == GameState.MAIN_MENU or self.state == GameState.GAME_PREP then
		self:drawMenu(160, 0)
	end

	if self.state == GameState.PAUSE then
		local r,g,b,a = love.graphics.getColor()
		love.graphics.setColor(255,255,255,255)
		love.graphics.print("PAUSED", 320-(78/2), 160-40)
		love.graphics.print("PRESS ENTER TO CONTINUE", 320-(299/2), 160-20)
		love.graphics.setColor(r,g,b,a)
	end
		

	if self.state == GameState.GAME_PREP then
		if self:getStateTime() < 1 then
			local r,g,b,a = love.graphics.getColor()
			love.graphics.setColor(255,255,255,self:getStateTime()*255)
			love.graphics.rectangle("fill",160,0,320,320)
			love.graphics.setColor(r,g,b,a)
		end
	end

	if self.state == GameState.PLAYING then
		if self:getStateTime() < 1 then
			local r,g,b,a = love.graphics.getColor()
			love.graphics.setColor(255,255,255,255-(self:getStateTime()*255))
			love.graphics.rectangle("fill",160,0,320,320)
			love.graphics.setColor(r,g,b,a)
		end
	end
end

function Game:drawMenu()
	local r,g,b,a = love.graphics.getColor()
	local menuAlpha = (self.state == GameState.MAIN_MENU) and math.min(self:getStateTime()*(255/2), 255) or 255
	love.graphics.setColor(255,255,255,menuAlpha)
	love.graphics.draw(self.mainMenuOverlay, 0, 0)
	love.graphics.draw(self.logo, 224, 16)
	love.graphics.setColor(0, 0, 0, menuAlpha)
	love.graphics.print("press ENTER to begin", 190, 128)
	love.graphics.setColor(r,g,b,a)
end

function Game:update(t)
	self:updateRunTime(t)
	self:updateStateTime(t)

	if self.state ~= GameState.PAUSE then
		self.board:update(t)
	end

	if self.state == GameState.GAME_PREP then
		if self:getStateTime() >= 1 then
			self:startPlaying()
		end

	elseif self.state == GameState.PLAYING then
		self:playUpdate(t)
	end
end

function Game:playUpdate(t)
	if self:getStateTime() < 1 then
		return
	end

	-- spawn a piece if there is no active one
	if self.currentPiece == nil or self.currentPiece:isSnapped() then
		if self.board:collideXY(160,0,32,32,0,0) then
			self:startMainMenu()
		else
			self.currentPiece = self.board:addNewPiece(160,0)
		end
	end
end

function Game:updateRunTime(t)
	self.runTime = self.runTime + t
end

function Game:updateStateTime(t)
	self.stateTime = self.stateTime + t
end

function Game:getRunTime()
	return self.runTime
end

function Game:getStateTime()
	return self.stateTime
end

function Game:setState(state)
	self.state = state
	self.stateTime = 0
end

function Game:startPrep()
	self:setState(GameState.GAME_PREP)
end

function Game:startPlaying()
	self:setState(GameState.PLAYING)
	self.board = GameBoard:new()
end

function Game:stopPlaying()
	self.currentPiece = nil
end

function Game:pause()
	self.__playTime = self:getStateTime()
	self:setState(GameState.PAUSE)
end

function Game:unpause()
	self:setState(GameState.PLAYING)
	self.stateTime = self.__playTime or 0
	self.__playTime = nil
end

function Game:startMainMenu()
	self:setState(GameState.MAIN_MENU)
	self.board = IntroGameBoard:new()
end

function Game:keypressed(key)
	if key == "return" or key == "kpenter" then
		if self.state == GameState.PAUSE then
			self:unpause()
		elseif self.state == GameState.PLAYING and self:getStateTime() > 1 then
			self:pause()
		elseif self.state == GameState.MAIN_MENU then
			self:startPrep()
		end
	end

	if key == "left" then
		if self.state == GameState.PLAYING then
			if self.currentPiece and not self.currentPiece:isSnapped() and not self.board:collidePiece(self.currentPiece, -32, 0) then
				self.currentPiece.x = math.max(self.currentPiece.x - 32, 0)
			end
		end
	end

	if key == "right" then
		if self.state == GameState.PLAYING then
			if self.currentPiece and not self.currentPiece:isSnapped() and not self.board:collidePiece(self.currentPiece, 32, 0) then
				self.currentPiece.x = math.min(self.currentPiece.x + 32, self.board:getWidth()-self.currentPiece:getWidth())
			end
		end
	end

	if key == "escape" then
		if self.state == GameState.PLAYING then
			self:stopPlaying()
			self:startMainMenu()
		end
	end
end

return Game
