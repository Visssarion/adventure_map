TheEncounter.Scenario({
	key = "add_deck",
	loc_txt = {
		name = "Mystery Deck",
		text = {
			"Grants you powers of others...",
		},
	},
	domains = {
		do_map_mystery = true,
	},
	config = {
		hide_image = true,
	},
	starting_step_key = "st_map_add_deck_add",
	weight = 1
})

-- might want to move this somewhere else and remove local and i need it again
---@param back Back
local apply_during_the_run = function (back)

	back:apply_to_run()


	if back.effect.center.calculate and type(back.effect.center.calculate) == 'function' then
		local old_calc = G.GAME.selected_back.calculate
		-- print(back.effect.center.key)
		-- print(inspectFunction(back.effect.center.calculate))
		G.GAME.selected_back.calculate = function (self, context)
			local res = {old_calc(self, context)}
			local res_new = {back.effect.center:calculate(back, context)}
			
			if res[1] then
				for key, value in pairs(res[1]) do
					if type(res[1][key]) == "number" and res_new[1] and type(res_new[1][key]) == "number" then
						res[1][key] = res[1][key] + res_new[1][key]
					end
				end
				for key, value in pairs(res_new[1]) do
					if res_new[1][key] == nil then
						res[1][key] = res_new[1][key]
					end
				end
			else
				res[1] = res_new[1]
			end
			
			return unpack(res)
		end

	end

	if back.name == "Plasma Deck" then
		local old_calc = G.GAME.selected_back.calculate

		G.GAME.selected_back.calculate = function (self, context)
			local res = {old_calc(self, context)}
			
			if context.final_scoring_step then
				if res[1] == nil then
					res[1] = {}
				end
				res[1].balance = true
			end

			return unpack(res)
		end
	end

	if back.name == "Anaglyph Deck" then
		local old_calc = G.GAME.selected_back.calculate

		G.GAME.selected_back.calculate = function (self, context)
			if context.round_eval and G.GAME.last_blind and G.GAME.last_blind.boss then
            G.E_MANAGER:add_event(Event({
                func = function()
                    add_tag(Tag('tag_double'))
                    play_sound('generic1', 0.9 + math.random() * 0.1, 0.8)
                    play_sound('holo1', 1.2 + math.random() * 0.1, 0.4)
                    return true
                end
            }))
        end
			return old_calc(self, context)
		end
	end

	if back.effect.config.hands then 
        G.GAME.round_resets.hands = G.GAME.round_resets.hands + back.effect.config.hands
		ease_hands_played(back.effect.config.hands)
    end

    if back.effect.config.dollars then
        ease_dollars(back.effect.config.dollars)
    end
    if back.effect.config.remove_faces then
        G.GAME.starting_params.no_faces = true -- TODO go through and remove the faces manually

		G.E_MANAGER:add_event(Event({
            func = function()
                for k, v in pairs(G.playing_cards) do
                    if v:is_face() then
                        v:start_dissolve(nil, true)
                    end
                end
            return true
            end
        }))

    end

    if back.effect.config.discards then 
		G.GAME.round_resets.discards = G.GAME.round_resets.discards + back.effect.config.discards
		ease_discard(back.effect.config.discards)
    end
    if back.effect.config.reroll_discount then
        G.GAME.round_resets.reroll_cost = G.GAME.round_resets.reroll_cost - back.effect.config.reroll_discount
		G.GAME.current_round.reroll_cost = G.GAME.current_round.reroll_cost - back.effect.config.reroll_discount
    end

    if back.effect.config.randomize_rank_suit then
        G.GAME.starting_params.erratic_suits_and_ranks = true
		-- TODO function here
		G.E_MANAGER:add_event(Event({
            func = function()
                for k, v in pairs(G.playing_cards) do
				   assert(SMODS.change_base(v, pseudorandom_element(SMODS.Suits, "map_erratic").key, pseudorandom_element(SMODS.Ranks, "map_erratic").key))
                end
            return true
            end
        }))
    end
    if back.effect.config.joker_slot then
		G.jokers.config.card_limit = G.jokers.config.card_limit + back.effect.config.joker_slot
    end
    if back.effect.config.hand_size then
		G.hand.config.card_limit = G.hand.config.card_limit + back.effect.config.hand_size
    end
    if back.effect.config.consumable_slot then
        G.consumeables.config.card_limit = G.consumeables.config.card_limit + back.effect.config.consumable_slot
    end
end

TheEncounter.Step({
	key = "add_deck_add",
	loc_txt = {
		text = {
			"I WILL BESTOW POWERS UPON YOU.",
			"POWERS THAT YOU DONT HAVE, BUT #1# HAS.",
			"SHALL YOU PROCEED?"
		},
		choices = {
			call = {
				name = { "Get powers of #1#" },
			},

		},
	},

	setup = function (self, event)
		--G.P_CENTERS 
		event.ability.extra.deck_key = pseudorandom_element(SMODS.get_clean_pool("Back"), 'map_add_deck')
		--event.ability.extra.deck_key = "b_vremade_anaglyph"
		event.ability.extra.deck = Back(G.P_CENTERS[event.ability.extra.deck_key])
		--SMODS.Back
	end,
	start = function (self, event, after_load)
		event:image_character({
			key = "joker",
			center = "v_hieroglyph",
			scale = 1,
			particles = { G.C.ORANGE, G.C.GOLD },
		})
	end,
	get_choices = function(self, event)
		return {
			{
				choice = "call",
				button = function()
					--print(event.ability.extra.deck)
					-- G.GAME.selected_back_key = event.ability.extra.deck_key
					-- G.GAME.selected_back = event.ability.extra.deck
					-- print("PLEAAASE")
					-- print(G.GAME.starting_params.hands)

					apply_during_the_run(event.ability.extra.deck)
					-- print(G.GAME.starting_params.hands)
					event:finish_scenario()
				end,
				loc_vars = function(self, info_queue, event)
					return {
						vars = {
							localize({type = "name_text", key = event.ability.extra.deck_key, set = "Back"}), -- TODO change to localize
						},
					}
				end,
			},
			"ch_map_leave"
		}
	end,
	loc_vars = function(self, info_queue, event)
		return {
			vars = {
				localize({type = "name_text", key = event.ability.extra.deck_key, set = "Back"}), -- TODO change to localize
			},
		}
	end,
})


