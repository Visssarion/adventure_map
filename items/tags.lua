SMODS.Atlas({
    key = "map_tags",
    path = "map_tags.png",
    px = 34,
    py = 34
})


SMODS.Tag {
    key = "bigger_map",
    pos = { x = 0, y = 0 },
    atlas = "map_tags",
    config = { extra = { extra_steps = 2 } },
    apply = function(self, tag, context)
        if context.new_map then
            print("im never being called. somehow??")
            context.config.steps = context.config.steps + tag.config.extra.extra_steps
            tag:yep(
                localize("k_bigger_map"),
                G.C.PURPLE
            )
            tag.triggered = true
            
        end
    end,
    loc_vars = function (self, info_queue, tag)
        return {
            vars = {
                tag.config.extra.extra_steps
            }
        }
    end,

    map_credits = {
        made = "vissa",
    },
}



SMODS.Tag:take_ownership('tag_skip', -- object key (class prefix not required)
    { 
    map_credits = {
        made = "vissa",
    },
    loc_vars = function(self, info_queue, tag)
        return { vars = { tag.config.skip_bonus, tag.config.skip_bonus * ((G.GAME.tags_used or 0) + 1) } }
    end,
    apply = function(self, tag, context)
        if context.type == 'immediate' then
            local lock = tag.ID
            G.CONTROLLER.locks[lock] = true
            tag:yep('+', G.C.MONEY, function()
                G.CONTROLLER.locks[lock] = nil
                return true
            end)
            ease_dollars(((G.GAME.tags_used or 0)+1) * tag.config.skip_bonus)
            tag.triggered = true
            return true
        end
    end
    }
)
