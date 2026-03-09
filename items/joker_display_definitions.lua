if JokerDisplay == nil then
    return
end

local jd_def = JokerDisplay.Definitions -- You can assign it to a variable to use as shorthand

---@type JDJokerDefinition
jd_def["j_map_gps"] = { -- GPS (based on Bull)
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "chips", retrigger_type = "mult" }
    },
    text_config = { colour = G.C.CHIPS },
    calc_function = function(card)
        card.joker_display_values.chips = card.ability.extra.chips * (G.GAME.events_visited_total or 0)
    end
}

---@type JDJokerDefinition
jd_def["j_throwback"] = {   -- Throwback
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            }
        }
    },
    calc_function = function(card)
        card.joker_display_values.x_mult = 1 + (G.GAME.tags_used or 0) * card.ability.extra
    end
}