--[[	Author:	Milkmanjack
		Date:	3/5/13
		Table for pretending to be an enum.
]]

local GameState		= {}
GameState.INITIAL	= 0 -- initial stage of the game
GameState.MAIN_MENU	= 1 -- main game menu
GameState.GAME_PREP	= 2 -- game preparation menu (if applicable)
GameState.PLAYING	= 3 -- game is in play
GameState.PAUSE		= 4 -- game is paused (but playing)
GameState.GAME_OVER	= 5 -- player has lost the game

return GameState
