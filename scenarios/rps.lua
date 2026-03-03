

TheEncounter.Scenario({
	key = "rps",
	loc_txt = {
		name = "Rock Paper Scissors",
		text = {
			"Description",
		},
	},
	domains = {
		do_enc_occurrence = true,
	},
	config = {
		
	},
	starting_step_key = "st_map_rps_start",
    weight = 10000
    -- change to 100000 to make it always spawn 
    -- 5 is the default weight value
})

TheEncounter.Step({
	key = "rps_start",
	loc_txt = {
		text = {
			"Sample text.",
		},
	},
	start = function(self, event, after_load)
		event:image_character({
			key = "joker",
			center = "j_card_sharp",
			scale = 1,
			--particles = { G.C.RED, G.C.ORANGE, G.C.CHIPS },
		})
	end,
	get_choices = function(self, event)
		return {
			"ch_map_rps_play",
			"ch_map_leave"
		}
	end,

})


TheEncounter.Choice({
	key = "rps_play",
	loc_txt = {
		name = { "Play! (Costs #1#$)" },
	},
	config = { extra = { cost = 3 } },

    loc_vars = function(self, info_queue, event)
		return {
			vars = {
				self.config.extra.cost,
			},
		}
	end,
	button = function(self, event)
		ease_dollars(-self.config.extra.cost)

		event:start_step("st_map_rps_select")
	end,
	func = function (self, event, ability)
		return G.GAME.dollars > ability.extra.cost
		
	end
})

TheEncounter.Step({
	key = "rps_select",
	loc_txt = {
		text = {
			"Select what to play:",
		},
		choices = {
			rock = {
				name = { "Rock" },
			},
			paper = {
				name = { "Paper" },
			},
			scissors = {
				name = { "Scissors" },
			},
		},
	},
	start = function(self, event, after_load)
		event.ability.extra.enemy_choice = pseudorandom_element({"rock", "paper", "scissors"}, 'map_rps')
	end,
	get_choices = function(self, event)
		return {
			{
				choice = "rock",
				button = function()
					event.ability.extra.choice = "rock"
					event:start_step("st_map_rps_play")
				end,
			},
			{
				choice = "paper",
				button = function()
					event.ability.extra.choice = "paper"
					event:start_step("st_map_rps_play")
				end,
			},
			{
				choice = "scissors",
				button = function()
					event.ability.extra.choice = "scissors"
					event:start_step("st_map_rps_play")
				end,
			},
		}
	end,

})

TheEncounter.Step({
	key = "rps_play",
	loc_txt = {
		text = {
			"#1#",
		},
	},
	

	config = {
		win_table = { 
			rock = {
				rock = "draw",
				paper = "lose",
				scissors = "win"
			},
			paper = {
				rock = "win",
				paper = "draw",
				scissors = "lose"
			},
			scissors = {
				rock = "lose",
				paper = "win",
				scissors = "draw"
			},
		}
	}, 

	start = function(self, event, after_load)

		event.ability.extra.state = self.config.win_table[event.ability.extra.choice][event.ability.extra.enemy_choice]

	end,
	get_choices = function(self, event)
		event.ability.extra.state = self.config.win_table[event.ability.extra.choice][event.ability.extra.enemy_choice]
		if event.ability.extra.state == "draw" then
			
		elseif event.ability.extra.state == "win" then

		else
			return {
				"ch_map_leave"
			}
		end
		
	end,

	loc_vars = function(self, info_queue, event)
		event.ability.extra.state = self.config.win_table[event.ability.extra.choice][event.ability.extra.enemy_choice]
		return {
			vars = {
				event.ability.extra.state,
			},
		}
	end,

})