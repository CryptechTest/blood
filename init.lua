dofile(minetest.get_modpath("blood") .. "/api.lua")


minetest.register_on_player_hpchange(function(player, hp_change, reason)

	if not minetest.is_player(player) then
		return hp_change
	elseif reason.type == "drown"then
		return hp_change
	elseif reason.from == "mod" and hp_change >= 0 then
		return hp_change
	elseif reason.from == "mod" and reason.hunger == true and hp_change >=0  then
		return hp_change
	elseif hp_change > -2 then
		return hp_change
	end

	blood.do_blood_effects(player, hp_change)
	return hp_change
end, true)
