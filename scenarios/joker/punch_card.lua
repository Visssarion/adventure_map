TheEncounter.Scenario({
	key = "punch_joker",
	loc_txt = {
		name = "Punch PLACEHOLDER",
		text = {
			"PLACEHOLDER"
		},
	},
	domains = {
		do_map_joker = true,
	},
	config = {
		--hide_image = true,
	},
	starting_step_key = "st_map_punch_joker_choice",
	map_credits = {
        made = "vissa",
    },
    get_weight = function (self, weight, domain)
        if next(SMODS.find_card("j_map_punch_card")) or next(SMODS.find_card("j_hanging_chad")) then 
            return 0
        end
        return 3
    end,
    rarity = 1,
})

TheEncounter.Step({
	key = "punch_joker_choice",
	loc_txt = {
		text = {
			"PLACEHOLDER"
		},
		choices = {
			reboot = {
				name = { "Reboot it" },
			},
			punch = {
				name = { "Punch the computer" },
			},
		},
	},
	get_choices = function(self, event)
		return {
			{
				choice = "reboot",
				button = function()
					if SMODS.pseudorandom_probability(nil, 'st_map_punch_joker_choice', 5, 7) then
						event:start_step("st_map_punch_joker_punch")
					else
						event:start_step("st_map_punch_joker_chad")
					end
					
				end,
			},
			{
				choice = "punch",
				button = function()
					if SMODS.pseudorandom_probability(nil, 'st_map_punch_joker_choice', 5, 7) then
						event:start_step("st_map_punch_joker_chad")
					else
						event:start_step("st_map_punch_joker_punch")
					end
				end,
			},
			"ch_map_leave"
		}
	end,
	loc_vars = function(self, info_queue, event)
		return {
			vars = {
				--localize({ type = "name_text", key = event.ability.extra.joker_key, set = "Joker" }),
			},
		}
	end,
    start = function(self, event)
        event:image_character({
			key = "joker",
			center = "j_map_punch_card",
			scale = 1,
		})
    end,
    finish = function (self, event)
        MAP.UTIL.remove_card_show_area(event)
    end
})


TheEncounter.Step({
	key = "punch_joker_punch",
	loc_txt = {
		text = {
			"PLACEHOLDER"
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
				--localize({ type = "name_text", key = event.ability.extra.joker_key, set = "Joker" }),
			},
		}
	end,
    setup = function (self, event)
        event.ability.extra.joker_key = "j_map_punch_card"
    end,
    start = function(self, event)
        MAP.UTIL.card_show_area(event)
        MAP.UTIL.add_card_to_event_area(event, event.ability.extra.joker_key)
    end,
    finish = function (self, event)
        MAP.UTIL.remove_card_show_area(event)
    end
})

TheEncounter.Step({
	key = "punch_joker_chad",
	loc_txt = {
		text = {
			"PLACEHOLDER"
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
				--localize({ type = "name_text", key = event.ability.extra.joker_key, set = "Joker" }),
			},
		}
	end,
    setup = function (self, event)
        event.ability.extra.joker_key = "j_hanging_chad"
    end,
    start = function(self, event)
        MAP.UTIL.card_show_area(event)
        MAP.UTIL.add_card_to_event_area(event, event.ability.extra.joker_key)
    end,
    finish = function (self, event)
        MAP.UTIL.remove_card_show_area(event)
    end
})