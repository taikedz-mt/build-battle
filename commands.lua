minetest.register_privilege("bbattler","Access build battle commands")

local giveplayer = function(playername,itemdef)
	local theitem = minetest.registered_nodes[itemdef.name]
	if not theitem then
		minetest.chat_send_player(playername,"No such item! Try using /bbsearch to find an item name")
		return
	end
	if itemdef.name == "build_battle:marker" then return end

	local user = minetest.get_player_by_name(playername)

	local inventory = user:get_inventory()
	for idx,x in pairs(inventory:get_list("main") ) do
		if itemdef.count < 1 then break end

		if x:get_name() == "" or x:get_name() == itemdef.name then
			local count = x:get_count() + itemdef.count
			if count > 99 then
				itemdef.count = count - 99
				count = 99
			else
				itemdef.count = 0
			end
			x:set_count(count)
			x:set_name(itemdef.name)
			inventory:set_stack("main",idx,x)
		end
	end

end

minetest.register_chatcommand("bbgiveme",{
	privs = "bbattler",
	func = function(playername,paramlist)
		local piterator = paramlist:gmatch("%S+")
		local item = {}
		item.count = 1

		local param = piterator()
		if param ~= nil then
			item.name = param
		else
			minetest.chat_send_player(playername,"No item specified")
			return
		end
		
		param = piterator()
		if param ~= nil then
			if param:match("^[0-9]+$") then
				item.count = tonumber(param)
			else
				minetest.chat_send_player(playername,"Not a number ".. param)
				return
			end
		end

		if not item.name:find("build_battle:") then
			item.name = "build_battle:".. item.name -- allow shorthands
		end
		giveplayer(playername,item)
	end,
})

minetest.register_chatcommand("bbsearch",{
	privs = "bbattler",
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
			if node:find("build_battle:") and node ~= "build_battle:marker" then
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
