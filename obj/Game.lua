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
Game.mainMenuOverlay	= love.graphics.newImage("resources/main_menu_overlay.png")
Game.logo				= love.graphics.newImage("resources/love_outline.png")

function Game:initialize()
	self.board	= IntroGameBoard:new()
	self.state	= GameState.INITIAL
end

function Game:draw()
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
	end
end

function Game:keypressed(key)
	if key == "return" or key == "kpenter" then
		if self.state == GameState.INITIAL then
			self.board:finishAnimation()
		end

		if self.state == GameState.MAIN_MENU then
			self.state	= GameState.PLAYING
			self.board	= GameBoard:new()
		end
	end
end

return Game
