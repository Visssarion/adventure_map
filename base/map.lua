--G.GAME.current_map
--G.GAME.current_map_progress

SMODS.Atlas({
    key = "map_icons",
    path = "map_icons.png",
    px = 34,
    py = 34
})

SMODS.Atlas({
    atlas_table = 'ANIMATION_ATLAS',
    frames = 4,
    key = "map_icons_shop_animated",
    path = "map_icons_shop_animated.png",
    px = 34,
    py = 34
})

MAP.UI.ICONS = {
    atlas = "map_icons",
    pos = {
        default = {x=0, y=0},
        unknown = {x=0, y=0},
        game = {x=1, y=0},
        enemy = {x=2, y=0},
        shop = {x=0, y=1},
        market = {x=1, y=1},
        gift = {x=2, y=1},
        coin = {x=3, y=1},
        golden = {x=0, y=2},
        joker = {x=1, y=2},
        space = {x=2, y=2},
        card = {x=3, y=2},
        crystal = {x=0, y=3},
        hieroglyph = {x=1, y=3},
        
    }

}


MAP.MapManager = {

    generate_new_map = function ()
        print("[ADVENTURE_MAP] Map Generating")

        -- passed into calculate_context. used for generating the map
        local config = {
            room_weights = {
                event = 0.9,
                shop = 0.25,
                small_blind = 0.07,
                big_blind = 0.07,
            },
            room_funcs = {
                event = function ()
                    local scenario_key = TheEncounter.POOL.poll_scenario("do_enc_occurrence", {ignore_domain = true, ignore_once_per_run=true})
                    return scenario_key
                end,
                shop = function ()
                    return "shop"
                end,
                small_blind = function ()
                    return "blind_small"
                end,
                big_blind = function ()
                    return "blind_big"
                end,
            },
            steps = 4,
            choices = 3
        }

        local context = {
            new_map = true,
            config = config
        }

        SMODS.calculate_context(context) -- send calculate to modify parameters
        for index, tag in ipairs(G.GAME.tags) do
            tag.apply_to_run(tag, context)
        end

        local combined_weight = 0.0
        for _key, value in pairs(config.room_weights) do
            combined_weight = combined_weight + value
        end

        local randomize_choice = function ()
            local weight = combined_weight * pseudorandom('MAPMAP')
            for room, room_weight in pairs(config.room_weights) do
                if weight > room_weight then
                    weight = weight - room_weight
                else
                    return config.room_funcs[room]()
                end
            end
        end
        

        local generate_choices = function ()
            local choices = {}
            for i=1, config.choices do
                choices[i] = randomize_choice()
            end
            return choices
        end

        -- generate an array based on that
        local map = {}

        local levels_pre_middle = math.ceil(config.steps/2)
        local levels_post_middle = config.steps - levels_pre_middle


        for i=1, (levels_pre_middle) do
            map[i] = generate_choices()
        end
        map[levels_pre_middle+1] = {"blind_big"}
        for i=levels_pre_middle+2,levels_pre_middle+2+levels_post_middle do
            map[i] = generate_choices()
        end
        map[levels_pre_middle+2+levels_post_middle] = {"blind_boss"}

        print(map)

        G.GAME.current_map = map -- setting map on the global state
        G.GAME.current_map_progress = {} -- resetting progress
        return map
    end,

    ---returns domain for the scenario
    ---@param scenario TheEncounter.Scenario
    ---@return string
    find_domain = function (scenario)
        if scenario.domains == nil then
            return "do_enc_occurrence"
        end
        for key, value in pairs(scenario.domains) do
            if value then
                return key
            end
        end
        return "do_enc_occurrence"
    end
}
