
-- you can have shared helper functions
function shakecard(self) --visually shake a card
    G.E_MANAGER:add_event(Event({
        func = function()
            self:juice_up(0.5, 0.5)
            return true
        end
    }))
end



SMODS.Atlas({
    key = "map_jokers",
    path = "map_jokers.png",
    px = 71,
    py = 95
})

SMODS.Joker{
    key = "rewards_program",
    config = { extra = { numerator = 1, denominator = 2, money = 5 } },
    atlas = 'map_jokers',
    pos = { x = 0, y = 0 },
    rarity = 1,
    cost = 2,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    map_credits = {
        made = "vissa",
    },

    calculate = function(self, card, context)
        if context.new_map then
            --shakecard(card)
            context.config.room_weights.shop = context.config.room_weights.shop * 2 
            return { 
                card = card,
                colour = G.C.GOLD,
                message = localize('k_more_shops'),
            }
        end
        if context.starting_shop and SMODS.pseudorandom_probability(card, 'j_map_rewards_program', card.ability.extra.numerator, card.ability.extra.denominator) then            
            ease_dollars(card.ability.extra.money)
            return { 
                card = card,
                colour = G.C.GOLD,
                message = localize('k_customer_bonus'),
            }
        end
    end,

    loc_vars = function(self, info_queue, card)          --defines variables to use in the UI. you can use #1# for example to show the chips variable
        local num, denom = SMODS.get_probability_vars(card, card.ability.extra.numerator, card.ability.extra.denominator)
        return { vars = {  num, denom, card.ability.extra.money }, key = self.key }
    end
}

SMODS.Joker{
    key = "hunting_license",
    config = { extra = { cost_per_blind = 1 } },
    atlas = 'map_jokers',
    pos = { x = 1, y = 0 },
    rarity = 1,
    cost = 4,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    map_credits = {
        made = "vissa",
    },

    calculate = function(self, card, context)
        if context.new_map then
            --shakecard(card)
            context.config.room_weights.small_blind = context.config.room_weights.small_blind * 3
            context.config.room_weights.big_blind = context.config.room_weights.big_blind * 3
            
            return { 
                card = card,
                colour = G.C.RED,
                message = localize('k_more_blinds'),
            }
        end
        if context.setting_blind  then            
            ease_dollars(- card.ability.extra.cost_per_blind)
            return { 
                card = card,
                colour = G.C.RED,
                message = localize('k_hunting_fees'),
            }
        end
    end,

    loc_vars = function(self, info_queue, card)          --defines variables to use in the UI. you can use #1# for example to show the chips variable
        return { vars = {  card.ability.extra.cost_per_blind }, key = self.key }
    end
}

SMODS.Joker{
    key = "travel_guide",
    config = { extra = { extra_steps = 2 } },
    atlas = 'map_jokers',
    pos = { x = 2, y = 0 },
    rarity = 3,
    cost = 7,
    blueprint_compat = false,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    map_credits = {
        code = "vissa",
        art = "chez"
    },

    calculate = function(self, card, context)
        if context.blueprint then
            return
        end
        if context.new_map then
            context.config.steps = context.config.steps + card.ability.extra.extra_steps
            
            return { 
                card = card,
                colour = G.C.PURPLE,
                message = localize('k_bigger_map'),
            }
        end

    end,

    loc_vars = function(self, info_queue, card)
        return { vars = {  card.ability.extra.extra_steps }, key = self.key }
    end
}


SMODS.Joker{
    key = "gps",
    config = { extra = { chips = 5 } },
    atlas = 'map_jokers',
    pos = { x = 3, y = 0 },
    rarity = 1,
    cost = 5,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    map_credits = {
        code = "vissa",
        art = {"chez", "vissa"}
    },

    calculate = function(self, card, context)
        if context.enc_scenario_start and not context.blueprint then
            return {
                card = card,
                color = G.C.BLUE,
                message = localize { type = 'variable', key = 'a_chips', vars = { card.ability.extra.chips } },
            }
        end
        if context.joker_main then
            return {
                chips = card.ability.extra.chips *
                    (G.GAME.events_visited_total or 0)
            }
        end
    end,

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips, card.ability.extra.chips * (G.GAME.events_visited_total or 0) } }
    end,
}


SMODS.Joker{
    key = "punch_card",
    config = { extra = { Xmult = 4, every = 4, remaining = 4 } },
    atlas = 'map_jokers',
    pos = { x = 4, y = 0 },
    rarity = 2,
    cost = 4,
    blueprint_compat = false,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    map_credits = {
        code = "vissa",
        art = {"chez", "vissa"}
    },

    calculate = function(self, card, context)
        if context.blueprint then
            return
        end
        if context.using_consumeable then
            card.ability.extra.remaining = card.ability.extra.remaining - 1

            if card.ability.extra.remaining == 1 then
                local eval = function(card)
                    return card.ability.extra.remaining == 1 and not G.RESET_JIGGLES
                end
                juice_card_until(card, eval, true)
            end
            
            if card.ability.extra.remaining == 0 then
                card.ability.extra.remaining = card.ability.extra.every

                G.E_MANAGER:add_event(Event({
                    func = (function()
                        SMODS.add_card {
                            key = context.consumeable.config.center.key -- Optional, useful for manipulating the random seed and checking the source of the creation in `in_pool`.
                        }
                        G.GAME.consumeable_buffer = 0
                        return true
                    end)
                }))
                return {
                    card = card,
                    colour = G.C.GREEN,
                    message = localize('k_punch_duplicate'),
                }
            end
        end
    end,

      loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.every,
                localize { type = 'variable', key = (card.ability.extra.remaining == 1 and 'punch_card_will' or 'punch_card_more'), vars = { card.ability.extra.remaining } }
            }
        }
    end,
}
-- 


SMODS.Joker:take_ownership('j_throwback', -- object key (class prefix not required)
    { 
    map_credits = {
        made = "vissa",
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra, 1 + (G.GAME.tags_used or 0) * card.ability.extra } }
    end,
	calculate = function(self, card, context)
        if context.skip_blind and not context.blueprint then
            return {
                message = localize { type = 'variable', key = 'a_xmult', vars = { 1 + (G.GAME.tags_used or 0) * card.ability.extra } }
            }
        end
        if context.joker_main then
            return {
                xmult = 1 + (G.GAME.tags_used or 0) * card.ability.extra
            }
        end
    end,
    }
)
