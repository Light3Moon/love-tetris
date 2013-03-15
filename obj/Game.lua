--[[	Author:	Milkmanjack
		Date:	3/5/13
		Master game object.
]]

local Cloneable				= require("obj.Cloneable")
local GameBoard				= require("obj.GameBoard")
local GameState				= require("obj.GameState")
local Tetromino				= require("obj.Tetromino")
local ZTetromino			= require("obj.ZTetromino")
local LTetromino			= require("obj.LTetromino")
local JTetromino			= require("obj.JTetromino")
local TTetromino			= require("obj.TTetromino")
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

--- game running information
Game.runTime				= 0
Game.stateTime				= 0
Game.previousStateTime		= 0
Game.lastMove				= 0
Game.moveDelay				= 0.25
Game.lastFall				= 0
Game.fallDelay				= 0.5
Game.fallQuickDelay			= 0.1
Game.currentTetromino		= nil
Game.startX					= 32*5
Game.startY					= 32

function Game:initialize()
	self.board = GameBoard:new()
	self:startMainMenu()
	Game.drumLoop:play()
end

-- draws the game
function Game:draw()
	self:drawBackground()
	self:drawBoard()

	-- draw the main menu
	if self.state == GameState.MAIN_MENU then
		self:drawMenu()
	end

	-- draw the pause screen
	if self.state == GameState.PAUSE then
		self:drawPauseScreen()
	end

	-- debug output
	self:drawDebugScreen()
end

-- draws the game board
function Game:drawBoard()
	self.board:draw(160,0)
end

-- draws the background for the game
function Game:drawBackground()
	love.graphics.draw(self.playingBackground, 0, 0)
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

-- draws the pause screen
function Game:drawPauseScreen()
	local r,g,b,a = love.graphics.getColor()
	love.graphics.setColor(255,255,255,255)
	love.graphics.print("PAUSED", 320-(78/2), 160-40)
	love.graphics.print("PRESS ENTER TO CONTINUE", 320-(299/2), 160-20)
	love.graphics.setColor(r,g,b,a)
end

-- draws the debug screen
function Game:drawDebugScreen()
	local s = ""
	table.foreach(self, function(x,y) s = string.format("%s\n(%s): %s", s, tostring(x), tostring(y)) end)
	local r,g,b,a = love.graphics.getColor()
	love.graphics.setColor(255,0,0,255)
	love.graphics.print(s, 0, 0)
	love.graphics.setColor(r,g,b,a)
end

-- update the game
function Game:update(t)
	self:updateRunTime(t)
	self:updateStateTime(t)

	if self.state == GameState.PLAYING or
		self.state == GameState.MAIN_MENU then
		self:updateBoard()
	end

	if self.state == GameState.PLAYING then
		self:updatePlaying(t)
	end
end

function Game:getRandomTetromino()
	local tetrominoes = {ZTetromino,LTetromino,JTetromino,TTetromino}
	return tetrominoes[math.ceil(math.random()*4)]
end

-- updates the game (the playing state update)
function Game:updatePlaying(t)
	-- spawn a piece if there is no active one
	if self.currentTetromino == nil then
		self:newTetromino(Game:getRandomTetromino())

	-- drop the current piece otherwise
	elseif self:canFall() then
		self:fall()
	end
end

function Game:canFall()
	return self:getStateTime() > (self.lastFall + self:getFallDelay()) or self.lastFall == 0
end

function Game:getFallDelay()
	if love.keyboard.isDown("down") then
		return self.fallQuickDelay
	end

	return self.fallDelay
end

function Game:canRepeatMove()
	return self:getStateTime() > self.lastMove + self.moveDelay
end

function Game:canMoveLeft()
	for i,v in ipairs(self.currentTetromino:getPieces()) do
		if self.board:collidePiece(v, -32, 0) or v:getX()-32 < 0 then
			return false
		end
	end

	return true
end

function Game:canMoveRight()
	for i,v in ipairs(self.currentTetromino:getPieces()) do
		if self.board:collidePiece(v, 32, 0) or v:getX()+32+v:getWidth() > self.board:getWidth() then
			return false
		end
	end

	return true
end

function Game:moveLeft()
	for i,v in ipairs(self.currentTetromino:getPieces()) do
		v:setX(v:getX()-32)
	end

	self.lastMove = self:getStateTime()
end

function Game:moveRight()
	for i,v in ipairs(self.currentTetromino:getPieces()) do
		v:setX(v:getX()+32)
	end

	self.lastMove = self:getStateTime()
end

-- this is kinda gross.
function Game:fall()
	local collision, collisionXDiff, collisionYDiff
	local distance = 32
	for i,v in ipairs(self.currentTetromino:getPieces()) do
		if not collision then
			collision = self.board:collidePiece(v, 0, distance)
			if collision then 
				collisionYDiff = math.abs(v:getY()-collision:getY())
			end
		end
	end

	if collision then
		for i,v in ipairs(self.currentTetromino:getPieces()) do
			v:setY(v:getY()+collisionYDiff-v:getHeight())
			self.board:snapPiece(v)
		end

		self:newTetromino(Game:getRandomTetromino())

	else
		local hitBottom = false
		for i,v in ipairs(self.currentTetromino:getPieces()) do
			local maxY = self.board:getHeight()-v:getHeight()
			v:setY(math.min(v:getY()+distance, maxY))
			if v:getY() == maxY then
				hitBottom = true
			end
		end

		if hitBottom then
			for i,v in ipairs(self.currentTetromino:getPieces()) do
				self.board:snapPiece(v)
			end

			self:newTetromino(Game:getRandomTetromino())
		end
	end

	self.lastFall = self:getStateTime()
end

-- update the game board
function Game:updateBoard()
	self.board:update()
end

-- updates run time timer from love.update()
function Game:updateRunTime(t)
	self.runTime = self.runTime + t
end

-- updates state time timer from love.update()
function Game:updateStateTime(t)
	self.stateTime = self.stateTime + t
end

function Game:getStartX()
	return self.startX
end

function Game:getStartY()
	return self.startY
end

-- grab the run time timer
function Game:getRunTime()
	return self.runTime
end

-- grab the state time timer
function Game:getStateTime()
	return self.stateTime
end

-- previous state time timer
function Game:getPreviousStateTime()
	return self.previousStateTime
end

-- get our current state
function Game:getState()
	return self.state
end

-- change the current state
function Game:setState(state)
	self.state = state
	self.previousStateTime = self.stateTime
	self.stateTime = 0
end

-- state management functions
function Game:startPlaying()
	self:setState(GameState.PLAYING)
	self.board:clear()
end

function Game:stopPlaying()
	self.currentTetromino	= nil
	self.lastMove			= 0
	self.lastFall			= 0
	self.board:clear()
end

function Game:pause()
	self:setState(GameState.PAUSE)
	self.drumLoop:setVolume(0.25)
end

function Game:unpause()
	local playTime = self:getPreviousStateTime()
	self:setState(GameState.PLAYING)
	self.stateTime = playTime
	self.drumLoop:setVolume(1)
	self.__playTime = nil
end

function Game:startMainMenu()
	self:setState(GameState.MAIN_MENU)
end

-- construct a new piece for play
function Game:newTetromino(style)
	local tetromino = style:new()
	tetromino:setPositionRelativeTo(self:getStartX(), self:getStartY())
	for i,v in ipairs(tetromino:getPieces()) do
		self.board:addPiece(v)
	end

	self.currentTetromino = tetromino
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

		if key == "left" then
			if self:canMoveLeft() then
				self:moveLeft()
			end
		end

		if key == "right" then
			if self:canMoveRight() then
				self:moveRight()
			end
		end

		if key == " " then
			self.currentTetromino:pivotLeft()
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

return Game
