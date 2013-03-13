--[[	Author:	Milkmanjack
		Date:	3/5/13
		Master game object.
]]

local Cloneable			= require("obj.Cloneable")
local GameBoard			= require("obj.GameBoard")
local GameState			= require("obj.GameState")
local Game				= Cloneable.clone()
Game.name				= "LOVE Tetris"
Game.version			= 0
Game.state				= -1
Game.board				= nil

-- resources
Game.playingBackground	= love.graphics.newImage("resources/playing_background.png")
Game.mainMenuOverlay	= love.graphics.newImage("resources/main_menu_overlay.png")
Game.logo				= love.graphics.newImage("resources/logo.png")

--[[
	This drum loop, titled "Marching Mice," is a little diddle
	by a cool cat going by the name kantouth (http://freesound.org/people/kantouth/)
	on freesound.org. This song and its license terms can be found here:
	http://freesound.org/people/kantouth/sounds/104984/
]]
Game.drumLoop			= love.audio.newSource("resources/drum_loop.ogg", "stream")
Game.drumLoop:setLooping(true)

Game.pauseLoop			= love.audio.newSource("resources/sine.ogg", "stream")
Game.pauseLoop:setVolume(0.1)
Game.pauseLoop:setLooping(true)

--- game running information
Game.runTime			= 0
Game.stateTime			= 0
Game.lastMove			= 0
Game.moveDelay			= 0.1
Game.lastDrop			= 0
Game.dropDelay			= 0.5
Game.fallSpeed			= 128 -- how many pixels the player piece moves per second
Game.currentPiece		= nil
Game.clearRowTime		= nil
Game.clearRowDelay		= 0.5 -- 1 seconds for the animation

function Game:initialize()
	self.board = GameBoard:new()
	self:startMainMenu()
	Game.drumLoop:play()
end

-- update the game
function Game:update(t)
	self:updateRunTime(t)
	self:updateStateTime(t)

	if self.state == GameState.PLAYING or
		self.state == GameState.MAIN_MENU then
		self.board:update(t)
	end

	if self.state == GameState.PLAYING then
		self:playUpdate(t)
	end
end

-- draws the game
function Game:draw()
	love.graphics.draw(self.playingBackground, 0, 0)
	self.board:draw(160, 0)

	if self.state == GameState.MAIN_MENU then
		self:drawMenu()
	end

	if self.state == GameState.PAUSE then
		local r,g,b,a = love.graphics.getColor()
		love.graphics.setColor(255,255,255,255)
		love.graphics.print("PAUSED", 320-(78/2), 160-40)
		love.graphics.print("PRESS ENTER TO CONTINUE", 320-(299/2), 160-20)
		love.graphics.setColor(r,g,b,a)
	end

	-- debug output
	local s = ""
	table.foreach(self, function(x,y) s = string.format("%s\n(%s): %s", s, tostring(x), tostring(y)) end)
	local r,g,b,a = love.graphics.getColor()
	love.graphics.setColor(255,0,0,255)
	love.graphics.print(s, 0, 0)
	love.graphics.setColor(r,g,b,a)
end


-- draws the menu
function Game:drawMenu()
	local r,g,b,a = love.graphics.getColor()
	local menuAlpha = math.min(self:getStateTime()*(255/2), 255)
	love.graphics.setColor(255,255,255,menuAlpha)
	love.graphics.draw(self.mainMenuOverlay, 0, 0)
	love.graphics.draw(self.logo, 224, 16)
	love.graphics.setColor(0, 0, 0, menuAlpha)
	love.graphics.print("press ENTER to begin", 190, 128)
	love.graphics.setColor(r,g,b,a)
end

-- updates the game (the playing state update)
function Game:playUpdate(t)
	-- spawn a piece if there is no active one
	if self.currentPiece == nil or self.currentPiece:isSnapped() then
		if self.board:collideXY(160,0,32,32,0,0) then
			self:stopPlaying()
			self:startMainMenu()
		else
			self.currentPiece = self.board:addNewPiece(160,0)
			self:resetLastMove()
		end

	-- drop the piece if it's active
	else
		self:dropPiece(self:getFallSpeed()*t)
	end

	if love.keyboard.isDown("left") and (self:getStateTime() > self.lastMove + self.moveDelay or self.lastMove == 0) then
		self:moveLeft()
	elseif love.keyboard.isDown("right") and (self:getStateTime() > self.lastMove + self.moveDelay or self.lastMove == 0) then
		self:moveRight()
	end
end

-- key press management
function Game:keypressed(key)
	if key == "return" or key == "kpenter" then
		if self.state == GameState.PAUSE then
			self:unpause()
		elseif self.state == GameState.PLAYING then
			self:pause()
		elseif self.state == GameState.MAIN_MENU then
			self:startPlaying()
		end
	end

	if key == "left" then
		if self.state == GameState.PLAYING then
			if self:canMoveLeft() then
				self:moveLeft()
			end
		end
	end

	if key == "right" then
		if self.state == GameState.PLAYING then
			if self:canMoveRight() then
				self:moveRight()
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

-- key release management
function Game:keyreleased(key)
end

-- updates run time timer from love.update()
function Game:updateRunTime(t)
	self.runTime = self.runTime + t
end

-- updates state time timer from love.update()
function Game:updateStateTime(t)
	self.stateTime = self.stateTime + t
end

-- grab the run time timer
function Game:getRunTime()
	return self.runTime
end

-- grab the state time timer
function Game:getStateTime()
	return self.stateTime
end

-- get our current state
function Game:getState()
	return self.state
end

-- change the current state
function Game:setState(state)
	self.state = state
	self.stateTime = 0
end

function Game:getFallSpeed()
	return self.fallSpeed
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
	self.drumLoop:pause()
	self.pauseLoop:play()
end

function Game:unpause()
	self:setState(GameState.PLAYING)
	self.stateTime = self.__playTime or 0
	self.pauseLoop:stop()
	self.drumLoop:resume()
	self.__playTime = nil
end

function Game:startMainMenu()
	self:setState(GameState.MAIN_MENU)
	self.board:clear()
end

function Game:resetLastMove()
	self.lastMove = 0
end

function Game:canMoveLeft()
	if self.currentPiece and not self.currentPiece:isSnapped() and not self.board:collidePiece(self.currentPiece, -32, 0) then
		return true
	end

	return false
end

function Game:canMoveRight()
	if self.currentPiece and not self.currentPiece:isSnapped() and not self.board:collidePiece(self.currentPiece, 32, 0) then
		return true
	end

	return false
end

function Game:dropPiece(distance)
	self.board:dropPiece(self.currentPiece, distance)
end

function Game:moveLeft()
	self.currentPiece.x = math.max(self.currentPiece.x - 32, 0)
	self.lastMove = self:getStateTime()
end

function Game:moveRight()
	self.currentPiece.x = math.min(self.currentPiece.x + 32, self.board:getWidth()-self.currentPiece:getWidth())
	self.lastMove = self:getStateTime()
end

return Game
