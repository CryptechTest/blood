blood = {}
local hud = {}
local last_damage_time = {}

-- custom particle effects
local function effect(pos, amount, texture, min_size, max_size, radius, gravity, glow, fall)

	radius = radius or 2
	min_size = min_size or 0.5
	max_size = max_size or 1
	gravity = gravity or -10
	glow = glow or 0

	if fall == true then
		fall = 0
	elseif fall == false then
		fall = radius
	else
		fall = -radius
	end

	minetest.add_particlespawner({
		amount = amount,
		time = 0.25,
		minpos = pos,
		maxpos = pos,
		minvel = {x = -radius, y = fall, z = -radius},
		maxvel = {x = radius, y = radius, z = radius},
		minacc = {x = 0, y = gravity, z = 0},
		maxacc = {x = 0, y = gravity, z = 0},
		minexptime = 0.1,
		maxexptime = 1,
		minsize = min_size,
		maxsize = max_size,
		texture = texture,
		glow = glow
	})
end


function blood.do_blood_effects(obj, damage_amount)
	local blood_texture = {"blood_1.png", "blood_2.png", "blood_3.png"}
	local blood_amount = 4
	if obj:is_player() and damage_amount > 2 then
		-- change the player's hud to have blood on it
		local player_name = obj:get_player_name()
		local current_time = minetest.get_us_time()

		-- Update the last damage time
		last_damage_time[player_name] = current_time

		if hud[player_name] == nil then
			hud[player_name] = obj:hud_add({
				hud_elem_type = "image",
				position = {x = 0.5, y = 0.5},
				offset = {x = 0, y = 0},
				scale = {x = -100, y = -100},
				text = "blood_vignette_0.png",
				alignment = {x = 0, y = 0},
				size = {x = 1, y = 1},
				z_index = -400
			})
		else
			obj:hud_change(hud[player_name], "text", "blood_vignette_0.png")
		end
		if obj:get_hp() + damage_amount > 0 then
			minetest.after(3, function()
				
					for i = 1, 4 do
						minetest.after(i * 0.2, function()
							if last_damage_time[player_name] ~= current_time then
								return
							end
							if i == 4 then
								if hud[player_name] then
									obj:hud_remove(hud[player_name])
								end
								hud[player_name] = nil
								last_damage_time[player_name] = nil
							else
								if hud[player_name] then
									obj:hud_change(hud[player_name], "text", "blood_vignette_"..i..".png")
								end
							end
						end)
					end
				
			end)
		end
	end

	-- blood_particles
	if blood_amount > 0 then

		local pos = obj:get_pos()
		local b = nil
		local amount = blood_amount
		local damage = math.abs(damage_amount)

		pos.y = pos.y + 1.4

		-- lots of damage = more blood :)
		if damage > 20 then
			amount = blood_amount * 8
		elseif damage > 2 then
			amount = blood_amount * 4
		end

		-- do we have a single blood texture or multiple?
        if type(blood_texture) == "table" then
            b = blood_texture[math.random(#blood_texture)]
        else
            b = blood_texture
        end

		effect(pos, amount, b, 0.25, 1.5, 1.75, -6, nil, true)
	end
end

minetest.register_on_leaveplayer(function(player)
	local player_name = player:get_player_name()
	if hud[player_name] then
		player:hud_remove(hud[player_name])
	end
	hud[player_name] = nil
end)

minetest.register_on_respawnplayer(function(player)
	local player_name = player:get_player_name()
	if hud[player_name] then
		player:hud_remove(hud[player_name])
	end
	hud[player_name] = nil
end)