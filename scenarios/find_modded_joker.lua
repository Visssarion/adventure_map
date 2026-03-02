local loaded_mod_ids = {}

for key, value in pairs(SMODS.Mods) do
	if value.can_load then
		loaded_mod_ids[key] = true
	end
end

local custom_jokers_count = 0

G.E_MANAGER:add_event(Event({
    func = function() 
        for key, value in pairs(G.P_CENTERS) do
			if value.set == 'Joker' and value.original_mod then
				custom_jokers_count = custom_jokers_count + 1
			end
		end
        return true 
    end
}))

TheEncounter.Scenario({
	key = "find_modded_joker",
	loc_txt = {
		name = "SCAN_FOR_CHANGES",
		text = {
			"Finds and gives you a random modded joker.",
		},
	},
	domains = {
		do_enc_occurrence = true,
	},
	config = {
		--hide_image = true,
	},
	starting_step_key = "st_map_find_modded_joker_start",
	get_weight = function(self, weight, domain)
		local weight = custom_jokers_count / 8 + 4
		weight = math.min(math.max(weight, 5), 15)
		return self.weight
	end,

})

TheEncounter.Step({
	key = "find_modded_joker_start",
	loc_txt = {
		text = {
			"Let's try to find some modded jokers!",
		},
		choices = {
			call = {
				name = { "Search" },
			},

		},
	},
	start = function(self, event, after_load)
		event:image_character({
			key = "joker",
			center = "j_brainstorm",
			scale = 1,
			--particles = { G.C.RED, G.C.ORANGE, G.C.CHIPS },
		})
	end,
	get_choices = function(self, event)
		return {
			{
				choice = "call",
				button = function()
					local jokers = {}
					for k, v in pairs(get_current_pool('Joker')) do
						if G.P_CENTERS[v] then
							if G.P_CENTERS[v].set == 'Joker' and G.P_CENTERS[v].original_mod and loaded_mod_ids[G.P_CENTERS[v].original_mod.id] then
								table.insert(jokers, G.P_CENTERS[v].key)
							end
						end
					end
					local key = pseudorandom_element(jokers, 'find_modded_joker')
					if key then
						event.ability.extra.joker_key = key
						
						event:start_step("st_map_joker_found")
					else
						event.ability.extra.joker_key = "j_joker" -- TODO - replace with a vanilla joker
						event:start_step("st_map_find_modded_joker_not_found")
					end
				end,
			},
			"ch_map_leave"
		}
	end,
	background_colour = function(self, event)
		-- custom vortex
		ease_background_colour({
			new_colour = darken(HEX("DE2041"), 0.2),
			special_colour = G.C.BLACK,
			contrast = 5,
		})
	end,
	
})

TheEncounter.Step({
	key = "find_modded_joker_not_found",
	loc_txt = {
		text = {
			"You havent found anything interesting...",
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
    start = function(self, event)
		local chara = event:get_image("joker")

		local quip = "lq_2"
		chara.ui_object_updated = true
		chara:add_speech_bubble(quip, nil, { quip = true })
		chara:say_stuff(5, false, quip)

        MAP.UTIL.card_show_area(event, event.ability.extra.joker_key)
    end,
    finish = function (self, event)
		

        MAP.UTIL.remove_card_show_area(event)
    end

})

