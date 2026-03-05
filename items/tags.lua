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
    end
}



