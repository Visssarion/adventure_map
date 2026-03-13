local create_booster_pack = function ()
    local lock = 2081
    G.CONTROLLER.locks[lock] = true
    
    local key = pseudorandom_element(SMODS.get_clean_pool("Booster"), 'map_booster_random_pack')
    local card = Card(G.play.T.x + G.play.T.w/2 - G.CARD_W*1.27/2,
    G.play.T.y + G.play.T.h/2-G.CARD_H*1.27/2, G.CARD_W*1.27, G.CARD_H*1.27, G.P_CARDS.empty, G.P_CENTERS[key], {bypass_discovery_center = true, bypass_discovery_ui = true})
    card.cost = 0
    card.from_tag = true
    G.FUNCS.use_card({config = {ref_table = card}})
    card:start_materialize()
    G.CONTROLLER.locks[lock] = nil
end

TheEncounter.Scenario({
	key = "random_booster",
	loc_txt = {
		name = "Booster Pack Gift",
		text = {
			"You find something in the mail",
		},
	},
	domains = {
		do_map_gift = true,
	},
	-- config = {
	-- 	hide_image = true,
	-- },
	starting_step_key = "st_map_random_booster_start",
    weight = 10,
	-- 10 because this servers any Booster Pack, so its gonna vary a lot.
})

TheEncounter.Step({
	key = "random_booster_start",
	loc_txt = {
		text = {
			"You find a thin gift package in mail.",
			"Open?"
		},
		choices = {
			call = {
				name = { "Open gift" },
			},

		},
	},
	get_choices = function(self, event)
		return {
			{
				choice = "call",
				button = function()
					event.ability.extra.used = true
					create_booster_pack()
					--event:finish_scenario() -- finishing event breaks booster pack state
				end,
				func = function(self, event, ability)
					return event.ability.extra.used == false
				end,
			},
			"ch_map_leave"
		}
	end,
	setup = function (self, event)
		event.ability.extra.used = false
	end,
	start = function(self, event)
        event:image_character({
			key = "joker",
			center = "j_gift",
			scale = 1,
		})
    end,
})
