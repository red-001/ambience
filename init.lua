
--= Ambience lite by TenPlus1 (24th December 2016)

local max_frequency_all = 1000 -- larger number means more frequent sounds (100-2000)
local SOUNDVOLUME = 1.0
local ambiences
-- sound sets (gain defaults to 0.3 unless specifically set)

local night = {
	frequency = 40,
	{name = "hornedowl", length = 2},
	{name = "wolves", length = 4, gain = 0.4},
	{name = "cricket", length = 6},
	{name = "deer", length = 7},
	{name = "frog", length = 1},
}

local day = {
	frequency = 40,
	{name = "cardinal", length = 3},
	{name = "craw", length = 3},
	{name = "bluejay", length = 6},
	{name = "robin", length = 4},
	{name = "bird1", length = 11},
	{name = "bird2", length = 6},
	{name = "crestedlark", length = 6},
	{name = "peacock", length = 2},
	{name = "wind", length = 9},
}

local high_up = {
	frequency = 40,
	{name = "desertwind", length = 8},
	{name = "wind", length = 9},
}

local cave = {
	frequency = 60,
	{name = "drippingwater1", length = 1.5},
	{name = "drippingwater2", length = 1.5}
}

local beach = {
	frequency = 40,
	{name = "seagull", length = 4.5},
	{name = "beach", length = 13},
	{name = "gull", length = 1},
	{name = "beach_2", length = 6},
}

local desert = {
	frequency = 20,
	{name = "coyote", length = 2.5},
	{name = "desertwind", length = 8}
}

local flowing_water = {
	frequency = 1000,
	{name = "waterfall", length = 6}
}

local underwater = {
	frequency = 1000,
	{name = "scuba", length = 8}
}

local splash = {
	frequency = 1000,
	{name = "swim_splashing", length = 3},
}

local lava = {
	frequency = 1000,
	{name = "lava", length = 7}
}

local river = {
	frequency = 1000,
	{name = "river", length = 4}
}

local smallfire = {
	frequency = 1000,
	{name = "fire_small", length = 6}
}

local largefire = {
	frequency = 1000,
	{name = "fire_large", length = 8, gain = 0.8}
}

local jungle = {
	frequency = 200,
	{name = "jungle_day_1", length = 7},
	{name = "deer", length = 7},
	{name = "canadianloon2", length = 14},
	{name = "bird1", length = 11},
	{name = "peacock", length = 2},
}

local jungle_night = {
	frequency = 200,
	{name = "jungle_night_1", length = 4},
	{name = "jungle_night_2", length = 4},
	{name = "deer", length = 7},
	{name = "frog", length = 1},
}

local radius = 6

local function count_nodes_in_area(minp, maxp)
	local nodenames = {}
	for x = minp.x, maxp.x do
		for y = minp.y, maxp.y do
			for z = minp.y, maxp.y do
				local pos = {x=x,y=y,z=z}
				local node_name = minetest.get_node(pos).name
				if nodenames[node_name] then
					nodenames[node_name] = nodenames[node_name] + 1
				else
					nodenames[node_name] = 1
				end
			end
		end
	end
	return nodenames
end

local localplayer
minetest.register_on_connect(function()
	localplayer = minetest.localplayer
end)

-- check where player is and which sounds are played
local function get_ambience()

	-- where am I?
	local pos = localplayer:get_pos()

	-- what is around me?
	pos.y = pos.y + 1.4 -- head level
	local node_head = minetest.get_node(pos).name

	pos.y = pos.y - 1.2 -- foot level
	local node_feet = minetest.get_node(pos).name

	pos.y = pos.y - 0.2 -- reset pos

--= START Ambiance

	if node_head:find("default:([%w%p]*)water_") then
		return {underwater = underwater}
	end

	if node_feet:find("default:([%w%p]*)water_") then
		local velo = localplayer:get_velocity()
		local player_is_moving = false
		if math.floor(velo.x) ~= 0 or math.floor(velo.y) ~= 0 or velo.z > 4 or velo.z < -4 then
			player_is_moving = true
		end
		
		if player_is_moving then
			return {splash = splash}
		end
	end

	local cn = count_nodes_in_area(
		{x = pos.x - radius, y = pos.y - radius, z = pos.z - radius},
		{x = pos.x + radius, y = pos.y + radius, z = pos.z + radius})

	local num_fire = (cn["fire:basic_flame"] or 0) + (cn["fire:permanent_flame"] or 0)
	local num_lava = (cn["default:lava_flowing"] or 0) + (cn["default:lava_source"] or 0)
	local num_water_flowing = (cn["default:water_flowing"] or 0)
	local num_water_source = (cn["default:water_source"] or 0)
	local num_desert = (cn["default:desert_sand"] or 0) + (cn["default:desert_stone"] or 0)
	local num_snow = (cn["default:snowblock"] or 0)
	local num_jungletree = (cn["default:jungletree"] or 0)
	local num_river = (cn["default:river_water_source"] or 0) + (cn["default:river_water_flowing"] or 0)
--cn
--[[
print (
	"fr:" .. num_fire,
	"lv:" .. num_lava,
	"wf:" .. num_water_flowing,
	"ws:" .. num_water_source,
	"ds:" .. num_desert,
	"sn:" .. num_snow,
	"jt:" .. num_jungletree
)
]]
	if num_fire > 8 then
		return {largefire = largefire}

	elseif num_fire > 0 then
		return {smallfire = smallfire}
	end

	if num_lava > 5 then
		return {lava = lava}
	end

	if num_water_flowing > 30 then
		return {flowing_water = flowing_water}
	end

	if num_river > 30 then
		return {river = river}
	end

	if pos.y < 7 and pos.y > 0
	and num_water_source > 100 then
		return {beach = beach}
	end

	if num_desert > 150 then
		return {desert = desert}
	end

	if pos.y > 60
	or num_snow > 150 then
		return {high_up = high_up}
	end

	if pos.y < -10 then
		return {cave = cave}
	end

	local tod = minetest.get_timeofday()

	if tod > 0.2
	and tod < 0.8 then

		if num_jungletree > 90 then
			return {jungle = jungle}
		end

		return {day = day}
	else

		if num_jungletree > 90 then
			return {jungle_night = jungle_night}
		end

		return {night = night}
	end

	-- END Ambiance

end

-- play sound, set handler then delete handler when sound finished
local function play_sound(list, number)

	if list.handler == nil then

		local handler = minetest.sound_play(list[number].name, {
			gain = (list[number].gain or 0.3) * SOUNDVOLUME
		})

		if handler then

			list.handler = handler

			minetest.after(list[number].length, function(list)
				if list.handler then
					minetest.sound_stop(list.handler)

					list.handler = nil
				end

			end, list)
		end
	end
end

-- stop sound in still_playing
local function stop_sound(list)
	if list.handler then
		minetest.sound_stop(list.handler)
		list.handler = nil
	end
end

-- check sounds that are not in still_playing
local function still_playing(still_playing)
	if not still_playing.cave then stop_sound(cave) end
	if not still_playing.high_up then stop_sound(high_up) end
	if not still_playing.beach then stop_sound(beach) end
	if not still_playing.desert then stop_sound(desert) end
	if not still_playing.night then stop_sound(night) end
	if not still_playing.day then stop_sound(day) end
	if not still_playing.flowing_water then stop_sound(flowing_water) end
	if not still_playing.splash then stop_sound(splash) end
	if not still_playing.underwater then stop_sound(underwater) end
	if not still_playing.river then stop_sound(river) end
	if not still_playing.lava then stop_sound(lava) end
	if not still_playing.smallfire then stop_sound(smallfire) end
	if not still_playing.largefire then stop_sound(largefire) end
	if not still_playing.jungle then stop_sound(jungle) end
	if not still_playing.jungle_night then stop_sound(jungle_night) end
end

-- player routine

local timer = 0

minetest.register_globalstep(function(dtime)
	if not localplayer then return end
	-- every half a second
	timer = timer + dtime
	if timer < 0.5 then return end
	timer = 0

	ambiences = get_ambience()
	still_playing(ambiences)

	for _,ambience in pairs(ambiences) do

		if math.random(1, 1000) <= ambience.frequency then

			play_sound(ambience, math.random(1, #ambience))
		end
	end
end)

-- set volume command
minetest.register_chatcommand("svol", {
	params = "<svol>",
	description = "set sound volume (0.1 to 1.0)",
	func = function(name, param)

		SOUNDVOLUME = tonumber(param) or SOUNDVOLUME

		if SOUNDVOLUME < 0.1 then SOUNDVOLUME = 0.1 end
		if SOUNDVOLUME > 1.0 then SOUNDVOLUME = 1.0 end

		return true, "Sound volume set to " .. SOUNDVOLUME
	end,
})
