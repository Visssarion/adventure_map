-- do_enc_occurrence
-- Default dummy domain

-- do_map_misc
TheEncounter.Domain({
	key = "misc",
	loc_txt = {
		name = "Miscellaneous",
		text = {
			"An assortment of random events",
		},
	},
	can_repeat = true,
	reward = 0,
	colour = G.C.GREY,
	background_colour = G.C.PALE_GREEN,

    atlas = MAP.UI.ICONS.atlas,
    pos = MAP.UI.ICONS.pos.unknown,
})

-- do_map_game
TheEncounter.Domain({
	key = "game",
	loc_txt = {
		name = "Game",
		text = {
			"Game-like events",
		},
	},
	can_repeat = true,
	reward = 0,
	colour = G.C.GREEN,
	background_colour = G.C.PALE_GREEN,

    atlas = MAP.UI.ICONS.atlas,
    pos = MAP.UI.ICONS.pos.game,
})

-- do_map_combat
TheEncounter.Domain({
	key = "combat",
	loc_txt = {
		name = "Combat",
		text = {
			"Fighting events",
		},
	},
	can_repeat = true,
	reward = 0,
	colour = G.C.RED,
	background_colour = G.C.RED,

    atlas = MAP.UI.ICONS.atlas,
    pos = MAP.UI.ICONS.pos.enemy,
})

-- do_map_market
TheEncounter.Domain({
	key = "market",
	loc_txt = {
		name = "Market",
		text = {
			"Events about exchanging goods and services",
		},
	},
	can_repeat = true,
	reward = 0,
	colour = G.C.GREEN,
	background_colour = G.C.GREEN,

    atlas = MAP.UI.ICONS.atlas,
    pos = MAP.UI.ICONS.pos.market,
})

-- do_map_gift
TheEncounter.Domain({
	key = "gift",
	loc_txt = {
		name = "Gift",
		text = {
			"Free stuff!",
		},
	},
	can_repeat = true,
	reward = 0,
	colour = G.C.GOLD,
	background_colour = G.C.RED,

    atlas = MAP.UI.ICONS.atlas,
    pos = MAP.UI.ICONS.pos.gift,
})

-- -- do_map_coin
-- TheEncounter.Domain({
-- 	key = "coin",
-- 	loc_txt = {
-- 		name = "Coin",
-- 		text = {
-- 			"Coin stuff?",
-- 		},
-- 	},
-- 	can_repeat = true,
-- 	reward = 0,
-- 	colour = G.C.GOLD,
-- 	background_colour = G.C.GOLD,

--     atlas = MAP.UI.ICONS.atlas,
--     pos = MAP.UI.ICONS.pos.coin,
-- })

-- do_map_golden
TheEncounter.Domain({
	key = "golden",
	loc_txt = {
		name = "Golden",
		text = {
			"Golden Events?",
		},
	},
	can_repeat = true,
	reward = 0,
	colour = G.C.GOLD,
	background_colour = G.C.GOLD,

    atlas = MAP.UI.ICONS.atlas,
    pos = MAP.UI.ICONS.pos.golden,
})

-- do_map_joker
TheEncounter.Domain({
	key = "joker",
	loc_txt = {
		name = "Joker",
		text = {
			"Joker events?",
		},
	},
	can_repeat = true,
	reward = 0,
	colour = G.C.WHITE,
	background_colour = G.C.BLACK,

    atlas = MAP.UI.ICONS.atlas,
    pos = MAP.UI.ICONS.pos.joker,
})

-- do_map_space
TheEncounter.Domain({
	key = "space",
	loc_txt = {
		name = "Space",
		text = {
			"Cosmical events...",
		},
	},
	can_repeat = true,
	reward = 0,
	colour = G.C.BLUE,
	background_colour = G.C.BLACK,

    atlas = MAP.UI.ICONS.atlas,
    pos = MAP.UI.ICONS.pos.space,
})


-- do_map_card
TheEncounter.Domain({
	key = "card",
	loc_txt = {
		name = "Card",
		text = {
			"Card events",
		},
	},
	can_repeat = true,
	reward = 0,
	colour = G.C.WHITE,
	background_colour = G.C.BLACK,

    atlas = MAP.UI.ICONS.atlas,
    pos = MAP.UI.ICONS.pos.card,
})

-- do_map_crystal
TheEncounter.Domain({
	key = "crystal",
	loc_txt = {
		name = "Crystal",
		text = {
			"Events that know your future...",
		},
	},
	can_repeat = true,
	reward = 0,
	colour = G.C.PURPLE,
	background_colour = G.C.PURPLE,

    atlas = MAP.UI.ICONS.atlas,
    pos = MAP.UI.ICONS.pos.crystal,
})



-- do_map_mystery
TheEncounter.Domain({
	key = "mystery",
	loc_txt = {
		name = "Mystery",
		text = {
			"Mysterious events...",
		},
	},
	can_repeat = true,
	reward = 0,
	colour = G.C.GOLD,
	background_colour = G.C.ORANGE,

    atlas = MAP.UI.ICONS.atlas,
    pos = MAP.UI.ICONS.pos.hieroglyph,
})

