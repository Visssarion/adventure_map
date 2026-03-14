local mod_path = "" .. SMODS.current_mod.path

assert(SMODS.load_file("globals.lua"))()

MAP.mod = SMODS.current_mod

-- Adding a new state
G.STATES.ADVENTURE_MAP = 2081

local function is_lua_path(path)
    return string.sub(path, -4) == ".lua"
end


local function folder_load(mod_path, folder) 
	local files = NFS.getDirectoryItems(mod_path .. folder)
	for _, file in ipairs(files) do
		if is_lua_path(file) then
			print("[ADVENTURE_MAP] Loading lua file " .. file)
			local f, err = SMODS.load_file(folder.."/" .. file)
			if err then
				error(err) 
			end
			f()
		end
	end
end

local function recursive_load(mod_path, folder, fileTree)
	local filesTable = SMODS.NFS.getDirectoryItems(mod_path..folder)
	for i,v in ipairs(filesTable) do
		local file = folder.."/"..v
		local info = SMODS.NFS.getInfo(mod_path..file)
		if info then
			if info.type == "file" and is_lua_path(file) then
				local f, err = SMODS.load_file(file)
				if err then
					error(err) 
				end
				f()
				fileTree = fileTree.."\n"..file
			elseif info.type == "directory" and SMODS.NFS.getInfo(mod_path..file.."/.loadignore") == nil then
				--fileTree = fileTree.."\n"..file.." (DIR)"
				fileTree = recursive_load(mod_path, file, fileTree)
			end
		end
	end
	return fileTree
end


folder_load(mod_path, "base")
folder_load(mod_path, "items")
folder_load(mod_path, "ui")
folder_load(mod_path, "state")

print(recursive_load(mod_path, 'scenarios', "[ADVENTURE_MAP] Loading LUA:"))

print("[ADVENTURE_MAP] Stopped Loading")




SMODS.current_mod.calculate = function(self, context)
	if context.beat_boss and context.end_of_round and context.main_eval then
		if G.GAME.combat_event then
		else
			MAP.MapManager.generate_new_map()
		end
	end
	if context.tag_triggered then
		G.GAME.tags_used = G.GAME.tags_used + 1
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
		G.GAME.tags_used = 0

	end
end

SMODS.Atlas{
	key = "modicon",
	path = "icon.png",
	px=34,
	py=34
}