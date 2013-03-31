--[[	Author:	Milkmanjack
		Date:	3/5/13
		Master game object.
]]

require("ext.table")
local Cloneable				= require("obj.Cloneable")
local GameBoard				= require("obj.GameBoard")
local GameState				= require("obj.GameState")
local Tetromino				= require("obj.Tetromino")
local ZTetromino			= require("obj.ZTetromino")
local LTetromino			= require("obj.LTetromino")
local JTetromino			= require("obj.JTetromino")
local TTetromino			= require("obj.TTetromino")
local OTetromino			= require("obj.OTetromino")
local ITetromino			= require("obj.ITetromino")
local Game					= Cloneable.clone()
Game.name					= "LOVE Tetris"
Game.version				= 0
Game.state					= -1
Game.board					= nil

-- resources
Game.playingBackground		= love.graphics.newImage("resources/playing_background.png")
Game.mainMenuOverlay		= love.graphics.newImage("resources/main_menu_overlay.png")
Game.logo					= love.graphics.newImage("resources/logo.png")
Game.drumLoop				= love.audio.newSource("resources/drum_loop.ogg", "static")
Game.drumLoop:setLooping(true)
Game.clearSound				= love.audio.newSource("resources/coins.ogg", "static")

-- game settings
Game.pointsPerRow			= 725
Game.tetrisBonus			= Game.pointsPerRow*2 -- 2 row bonus for clearing 4 rows at once
Game.fallDelay				= 0.5
Game.fallQuickDelay			= 0.1
Game.moveDelay				= 0.25
Game.pointDisplayRate		= 5 -- 5 points per point update
Game.startX					= 32*5
Game.startY					= 32

--- game runtime information
Game.runTime				= 0
Game.stateTime				= 0
Game.previousStateTime		= 0
Game.lastMove				= 0
Game.lastFall				= 0
Game.currentTetromino		= nil
Game.pointsDisplay			= 0
Game.points					= 0
Game.pointsDisplayDelay		= 0.01
Game.lastPointUpdate		= 0
Game.lines					= 0

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

	-- draw the game info (score and timer)
	if self.state == GameState.PAUSE or self.state == GameState.PLAYING then
		self:drawGameInfo()
	end

	-- debug output
	--self:drawDebugScreen()
end

-- draws the background for the game
function Game:drawBackground()
	love.graphics.draw(self.playingBackground, 0, 0)
end

-- draws the game board
function Game:drawBoard()
	self.board:draw(160,0)
end

-- draws the menu
function Game:drawMenu()
	local r,g,b,a = love.graphics.getColor()
	local menuAlpha = math.min(self:getStateTime()*(255/2), 255)
	love.graphics.setColor(255,255,255,menuAlpha)
	love.graphics.draw(self.mainMenuOverlay, 0, 0)
	love.graphics.draw(self.logo, 640/2 - 192/2, 100)
	love.graphics.setColor(0, 0, 0, menuAlpha)
	love.graphics.print("press ENTER to begin", 190, 228)
	love.graphics.setColor(r,g,b,a)
end

-- draws the pause screen
function Game:drawPauseScreen()
	if self:getStateTime() % 0.5 < 0.25 then
		local r,g,b,a = love.graphics.getColor()
		love.graphics.setColor(255,255,255,255)
		love.graphics.print("PAUSED", 320-(78/2), 184)
		love.graphics.print("PRESS ENTER TO CONTINUE", 320-(299/2), 204)
		love.graphics.setColor(r,g,b,a)
	end
end

function Game:drawGameInfo()
	local font = love.graphics.getFont()
	local r,g,b,a = love.graphics.getColor()
	love.graphics.setFont(scoreFont)
	love.graphics.setColor(255,255,0,255)
	love.graphics.print("SCORE:", 16, 16)
	love.graphics.print(string.format("%d", self.pointsDisplay), 80, 16)

	love.graphics.print("LINES:", 16, 32)
	love.graphics.print(string.format("%d", self.lines), 80, 32)

	love.graphics.print("TIME:", 16, 64)
	love.graphics.print(string.format("%d", self.state == GameState.PLAYING and self:getStateTime() or self:getPreviousStateTime()), 80, 64)
	love.graphics.setFont(font)
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
	self.runTime = self.runTime + t
	self.stateTime = self.stateTime + t

	if self.state == GameState.PLAYING or
		self.state == GameState.MAIN_MENU then
		self:updateBoard()
	end

	if self.state == GameState.PLAYING then
		self:updatePlaying(t)
	end
end

-- updates the game (the playing state update)
function Game:updatePlaying(t)
	if self.points > self.pointsDisplay and self:getStateTime() > self.lastPointUpdate + self.pointsDisplayDelay then
		self.pointsDisplay = math.min(self.pointsDisplay + self.pointDisplayRate, self.points)
		self.lastPointDisplay = self:getStateTime()
	end

	-- spawn a piece if there is no active one
	if self.currentTetromino == nil or self.currentTetromino:isSnapped() then
		local tetromino = Game:getRandomTetromino():new()
		if not self:playWithTetromino(tetromino) then -- can't place tetromino? end the game
			self:stopPlaying()
			self:startMainMenu()
		end

	-- piece control goes here
	else
		if (love.keyboard.isDown("left") or love.keyboard.isDown("a")) and self:canRepeatMove() and self:canMoveLeft() then
			self:moveLeft()

		elseif (love.keyboard.isDown("right") or love.keyboard.isDown("d")) and self:canRepeatMove() and self:canMoveRight() then
			self:moveRight()
		end

		-- clear rows, get points
		if #self.board:getFullRows() > 0 then
			local fullRows = self.board:getFullRows()
			local clearRows = #fullRows
			self.lines = self.lines + clearRows
			for i,v in table.safeIPairs(fullRows) do
				self.board:clearRow(v)
				self.board:flagEmptyRow(v)
			end

			self:addPoints(clearRows*self.pointsPerRow)
			if clearRows >= 4 then
				self:addPoints(self.tetrisBonus)
			end

			self.clearSound:play()
		end

		if self:canFall() then
			self:fall()
		end
	end
end

function Game:canFall()
	return self:getStateTime() > (self.lastFall + self:getFallDelay()) or self.lastFall == 0
end

function Game:getFallDelay()
	if love.keyboard.isDown("down") or love.keyboard.isDown("s") then
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
		end

		self.board:snapTetromino(self.currentTetromino)

	else
		local hitBottom = false
		for i,v in ipairs(self.currentTetromino:getPieces()) do
			if v:getY() == self.board:getHeight()-v:getHeight() then
				hitBottom = true
			end
		end

		-- snap it
		if hitBottom then
			self.board:snapTetromino(self.currentTetromino)

		-- drop down
		else
			for i,v in ipairs(self.currentTetromino:getPieces()) do
				local maxY = self.board:getHeight()-v:getHeight()
				v:setY(math.min(v:getY()+distance, maxY))
			end
		end
	end

	self.lastFall = self:getStateTime()
end

-- update the game board
function Game:updateBoard()
	self.board:update()
end

-- retrieves a random tetromino "class"
function Game:getRandomTetromino()
	local tetrominoes = {ZTetromino,LTetromino,JTetromino,TTetromino,OTetromino,ITetromino}
	return tetrominoes[math.ceil(math.random()*6)]
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

function Game:addPoints(amount)
	self.points = self.points + amount
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
	self.lastPointUpdate	= 0
	self.points				= 0
	self.pointsDisplay		= 0
	self.lines				= 0
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
end

function Game:startMainMenu()
	self:setState(GameState.MAIN_MENU)
end

-- prepare the piece for play
function Game:playWithTetromino(tetromino)
	tetromino:setPositionRelativeTo(self:getStartX(), self:getStartY())
	for i,v in ipairs(tetromino:getPieces()) do
		if self.board:collidePiece(v) then
			return false
		end
	end

	for i,v in ipairs(tetromino:getPieces()) do
		self.board:addPiece(v)
	end

	self.currentTetromino = tetromino
	return true
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

		if key == "left" or key == "a" then
			if self:canMoveLeft() then
				self:moveLeft()
			end
		end

		if key == "right" or key == "d" then
			if self:canMoveRight() then
				self:moveRight()
			end
		end

		if key == " " then
			if self.board:canPivotLeft(self.currentTetromino) then
				self.currentTetromino:pivotLeft()
			end
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
