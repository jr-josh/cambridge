require 'funcs'

local GameMode = require 'tetris.modes.gamemode'
local Piece = require 'tetris.components.piece'
local Grid = require 'tetris.components.grid'
local Randomizer = require 'tetris.randomizers.randomizer'
local Bag7Randomizer = require 'tetris.randomizers.bag7noI'
local MarathonGF = require 'tetris.modes.marathon_gf'

local TetrsChallenge = MarathonGF:extend()

TetrsChallenge.name = "Another mode"
TetrsChallenge.hash = "Tetrs2"
TetrsChallenge.mode = "MarathonGF"
TetrsChallenge.ruleset = "Standard"
TetrsChallenge.tagline = "Hey look! The feature works!"
TetrsChallenge.description = "This is just a clone of Tetrs to test out the challenge details feature."

function TetrsChallenge:new()

    TetrsChallenge.super:new()
  self.randomizer = Bag7Randomizer()
  self.next_queue_length = 6
end

return TetrsChallenge
