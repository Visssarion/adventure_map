-- Defining scenario aka event inself
TheEncounter.Scenario({
	map_credits = {
		code = { "SleepyG11" },
	},
	
	-- Required fields
	key = "buzzfeed_quiz",
	starting_step_key = "st_map_buzzfeed_quiz_start",

	loc_txt = {
		-- Both name and description supports formatting and multiline, but not multibox
		name = { "Personality Quiz" },
		-- This is text which displayed on collection or, if `blind_text` is not specified, on blind select
		text = {
			"Which Balatro joker you are?",
		},
		-- This is text which displayed on blind select, if not provided `text` will be used
		blind_text = {
			"Click here and find out",
			"which Joker you are!",
		},
	},
	-- Specify in which domains this scenario can be encountered
	domains = { do_enc_occurrence = true },
	-- This object is something similar to 'card.ability', here stored persistent data such as current visibility flags and, just like on cards, `extra`, where you can store any data you need
	-- Of course, all data in here should be serializeable. For storing objects like cards or card areas, use `data` object instead. Usage example in `hotpot_blackjack.lua`
	-- In our case here, we want just hide a hand, but if you want, you can hide deck, custom hud panel (example of it in `hotpot_transaction.lua`), text and other ui elements
	config = {
		hide_hand = true,
	},

	-- As usual, function to specify is current scenario in pool under specific domain
	in_pool = function(self, domain)
		return true
		-- return not next(SMODS.find_card("j_hpot_diy", true))
	end,

	-- By default, scenario progress between steps is not saved.
	-- This can be enabled, but require additional work to make sure all custom logic saved properly
	-- On out case we want prevent save-scumming, so we implement some checks, which can be found in this example below.
	can_save = true,

	-- Main colour for scenario, used for most UI elements
	colour = HEX("D60000"),
	-- Colour used for background vortex shader. Can pass a function for custom shader (see `hotpot_room_in_between.lua`)
	background_colour = HEX("A50000"),

	-- Start callback is called when player enters scenario, or loads in it
	-- During entire scenario, whould be cool to display something as "image" instead of just panel of text.
	-- So, on scenario start, we creating a Card_Character, which will be placed on black box on right side of panel
	start = function(self, event, after_load)
		event:image_character({
			center = "j_joker",
			scale = 0.75,
		})
	end,

	weight = 0,
})

-- Starting step
TheEncounter.Step({
	key = "buzzfeed_quiz_start",
	loc_txt = {
		-- Step doesnt have name (at least for now)

		-- This is main text player see during step.
		-- It splitted on a lines and displayed line-by-line.
		-- How this can be itilized shown in this example below.
		text = {
			"You accidentally clicked one of the ads on the screen. The page reads:",
			" ",
			'{s:1.2}"Which {s:1.2,C:attention}Balatro{s:1.2} Joker are you?"',
			" ",
			"No harm in trying it out, right?",
		},

		-- Instead of making an entire choice class for each choice, in each event, they can be "auto-generated".
		choices = {
			take_quiz = {
				-- Text displayed on button
				name = {
					"Take the quiz",
				},
				-- Text displayed on button hover, here you can pass additional information such as requirements or a bit of lore, up to you!
				text = {
					"Require Joker slot",
				},
			},
		},
	},
	-- List of choices user can do in this step
	-- Each of them can do various stuff: proceed to next step, call any effects or just finish scenario and return back to regular game loop
	get_choices = function(self, event)
		return {
			{
				-- Key in this case refers to a localization entry we passed earlier, `choices.take_quiz`
				choice = "take_quiz",
				-- Similar to UI buttons, you can specify `func` (condition when button can be pressed) and `button` (effect)
				-- In out case we proceed to next step, but here you can do anything: spawn jokers, give money, explode, you name it!
				-- Moving to next step or finishing scenario is optional, so you can make multi-use buttons, (for example currency exchange)
				button = function(self, event, ability)
					event:start_step("st_map_buzzfeed_quiz_1")
				end,
			},

			-- Instead of object key can be passed aswell
			"ch_map_move_on",
		}
	end,
})

-- First effect
TheEncounter.Choice({
	key = "buzzfeed_quiz_trigger",
	loc_txt = {
		name = {
			"I don't know",
		},
		variants = {
			park = {
				name = { "To the park" },
			},
			carnival = {
				name = { "To the town fair" },
			},
			casino = {
				name = { "To the casino" },
			},
			no_date = {
				name = { "Nowhere, because nothing ever happens" },
			},
		},
	},
	config = {
		extra = {
			effects = {
				park = 1,
				carnival = 2,
				casino = 3,
				no_date = 4,
			},
		},
	},
	button = function(self, event, ability)
		event.ability.extra.trigger_value = ability.extra.effects[ability.extra.chosen]
		event.ability.extra.trigger = ability.extra.chosen
		event:start_step("st_map_buzzfeed_quiz_1_result")
	end,
	loc_vars = function(self, info_queue, event, ability)
		return {
			variant = ability.extra.chosen,
		}
	end,
	get_colours = function(self, event, ability)
		if ability.extra.chosen == "no_date" then
			return {
				colour = G.C.MULT,
			}
		end
	end,
})
TheEncounter.Step({
	key = "buzzfeed_quiz_1",
	loc_txt = {
		text = {
			'"Where would you like to go on a first date?"',
		},
	},
	get_choices = function(self, event)
		local result = {}
		for _, variant in ipairs({ "park", "carnival", "casino", "no_date" }) do
			table.insert(result, {
				key = "ch_map_buzzfeed_quiz_trigger",
				ability = {
					extra = {
						chosen = variant,
					},
				},
			})
		end
		result.columns = { 2, 2 }
		return result
	end,
})

-- First result
TheEncounter.Step({
	key = "buzzfeed_quiz_1_result",
	loc_txt = {
		text = {
			"You did not pick anything...",
		},
		choices = {
			continue = {
				name = { "Read the next question" },
			},
		},
		variants = {
			park = {
				text = { "You would like to go on a nice handholding date", "to the local park, you thought." },
			},
			carnival = {
				text = {
					"You would like to enjoy the attractions",
					"together at the local town fair, you thought.",
				},
			},
			casino = {
				text = {
					"They are not going out with me if they can't",
					"enjoy a little Plinko gambling, you thought.",
				},
			},
			no_date = {
				text = { "Dates? Those are woke nonsense.", "I'm going to be by my lonesome, you thought." },
			},
		},
	},
	get_choices = function(self, event)
		return {
			{
				choice = "continue",
				button = function()
					event:start_step("st_map_buzzfeed_quiz_2")
				end,
			},
		}
	end,
	loc_vars = function(self, info_queue, event)
		return {
			variant = event.ability.extra.trigger,
		}
	end,
})

-- Second effect
TheEncounter.Choice({
	key = "buzzfeed_quiz_effect",
	loc_txt = {
		name = {
			"I don't know",
		},
		variants = {
			wait = {
				name = { "Wait patiently" },
			},
			forgive = {
				name = { "Forgive the debt" },
			},
			move = {
				name = { "Move out" },
			},
			sell = {
				name = { "Sell their possessions on the Black Market" },
			},
		},
	},
	config = {
		extra = {
			effects = {
				wait = 3,
				forgive = 6,
				move = 1,
				sell = 5,
			},
		},
	},
	button = function(self, event, ability)
		event.ability.extra.effect_value = ability.extra.effects[ability.extra.chosen]
		event.ability.extra.effect = ability.extra.chosen
		event:start_step("st_map_buzzfeed_quiz_2_result")
	end,
	loc_vars = function(self, info_queue, event, ability)
		return {
			variant = ability.extra.chosen,
		}
	end,
	get_colours = function(self, event, ability)
		if ability.extra.chosen == "sell" then
			return {
				colour = G.C.MULT,
				text_colour = G.C.UI.TEXT_DARK,
			}
		end
	end,
})
TheEncounter.Step({
	key = "buzzfeed_quiz_2",
	loc_txt = {
		text = {
			'"Your roommate owes you 500 credits.',
			"They say they can pay you back if you just give them a",
			"little bit more time.",
			" ",
			'What do you do?"',
		},
	},
	get_choices = function(self, event)
		local result = {}
		for _, variant in ipairs({ "wait", "forgive", "move", "sell" }) do
			table.insert(result, {
				key = "ch_map_buzzfeed_quiz_effect",
				ability = {
					extra = {
						chosen = variant,
					},
				},
			})
		end
		result.columns = { 2, 2 }
		return result
	end,
})

-- Second result
TheEncounter.Step({
	key = "buzzfeed_quiz_2_result",
	loc_txt = {
		text = {
			"You did not pick anything...",
		},
		choices = {
			continue = {
				name = { "See results" },
			},
		},
		variants = {
			wait = {
				text = {
					"I'm patient. I can wait for them, you thought.",
					" ",
					"You may be betrayed by those words some day.",
				},
			},
			forgive = {
				text = {
					"No relationship should be shackled to such things as",
					"money, you thought.",
					" ",
					"Maybe you're too forgiving.",
				},
			},
			move = {
				text = {
					"I can't be living with a leech! You thought.",
					" ",
					"Are credits this important to you?",
				},
			},
			sell = {
				text = {
					"Hey, at least I can make some of it back, you thought.",
					" ",
					"Maybe you should stop and think about what you would do after that.",
				},
			},
		},
	},
	get_choices = function(self, event)
		return {
			{
				choice = "continue",
				button = function()
					event:start_step("st_map_buzzfeed_quiz_finish")
				end,
			},
		}
	end,
	loc_vars = function(self, info_queue, event)
		return {
			variant = event.ability.extra.effect,
		}
	end,
})

-- Finish
TheEncounter.Step({
	key = "buzzfeed_quiz_finish",
	loc_txt = {
		text = {
			'{s:1.2}"This is who you are!"',
			" ",
			"A picture of yourself appears on the screen.",
			" ",
			"...",
			"I thought this was about Balatro? Boring.",
		},
	},
	start = function(self, event, after_load)
		event:show_lines(3)
		if #G.jokers.cards + G.GAME.joker_buffer < G.jokers.config.card_limit then
			G.E_MANAGER:add_event(Event({
				func = function()
					G.GAME.hotpot_diy = {
						trigger = event.ability.extra.trigger_value,
						effect = event.ability.extra.effect_value,
					}
					print(G.GAME.hotpot_diy)
					SMODS.add_card({ key = "j_joker" })
					return true
				end,
			}))
		end
		delay(1)
	end,
})
