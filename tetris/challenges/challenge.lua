-- currently you need to require and extend the gamemode you're making a challenge out of

require 'funcs'

local GameMode = require 'tetris.modes.gamemode'
local Piece = require 'tetris.components.piece'
local Grid = require 'tetris.components.grid'
local Randomizer = require 'tetris.randomizers.randomizer'
local BagRandomizer = require 'tetris.randomizers.bag'
local MarathonGF = require 'tetris.modes.marathon_gf'

local Challenge = GameMode:extend()

Challenge.name = "A really cool challenge name"
Challenge.hash = ""
Challenge.mode = ""
Challenge.ruleset = ""
Challenge.tagline = "Are you up for this challenge?"
Challenge.description = "Complete a mode with a specific ruleset and idk they did some other stupid things too lol"



return Challenge
