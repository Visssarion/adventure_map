

TheEncounter.Scenario({
	key = "buy_seals",
	loc_txt = {
		name = "The Stamper",
		text = {
			"PLACEHOLDER",
		},
	},
	domains = {
		do_map_card = true,
	},

	starting_step_key = "st_map_buy_seals",
    weight = 3.5,
	map_credits = {
        made = "vissa",
    },
})


TheEncounter.Step({
	key = "buy_seals",
	loc_txt = {
		text = {
			"PLACEHOLDER"
		},
		choices = {
			buy = {
				name = { "Buy #1#. (Costs {C:money}#2#${})" },
			},
		},
	},
	start = function(self, event, after_load)
		event:image_character({
			key = "j_certificate",
			center = "buy_seals",
			scale = 1,
		})
	end,
	get_choices = function(self, event)
		return {
			MAP.UTIL.create_seal_sell_choice("Gold", 4),
			MAP.UTIL.create_seal_sell_choice("Red", 5),
			MAP.UTIL.create_seal_sell_choice("Purple", 7),
			MAP.UTIL.create_seal_sell_choice("Blue", 10),
			-- MAP.UTIL.create_seal_sell_choice(SMODS.poll_seal {key = "modprefix_seed", guaranteed = true} , 0),
			"ch_map_leave"
		}
	end,

})


