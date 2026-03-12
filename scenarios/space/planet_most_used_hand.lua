local planet_most_used_hand = function ()
    local _planet, _hand, _tally = "c_black_hole", nil, 0
    for _, handname in ipairs(G.handlist) do
        if SMODS.is_poker_hand_visible(handname) and G.GAME.hands[handname].played > _tally then
            _hand = handname
            _tally = G.GAME.hands[handname].played
        end
    end
    if _hand then
        for _, v in pairs(G.P_CENTER_POOLS.Planet) do
            if v.config.hand_type == _hand then
                _planet = v.key
            end
        end
    end
    -- _card = {
    --     set = "Planet",
    --     area = G.pack_cards,
    --     skip_materialize = true,
    --     soulable = true,
    --     key = _planet,
    --     key_append = "pl1"
    -- }
    return _planet
end 

TheEncounter.Scenario({
	key = "planet_most_used_hand",
	loc_txt = {
		name = "Your Orbit",
		text = {
			"That planet you really need.",
		},
	},
	domains = {
		do_map_space = true,
	},
	config = {
		--hide_image = true,
	},
	starting_step_key = "st_map_planet_most_used_hand",
	map_credits = {
        made = "vissa",
    },
    weight = 5
})

TheEncounter.Step({
	key = "planet_most_used_hand",
	loc_txt = {
		text = {
			"It looks like #1# is gonna crash from the sky!!!",
            "...",
            "Oh nevermind. It's just a card."
		},
	},
	get_choices = function(self, event)
		return {
			"ch_map_take_consumable",
			"ch_map_leave"
		}
	end,
	loc_vars = function(self, info_queue, event)
		return {
			vars = {
				localize({ type = "name_text", key = event.ability.extra.planet_key, set = G.P_CENTERS[event.ability.extra.planet_key].set }),
			},
		}
	end,
    setup = function (self, event)
        event.ability.extra.planet_key = planet_most_used_hand()
    end,
    start = function(self, event)
        MAP.UTIL.card_show_area(event)
        MAP.UTIL.add_card_to_event_area(event, event.ability.extra.planet_key)
    end,
    finish = function (self, event)
        MAP.UTIL.remove_card_show_area(event)
    end
})