

TheEncounter.Scenario({
	key = "tag_market",
	loc_txt = {
		name = "Tag Market",
		text = {
			"Just for 4.99!",
		},
	},
	domains = {
		do_map_market = true,
	},

	starting_step_key = "st_map_tag_market_buy",
    weight = 5,
	map_credits = {
        made = "vissa",
    },
})

TheEncounter.Step({
	key = "tag_market_buy",
	loc_txt = {
		text = {
			'"Psst, hey."',
			"\"Do you want these Tags? It's a clearance sale.\""
		},
		choices = {
			buy = {
				name = { "Buy #1#. (Costs {C:money}#2#${})" },
			},
		},
	},
	config = {
		extra = {
			min_price = 4,
			max_price = 7,
			amount = 3
		}
	},
	setup = function(self, event)
		event.ability.extra.tags = {}
		event.ability.extra.prices = {}
		event.ability.extra.bought = {}
		for i = 1, event.ability.extra.amount, 1 do
			local tag = pseudorandom_element(SMODS.get_clean_pool("Tag"), 'map_tag_market_tag')
			event.ability.extra.tags[i] = tag
			local tag_obj = Tag(tag)
			local tag_sprite_ui = tag_obj:generate_UI()
			event.ui.image.children["tag"..i] = UIBox{
				definition = {n=G.UIT.ROOT, config={align = "cm",padding = 0.05, colour = G.C.CLEAR}, nodes={
					tag_sprite_ui
				}},
				config = {
					align = 'bm',
					major = i == 1 and event.ui.image or event.ui.image.children["tag"..(i-1)]
				}
			}
			local price = pseudorandom("map_tag_market_price", event.ability.extra.min_price, event.ability.extra.max_price)
			event.ability.extra.prices[i] = price
			event.ability.extra.bought[i] = false
		end


	end,
	start = function(self, event, after_load)
		event:image_character({
			key = "joker",
			center = "j_shortcut",
			scale = 1,
			--particles = { G.C.RED, G.C.ORANGE, G.C.CHIPS },
		})
	end,
	get_choices = function(self, event)
		local choices = {}
		for i = 1, event.ability.extra.amount, 1 do
			choices[i] = {
				choice = "buy",
				button = function()
					ease_dollars(-event.ability.extra.prices[i])
					add_tag(Tag(event.ability.extra.tags[i]))
					MAP.UTIL.immediate_tag_trigger()
					event.ability.extra.bought[i] = true
					--event:finish_scenario()
				end,
				loc_vars = function(self, info_queue, event)
					return {
						vars = {
							localize({type = "name_text", key = event.ability.extra.tags[i], set = "Tag"}),
							event.ability.extra.prices[i]
						},
					}
				end,
				func = function (self, event, ability)
					return G.GAME.dollars >= event.ability.extra.prices[i] and event.ability.extra.bought[i] == false
					
				end,
			}
		end
		choices[#choices+1] = "ch_map_leave"
		print(choices)
		return choices
	end,

})
