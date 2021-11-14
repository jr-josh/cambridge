local ChallengeSelectScene = Scene:extend()

ChallengeSelectScene.title = "Challenges"

current_challenge = 1

function indexOf(array, value)
    for i, v in ipairs(array) do
        if v == value then
            return i
        end
    end
    return nil
end

function ChallengeSelectScene:new()
	-- reload custom modules
	initModules()
	if table.getn(challenges) == 0 then
		self.display_warning = true
		current_challenge = 1
	else
		self.display_warning = false
		if current_challenge > table.getn(challenges) then
			current_challenge = 1
		end
	end

	self.menu_state = {
		challenge = current_challenge,
		select = "challenge",
	}
	self.secret_inputs = {}
	self.das = 0
	DiscordRPC:update({
		details = "In menus",
		state = "Choosing a challenge",
		largeImageKey = "ingame-000"
	})
end

function ChallengeSelectScene:update()
	switchBGM(nil) -- experimental

	if self.das_up or self.das_down then
		self.das = self.das + 1
	else
		self.das = 0
	end

	if self.das >= 15 then
		self:changeOption(self.das_up and -1 or 1)
		self.das = self.das - 4
	end

	DiscordRPC:update({
		details = "In menus",
		state = "Choosing a challenge",
		largeImageKey = "ingame-000"
	})
end

function ChallengeSelectScene:render()
	love.graphics.draw(
		backgrounds[0],
		0, 0, 0,
		0.5, 0.5
	)

	love.graphics.draw(misc_graphics["select_challenge"], 20, 40)

	if self.display_warning then
		love.graphics.setFont(font_3x5_3)
		love.graphics.printf(
			"You have no challenges",
			80, 200, 480, "center"
		)
		love.graphics.setFont(font_3x5_2)
		love.graphics.printf(
			"Come back to this menu after getting more challenges. " ..
			"Press any button to return to the main menu.",
			80, 250, 480, "center"
		)
		return
	end

	if self.menu_state.select == "challenge" then
		love.graphics.setColor(1, 1, 1, 0.5)
	end
	love.graphics.rectangle("fill", 20, 258, 240, 22)

	if self.menu_state.select == "challenge" then
		love.graphics.setColor(1, 1, 1, 0.25)
	end

	love.graphics.setColor(1, 1, 1, 1)

	love.graphics.setFont(font_3x5_2)
	for idx, challenge in pairs(challenges) do
		if(idx >= self.menu_state.challenge-9 and idx <= self.menu_state.challenge+9) then
			love.graphics.printf(challenge.name, 40, (260 - 20*(self.menu_state.challenge)) + 20 * idx, 200, "left")
			cur_tagline = challenge.tagline
		end
	end



end

function ChallengeSelectScene:onInputPress(e)
	if self.display_warning and e.input then
		scene = TitleScene()
	elseif e.type == "wheel" then
		if e.x % 2 == 1 then
			self:switchSelect()
		end
		if e.y ~= 0 then
			self:changeOption(-e.y)
		end
	elseif e.input == "menu_decide" or e.scancode == "return" then
		for idx, mode in pairs(game_modes) do
			if mode.hash == challenges[self.menu_state.challenge].mode then
				cur_mode = idx
				break
			end
		end
		for idx, ruleset in pairs(rulesets) do
			if ruleset.hash == challenges[self.menu_state.challenge].ruleset then
				cur_ruleset = idx
				break
			end
		end
		playSE("mode_decide")
		saveConfig()
		scene = ChallengeScene(
			challenges[current_challenge],
			rulesets[cur_ruleset]
		)
	elseif e.input == "up" or e.scancode == "up" then
		self:changeOption(-1)
		self.das_up = true
		self.das_down = nil
	elseif e.input == "down" or e.scancode == "down" then
		self:changeOption(1)
		self.das_down = true
		self.das_up = nil
	elseif e.input == "menu_back" or e.scancode == "delete" or e.scancode == "backspace" then
		scene = TitleScene()
	elseif e.input then
		self.secret_inputs[e.input] = true
	end


	love.graphics.printf("test???", 340, 258, 200, "left")

end

function ChallengeSelectScene:onInputRelease(e)
	if e.input == "up" or e.scancode == "up" then
		self.das_up = nil
	elseif e.input == "down" or e.scancode == "down" then
		self.das_down = nil
	elseif e.input then
		self.secret_inputs[e.input] = false
	end
end

function ChallengeSelectScene:changeOption(rel)
			self:changechallenge(rel)
			playSE("cursor")
end



function ChallengeSelectScene:changechallenge(rel)
	local len = table.getn(challenges)
	self.menu_state.challenge = Mod1(self.menu_state.challenge + rel, len)
end



return ChallengeSelectScene
