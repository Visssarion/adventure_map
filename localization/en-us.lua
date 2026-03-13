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
                        "Adds #1# more steps to your map.",
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
            j_throwback = {
                text = {
                    "{X:mult,C:white} X#1# {} Mult for each",
                    "{C:attention}Tag{} activated this run",
                    "{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult)",
                },
            }
        },
        Tag = {
            tag_map_bigger_map = {
                name = "Bigger Map Tag",
                text = {"Adds #1# more steps to your map"}
            },
            tag_skip = {
                text = {
                    "Gives {C:money}$#1#{} per activated",
                    "Tag this run",
                    "{C:inactive}(Will give {C:money}$#2#{C:inactive})",
                },
            }
        },
        enc_Step = {
            st_map_rps_play_win = {
                text = {
                    "\"Damn, you won! You must have cheated!!\"",
                    "\"Whatever, take your #1# and leave.\""
                }
            },
            st_map_rps_play_lose = {
                text = {
                    "\"Easy money, hehe.\""
                }
            },
            st_map_rps_play_draw = {
                text = {
                    "\"Draw means a refund.",
                    "\"But only after I take the fee money, of course.\""
                }
            },
        }
    },
    misc = {
        dictionary = {

            k_more_shops="More Shops!",
            k_customer_bonus="Customer Bonus!",
            k_more_blinds="More Blinds!",
            k_hunting_fees="Hunting Fees...",
            k_bigger_map="Bigger Map",
            k_punch_duplicate="Consumable printed",

            b_debug_button="DEBUG BUTTON",

            rps_rock="Rock",
            rps_paper="Paper",
            rps_scissors="Scissors"
        },
        v_dictionary={
            punch_card_more="#1# more required.",
            punch_card_will="Next consumable will be duplicated!",
            
            map_art = { "Art: #1#" },
            map_code = { "Code: #1#" },
            map_idea = { "Idea: #1#" },
            map_made = { "Made: #1#" },
            map_help = { "Help: #1#"},
            map_rewrite = { "Rewrite: #1#"}
        }
    }
}