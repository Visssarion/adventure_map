return {
    descriptions = {
        Joker = {
            j_map_rewards_program = {
                name = "Rewards Program Card",
                text = {
                    {
                        "Doubles the chance of",
                        "a Shop appearing on the map.",
                        "{C:green}#1# in #2#{} chance to",
						"get {C:money}#3#${} on entering Shop.",
                    }
                },
            },
            j_map_hunting_license = {
                name = "Hunting License",
                text = {
                    {
                        "Triples the chance of",
                        "blinds appearing on the map.",
                        "Lose {C:money}#1#${} on blind start.",
                    }
                },
            },

            j_map_travel_guide = {
                name = "Travel Guide",
                text = {
                    {
                        "Adds #1# more step to your map.",
                    }
                },
            },

            j_map_gps = {
                name = "GPS",
                text = {
                    "{C:blue}+#1#{} Chips per every",
                    "{C:purple}Event{} visited this run",
                    "{C:inactive}(Currently {C:blue}+#2#{C:inactive})",
                },
            },

            j_map_punch_card = {
                name = "Punch card",
                text = {
                    "Duplicates used consumable",
                    "every {C:attention}#1#{} consumables used",
                    "{C:inactive}#2#",
                },
            },
        }
    },
    misc = {

            -- do note that when using messages such as: 
            -- message = localize{type='variable',key='a_xmult',vars={current_xmult}},
            -- that the key 'a_xmult' will use provided values from vars={} in that order to replace #1#, #2# etc... in the localization file.


        dictionary = {
            -- a_chips="+#1#",
            -- a_chips_minus="-#1#",
            -- a_hands="+#1# Hands",
            -- a_handsize="+#1# Hand Size",
            -- a_handsize_minus="-#1# Hand Size",
            -- a_mult="+#1# Mult",
            -- a_mult_minus="-#1# Mult",
            -- a_remaining="#1# Remaining",
            -- a_sold_tally="#1#/#2# Sold",
            -- a_xmult="X#1# Mult",
            -- a_xmult_minus="-X#1# Mult",
            k_more_shops="More Shops!",
            k_customer_bonus="Customer Bonus!",
            k_more_blinds="More Blinds!",
            k_hunting_fees="Hunting Fees...",
            k_bigger_map="Bigger Map",
            k_punch_duplicate="Consumable printed",

            

            b_debug_button="DEBUG BUTTON",
        },
        v_dictionary={
            punch_card_more="#1# more required.",
            punch_card_will="Next consumable will be duplicated!",
        }
    }
}