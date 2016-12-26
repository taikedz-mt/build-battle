local bbook = {}
local playerpage = {}
local playerlastsearch = {}

local thebook = "build_battle:book"

local function drill_image(item)
	if type(item) == "string" then
		return item
	else
		if item.name then
			return item.name
		end
	end
	return nil
end

local function generate_form(player,searchterm)
	local playername = player:get_player_name()
	if not searchterm then
		searchterm = ""
		playerpage[playername] = 1
	else
		if searchterm ~= playerlastsearch[playername] then
			playerpage[playername] = 1
		end
	end
	playerlastsearch[playername] = searchterm

	-- results display size
	local width = 12
	local height = 7
	local pagesize = width*height

	formspeccer:clear(thebook)
	formspeccer:newform(thebook,"12,10")

	formspeccer:add_field(thebook,{
		xy = "3,1",
		wh = "5,1",
		name = "searchterm",
		label = "Search:",
		value = searchterm,
	})

	formspeccer:add_button(thebook,{
		xy = "8,0.65",
		wh = "2,1",
		name = "label",
		label = "Search"
	},
	true)

	formspeccer:add_button(thebook,{
		xy = "5,9",
		wh = "2,1",
		name = "exit",
		value = "OK",
		label = "Quit",
	},
	true) -- is exit button

	local searchresult = {}
	if searchterm ~= "" then
		searchresult = bbattle:searchitem(searchterm)
	end

	if #searchresult > 0 then -- TODO - make multi-page results
		local skip = ( playerpage[playername] - 1 ) * pagesize
		local reachedend = false

		for i=0+skip,skip+pagesize-1 do -- build out buttons
			idx = i+1
			if searchresult[idx] then
				local x = i % width
				local y = math.floor((i - i % width) / width ) % height +2

				formspeccer:add_item_button(thebook,{
					xy = x..","..y,
					wh = "1,1",
					name = searchresult[idx],
					label = "",
					item_name = searchresult[idx],
				})
			else
				reachedend = true
			end
		end

		formspeccer:add_label(thebook,{
			xy = "7,9",
			wh = "2,1",
			name = "label",
			value = "Page "..tostring(playerpage[playername]),
			label = "Page "..tostring(playerpage[playername]),
		})

		if playerpage[playername] > 1 then
			formspeccer:add_button(thebook,{
				xy = "1,9",
				wh = "2,1",
				name = "prev",
				value = "<",
				label = " << ",
			},true)
		end

		if not reachedend then
			formspeccer:add_button(thebook,{
				xy = "3,9",
				wh = "2,1",
				name = "next",
				value = ">",
				label = " >> ",
			},true)
		end

	else
		formspeccer:add_label(thebook,{
			xy = "1,3",
			wh = "7,1",
			name = "label",
			value = "Nothing to display",
			label = "Nothing to display",
		})
	end


	minetest.after(0,function()
		formspeccer:show(player,thebook)
	end)
end

minetest.register_on_player_receive_fields(function(player,formname,fields)
	local playername = player:get_player_name()
	if formname ~= thebook then
		return
	end

	if fields.quit and fields.searchterm and not fields.exit then
		if fields.prev then
			if playerpage[playername] > 1 then
				playerpage[playername] = playerpage[playername] - 1
			end
		end
		if fields.next then
			playerpage[playername] = playerpage[playername] + 1
		end
		generate_form(player, fields.searchterm)
	else
		local giveitem = nil
		for key,value in pairs(fields) do
			if key:find("build_battle:") then
				giveitem = key
				break
			end
		end
		if giveitem then
			minetest.debug("Giving "..giveitem)
			minetest.chat_send_player(playername, "Giving "..giveitem)
			bbattle.giveplayer(playername, {name=giveitem, count = 99})
		end
	end

	return true
end)

minetest.register_craftitem("build_battle:book",{
	on_use = function(itemstack, player, pointed_thing)
		generate_form(player)
	end,
	description = "Build Battle Book",
	inventory_image = "build_battle_book.png",
	stack_max = 1,
})
