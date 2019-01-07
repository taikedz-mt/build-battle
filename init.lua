-- (C) 2016 Tai "DuCake" Kedzierski

-- This program is Free Software, you can modify and redistribute it as long as
-- that you provide the same rights to whomever you provide the original or
-- modified version of the software to, and provide the source to whomever you
-- distribute the software to.
-- Released under the terms of the GPLv3

local default_mods = {
    "default",
    --"butterflies", -- not in older default game
    "flowers",
    "bones",
    "beds",
    "doors",
    "fire",
    "farming",
    "stairs",
    "farming",
    "stairs",
    "vessels",
    "walls",
    "wool",
    "xpanes",
    "moreblocks",
}

local function stringjoin(t, sep)
    local final = ""
    for _,v in ipairs(t) do
        final = final..","..v
    end
    minetest.debug(final:sub(2))
    return final:sub(2)
end

bbattle = {}

bbattle.radius = tonumber(minetest.settings:get("buildbattle.radius") ) or 16

bbattle.mods = minetest.settings:get("buildbattle.mods") or stringjoin(default_mods,",")
bbattle.forbidden = minetest.settings:get("buildbattle.forbidden") or ""

bbattle.mods = bbattle.mods:split(",")
bbattle.forbidden = bbattle.forbidden:split(",")

local notify_failures = minetest.settings:get_bool("buildbattle.report_registration_failures")
local allow_hidden_inventory = minetest.settings:get_bool("buildbattle.allow_hidden_inventory")
local require_all = minetest.settings:get_bool("buildbattle.require_all")

dofile(minetest.get_modpath("build_battle").."/forceloads.lua")

-- Groups to copy over from original block to BB block
-- All blocks become 'oddly_breakable_by_hand' unless 'dig_immediate' is on the original block
local allowed_groups = {
        'attached_node',
        'dig_immediate',
}

local function is_in_array(item,array)
    for k,v in pairs(array) do
        if v == item then
            return true
        end
    end
    return false
end

bbattle.is_in_bbfield = function(pos)
    local mcount = minetest.find_nodes_in_area(
    {x=pos.x-bbattle.radius,y=pos.y-bbattle.radius,z=pos.z-bbattle.radius},
    {x=pos.x+bbattle.radius,y=pos.y+bbattle.radius,z=pos.z+bbattle.radius},
    {"build_battle:marker"}
    )

    return #mcount > 0
end


local battlefy = function(name)
    return "build_battle:"..name:gsub(":","_")
end

local battlize = function(name)
    if type(name) == "string" then
        return battlefy(name)
    elseif type(name) == "table" then
        local newnames = {}
        for key,value in pairs(name) do
            newnames[#newnames+1] = battlefy(key)
        end
        return newnames
    else
        return name
    end
            
end

local function deepclone (t) -- deep-copy a table -- from https://gist.github.com/MihailJP/3931841
    if type(t) ~= "table" then return t end

    local target = {}
    
    for k, v in pairs(t) do
        if k ~= "__index" and type(v) == "table" then -- omit circular reference
            target[k] = deepclone(v)
        elseif k == "__index" then
            target[k] = target -- own circular reference, not reference to original object!
        else
            target[k] = v
        end
    end
    return target
end 

local function sanitize_groups(def)
        local newdef = {}
        if not def then return {} end

        for _,level in pairs(allowed_groups) do
                newdef[level] = def[level]
        end

        -- Always easy to break by hand - this is a mini creative mode.
        newdef['dig_immediate'] = 3

        return newdef
end

local function mark_forceload(pos, nodename)
    minetest.debug("Checking forceload "..nodename)
    if nodename == "build_battle:marker" and bbattle.radius > 32 then -- FIXME this should be congruent with the server setting for active block send range
        minetest.debug("Registering forceload on "..nodename.." at "..minetest.pos_to_string(pos))
        bbattle.register_forceload(pos)
    end
end

local function nullify(def)
    for _,k in pairs({
        "formspec",
        "on_place", -- Defining on_place prevents on_placenode handlers from being called, which are needed to check for marker
        "on_rightclick",
        "drop",
        "on_construct",
        "on_destruct",
        "after_destruct",
        "on_flood",
        "preserve_metadata",
        "after_place_node",
        "after_dig_node",
        "can_dig",
        "on_punch",
        "on_dig",
        "on_timer",
        "on_use",
        "on_receive_fields",
        "allow_metadata_inventory_move",
        "allow_metadata_inventory_put",
        "allow_metadata_inventory_take",
        "on_metadata_inventory_move",
    }) do
        def[k] = nil
    end

    -- Prevent from being affected by TNT
    def.on_blast = function() end

    return def
end

local function check_mods_loaded()
    local modname,_
    local all_mods_loaded = true
    for _,modname in ipairs(bbattle.mods) do

        if require_all and not minetest.get_modpath(modname) then
            minetest.log("error", "Build Battle: add mod or mod dependency: "..modname)
            all_mods_loaded = false
        end
    end

    return all_mods_loaded
end

--    Active Script Commences

if not check_mods_loaded() then
    minetest.log("error", "Dependencies were not met - aborting Build Battle registrations")
    return
end

minetest.register_on_placenode( function(pos, newnode, placer, oldnode, itemstack, pointed_thing)
    local node = newnode.name
    if not node:find("build_battle:") then return end

    mark_forceload(pos, node)

    if not bbattle.is_in_bbfield(pos) then
        minetest.chat_send_player(
            placer:get_player_name(),
            node.." can only be placed in a Build Battle Arena!"
            )
        minetest.swap_node(pos,{name = oldnode.name})
        return true
    end
end
)

local function should_register(oldnode, olddef, nodeparts)
    return (not oldnode:find("build_battle:")
        and is_in_array(nodeparts[1],bbattle.mods)
        and not is_in_array(oldnode,bbattle.forbidden)
        and not (                                       -- DISALLOW if
            olddef.groups
            and olddef.groups.not_in_creative_inventory -- CREATIVE denied
            and not allow_hidden_inventory              -- and CREATIVE override denied
        )
)

end

for oldnode,olddef in pairs(minetest.registered_nodes) do
    local nodeparts = oldnode:split(":")
    if should_register(oldnode, olddef, nodeparts) then
        
        local node = battlize(oldnode)
        local def = deepclone(olddef)

        def.drop = node
        local desc = def.description or "("..oldnode..")"
        def.description = desc.." +"
        
        if def.liquid_alternative_flowing or def.liquid_alternative_source then
            def.liquid_alternative_flowing = node:gsub("_source","_flowing")
            def.liquid_alternative_source = node:gsub("_flowing","_source")
        end

        def.groups = sanitize_groups(def.groups)
        def.groups.not_in_creative_inventory = 1

        def = nullify(def)

        minetest.register_node(node,def)
        if not minetest.registered_nodes[node] and notify_failures then
            minetest.debug("BB - Failed to register "..node) -- use "info" log level, as "error" level would get sent to clients
        end
    end
end

if notify_failures then
    minetest.after(0,function()
        for oldnode,olddef in pairs(minetest.registered_nodes) do
            local nodeparts = oldnode:split(":")
            if should_register(oldnode, olddef, nodeparts) then
                local battlenode = battlize(oldnode)

                if not minetest.registered_nodes[battlenode] then
                    minetest.debug("Build Battle ---- "..battlenode.." failed registration!")
                end
            end
        end
    end)
end

minetest.register_node("build_battle:marker", {
    description = "Build Battle Marker",
    tiles = {"default_stone.png^default_tool_diamondsword.png"},
    groups = {unbreakable = 1}
})

dofile(minetest.get_modpath("build_battle").."/api.lua")
dofile(minetest.get_modpath("build_battle").."/buildbook.lua")
dofile(minetest.get_modpath("build_battle").."/areas.lua")
