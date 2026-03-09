local planet_most_used_hand = function ()
    local _planet, _hand, _tally = nil, nil, 0
    for _, handname in ipairs(G.handlist) do
        if SMODS.is_poker_hand_visible(handname) and G.GAME.hands[handname].played > _tally then
            _hand = handname
            _tally = G.GAME.hands[handname].played
        end
    end
    if _hand then
        for _, v in pairs(G.P_CENTER_POOLS.Planet) do
            if v.config.hand_type == _hand then
                _planet = v.key
            end
        end
    end
    -- _card = {
    --     set = "Planet",
    --     area = G.pack_cards,
    --     skip_materialize = true,
    --     soulable = true,
    --     key = _planet,
    --     key_append = "pl1"
    -- }
    return _planet
end 
