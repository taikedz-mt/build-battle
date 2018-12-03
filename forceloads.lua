local forceloads_file = minetest.get_worldpath().."/build_battle_forceloads.ser"
local forceloads_data = {}

local function fl_save()
    local serdata = minetest.serialize(forceloads_data)
    if not serdata then
        return
    end
    local file, err = io.open(forceloads_file, "w")
    if err then
        return err
    end
    file:write(serdata)
    file:close()
end

local function fl_load()
    local file, err = io.open(forceloads_file, "r")
    if err then
        minetest.log("info", "[build_battle] could not load forceloads records")
        return
    end
    forceloads_data = minetest.deserialize(file:read("*a"))
    file:close()
end

bbattle.register_forceload = function(pos)
	minetest.forceload_block(pos)
	forceloads_data[minetest.pos_to_string(pos)] = 1
	fl_save()
end

bbattle.unregister_forceload = function(pos)
	minetest.forceload_free_block(pos)
	forceloads_data[minetest.pos_to_string(pos)] = nil
	fl_save()
end

-- Cleanup tool

local function clear_all_nonmarkers(playername)
    for pos_s,_ in pairs(forceloads_data) do
        local pos = minetest.string_to_pos(pos_s)
        local node = minetest.get_node(pos)
        if node.name == "build_battle:marker" or node.name == "ignore" then
            minetest.chat_send_player(playername, "Ignoring "..node.name.." found at "..pos_s)
        else
            bbattle.unregister_forceload(pos)
            minetest.chat_send_player(playername,"Cleared "..node.name.." at "..pos_s)
        end
    end
end

local function show_forceloads(playername)
	minetest.chat_send_player(playername, minetest.serialize(forceloads_data) )
end

local function unload_forceload(playername, pos_s)
    if pos_s == "" then
        clear_all_nonmarkers(playername)
    else
        local pos = minetest.string_to_pos(pos_s)
        if not pos then
            minetest.chat_send_player(playername, "No pos obtained for "..pos_s)
            return
        end
        bbattle.unregister_forceload(pos)
    end
end

minetest.register_chatcommand("bbattle_showfl", {
	description = "Show forceloaded positions",
	func = function(playername, command)
		show_forceloads(playername )
	end
})

minetest.register_chatcommand("bbattle_clearfl", {
	description = "Show forceloaded positions",
	func = function(playername, command)
		unload_forceload(playername, command)
	end
})

-- Initialize

fl_load()
