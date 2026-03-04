map_icons = SMODS.Atlas({
    key = "map_icons",
    path = "map_icons.png",
    px = 34,
    py = 34
})


MAP.UI.render_map = function ()
    if MAP.UI._map then
        MAP.UI._map:remove()
    end
    MAP.UI._map = UIBox({
        definition = {
            n = G.UIT.ROOT,
            config = { align = "cm", 
                    minw=10, minh=8, maxw=10, maxh=8, r = 0.1,
                    colour = G.C.L_BLACK, padding = 0.2, outline = 1, outline_colour = G.C.BLACK,
                    hover = true, shadow = true, juice = true, emboss = 0.5,
                    },
            nodes = {
                {n = G.UIT.C, config = {padding = 0.15}, nodes = {

                    {n = G.UIT.R, config = {padding = 0.15}, nodes = {
                        {n = G.UIT.T, config = {text = "Select your path...", colour = G.C.UI.TEXT_LIGHT, scale = 0.5}},
                    }},

                    MAP.UI.construct_map(),
                }}
            },
        },
        config = { align = "bmi", major = G.ROOM_ATTACH, bond = 'Weak' },
    })
end

MAP.UI.remove_map = function ()
    if MAP.UI._map then
        MAP.UI._map:remove()
        MAP.UI._map = nil
    end
end

G.FUNCS.debug_button = function(e)

    G.STATE = G.STATES.SHOP
    G.STATE_COMPLETE = false
    MAP.UI.remove_map()
end

G.FUNCS.go_to_shop_button = function(e)

    G.GAME.current_map_progress[e.config.progress.column] = e.config.progress.row

    G.STATE = G.STATES.SHOP
    G.STATE_COMPLETE = false
    MAP.UI.remove_map()

    play_sound("coin7", 1, 0.7)
	play_sound("generic1")
end

G.FUNCS.go_to_round_button = function(e)
    
    G.GAME.current_map_progress[e.config.progress.column] = e.config.progress.row
    G.GAME.round_resets.blind = G.P_BLINDS[G.GAME.round_resets.blind_choices[e.config.blind_data]]

    stop_use() -- i wish i knew what these are, used in the balatro source code
    ease_round(1)
    inc_career_stat('c_rounds', 1)
    
    MAP.UI.remove_map() 
    new_round()
end


G.FUNCS.go_to_blind_select_button = function(e)
    G.STATE = G.STATES.BLIND_SELECT
    G.STATE_COMPLETE = false
    MAP.UI.remove_map()
end

G.FUNCS.go_to_event_button = function(e)
    G.GAME.current_map_progress[e.config.progress.column] = e.config.progress.row
    local scenario_key = e.config.event_data.key
    --local scenario_key = TheEncounter.POOL.poll_scenario("do_enc_occurrence", {ignore_domain = true, ignore_once_per_run=true})
    local domain_key = nil
    for key, value in pairs(TheEncounter.Scenarios[scenario_key].domains) do
        domain_key = key
    end
    domain_key = domain_key or "do_enc_occurrence"
    print({scenario_key = scenario_key, domain_key = domain_key})

    G.GAME.TheEncounter_choice = TheEncounter.select_choice(domain_key, scenario_key)

    G.GAME.TheEncounter_replaced_state = G.STATES.ADVENTURE_MAP

    G.STATE = G.STATES.ENC_EVENT
    G.STATE_COMPLETE = false
    MAP.UI.remove_map()

    G.GAME.events_visited_total = G.GAME.events_visited_total + 1

    play_sound("gong", 0.9+math.random()*0.2, 0.6)
	play_sound("generic1")
end






MAP.UI.construct_map = function ()
    local map = {n=G.UIT.R, nodes={}}

    local current_column = #G.GAME.current_map_progress + 1

    for column_index, choices in ipairs(G.GAME.current_map) do
        local column = {n=G.UIT.C, 
        config = {
            align = "cm"
        },
        nodes={}}
        
        for row_index, value in ipairs(choices) do
            local item = nil

            if value == "shop" then
                item = {n=G.UIT.O, config={object = SMODS.create_sprite(0, 0, 1, 1, map_icons, {x = 0,y = 1}),
                                button = "go_to_shop_button", progress = {column = column_index, row = row_index}
                        }}
            --elseif string.sub(value, 1, 3) == "ev_" then
            elseif string.sub(value, 1, 3) == "sc_" then
                item = {n=G.UIT.O, config={object = SMODS.create_sprite(0, 0, 1, 1, map_icons, {x = 0,y = 0}), --hover = true, shadow = true, juice = true, emboss = 0.5,
                                button = "go_to_event_button", event_data={key=value}, progress = {column = column_index, row = row_index}
                        }}
            elseif string.sub(value, 1, 6) == "blind_" then
                if value == "blind_small" then
                    item = {n=G.UIT.O, config={object = Sprite(0, 0, 1, 1, G.ANIMATION_ATLAS['blind_chips'], {x = 0,y = 0}),
                                button = "go_to_round_button", blind_data='Small', progress = {column = column_index, row = row_index}
                        }}
                elseif  value == "blind_big" then
                    item = {n=G.UIT.O, config={object = Sprite(0, 0, 1, 1, G.ANIMATION_ATLAS['blind_chips'], {x = 0,y = 1}),
                                button = "go_to_round_button", blind_data='Big', progress = {column = column_index, row = row_index}
                        }}
                elseif  value == "blind_boss" and G.GAME.round_resets.blind_choices["Boss"] and G.P_BLINDS[G.GAME.round_resets.blind_choices["Boss"]] then
                    local pos = (G.P_BLINDS[G.GAME.round_resets.blind_choices["Boss"]].pos) or {x=0, y=0}
                    if pos.x == nil then -- GUARDRAILS BECAUSE SOMETIMES I GUESS THEY DONT SET ONE OF THE PROPERTIES???
                        pos.x = 0
                    end
                    if pos.y == nil then
                        pos.y = 0 
                    end
                    local atlas = SMODS.Atlases[G.P_BLINDS[G.GAME.round_resets.blind_choices["Boss"]].atlas] or G.ANIMATION_ATLAS['blind_chips']
                    item = {n=G.UIT.O, config={object = Sprite(0, 0, 1, 1, atlas, pos),
                                button = "go_to_round_button", blind_data='Boss', progress = {column = column_index, row = row_index}
                        }}
                end
            end

            

            local item_container = {n=G.UIT.R, nodes={item}, config = {}}
            if item then
                if column_index ~= current_column then
                    item.config.button = nil
                end
                if G.GAME.current_map_progress[column_index] and G.GAME.current_map_progress[column_index] == row_index then
                    item_container.config.outline = 1
                    item_container.config.r = 1
                    item_container.config.outline_colour = G.C.BLACK
                end 
                column.nodes[row_index] = item_container
            end
            
        end

        if column_index == current_column then
            column.config.outline = 1
            column.config.outline_colour = G.C.UI.OUTLINE_LIGHT
            column.config.r = 5
            
        end 

        map.nodes[column_index] = column
    end
        
    return map
    
end

