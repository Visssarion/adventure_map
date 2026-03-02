--- Check out lovely/states.lua for more state logic.

function Game:update_adventure_map(dt)
    -- Vanilla functions. Wish i knew what they did.
    if self.buttons then self.buttons:remove(); self.buttons = nil end
    if self.shop then self.shop:remove(); self.shop = nil end
        

    if not G.STATE_COMPLETE then
        stop_use()
        ease_background_colour_blind(G.STATES.BLIND_SELECT) -- TODO maybe change this to other color?
        
        G.STATE_COMPLETE = true
        G.CONTROLLER.interrupt.focus = true
        
        MAP.UI.render_map()

        G.E_MANAGER:add_event(Event({ func = function()
                    save_run()
                return true end}))
    end     
end
