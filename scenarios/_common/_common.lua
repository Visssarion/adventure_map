MAP.UTIL.immediate_tag_trigger = function ()
    for index, tag in ipairs(G.GAME.tags) do
        tag:apply_to_run({type = 'immediate'})
    end
    for index, tag in ipairs(G.GAME.tags) do
        tag:apply_to_run({type = 'new_blind_choice'})
    end
end


TheEncounter.Choice({
	key = "take_joker",
	loc_txt = {
		name = { "Take #1#!" },
	},
    loc_vars = function(self, info_queue, event)
        local joker_key = "j_joker"
        if G.event_cards and G.event_cards.cards and #G.event_cards.cards > 0 then
            joker_key = G.event_cards.cards[1].config.center.key
            print(joker_key)
        elseif event.ability.extra.joker_key then
           joker_key = event.ability.extra.joker_key 
        end

		return {
			vars = {
				localize({ type = "name_text", key = event.ability.extra.joker_key or joker_key, set = "Joker" }),
			},
		}
	end,
	button = function(self, event)
        if G.event_cards then
            local card = G.event_cards.cards and G.event_cards.cards[1]
            if card == nil then
                print("[ch_map_take_joker]: something went wrong")
            else
                G.event_cards:remove_card(card)
                card:add_to_deck()
                G.jokers:emplace(card)
                if #G.event_cards.cards == 0 then
                    event:finish_scenario()
                    return
                end
            end
		else
            SMODS.add_card({key = event.ability.extra.joker_key})
            event:finish_scenario()
        end
	end,
	func = function (self, event, ability)
		return G.jokers and #G.jokers.cards < G.jokers.config.card_limit
	end
})


TheEncounter.Choice({
	key = "take_consumable",
	loc_txt = {
		name = { "Take #1#!" },
	},
    loc_vars = function(self, info_queue, event)
        local consumable_key = "c_pluto"
        local consumable_set = "Planet"
        if G.event_cards and G.event_cards.cards and #G.event_cards.cards > 0 then
            consumable_key = G.event_cards.cards[1].config.center.key
            consumable_set = G.event_cards.cards[1].config.center.set
        end

		return {
			vars = {
				localize({ type = "name_text", key = consumable_key, set = consumable_set }),
			},
		}
	end,
	button = function(self, event)
        if G.event_cards then
            local card = G.event_cards.cards and G.event_cards.cards[1]
            if card == nil then
                print("[ch_map_take_consumable]: something went wrong")
            else
                G.event_cards:remove_card(card)
                card:add_to_deck()
                G.consumeables:emplace(card)
                if #G.event_cards.cards == 0 then
                    event:finish_scenario()
                    return
                end
            end
        end
	end,
	func = function (self, event, ability)
		return G.consumeables and #G.consumeables.cards < G.consumeables.config.card_limit
	end
})

TheEncounter.Choice({
	key = "leave",
	loc_txt = {
		name = { "Leave" },
	},
})

TheEncounter.Step({
	key = "joker_found",
	loc_txt = {
		text = {
			"You found: #1#!",
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
        MAP.UTIL.card_show_area(event)
        MAP.UTIL.add_card_to_event_area(event, event.ability.extra.joker_key)
    end,
    finish = function (self, event)
        MAP.UTIL.remove_card_show_area(event)
    end
})

MAP.UTIL.card_show_area = function (event)
    G.event_cards = CardArea(
        G.hand.T.x + (G.hand.T.w - 5 * 1.02 * G.CARD_W) / 2,
        G.hand.T.y - 0.5,
        5 * 1.02 * G.CARD_W,
        1.05 * G.CARD_H,
        { card_limit = 5, type = "title", highlight_limit = 1, negative_info = true } --title_2
    )
    local sizes = TheEncounter.UI.event_panel_sizes(event)
    G.event_cards:set_alignment({
        bond = "Weak",
        major = event.ui.panel,
        type = "tm",
        offset = {
            y = sizes.container_H,
            x = 0,
        },
    })
    G.event_cards.children.area_uibox = UIBox({
        definition = {
            n = G.UIT.ROOT,
            config = {
                colour = { 0, 0, 0, 0.1 },
                padding = 0.15,
                r = 0.1,
                minw = G.event_cards.T.w,
                minh = G.event_cards.T.h,
            },
            nodes = {},
        },
        config = {
            mid = true,
            ref_table = G.event_cards,
            align = "cm",
            major = G.event_cards,
        },
    })

    
end

MAP.UTIL.add_card_to_event_area = function (event, card_key)
    local card = SMODS.add_card({key = card_key, area = G.event_cards})
    card:juice_up()
end

MAP.UTIL.remove_card_show_area = function (event)
    -- To make it look smooth, we need remove this elements when it's out of screen boundaries, aka when event is finished
    event:before_remove_callback(function ()
        -- G.SHOP_SIGN:remove()
        -- G.SHOP_SIGN = nil
        G.event_cards.children.area_uibox:remove()
        G.event_cards:remove()
        G.event_cards = nil
    end)

end
