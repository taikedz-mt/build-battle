
if minetest.get_modpath("areas") then
	if areas.registerHudHandler then

		local function advertise_buildbattle(pos, list)
			if bbattle.is_in_bbfield(pos) then
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
