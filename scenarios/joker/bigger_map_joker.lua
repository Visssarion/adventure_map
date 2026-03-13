TheEncounter.Scenario({
	key = "bigger_map_joker",
	loc_txt = {
		name = "Directions",
		text = {
			"Maybe the true directions were",
            "the jokers we found along the way.",
		},
	},
	domains = {
		do_map_joker = true,
	},
	config = {
		--hide_image = true,
	},
	starting_step_key = "st_map_bigger_map_joker",
	map_credits = {
        made = "vissa",
    },
    get_weight = function (self, weight, domain)
        if next(SMODS.find_card("j_map_travel_guide")) then -- If player already has joker
            return 0.1 -- 0.1 because why not spice it up
        end
        if G.GAME.round_resets.ante > 1 and G.GAME.round_resets.ante < 4 then
            return 3
        end
        return 0 
    end,
    rarity = 2,
})

TheEncounter.Step({
	key = "bigger_map_joker",
	loc_txt = {
		text = {
			"You got lost trying to find the shop.",
            "You tried to find someone to ask for directions.",
            "\"Where is everybody?\" - the streets are completely empty.",
            "Finally you notice something lying on a bench.",
            "It's a #1#?"
		},
	},
	get_choices = function(self, event)
		return {
			"ch_map_take_joker",
			"ch_map_leave"
		}
	end,
	loc_vars = function(self, info_queue, event)
		return {
			vars = {
				localize({ type = "name_text", key = event.ability.extra.joker_key, set = "Joker" }),
			},
		}
	end,
    setup = function (self, event)
        event.ability.extra.joker_key = "j_map_travel_guide"
    end,
    start = function(self, event)
        MAP.UTIL.card_show_area(event)
        MAP.UTIL.add_card_to_event_area(event, event.ability.extra.joker_key)

        event:image_character({
			key = "joker",
			center = "j_hit_the_road",
			scale = 1,
		})
    end,
    finish = function (self, event)
        MAP.UTIL.remove_card_show_area(event)
    end
})