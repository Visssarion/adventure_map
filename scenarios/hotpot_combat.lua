-- Rewards logic and stuff taken from HotPot

local hpot_event_get_random_boss = function(seed)
	local eligible_bosses = {}
	for k, v in pairs(G.P_BLINDS) do
		local res, options = SMODS.add_to_pool(v)
		eligible_bosses[k] = res and true or nil
	end
	for k, v in pairs(G.GAME.banned_keys) do
		if eligible_bosses[k] then
			eligible_bosses[k] = nil
		end
	end
	local _, boss = pseudorandom_element(eligible_bosses, seed or "hpot_event_boss")
	return boss or "bl_wall"
end
local hpot_event_get_random_combat_effect = function(seed)
	-- TODO: localize these
	local effects = {
		{ change_size = 2, text = "but Blind size is doubled" },
		{ total_hands = 1, text = "with only 1 hand" },
		{ total_discards = 0, text = "with 0 discards" },
		{ debuff = { jokers = true }, text = "but all Jokers are debuffed" },
		{ debuff = { suit = true }, text = "but all [suit] are debuffed" }, -- not valid, randomizes later
		{ debuff = { face = true }, text = "but all face cards are debuffed" },
		{
			debuff = { most_played_hand = true },
			text = "but " .. localize(G.GAME.current_round.most_played_poker_hand, "poker_hands") .. " is not allowed",
		},
		{
			set_to_zero = { most_played_hand = true, dollars = true },
			text = "but playing "
				.. localize(G.GAME.current_round.most_played_poker_hand, "poker_hands")
				.. " sets money to 0",
		},
		{ no_repeat_hands = true, text = "but no repeat hand types" },
		{ one_hand_type = true, text = "but only one hand type can be played" },
		{ flipped = { suit = true }, text = "but all [suit] are drawn facedown" }, -- not valid, randomizes later
		{ flipped = { face = true }, text = "but all face cards are drawn facedown" },
		{ flipped = { first_hand = true }, text = "but first hand is drawn facedown" },
		{ base_score_halved = true, text = "but base Chips and Mult are halved" },
	}

	local rank_counts = {}
	for _, pcard in ipairs(G.playing_cards) do
		if not SMODS.has_no_rank(pcard) then
			rank_counts[pcard.base.value] = (rank_counts[pcard.base.value] or 0) + 1
		end
	end
	local min_rank, rank_key = 0, "King"
	for key, value in pairs(rank_counts) do
		if value >= min_rank then
			rank_key = key
			min_rank = value
		end
	end

	effects[#effects + 1] = {
		debuff = { rank = rank_key },
		text = "but all " .. localize(rank_key, "ranks") .. "s are debuffed",
	}

	local chosen_effect = pseudorandom_element(effects, seed or "hpot_event_combat_effect")
	if not chosen_effect then
		return
	end
	if chosen_effect.debuff and chosen_effect.debuff.suit then
		local suit = pseudorandom_element(SMODS.Suits, (seed or "hpot_event_combat_effect") .. "suit_debuff")
		chosen_effect.debuff.suit = (suit or {}).key or "Spades"
		chosen_effect.text = "but all " .. localize(chosen_effect.debuff.suit, "suits_plural") .. " are debuffed"
	end
	if chosen_effect.flipped and chosen_effect.flipped.suit then
		local suit = pseudorandom_element(SMODS.Suits, (seed or "hpot_event_combat_effect") .. "suit_flip")
		chosen_effect.flipped.suit = (suit or {}).key or "Diamonds"
		chosen_effect.text = "but all " .. localize(chosen_effect.flipped.suit, "suits_plural") .. " are drawn facedown"
	end

	return chosen_effect
end
local hpot_event_get_random_combat_reward = function(as_encounter, seed)
	-- TODO: localize these
	local combat_rewards = {
		{ jokers = { { rarity = "Common" } }, text = "Common joker" },
		{ jokers = { { rarity = "Uncommon", need_room = true } }, text = "Uncommon joker" },
		{ consumables = { { set = "Tarot", need_room = true, amount = 2 } }, text = "2 Tarots" },
		{ consumables = { { set = "Planet", need_room = true, amount = 2 } }, text = "2 Planets" },
		-- { consumables = { { set = "bottlecap_Common", need_room = true, amount = 2 } } },
		-- { consumables = { { set = "bottlecap_Uncommon", need_room = true } } },
		-- { consumables = { { set = "Czech", need_room = true } } },
		-- { consumables = { { set = "Hanafuda", need_room = true, amount = 2 } } },
		{ tags = { random_amount = 2 }, text = "2 random Tags" },
		{ tags = { keys = { "tag_double" } }, text = "Double tag" },
		{ dollars = 4, text = "4 Dollars" },
		-- { credits = 30 },
		-- { sparkle = 35000 },
		-- { crypto = 0.5 },
	}
	-- for k, v in ipairs(G.localization.misc.CombatEventRewards.generic) do
	-- 	if combat_rewards[k] then
	-- 		combat_rewards[k].text = v
	-- 	end
	-- end

	local encounter_rewards = {
		{ jokers = { { rarity = "Uncommon" } }, text = "Uncommon joker" },
		{ jokers = { { rarity = "Rare", need_room = true } }, text = "Rare joker" },
		{ consumables = { { set = "Spectral", need_room = true, amount = 2 } }, text = "2 Spectrals" },
		-- { consumables = { { set = "bottlecap_Uncommon", need_room = true, amount = 2 } } },
		-- { consumables = { { set = "bottlecap_Rare", need_room = true } } },
		-- { consumables = { { set = "Czech", need_room = true, amount = 2 } } },
		{ tags = { random_amount = 5 }, text = "5 random Tags" },
		{ tags = { keys = { "tag_double", "tag_double" } }, text = "2 Double Tags" },
		{ dollars = 8, text = "8 Dollars" },
		-- { credits = 30 },
		-- { sparkle = 75000 },
		-- { crypto = 2 },
	}
	-- for k, v in ipairs(G.localization.misc.EncounterEventRewards.generic) do
	-- 	if encounter_rewards[k] then
	-- 		encounter_rewards[k].text = v
	-- 	end
	-- end

	local _handname, _played = "High Card", -1
	for hand_key, hand in pairs(G.GAME.hands) do
		if hand.played > _played then
			_played = hand.played
			_handname = hand_key
		end
	end
	local most_played = _handname

	combat_rewards[#combat_rewards + 1] = {
		level_up_hand = { key = most_played, amount = 2 },
		text = "Level up " .. localize(most_played, "poker_hands") .. " 2 times",
	}
	encounter_rewards[#encounter_rewards + 1] = {
		level_up_hand = { key = most_played, amount = 4 },
		text = "Level up " .. localize(most_played, "poker_hands") .. " 4 times",
	}

	local _poker_hands = {}
	for handname, _ in pairs(G.GAME.hands) do
		if SMODS.is_poker_hand_visible(handname) and handname ~= most_played then
			_poker_hands[#_poker_hands + 1] = handname
		end
	end

	local chosen_hand = pseudorandom_element(_poker_hands, seed or "hpot_event_combat_reward")

	if chosen_hand then
		combat_rewards[#combat_rewards + 1] = {
			level_up_hand = { key = chosen_hand, amount = 2 },
			text = "Level up " .. localize(chosen_hand, "poker_hands") .. " 2 times",
		}
		encounter_rewards[#encounter_rewards + 1] = {
			level_up_hand = { key = chosen_hand, amount = 4 },
			text = "Level up " .. localize(chosen_hand, "poker_hands") .. " 4 times",
		}
	end

	local add_rank = pseudorandom("hpot_event_combat_reward", 1, 3)
	local add_enhancement = SMODS.poll_enhancement({ guaranteed = true })
	local add_seal = SMODS.poll_seal({ guaranteed = true }) or "Red"

	local add_rank_text = (add_rank == 1 and "Ace") or (add_rank == 2 and "Face card") or "Numbered card"
	local add_enhancement_text = localize({ type = "name_text", set = "Enhanced", key = add_enhancement })
	local add_seal_text = localize({ type = "name_text", set = "Other", key = add_seal:lower() .. "_seal" })

	if pseudorandom("hpot_event_combat_reward") < 0.5 then
		combat_rewards[#combat_rewards + 1] = {
			playing_cards = {
				{
					rank = add_rank == 1 and "Ace" or nil,
					face = add_rank == 2 or nil,
					numbered = add_rank == 3 or nil,
					edition = "e_foil",
					amount = 2,
				},
			},
			text = "Add 2 random Foil " .. add_rank_text .. "s to the deck",
		}
		encounter_rewards[#encounter_rewards + 1] = {
			playing_cards = {
				{
					rank = add_rank == 1 and "Ace" or nil,
					face = add_rank == 2 or nil,
					numbered = add_rank == 3 or nil,
					edition = "e_holo",
					amount = 2,
				},
			},
			text = "Add 2 random Holographic " .. add_rank_text .. "s to the deck",
		}
		encounter_rewards[#encounter_rewards + 1] = {
			playing_cards = {
				{
					rank = add_rank == 1 and "Ace" or nil,
					face = add_rank == 2 or nil,
					numbered = add_rank == 3 or nil,
					edition = "e_polychrome",
					amount = 1,
				},
			},
			text = "Add 1 random Polychrome " .. add_rank_text .. " to the deck",
		}
		combat_rewards[#combat_rewards + 1] = {
			playing_cards = {
				{
					rank = add_rank == 1 and "Ace" or nil,
					face = add_rank == 2 or nil,
					numbered = add_rank == 3 or nil,
					enhanced = true,
					amount = 2,
				},
			},
			text = "Add 2 random Enhanced " .. add_rank_text .. "s to the deck",
		}
		encounter_rewards[#encounter_rewards + 1] = {
			playing_cards = {
				{
					rank = add_rank == 1 and "Ace" or nil,
					face = add_rank == 2 or nil,
					numbered = add_rank == 3 or nil,
					enhanced = true,
					amount = 5,
				},
			},
			text = "Add 5 random Enhanced " .. add_rank_text .. "s to the deck",
		}
		combat_rewards[#combat_rewards + 1] = {
			playing_cards = {
				{
					rank = add_rank == 1 and "Ace" or nil,
					face = add_rank == 2 or nil,
					numbered = add_rank == 3 or nil,
					enhancement = add_enhancement,
					amount = 2,
				},
			},
			text = "Add 2 random " .. add_enhancement_text .. " " .. add_rank_text .. "s to the deck",
		}
		encounter_rewards[#encounter_rewards + 1] = {
			playing_cards = {
				{
					rank = add_rank == 1 and "Ace" or nil,
					face = add_rank == 2 or nil,
					numbered = add_rank == 3 or nil,
					enhancement = add_enhancement,
					amount = 5,
				},
			},
			text = "Add 5 random " .. add_enhancement_text .. " " .. add_rank_text .. "s to the deck",
		}
		encounter_rewards[#encounter_rewards + 1] = {
			playing_cards = {
				{
					rank = add_rank == 1 and "Ace" or nil,
					face = add_rank == 2 or nil,
					numbered = add_rank == 3 or nil,
					seal = add_seal,
					amount = 2,
				},
			},
			text = "Add 2 random " .. add_seal_text .. " " .. add_rank_text .. "s to the deck",
		}
	else
		combat_rewards[#combat_rewards + 1] = {
			enhance_deck = {
				{
					edition = "e_foil",
					amount = 2,
				},
			},
			text = "Turn 2 random cards in deck Foil",
		}
		encounter_rewards[#encounter_rewards + 1] = {
			enhance_deck = {
				{
					edition = "e_holo",
					amount = 2,
				},
			},
			text = "Turn 2 random cards in deck Holographic",
		}
		encounter_rewards[#encounter_rewards + 1] = {
			enhance_deck = {
				{
					edition = "e_polychrome",
					amount = 1,
				},
			},
			text = "Turn a random card in deck Polychrome",
		}
		combat_rewards[#combat_rewards + 1] = {
			enhance_deck = {
				{
					change_base = {
						rank = add_rank == 1 and "Ace" or nil,
						face = add_rank == 2 or nil,
						numbered = add_rank == 3 or nil,
					},
					enhancement = add_enhancement,
					amount = 1,
				},
			},
			text = "Change a random card in deck into a " .. add_enhancement_text .. " " .. add_rank_text,
		}
		encounter_rewards[#encounter_rewards + 1] = {
			enhance_deck = {
				{
					change_base = {
						rank = add_rank == 1 and "Ace" or nil,
						face = add_rank == 2 or nil,
						numbered = add_rank == 3 or nil,
					},
					enhancement = add_enhancement,
					amount = 3,
				},
			},
			text = "Change 3 random cards in deck into " .. add_enhancement_text .. " " .. add_rank_text .. "s",
		}
		encounter_rewards[#encounter_rewards + 1] = {
			enhance_deck = {
				{ seal = add_seal },
			},
			text = "Add " .. add_seal_text .. " to a random card in the deck",
		}
	end

	return pseudorandom_element(
		as_encounter and encounter_rewards or combat_rewards,
		seed or "hpot_event_combat_reward"
	)
end
local hpot_start_additional_round = function(event)
	local hpot_combat = {
		blind_key = event.ability.extra.blind,
		blind_effect = event.ability.extra.effect,
		blind_reward = event.ability.extra.reward,
	}

	G.RESET_JIGGLES = nil
	delay(0.4)
	G.E_MANAGER:add_event(Event({
		trigger = "immediate",
		func = function()

			G.GAME.combat_event = true

			G.GAME.current_round.discards_left = math.max(0, G.GAME.round_resets.discards + G.GAME.round_bonus.discards)
			G.GAME.current_round.hands_left = (math.max(1, G.GAME.round_resets.hands + G.GAME.round_bonus.next_hands))
			G.GAME.current_round.hands_played = 0
			G.GAME.current_round.discards_used = 0
			G.GAME.current_round.reroll_cost_increase = 0
			G.GAME.current_round.used_packs = {}

			for k, v in pairs(G.GAME.hands) do
				v.played_this_round = 0
			end

			for k, v in pairs(G.playing_cards) do
				v.ability.wheel_flipped = nil
			end

			G.GAME.round_bonus.next_hands = 0
			G.GAME.round_bonus.discards = 0

			local blhash = "S"
			G.GAME.subhash = G.GAME.round_resets.ante .. blhash
			G.GAME.blind_on_deck = "Combat"
			G.GAME.blind:set_blind(G.P_BLINDS[hpot_combat.blind_key])
			G.GAME.blind.effect.hpot_combat = hpot_combat
			for _, v in ipairs(G.playing_cards) do
				SMODS.recalc_debuff(v)
			end
			for _, v in ipairs(G.jokers.cards) do
				SMODS.recalc_debuff(v)
			end
			G.GAME.last_blind.boss = nil
			G.HUD_blind.alignment.offset.y = -10
			G.HUD_blind:recalculate(false)

			SMODS.calculate_context({ setting_blind = true, blind = G.P_BLINDS[hpot_combat.blind_key] })
			delay(0.4)

			G.E_MANAGER:add_event(Event({
				trigger = "immediate",
				func = function()
					G.STATE = G.STATES.DRAW_TO_HAND
					G.deck:shuffle("hpot_nr" .. G.GAME.round_resets.ante)
					G.deck:hard_set_T()
					G.STATE_COMPLETE = false
					return true
				end,
			}))
			return true
		end,
	}))
end

local old_calc = TheEncounter.current_mod.calculate or function() end
TheEncounter.current_mod.calculate = function(self, context)
	if G.GAME.blind and G.GAME.blind.effect.hpot_combat then
		local effect = G.GAME.blind.effect.hpot_combat.blind_effect
		if effect then
			if context.setting_blind then
				if effect.change_size then
					G.GAME.blind.chips = G.GAME.blind.chips * effect.change_size
					G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
				end

				if effect.total_hands or effect.hands then
					G.E_MANAGER:add_event(Event({
						func = function()
							ease_hands_played(
								(effect.total_hands and (-G.GAME.current_round.hands_left + effect.total_hands) or 0)
									+ (effect.hands or 0)
							)
							return true
						end,
					}))
				end

				if effect.total_discards or effect.discards then
					G.E_MANAGER:add_event(Event({
						func = function()
							ease_discard(
								(
									effect.total_discards
										and (-G.GAME.current_round.discards_left + effect.total_discards)
									or 0
								) + (effect.discards or 0)
							)
							return true
						end,
					}))
				end

				effect.hpot_hands = {}
				for _, poker_hand in ipairs(G.handlist) do
					effect.hpot_hands[poker_hand] = false
				end
			end

			if context.debuff_card and effect.debuff then
				if context.debuff_card.area == G.jokers then
					if effect.debuff.jokers then
						return {
							debuff = true,
						}
					end
				else
					if effect.debuff.suit and context.debuff_card:is_suit(effect.debuff.suit, true) then
						return {
							debuff = true,
						}
					end
					if effect.debuff.face and context.debuff_card:is_face(true) then
						return {
							debuff = true,
						}
					end
					if effect.debuff.played_this_ante and context.debuff_card.ability.played_this_ante then
						return {
							debuff = true,
						}
					end
					if effect.debuff.rank and context.debuff_card.base.value == effect.debuff.rank then
						return {
							debuff = true,
						}
					end
				end
			end

			if
				context.debuff_hand
				and (effect.debuff or effect.set_to_zero or effect.one_hand_type or effect.no_repeat_hands)
			then
				local set_to_zero = false
				local debuff = false
				if context.scoring_name == G.GAME.current_round.most_played_poker_hand then
					if effect.set_to_zero and effect.set_to_zero.most_played_hand then
						set_to_zero = true
					end
					if effect.debuff and effect.debuff.most_played_hand then
						debuff = true
					end
				end
				if effect.set_to_zero and context.scoring_name == effect.set_to_zero.scoring_name then
					set_to_zero = true
				end
				if effect.debuff and context.scoring_name == effect.debuff.scoring_name then
					debuff = true
				end
				if effect.no_repeat_hands then
					if effect.hpot_hands[context.scoring_name] then
						debuff = true
					end
					if not context.check then
						effect.hpot_hands[context.scoring_name] = true
					end
				end
				if effect.one_hand_type then
					if effect.hpot_only_hand and effect.hpot_only_hand ~= context.scoring_name then
						return {
							debuff = true,
						}
					end
				end

				if not context.check then
					effect.hpot_only_hand = context.scoring_name
				end
				if set_to_zero then
					if not context.check then
						if effect.set_to_zero.dollars then
							ease_dollars(math.min(0, -G.GAME.dollars), true)
						end
						if effect.set_to_zero.plincoins then
							ease_plincoins(math.min(0, -G.GAME.plincoins), true)
						end
						if effect.set_to_zero.credits then
							HPTN.ease_credits(
								math.min(
									0,
									G.GAME.seeded and -G.GAME.budget or -G.PROFILES[G.SETTINGS.profile].TNameCredits
								),
								true
							)
						end
						if effect.set_to_zero.sparkle then
							ease_spark_points(math.min(0, -G.GAME.spark_points), true)
						end
						if effect.set_to_zero.crypto then
							ease_cryptocurrency(math.min(0, -G.GAME.cryptocurrency), true)
						end
					end
				end
				if debuff then
					return {
						debuff = true,
					}
				end
			end

			if context.stay_flipped and context.to_area == G.hand and effect.flipped then
				if effect.flipped.suit and context.other_card:is_suit(effect.flipped.suit, true) then
					return {
						stay_flipped = true,
					}
				end
				if effect.flipped.face and context.other_card:is_face(true) then
					return {
						stay_flipped = true,
					}
				end
				if effect.flipped.played_this_ante and context.other_card.ability.played_this_ante then
					return {
						stay_flipped = true,
					}
				end
				if
					effect.flipped.first_hand
					and G.GAME.current_round.hands_played == 0
					and G.GAME.current_round.discards_used == 0
				then
					return {
						stay_flipped = true,
					}
				end
			end

			if context.modify_hand then
				if effect.base_score_halved then
					mult = mod_mult(math.max(math.floor(mult * 0.5 + 0.5), 1))
					hand_chips = mod_chips(math.max(math.floor(hand_chips * 0.5 + 0.5), 0))
					update_hand_text({ sound = "chips2", modded = true }, { chips = hand_chips, mult = mult })
				end
			end
		end
		local reward = G.GAME.blind.effect.hpot_combat.blind_reward
		if context.blind_defeated then
			if reward.jokers then
				for _, joker in ipairs(reward.jokers) do
					for i = 1, (joker.amount or 1) do
						if
							not joker.need_room or (#G.jokers.cards + G.GAME.joker_buffer < G.jokers.config.card_limit)
						then
							SMODS.add_card({
								set = "Joker",
								rarity = joker.rarity,
								edition = joker.edition,
								no_edition = joker.no_edition,
								stickers = joker.stickers,
								key_append = joker.key_append or "hpot_combat_reward",
								key = joker.key,
								area = G.jokers,
							})
						end
					end
				end
			end

			if reward.consumables then
				for _, consumable in ipairs(reward.consumables) do
					for i = 1, (consumable.amount or 1) do
						if
							not consumable.need_room
							or (#G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit)
						then
							SMODS.add_card({
								set = consumable.set,
								edition = consumable.edition,
								key_append = consumable.key_append or "hpot_combat_reward",
								key = consumable.key,
								area = G.consumeables,
							})
						end
					end
				end
			end

			if reward.tags then
				G.GAME.orbital_choices = G.GAME.orbital_choices or {}
				G.GAME.orbital_choices[G.GAME.round_resets.ante] = G.GAME.orbital_choices[G.GAME.round_resets.ante]
					or {}

				if not G.GAME.orbital_choices[G.GAME.round_resets.ante]["Small"] then
					local _poker_hands = {}
					for k, v in pairs(G.GAME.hands) do
						if SMODS.is_poker_hand_visible(k) then
							_poker_hands[#_poker_hands + 1] = k
						end
					end

					G.GAME.orbital_choices[G.GAME.round_resets.ante]["Small"] =
						pseudorandom_element(_poker_hands, "orbital")
				end
				for _, tag_key in ipairs(reward.tags.keys or {}) do
					add_tag(Tag(tag_key, false, "Small"))
				end
				if reward.tags.random_amount then
					local tag_pool = get_current_pool("Tag")
					for i = 1, reward.tags.random_amount do
						local selected_tag = pseudorandom_element(tag_pool, "hpot_combat_reward")
						local it = 1
						while selected_tag == "UNAVAILABLE" do
							it = it + 1
							selected_tag = pseudorandom_element(tag_pool, "hpot_combat_reward_resample" .. it)
						end
						add_tag(Tag(selected_tag, false, "Small"))
					end
				end
			end

			if reward.vouchers then
				local vouchers_to_redeem = {}
				for _, voucher_key in ipairs(reward.vouchers.keys or {}) do
					vouchers_to_redeem[#vouchers_to_redeem + 1] = voucher_key
				end
				if reward.vouchers.random_amount then
					local voucher_pool = get_current_pool("Voucher")
					for i = 1, reward.vouchers.random_amount do
						local selected_voucher = pseudorandom_element(voucher_pool, "modprefix_seed")
						local it = 1
						while selected_voucher == "UNAVAILABLE" do
							it = it + 1
							selected_voucher = pseudorandom_element(voucher_pool, "modprefix_seed" .. it)
						end
						vouchers_to_redeem[#vouchers_to_redeem + 1] = selected_voucher
					end
				end
				for _, voucher_key in ipairs(vouchers_to_redeem) do
					local voucher_card = SMODS.create_card({ area = G.play, key = voucher_key })
					voucher_card:start_materialize()
					voucher_card.cost = 0
					G.play:emplace(voucher_card)
					delay(0.8)
					voucher_card:redeem()

					G.E_MANAGER:add_event(Event({
						trigger = "after",
						delay = 0.5,
						func = function()
							voucher_card:start_dissolve()
							return true
						end,
					}))
				end
			end

			if reward.playing_cards then
				for _, pcard in ipairs(reward.playing_cards) do
					for i = 1, (pcard.amount or 1) do
						-- TODO: account for modded ranks I guess
						local rank = pcard.rank
							or (pcard.face and pseudorandom_element(
								{ "King", "Queen", "Jack" },
								"hpot_event_combat_reward"
							))
							or (pcard.numbered and tostring(pseudorandom("hpot_event_combat_reward", 2, 10)))
						SMODS.add_card({
							set = (pcard.enhanced and "Enhanced") or (pcard.base and "Base") or "Playing Card",
							edition = pcard.edition,
							stickers = pcard.stickers,
							enhancement = pcard.enhancement,
							key_append = pcard.key_append or "hpot_combat_reward",
							rank = rank,
							suit = pcard.suit,
							seal = pcard.seal,
							area = G.deck,
						})
					end
				end
			end

			if reward.enhance_deck then
				for _, mod in ipairs(reward.enhance_deck) do
					local amount = mod.amount or 1
					local valid_cards = {}
					local chosen_cards = {}
					local conditions = mod.conditions or {}

					for _, pcard in ipairs(G.playing_cards) do
						local valid = true
						if conditions.suits then
							local has_suit = false
							for _, suit in ipairs(conditions.suits) do
								if pcard:is_suit(suit) then
									has_suit = true
									break
								end
							end
							if not has_suit then
								valid = false
							end
						end
						if valid and conditions.ranks then
							local has_rank = false
							for _, rank in ipairs(conditions.ranks) do
								if pcard.base.value == rank then
									has_rank = true
									break
								end
							end
							if not has_rank then
								valid = false
							end
						end
						if valid and conditions.no_enhancement then
							if pcard.ability.set == "Enhanced" then
								valid = false
							end
						end
						if valid and conditions.no_edition then
							if pcard.edition then
								valid = false
							end
						end
						if valid and conditions.no_seal then
							if pcard.seal then
								valid = false
							end
						end
						if valid then
							valid_cards[#valid_cards + 1] = pcard
						end
					end

					for i = 1, amount do
						local chosen = pseudorandom_element(valid_cards, "hpot_event_combat_reward")
						chosen_cards[#chosen_cards + 1] = chosen
					end

					for _, pcard in ipairs(chosen_cards) do
						if mod.change_base then
							-- TODO: account for modded ranks I guess
							local rank = mod.change_base.rank
								or (mod.change_base.face and pseudorandom_element(
									{ "King", "Queen", "Jack" },
									"hpot_event_combat_reward"
								))
								or (
									mod.change_base.numbered
									and tostring(pseudorandom("hpot_event_combat_reward", 2, 10))
								)
							assert(SMODS.change_base(pcard, mod.change_base.suit, rank))
						end
						if mod.edition then
							pcard:set_edition(mod.edition)
						end
						if mod.enhancement then
							pcard:set_ability(mod.enhancement)
						end
						if mod.seal then
							pcard:set_seal(mod.seal)
						end
					end
				end
			end

			if reward.dollars then
				ease_dollars(reward.dollars)
			end
			if reward.level_up_hand then
				SMODS.smart_level_up_hand(nil, reward.level_up_hand.key, nil, reward.level_up_hand.amount)
			end
		end
	end
	return old_calc(self, context)
end

TheEncounter.Domain({
	key = "combat",
	loc_txt = {
		name = "Combat",
		text = {
			"Face the difficult foe",
		},
	},

	atlas = "map_icons",
	pos = MAP.UI.ICONS.pos.enemy,

	can_repeat = true,

	reward = 2,

	colour = HEX("D60000"),
	background_colour = HEX("A50000"),
})
TheEncounter.Domain({
	key = "encounter",
	loc_txt = {
		name = "Encounter",
		text = {
			"Face the difficult challenge",
		},
	},

	atlas = "map_icons",
	pos = MAP.UI.ICONS.pos.enemy,

	can_repeat = true,

	reward = 4,

	colour = HEX("AE0202"),
	background_colour = HEX("900000"),

	setup = function(self, event)
		event.ability.extra.is_encounter = true
		event.ability.extra.blind = hpot_event_get_random_boss()
	end,
})
TheEncounter.Scenario({
	key = "tavern",
	starting_step_key = "st_map_tavern_start",
	loc_txt = {
		name = "Tavern",
		text = {
			"You think you can be in this part of town",
			"looking all cool? Yes, you can.",
		},
	},

	domains = {
		do_map_combat = true,
		do_map_encounter = true,
	},

	colour = HEX("D60000"),
	background_colour = HEX("A50000"),

	map_credits = {
		code = { "N'" }
	}
})
TheEncounter.Step({
	key = "tavern_start",
	loc_txt = {
		text = {
			'"This person over here thinks they\'re so tough."',
			" ",
			'"Really? Let\'s see you beat this!"',
			" ",
			"Face {C:attention}#1#{} #2#",
			"{C:money}Reward:{} #3#",
			"{C:inactive}(Regular Blind rewards are also obtained){}",
		},
	},
	config = {
		hide_hand = true,
		hide_image = true,
	},
	setup = function(self, event)
		event.ability.extra.effect = hpot_event_get_random_combat_effect()
		event.ability.extra.reward = hpot_event_get_random_combat_reward(event.ability.extra.is_encounter)
	end,
	loc_vars = function(self, info_queue, event)
		return {
			vars = {
				localize({ type = "name_text", key = event.ability.extra.blind or "bl_big", set = "Blind" }),
				event.ability.extra.effect.text or "",
				event.ability.extra.reward.text or "",
			},
		}
	end,

	get_choices = function(self, event)
		return {
			"ch_map_tavern_fight",
			"ch_map_move_on",
		}
	end,
})
TheEncounter.Choice({
	key = "tavern_fight",
	loc_txt = {
		name = { "Fight!" },
	},
	button = function(self, event)
		event:finish_scenario(function()
			hpot_start_additional_round(event)
		end)
	end,
})

