

TheEncounter.Scenario({
	key = "paid_shop",
	loc_txt = {
		name = "Entry Fee",
		text = {
			"Only for elite members...",
		},
	},
	domains = {
		do_map_market = true,
	},

	starting_step_key = "st_map_paid_shop_entrance",
    weight = 2.5,
	map_credits = {
        made = "vissa",
    },
})

TheEncounter.Step({
	key = "paid_shop_entrance",
	loc_txt = {
		text = {
			'"PLACEHOLDER."',
			'It costs money to enter this shop'
		},
		choices = {
			buy = {
				name = { "Enter shop. (Costs {C:money}#1#${})" },
			},
		},
	},
	config = {
		extra = {
			min_price = 4,
			max_price = 7,
		}
	},
	setup = function(self, event)
		local price = 0
		if next(SMODS.find_card("j_map_rewards_program")) then -- If player already has joker
            price = 0
			-- TODO change text by changing key.
        else
			price = pseudorandom("map_paid_shop_fee", event.ability.extra.min_price, event.ability.extra.max_price)
		end
		event.ability.extra.price = price


	end,
	start = function(self, event, after_load)
		event:image_character({
			key = "joker",
			center = "j_shortcut",
			scale = 1,
		})
	end,
	get_choices = function(self, event)
		return {
			{
				choice = "buy",
				button = function()
					ease_dollars(-event.ability.extra.price)
					event:finish_scenario(function()
						G.STATE = G.STATES.SHOP
						G.STATE_COMPLETE = false
					end)
				end,
				loc_vars = function(self, info_queue, event)
					return {
						vars = {
							event.ability.extra.price
						},
					}
				end,
				func = function (self, event, ability)
					return G.GAME.dollars >= event.ability.extra.price
					
				end,
			},
			"ch_map_leave"
		}
	end,

})
