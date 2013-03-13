--[[	Author:	Milkmanjack
		Date:	3/5/13
		Master game object.
]]

local Cloneable				= require("obj.Cloneable")
local GameBoard				= require("obj.GameBoard")
local GameState				= require("obj.GameState")
local Tetromino				= require("obj.Tetromino")
local Game					= Cloneable.clone()
Game.name					= "LOVE Tetris"
Game.version				= 0
Game.state					= -1
Game.board					= nil

-- resources
Game.playingBackground		= love.graphics.newImage("resources/playing_background.png")
Game.mainMenuOverlay		= love.graphics.newImage("resources/main_menu_overlay.png")
Game.logo					= love.graphics.newImage("resources/logo.png")

--[[
	This drum loop, titled "Marching Mice," is a little diddle
	by a cool cat going by the name kantouth (http://freesound.org/people/kantouth/)
	on freesound.org. This song and its license terms can be found here:
	http://freesound.org/people/kantouth/sounds/104984/
]]
Game.drumLoop				= love.audio.newSource("resources/drum_loop.ogg", "stream")
Game.drumLoop:setLooping(true)

Game.pauseLoop				= love.audio.newSource("resources/sine.ogg", "stream")
Game.pauseLoop:setVolume(0.1)
Game.pauseLoop:setLooping(true)

--- game running information
Game.runTime				= 0
Game.stateTime				= 0
Game.lastMove				= 0
Game.moveDelay				= 0.1
Game.lastDrop				= 0
Game.dropDelay				= 5
Game.fallSpeed				= 128 -- how many pixels the player piece moves per second
Game.fallSpeedMultiplier	= 3
Game.currentPiece			= nil
Game.clearRowTime			= nil
Game.clearRowDelay			= 0.5 -- 1 seconds for the animation

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
		self:drop(self:getFallSpeed()*t)
	end
end

-- key press management
function Game:keypressed(key)
	if self.state == GameState.PAUSE then
		if key == "return" or key == "kpenter" then
			self:unpause()
		end

	elseif self.state == GameState.MAIN_MENU then
		if key == "return" or key == "kpenter" then
			self:startPlaying()
		end

	elseif self.state == GameState.PLAYING then
		if key == "return" or key == "kpenter" then
			self:pause()
		end

		if key == "space" then
			self.piece:pivotLeft()
		end

		if key == "escape" then
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
	if love.keyboard.isDown("down") then
		return self.fallSpeed * self.fallSpeedMultiplier
	end

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

function Game:resetLastDrop()
	self.lastDrop = 0
end

function Game:resetLastMove()
	self.lastMove = 0
end

function Game:canMoveLeft()	
	return false
end

function Game:canMoveRight()
	return false
end

function Game:canDrop()
	return false
end

function Game:drop(distance)
end

function Game:moveLeft()
	self.lastMove = self:getStateTime()
end

function Game:moveRight()
	self.lastMove = self:getStateTime()
end

return Game
