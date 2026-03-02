

TheEncounter.Scenario({
	key = "template",
	loc_txt = {
		name = "Title",
		text = {
			"Description",
		},
	},
	domains = {
		do_enc_occurrence = true,
	},
	config = {
		hide_image = true,
	},
	starting_step_key = "st_map_template_start",
    weight = 0
    -- change to 100000 to make it always spawn 
    -- 5 is the default weight value
})

TheEncounter.Step({
	key = "template_start",
	loc_txt = {
		text = {
			"Sample text.",
		},
		choices = {
			call = {
				name = { "Call function" },
			},
			skip = {
				name = { "Skip" },
			},
		},
	},
	get_choices = function(self, event)
		return {
			{
				choice = "call",
				button = function()
					SMODS.add_card({ key = "j_egg", edition = "e_negative" })
					event:finish_scenario()
				end,
			},
			{
				choice = "skip",
			},
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
