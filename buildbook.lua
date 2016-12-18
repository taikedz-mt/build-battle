local bbook = {}

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
	if not searchterm then
		searchterm = ""
	end

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

	if #searchresult > 0 then
		for i=1,8*4 do -- build out buttons
			if searchresult[i] then
				local x = i % 8
				local y = (i - i % 8) / 8 + 3

				formspeccer:add_item_button(thebook,{
					xy = x..","..y,
					wh = "1,1",
					name = "giveitem"..tostring(i),
					label = searchresult[i],
					item_name = searchresult[i],
				})
			end
		end
	else
		formspeccer:add_label(thebook,{
			xy = "1,3",
			wh = "7,1",
			name = "label",
			value = "Nothing to display",
			label = "Nothing here"
		})
	end


	minetest.after(0.2,function()
		formspeccer:show(player,thebook)
	end)
end

minetest.register_on_player_receive_fields(function(player,formname,fields)
	if formname ~= thebook then
		return
	end

	if fields.quit and fields.searchterm and not fields.exit then
		generate_form(player, fields.searchterm)
	else
		local giveitem = nil
		for key,value in pairs(fields) do
			if key:find("giveitem") then
				giveitem = value
				break
			end
		end
		if giveitem then
			minetest.debug("Giving "..giveitem)
			bbattle.giveplayer(player:get_player_name(), {name=giveitem, count = 99})
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
