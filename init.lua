-- (C) 2016 Tai "DuCake" Kedzierski

-- This program is Free Software, you can modify and redistribute it as long as
-- that you provide the same rights to whomever you provide the original or
-- modified version of the software to, and provide the source to whomever you
-- distribute the software to.
-- Released under the terms of the GPLv3


local bbattle = {}

bbattle.radius = tonumber(minetest.setting_get("buildbattle.radius") ) or 7

local is_in_bbfield = function(pos)
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
		for key,value in paris(name) do
			newnames[key] = battlefy(value)
		end
		return newnames
	else
		return name
	end
			
end

local function deepclone (t) -- deep-copy a table -- from https://gist.github.com/MihailJP/3931841
	if type(t) ~= "table" then return t end

	local meta = getmetatable(t)
	local target = {}
	
	for k, v in pairs(t) do
		if k ~= "__index" and type(v) == "table" then -- omit circular reference
			target[k] = deepclone(v)
		else
			target[k] = v
		end
	end
	setmetatable(target, meta)
	return target
end 

minetest.register_on_placenode( function(pos, newnode, placer, oldnode, itemstack, pointed_thing)
	local node = newnode.name
	if not node:find("build_battle:") then return end

	if not is_in_bbfield(pos) then
		minetest.chat_send_player(placer:get_player_name(),node.." can only be placed in a Build Battle Arena!")
		minetest.swap_node(pos,{name = oldnode.name})
		return true
	end
end
)

for node,olddef in pairs(minetest.registered_nodes) do
	if not node:find("build_battle:") then
		local def = deepclone(olddef)
		local oldonpplace = def.on_place
		def.drops = battlize(def.drops)
		def.description = def.description.." +"
		node = battlize(node)

		if def.groups == nil then def.groups = {} end
		def.groups.not_in_creative_inventory = 1
		minetest.register_node(node,def)
	end
end

minetest.register_node("build_battle:marker", {
	description = "Build Battle Marker",
	tiles = {"default_stone.png^default_tool_diamondsword.png"},
	groups = {cracky = 3}
})

minetest.register_privilege("bbattle_moderator","Lookup build battle blocks")
minetest.register_chatcommand("bbsearch",{
	privs = "bbattle_moderator",
	func = function(player,paramlist)
		local piterator = paramlist:gmatch("%S+")
		local paramt = {}
		while true do
			local param = piterator()
			if param ~= nil then
				paramt[#paramt+1] = param
			else
				break
			end
		end
		for node,def in pairs(minetest.registered_nodes) do
			if node:find("build_battle:") then
				local found = true
				for _,param in pairs(paramt) do
					if not node:find(param) then
						found = false
					end
					if not found then break end
				end
				if found then minetest.chat_send_player(player,"-> "..node) end
			end
		end
	end,
})
