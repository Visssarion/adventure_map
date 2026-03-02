SMODS.Sound({
    key = "music_map",
    path = "music_map.ogg",
    pitch = 1,
    volume = 0.4,
    select_music_track = function (self)
        if G.STATE == G.STATES.ADVENTURE_MAP then
            return 1
        end
        return nil
    end
})

SMODS.Sound({
    key = "music_event",
    path = "music_event.ogg",
    pitch = 1,
    volume = 0.4,
    select_music_track = function (self)
        if G.STATE == G.STATES.ENC_EVENT then
            return 1
        end
        return nil
    end
})