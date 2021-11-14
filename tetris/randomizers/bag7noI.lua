-- for the pre-packaged/example challenge tetrs

local Randomizer = require 'tetris.randomizers.randomizer'

local Bag7NoIRandomizer = Randomizer:extend()

function Bag7NoIRandomizer:initialize()
	self.bag = {"J", "L", "O", "S", "T", "Z"}
end

function Bag7NoIRandomizer:generatePiece()
	if next(self.bag) == nil then
		self.bag = {"J", "L", "O", "S", "T", "Z"}
	end
	local x = math.random(table.getn(self.bag))
	return table.remove(self.bag, x)
end

return Bag7NoIRandomizer
