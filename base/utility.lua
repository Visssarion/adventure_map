function print_event_queue(queue)
    queue = queue or G.E_MANAGER.queues.base
    for index, event in ipairs(queue) do
        print(index)
        print(inspectFunction(event.func))
        print(event)
    end
end



-- CREDITS SYSTEM
--#region Card Credits System
local smcmb = SMODS.create_mod_badges
function SMODS.create_mod_badges(obj, badges)
	smcmb(obj, badges)
	if not SMODS.config.no_mod_badges and obj and obj.map_credits then
		local function calc_scale_fac(text)
			local size = 0.9
			local font = G.LANG.font
			local max_text_width = 2 - 2 * 0.05 - 4 * 0.03 * size - 2 * 0.03
			local calced_text_width = 0
			-- Math reproduced from DynaText:update_text
			for _, c in utf8.chars(text) do
				local tx = font.FONT:getWidth(c) * (0.33 * size) * G.TILESCALE * font.FONTSCALE
					+ 2.7 * 1 * G.TILESCALE * font.FONTSCALE
				calced_text_width = calced_text_width + tx / (G.TILESIZE * G.TILESCALE)
			end
			local scale_fac = calced_text_width > max_text_width and max_text_width / calced_text_width or 1
			return scale_fac
		end
		if obj.map_credits.art or obj.map_credits.code or obj.map_credits.idea or obj.map_credits.made or obj.map_credits.help or obj.map_credits.rewrite or obj.map_credits.custom then
			local scale_fac = {}
			local min_scale_fac = 1
			local strings = { MAP.mod.display_name }
			for _, v in ipairs({ "idea", "art", "code", "made", "help", "rewrite" }) do
				if obj.map_credits[v] then
					if type(obj.map_credits[v]) == "string" then obj.map_credits[v] = { obj.map_credits[v] } end
					for i = 1, #obj.map_credits[v] do
						strings[#strings + 1] =
							localize({ type = "variable", key = "map_" .. v, vars = { obj.map_credits[v][i] } })
							[1]
					end
				end
			end
			if obj.map_credits.custom then
				strings[#strings + 1] = localize({ type = "variable", key = obj.map_credits.custom.key, vars = { obj.map_credits.custom.text } })
			end
			for i = 1, #strings do
				scale_fac[i] = calc_scale_fac(strings[i])
				min_scale_fac = math.min(min_scale_fac, scale_fac[i])
			end
			local ct = {}
			for i = 1, #strings do
				ct[i] = {
					string = strings[i],
				}
			end
			for i = 1, #badges do
				if badges[i].nodes[1].nodes[2].config.object.string == MAP.mod.display_name then --this was meant to be a hex code but it just doesnt work for like no reason so its hardcoded
					badges[i].nodes[1].nodes[2].config.object:remove()
					badges[i] = {
                        n = G.UIT.R,
                        config = { align = "cm" },
                        nodes = {
                            {
                                n = G.UIT.R,
                                config = {
                                    align = "cm",
                                    colour = MAP.mod.badge_colour,
                                    r = 0.1,
                                    minw = 2 / min_scale_fac,
                                    minh = 0.36,
                                    emboss = 0.05,
                                    padding = 0.03 * 0.9,
                                },
                                nodes = {
                                    { n = G.UIT.B, config = { h = 0.1, w = 0.03 } },
                                    {
                                        n = G.UIT.O,
                                        config = {
                                            object = DynaText({
                                                string = ct or "ERROR",
                                                colours = { obj.map_credits and obj.map_credits.text_colour or G.C.WHITE },
                                                silent = true,
                                                float = true,
                                                shadow = true,
                                                offset_y = -0.03,
                                                spacing = 1,
                                                scale = 0.33 * 0.9,
                                            }),
                                        },
                                    },
                                    { n = G.UIT.B, config = { h = 0.1, w = 0.03 } },
                                },
                            },
                        },
                    }
					break
				end
			end
		end
	end
end

--#endregion
