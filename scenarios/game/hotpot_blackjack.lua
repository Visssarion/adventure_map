TheEncounter.Scenario({
	key = "bj",
	loc_txt = {
		name = "Blackjack",
		text = {
			"What's 9+10?",
		},
	},
	config = {
		hide_hand = true,
		can_use = false,
	},
	can_save = true,
	domains = { do_map_game = true },
	can_repeat = true,
	starting_step_key = "st_map_bj_in",

	colour = G.C.ORANGE,
	background_colour = G.C.ORANGE,

	in_pool = function()
		if #G.deck.cards >= 2 and to_big(G.GAME.dollars) > to_big(0) then
			return true
		end
	end,

	save = function(self, event, data)
		if data.dealer_area then
			return {
				dealer_area = data.dealer_area:save(),
			}
		end
	end,
	load = function(self, event, saveTable)
		if saveTable.dealer_area then
			local area = CardArea(0, 0, G.CARD_W * 1.5, G.CARD_H, { type = "title", highlight_limit = 0 })
			area:load(saveTable.dealer_area)
			event.ui.dealer_cards = UIBox({
				definition = {
					n = G.UIT.ROOT,
					config = {
						colour = G.C.CLEAR,
					},
					nodes = {
						{
							n = G.UIT.O,
							config = {
								object = area,
							},
						},
					},
				},
				config = {
					major = event.ui.panel,
					align = "tmi",
					offset = { x = 0.5, y = 0.75 },
				},
			})
			return {
				dealer_area = area,
			}
		end
	end,
	start = function(self, event, after_load)
		event:image_character({
			key = "dealer",
			center = "j_ring_master",
			scale = 0.75,
			particles = { G.C.RED, G.C.ORANGE, G.C.CHIPS },
		})
	end,

	map_credits = {
		code = { "fey <3" }
	}
})

TheEncounter.Step({
	key = "bj_in",

	loc_txt = {
		text = {
			"You see a shady figure with a set of cards",
			"infront of him, a 'normal' 52 card deck.",
			" ",
			'"Up for a game of Black Jack, pal?" He sounds',
			"like he's straight out of the 'slammer'...",
		},
		choices = {
			start = {
				name = { "I'm all in!" },
			},
			stop = {
				name = { "On second thought, maybe not..." },
			},
		},
	},

	setup = function(self, event)
		event.ability.extra.total = 0
	end,
	start = function(self, event) end,
	get_choices = function(self, event)
		return {
			{
				choice = "start",
				button = function()
					event.ability.extra.started = true
					event:start_step("st_map_bj_check")
				end,
			},
			{
				choice = "stop",
			},
		}
	end,
	finish = function(self, event)
		if event.ability.extra.started then
			event.ability.extra.bet = G.GAME.dollars
			ease_dollars(-G.GAME.dollars)
			event.ability.hide_hand = false

			G.E_MANAGER:add_event(Event({
				func = function()
					draw_card(G.deck, G.hand, 1, "up", true)
					draw_card(G.deck, G.hand, 1, "up", true)
					return true
				end,
			}))
			G.E_MANAGER:add_event(Event({
				func = function()
					local area = CardArea(0, 0, G.CARD_W * 1.5, G.CARD_H, {
						card_limit = 2,
						type = "title",
						highlight_limit = 0,
					})
					event.data = {
						dealer_area = area,
					}
					event.ability.extra.dealer_total = 0
					for i = 1, 2 do
						local card = SMODS.add_card({ set = "Base", area = event.data.dealer_area })
						card:start_materialize()
						event.ability.extra.dealer_total = event.ability.extra.dealer_total + card.base.nominal
						if i == 2 then
							card:flip()
						end
					end
					event.ui.dealer_cards = UIBox({
						definition = {
							n = G.UIT.ROOT,
							config = {
								colour = G.C.CLEAR,
							},
							nodes = {
								{
									n = G.UIT.O,
									config = {
										object = area,
									},
								},
							},
						},
						config = {
							major = event.ui.panel,
							align = "tmi",
							offset = { x = 0.5, y = 0.75 },
						},
					})
					return true
				end,
			}))
		end
	end,
})
TheEncounter.Step({
	key = "bj_check",
	loc_txt = {
		choices = {
			hit = {
				name = "Lady Luck gimme a kiss! (Hit)",
			},
			stand = {
				name = "Wee hee hee! (Stand)",
			},
		},
	},
	config = {
		hide_hand = false,
	},
	colour = G.C.MONEY,
	background_colour = G.C.MONEY,
	get_choices = function(self, event)
		return {
			{
				choice = "hit",
				button = function()
					draw_card(G.deck, G.hand, 1, "up", true)
					event:start_step("st_map_bj_check")
				end,
				func = function()
					return event.ability.extra.total < 21 and #G.deck.cards > 0
				end,
			},
			{
				choice = "stand",
				button = function()
					event:start_step("st_map_bj_final")
				end,
			},
		}
	end,
	setup = function(self, event)
		local count = 0
		local aces = 0
		for i, v in ipairs(G.hand.cards) do
			if not SMODS.has_no_rank(v) then
				if v:get_id() == 14 then
					aces = aces + 1
					count = count + 1
				else
					count = count + v.base.nominal
				end
			end
		end
		if aces > 0 then
			for i = 1, aces do
				if count <= 11 then
					count = count + 10
				else
					break
				end
			end
		end
		event.ability.extra.total = count
	end,
})
TheEncounter.Step({
	key = "bj_final",
	hide_hand = false,
	loc_txt = {
		text = {
			"Looks like you #1#.",
			"Cash in for {C:money}$#2#{}!",
		},
		choices = {
			cashin = {
				name = "Cash in!",
			},
		},
	},
	colour = G.C.MONEY,
	background_colour = G.C.MONEY,
	setup = function(self, event)
		event.ability.won = nil
		event.ability.final_money = 0

		local count = 0
		local aces = 0
		for i, v in ipairs(G.hand.cards) do
			if not SMODS.has_no_rank(v) then
				if v:get_id() == 14 then
					aces = aces + 1
					count = count + 1
				else
					count = count + v.base.nominal
				end
			end
		end
		if aces > 0 then
			for i = 1, aces do
				if count <= 11 then
					count = count + 10
				else
					break
				end
			end
		end
		event.ability.extra.total = count
		event.ability.extra.final_money = 0
		if event.ability.extra.total <= 21 and event.ability.extra.total > event.ability.extra.dealer_total then
			event.ability.extra.won = true
			event.ability.extra.final_money = event.ability.extra.bet * 2
		end
	end,
	start = function(self, event)
		for _, card in ipairs(event.data.dealer_area.cards) do
			if card.facing == "back" then
				card:flip()
			end
		end
		print(event.ability.extra)
	end,
	get_choices = function(self, event)
		return {
			{
				choice = "cashin",
			},
		}
	end,
	loc_vars = function(self, info_queue, event)
		return {
			vars = {
				event.ability.extra.won and "won" or "lost",
				event.ability.extra.final_money,
			},
		}
	end,
	finish = function(self, event)
		if event.ability.extra.final_money ~= 0 then
			ease_dollars(event.ability.extra.final_money)
		end
		for _, card in ipairs(event.data.dealer_area.cards) do
			card:start_dissolve()
		end
		G.E_MANAGER:add_event(Event({
			func = function()
				G.deck:shuffle("bj" .. G.GAME.round_resets.ante)
				return true
			end,
		}))
	end,
})
