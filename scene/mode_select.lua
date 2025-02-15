local ModeSelectScene = Scene:extend()

ModeSelectScene.title = "Game Start"

current_mode = 1
current_ruleset = 1

function ModeSelectScene:new()
	-- reload custom modules
	initModules()
	if table.getn(game_modes) == 0 or table.getn(rulesets) == 0 then
		self.display_warning = true
		current_mode = 1
		current_ruleset = 1
	else
		self.display_warning = false
		if current_mode > table.getn(game_modes) then
			current_mode = 1
		end
		if current_ruleset > table.getn(rulesets) then
			current_ruleset = 1
		end
	end

	self.menu_state = {
		mode = current_mode,
		ruleset = current_ruleset,
		select = "mode",
	}
	self.secret_inputs = {}
	self.das = 0
	-- It's not exactly self-descriptive.
	self.menu_mode_height = 20
	-- It's not exactly self-descriptive.
	self.menu_ruleset_height = 20
	self.auto_menu_offset = 0
	self.auto_menu_state = "mode"
	DiscordRPC:update({
		details = "In menus",
		state = "Choosing a mode",
		largeImageKey = "ingame-000"
	})
	self.mouse_state = {
		prev_x = 0,
		prev_y = 0,
		used_since_last_keypress = true
	}
end

function ModeSelectScene:update()
	switchBGM(nil) -- experimental

	local mouse_x, mouse_y = getScaledPos(love.mouse.getPosition())
	if (mouse_x ~= self.mouse_state.prev_x) or (mouse_y ~= self.mouse_state.prev_y) then
		self.mouse_state.used_since_last_keypress = true
	end
	self.mouse_state.prev_x = mouse_x
	self.mouse_state.prev_y = mouse_y
	if self.mouse_state.used_since_last_keypress then
		if mouse_x < 320 then
			self.auto_menu_state = "mode"
		else
			self.auto_menu_state = "ruleset"
		end
		if self.auto_menu_state ~= self.menu_state.select then
			self:switchSelect()
		end
		if love.mouse.isDown(1) and not left_clicked_before then
			self.auto_menu_offset = math.floor((mouse_y - 260)/20)
			if self.auto_menu_offset == 0 and self.auto_menu_state == "mode" then
				self:startMode()
			end
		end
	end

	if self.das_up or self.das_down then
		self.das = self.das + 1
	else
		self.das = 0
	end
	if self.auto_menu_offset ~= 0 then
		self:changeOption(self.auto_menu_offset < 0 and -1 or 1)
		if self.auto_menu_offset > 0 then self.auto_menu_offset = self.auto_menu_offset - 1 end
		if self.auto_menu_offset < 0 then self.auto_menu_offset = self.auto_menu_offset + 1 end
	end
	if self.das >= 15 then
		self:changeOption(self.das_up and -1 or 1)
		self.das = self.das - 4
	end

	DiscordRPC:update({
		details = "In menus",
		state = "Choosing a " .. self.menu_state.select,
		largeImageKey = "ingame-000"
	})
end

function ModeSelectScene:render()
	love.graphics.draw(
		backgrounds[0],
		0, 0, 0,
		0.5, 0.5
	)

	love.graphics.draw(misc_graphics["select_mode"], 20, 40)

	if self.display_warning then
		love.graphics.setFont(font_3x5_3)
		love.graphics.printf(
			"You have no modes or rulesets.",
			80, 200, 480, "center"
		)
		love.graphics.setFont(font_3x5_2)
		love.graphics.printf(
			"Come back to this menu after getting more modes or rulesets. " ..
			"Press any button to return to the main menu.",
			80, 250, 480, "center"
		)
		return
	end

	if self.menu_state.select == "mode" then
		love.graphics.setColor(1, 1, 1, 0.5)
	elseif self.menu_state.select == "ruleset" then
		love.graphics.setColor(1, 1, 1, 0.25)
	end
	self.menu_mode_height = interpolateListHeight(self.menu_mode_height / 20, self.menu_state.mode) * 20
	self.menu_ruleset_height = interpolateListHeight(self.menu_ruleset_height / 20, self.menu_state.ruleset) * 20
	love.graphics.rectangle("fill", 20, 258 + (self.menu_state.mode * 20) - self.menu_mode_height, 240, 22)

	if self.menu_state.select == "mode" then
		love.graphics.setColor(1, 1, 1, 0.25)
	elseif self.menu_state.select == "ruleset" then
		love.graphics.setColor(1, 1, 1, 0.5)
	end
	love.graphics.rectangle("fill", 340, 258 + (self.menu_state.ruleset * 20) - self.menu_ruleset_height, 200, 22)

	love.graphics.setColor(1, 1, 1, 1)

	love.graphics.setFont(font_3x5_2)
	for idx, mode in pairs(game_modes) do
		if(idx >= self.menu_mode_height / 20-10 and idx <= self.menu_mode_height / 20+10) then
			local b = self:CursorHighlight(0,(260 - self.menu_mode_height) + 20 * idx,320,20)
			love.graphics.setColor(1,1,b,FadeoutAtEdges((-self.menu_mode_height) + 20 * idx, 180, 20))
			love.graphics.printf(mode.name, 40, (260 - self.menu_mode_height) + 20 * idx, 200, "left")
		end
	end
	for idx, ruleset in pairs(rulesets) do
		if(idx >= self.menu_ruleset_height / 20-10 and idx <= self.menu_ruleset_height / 20+10) then
			local b = self:CursorHighlight(320,(260 - self.menu_ruleset_height) + 20 * idx,320,20)
			love.graphics.setColor(1,1,b,FadeoutAtEdges(-self.menu_ruleset_height + 20 * idx, 180, 20))
			love.graphics.printf(ruleset.name, 360, (260 - self.menu_ruleset_height) + 20 * idx, 160, "left")
		end
	end
	love.graphics.setColor(1,1,1,1)
end
function ModeSelectScene:CursorHighlight(x,y,w,h)
	if self.mouse_state.used_since_last_keypress then
		return CursorHighlight(x, y, w, h)
	else
		return 1
	end
end


function CursorHighlight(x,y,w,h)
	local mouse_x, mouse_y = getScaledPos(love.mouse.getPosition())
	if mouse_x > x and mouse_x < x+w and mouse_y > y and mouse_y < y+h then
		return 0
	else 
		return 1
	end
end
function FadeoutAtEdges(input, edge_distance, edge_width)
	if input < 0 then
		input = input * -1
	end
	if input > edge_distance then
		return 1 - (input - edge_distance) / edge_width
	end
	return 1
end
function ModeSelectScene:startMode()
	current_mode = self.menu_state.mode
	current_ruleset = self.menu_state.ruleset
	config.current_mode = current_mode
	config.current_ruleset = current_ruleset
	playSE("mode_decide")
	saveConfig()
	scene = GameScene(
		game_modes[self.menu_state.mode],
		rulesets[self.menu_state.ruleset],
		self.secret_inputs
	)
end

function ModeSelectScene:onInputPress(e)
	if self.display_warning and e.input then
		scene = TitleScene()
	elseif e.type == "wheel" then
		if e.x % 2 == 1 then
			self:switchSelect()
		end
		if e.y ~= 0 then
			self:changeOption(-e.y)
		end
	else
		self.mouse_state.used_since_last_keypress = false
		if e.input == "menu_decide" or e.scancode == "return" then
			current_mode = self.menu_state.mode
			current_ruleset = self.menu_state.ruleset
			config.current_mode = current_mode
			config.current_ruleset = current_ruleset
			playSE("mode_decide")
			saveConfig()
			scene = GameScene(
				game_modes[self.menu_state.mode],
				rulesets[self.menu_state.ruleset],
				self.secret_inputs
			)
		elseif e.input == "up" or e.scancode == "up" then
			self:changeOption(-1)
			self.das_up = true
			self.das_down = nil
		elseif e.input == "down" or e.scancode == "down" then
			self:changeOption(1)
			self.das_down = true
			self.das_up = nil
		elseif e.input == "left" or e.input == "right" or e.scancode == "left" or e.scancode == "right" then
			self:switchSelect()
		elseif e.input == "menu_back" or e.scancode == "delete" or e.scancode == "backspace" then
			scene = TitleScene()
		elseif e.input then
			self.secret_inputs[e.input] = true
		end
	end
end 

function ModeSelectScene:onInputRelease(e)
	if e.input == "up" or e.scancode == "up" then
		self.das_up = nil
	elseif e.input == "down" or e.scancode == "down" then
		self.das_down = nil
	elseif e.input then
		self.secret_inputs[e.input] = false
	end
end

function ModeSelectScene:changeOption(rel)
	if self.menu_state.select == "mode" then
		self:changeMode(rel)
	elseif self.menu_state.select == "ruleset" then
		self:changeRuleset(rel)
	end
	playSE("cursor")
end

function ModeSelectScene:switchSelect()
	if self.menu_state.select == "mode" then
		self.menu_state.select = "ruleset"
	elseif self.menu_state.select == "ruleset" then
		self.menu_state.select = "mode"
	end
	print(self.menu_state.select)
	playSE("cursor_lr")
end

function ModeSelectScene:changeMode(rel)
	local len = table.getn(game_modes)
	self.menu_state.mode = Mod1(self.menu_state.mode + rel, len)
end

function ModeSelectScene:changeRuleset(rel)
	local len = table.getn(rulesets)
	self.menu_state.ruleset = Mod1(self.menu_state.ruleset + rel, len)
end

return ModeSelectScene