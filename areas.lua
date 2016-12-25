
if minetest.get_modpath("areas") then
	if areas.registerHudHandler then

		local function advertise_buildbattle(pos, list)
			local r = bbattle.radius
			local posmin = {x=pos.x-r, y=pos.y-r, z=pos.z-r}
			local posmax = {x=pos.x+r, y=pos.y+r, z=pos.z+r}
			local nodes = minetest.find_nodes_in_area(posmin, posmax, {"build_battle:marker"})
			if #nodes > 0 then
				table.insert(list, {
					id = "Build Battle Zone !",
				} )
			end
		end

		areas:registerHudHandler(advertise_buildbattle)
	else
		minetest.log("info","Your version of `areas` does not support registering hud handlers.")
	end
end
