TheEncounter.Scenario({
	key = "postlatro",
	loc_txt = {
		name = "Postlatro Express",
		text = {
			"Where everything is 0% off!",
		},
	},
	config = {
		hide_hud = true,
	},
	domains = {
		do_map_market = true,
	},
	can_repeat = true,
	starting_step_key = "st_map_postlatro_start",

	map_credits = {
		code = { "N'" },
	},
})
TheEncounter.Step({
	key = "postlatro_start",
	loc_txt = {
		text = {},
	},

	set_text_ui = function(self, event, content, objects)
		table.insert(content.nodes, 1, {
			n = G.UIT.R,
			nodes = {
				{
					n = G.UIT.T,
					config = {
						text = "In biz we call it 'dropshipping'.",
						scale = 0.35,
						colour = G.C.MULT,
					},
				},
			},
		})
	end,

	start = function(self, event)
		local chara = event:image_character({
			center = "j_certificate",
			dy = -0.75,
			key = "shopkeeper",
			scale = 0.75,
		})

		local quip = "lq_10"
		chara.ui_object_updated = true
		chara:add_speech_bubble(quip, nil, { quip = true })
		chara:say_stuff(5, false, quip)

		local shop_sign = AnimatedSprite(0, 0, 4.4, 2.2, G.ANIMATION_ATLAS["shop_sign"])
		shop_sign:define_draw_steps({
			{ shader = "dissolve", shadow_height = 0.05 },
			{ shader = "dissolve" },
		})
		G.SHOP_SIGN = UIBox({
			definition = {
				n = G.UIT.ROOT,
				config = { colour = G.C.DYN_UI.MAIN, emboss = 0.05, align = "cm", r = 0.1, padding = 0.1 },
				nodes = {
					{
						n = G.UIT.R,
						config = {
							align = "cm",
							padding = 0.1,
							minw = 4.72,
							minh = 3.1,
							colour = G.C.DYN_UI.DARK,
							r = 0.1,
						},
						nodes = {
							{
								n = G.UIT.R,
								config = { align = "cm" },
								nodes = {
									{ n = G.UIT.O, config = { object = shop_sign } },
								},
							},
							{
								n = G.UIT.R,
								config = { align = "cm" },
								nodes = {
									{
										n = G.UIT.O,
										config = {
											object = DynaText({
												string = { "Delivery!" },
												colours = { lighten(G.C.GOLD, 0.3) },
												shadow = true,
												rotate = true,
												float = true,
												bump = true,
												scale = 0.5,
												spacing = 1,
												pop_in = 1.5,
												maxw = 4.3,
											}),
										},
									},
								},
							},
						},
					},
				},
			},
			config = {
				align = "cm",
				offset = { x = 0, y = -10 },
				major = G.HUD:get_UIE_by_ID("row_blind"),
				bond = "Weak",
			},
		})
		G.E_MANAGER:add_event(Event({
			trigger = "immediate",
			blockable = false,
			func = function()
				G.SHOP_SIGN.alignment.offset.y = 0
				return true
			end,
		}))

		G.shop_jokers = CardArea(
			G.hand.T.x + (G.hand.T.w - 5 * 1.02 * G.CARD_W) / 2,
			G.hand.T.y - 0.5,
			5 * 1.02 * G.CARD_W,
			1.05 * G.CARD_H,
			{ card_limit = 5, type = "shop", highlight_limit = 1, negative_info = true }
		)
		local sizes = TheEncounter.UI.event_panel_sizes(event)
		G.shop_jokers:set_alignment({
			bond = "Weak",
			major = event.ui.panel,
			type = "tm",
			offset = {
				y = sizes.container_H,
				x = 0,
			},
		})
		G.shop_jokers.children.area_uibox = UIBox({
			definition = {
				n = G.UIT.ROOT,
				config = {
					colour = { 0, 0, 0, 0.1 },
					padding = 0.15,
					r = 0.1,
					minw = G.shop_jokers.T.w,
					minh = G.shop_jokers.T.h,
				},
				nodes = {},
			},
			config = {
				mid = true,
				ref_table = G.shop_jokers,
				align = "cm",
				major = G.shop_jokers,
			},
		})

		for i = 1, 5 do
			local new_shop_card = create_card_for_shop(G.shop_jokers)
			G.shop_jokers:emplace(new_shop_card)
			new_shop_card:juice_up()
		end
	end,
	finish = function(self, event)
		local chara = event:get_image("shopkeeper")

		local quip = "lq_2"
		chara.ui_object_updated = true
		chara:add_speech_bubble(quip, nil, { quip = true })
		chara:say_stuff(5, false, quip)
		delay(2)
		G.E_MANAGER:add_event(Event({
			trigger = "after",
			delay = 2,
			blocking = false,
			func = function()
				G.SHOP_SIGN.alignment.offset.y = -10
				return true
			end,
		}))

		-- To make it look smooth, we need remove this elements when it's out of screen boundaries, aka when event is finished
		event:before_remove_callback(function()
			G.SHOP_SIGN:remove()
			G.SHOP_SIGN = nil
			G.shop_jokers.children.area_uibox:remove()
			G.shop_jokers:remove()
			G.shop_jokers = nil
		end)
	end,

	-- Good example of choices was in diy example, ok?
	-- get_choices = function()
	-- end,
})
