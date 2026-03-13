

TheEncounter.Scenario({
	key = "rps",
	loc_txt = {
		name = "Rock Paper Scissors",
		text = {
			"Gambling!",
		},
	},
	domains = {
		do_map_game = true,
	},
	config = {
		
	},
	starting_step_key = "st_map_rps_start",
    weight = 5,
	map_credits = {
        made = "vissa",
    },
})

TheEncounter.Step({
	key = "rps_start",
	loc_txt = {
		text = {
			'"Hey kid do you wanna gamble?"',
			"\"I'll give you a Tag if you win.\""
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
		name = { "Play! (Costs {C:money}#1#${})" },
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
		return G.GAME.dollars >= ability.extra.cost
		
	end
})

TheEncounter.Step({
	key = "rps_select",
	loc_txt = {
		text = {
			"Rock,",
			"Paper,",
			"Scissors,",
			"MULT!",
			"",
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
	setup = function(self, event)
		event.ability.extra.enemy_choice = pseudorandom_element({"rock", "paper", "scissors"}, 'map_rps')
	end,
	get_choices = function(self, event)
		return {
			{
				choice = "rock",
				button = function()
					event.ability.extra.choice = "rock"
					event:start_step("st_map_rps_info")
				end,
			},
			{
				choice = "paper",
				button = function()
					event.ability.extra.choice = "paper"
					event:start_step("st_map_rps_info")
				end,
			},
			{
				choice = "scissors",
				button = function()
					event.ability.extra.choice = "scissors"
					event:start_step("st_map_rps_info")
				end,
			},
		}
	end,

})

TheEncounter.Step({
	key = "rps_info",
	loc_txt = {
		text = {
			"You picked: #1#.",
			"Enemy picked: #2#."
		},
		choices = {
			call = {
				name = { "Continue" },
			},

		},
	},
	get_choices = function(self, event)
		return {
			{
				choice = "call",
				button = function()
					event:start_step("st_map_rps_play")
				end,
			},
		}
	end,
	loc_vars = function (self, info_queue, event)
		return {
			vars = {
				localize('rps_'..event.ability.extra.choice),
				localize('rps_'..event.ability.extra.enemy_choice),
			}
		}
	end
})


TheEncounter.Step({
	key = "rps_play",
	loc_txt = {

		choices = {
			draw = {
				name = { "Draw! Take {C:money}#1#${})" },
				
			},
			win = {
				name = { "Won! Take #1#" },
			},


		},
	},
	setup = function(self, event)
		event.ability.extra.state = self.config.win_table[event.ability.extra.choice][event.ability.extra.enemy_choice]
		if event.ability.extra.state == "win" then
			event.ability.extra.tag = pseudorandom_element(SMODS.get_clean_pool("Tag"), 'map_rps_tag')
			local temp_tag = Tag(event.ability.extra.tag)
			local tag_sprite_ui = temp_tag:generate_UI()

			event.ui.image.children.tag = UIBox{
				definition = {n=G.UIT.ROOT, config={align = "cm",padding = 0.05, colour = G.C.CLEAR}, nodes={
					tag_sprite_ui
				}},
				config = {
					align = 'bm',
					-- offset = G.HUD_tags[1] and {x=0,y=0} or {x=0.7,y=0},
					major = event.ui.image
				}
			}
		end
	end,
	loc_vars = function(self, info_queue, event)
		return {
			vars = {
				localize({type = "name_text", key = event.ability.extra.tag, set = "Tag"}),
				event.ability.extra.cost
			},
			key = self.key.."_"..event.ability.extra.state
		}
	end,

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
		},
		extra = { cost = 1 },
	}, 

	get_choices = function(self, event)
		if event.ability.extra.state == "draw" then
			return {
				{
					choice = "draw", 
					button = function()
						ease_dollars(event.ability.extra.cost)
						event:finish_scenario()
					end,
					loc_vars = function(self, info_queue, event)
						return {
							vars = {
								event.ability.extra.cost,
							},
						}
					end,
				},
				"ch_map_leave"
			}
		elseif event.ability.extra.state == "win" then
			return {
				{
					choice = "win",
					button = function()
						
						add_tag(Tag(event.ability.extra.tag))
						MAP.UTIL.immediate_tag_trigger()
						event:finish_scenario()
					end,
					loc_vars = function(self, info_queue, event)
						return {
							vars = {
								localize({type = "name_text", key = event.ability.extra.tag, set = "Tag"}),
							},
						}
					end,
				},
				"ch_map_leave"
			}
		else
			return {
				"ch_map_leave"
			}
		end
		
	end,

	
})
