adventure_map = {}

local mod_path = "" .. SMODS.current_mod.path
adventure_map.path = mod_path
adventure_map_config = SMODS.current_mod.config

assert(SMODS.load_file("globals.lua"))()

-- Adding a new state
G.STATES.ADVENTURE_MAP = 2081

--Load base classes files
local files = NFS.getDirectoryItems(mod_path .. "base")
for _, file in ipairs(files) do
	print("[ADVENTURE_MAP] Loading lua file " .. file)
	local f, err = SMODS.load_file("base/" .. file)
	if err then
		error(err) 
	end
	f()
end


--Load item files
local files = NFS.getDirectoryItems(mod_path .. "items")
for _, file in ipairs(files) do
	print("[ADVENTURE_MAP] Loading lua file " .. file)
	local f, err = SMODS.load_file("items/" .. file)
	if err then
		error(err) 
	end
	f()
end

--Load ui files
local files = NFS.getDirectoryItems(mod_path .. "ui")
for _, file in ipairs(files) do
	print("[ADVENTURE_MAP] Loading lua file " .. file)
	local f, err = SMODS.load_file("ui/" .. file)
	if err then
		error(err) 
	end
	f()
end

--Load state files
local files = NFS.getDirectoryItems(mod_path .. "state")
for _, file in ipairs(files) do
	print("[ADVENTURE_MAP] Loading lua file " .. file)
	local f, err = SMODS.load_file("state/" .. file)
	if err then
		error(err) 
	end
	f()
end


--Load state files
local files = NFS.getDirectoryItems(mod_path .. "scenarios")
for _, file in ipairs(files) do
	print("[ADVENTURE_MAP] Loading lua file " .. file)
	local f, err = SMODS.load_file("scenarios/" .. file)
	if err then
		error(err) 
	end
	f()
end


print("[ADVENTURE_MAP] Stopped Loading")




SMODS.current_mod.calculate = function(self, context)
	if context.beat_boss and context.end_of_round and context.main_eval then
		if G.GAME.combat_event then
		else
			MAP.MapManager.generate_new_map()
		end
	end
end

SMODS.current_mod.reset_game_globals = function(run_start)
	if run_start then
		print(G.STATE)
		print(G.STATE_COMPLETE)
		G.STATE = G.STATES.ADVENTURE_MAP
		G.STATE_COMPLETE = false
		MAP.MapManager.generate_new_map()

		G.GAME.events_visited_total = 0
	end
end
