G_AddGametype({
    name = "Pizza Time Deluxe",
    identifier = "PIZZATIMEDELUXE",
    typeoflevel = TOL_RACE,
    rules = GTR_FRIENDLY|GTR_SPAWNENEMIES|GTR_TIMELIMIT,
    intermissiontype = int_match,
    headercolor = 67,
    description = "Run away from pizzaface, in style!"
})

local loaded_mods = false

rawset(_G, "PTD", { -- variables
	spawn_location = 
	{x = 0, y = 0, z = 0, angle = 0}, -- where the sign is at the start of the map
	
	end_location = 
	{x = 0, y = 0, z = 0, angle = 0}, -- where the sign originally was in the map placement
	
	pizzatime = false,
	dynamic_maxlaps = 0,
	laps = 0,
	quitting = false,
	pizzatime_tics = 0,
	
	timeleft = 0,
	
	timeover = false,
	
	endsector = nil,
	
	showtime = false,
	
	hudstuff = {
		anim = 0,
		anim_active = false,
		
		rev = false,
		wait_tics = 0,
		
		stop = false,
	},
	
	maxrankpoints = 0,
})

addHook("NetVars", function(net)
	local sync_list = {
		"spawn_location",
		"end_location",
		"pizzatime",
		"dynamic_maxlaps",
		"laps",
		"quitting",
		"pizzatime_tics",
		"timeleft",
		"timeover",
		"showtime",
		"endsector",
		
		"hudstuff",
		
		"maxrankpoints",
	}
	
	for i,v in ipairs(sync_list) do
		PTD[v] = net($)
	end
end)


local function ResetPlayerVars(player)	
	player.pizzaface = false
	player.pizzamask = nil
	player.stuntime = 0
	player.spectator = false
	player.lapsdid = 0
	player.laptime = 0
	player["PT@hudstuff"] = PTD.hudstuff
end

PTD.spawn_location_atdefault = (
PTD.spawn_location.x == 0 and 
PTD.spawn_location.y == 0 and 
PTD.spawn_location.z == 0 and 
PTD.spawn_location.angle == 0
) -- returns true if at the defaults

PTD.end_location_atdefault = (
PTD.end_location.x == 0 and 
PTD.end_location.y == 0 and 
PTD.end_location.z == 0 and 
PTD.end_location.angle == 0
) -- returns true if at the defaults



rawset(_G, "PTD_COUNT", do
	local playerCount = 0
	local exitingCount = 0
	local pizzaCount = 0
	for player in players.iterate
		if player.valid
			if player.pizzaface then
				pizzaCount = $+1
			end
			if player.exiting or player.spectator or player.pizzaface or (player.playerstate == PST_DEAD and PTD.pizzatime)
				exitingCount = $+1
			end
		end
		playerCount = $+1
	end
	return exitingCount,playerCount, pizzaCount
end)




--heres where the values reset when maps load
local function InitMap()
	PTD.pizzatime = false -- doesn't matter what gamemode it is, just make it false all the time.
    PTD.spawn_location = {x = 0, y = 0, z = 0}
    PTD.endsector = nil
	PTD.laps = 0
	PTD.quitting = false
	PTD.dynamic_maxlaps = 0
	PTD.pizzatime_tics = 0 
	PTD.timeleft = 0
	PTD.timeover = false
	PTD.showtime = false
end

local function InitMap2()
    if gametype ~= GT_PIZZATIMEDELUXE then return end
	PTD.john = nil
    for map in mapthings.iterate do
        if map.type == 1 then
            PTD.spawn_location.x = map.x
            PTD.spawn_location.y = map.y
            PTD.spawn_location.z = map.z
            PTD.spawn_location.angle = map.angle
        end
		
        if map.type == 501 then
            PTD.end_location.x = map.x
            PTD.end_location.y = map.y
            PTD.end_location.z = map.z
            PTD.end_location.angle = map.angle
			local john = P_SpawnMobj(
				map.x*FU - cos(map.angle*ANG1)*200, 
				map.y*FU - sin(map.angle*ANG1)*200, 
				map.z*FU,
				MT_PILLARJOHN
			)
			john.angle = map.angle*ANG1
			if map.options & MTF_OBJECTFLIP then
				john.flags2 = $ | MF2_OBJECTFLIP
			end
			PTD.john = john
        end
    end
	-- dont use the playercount function since it will iterate through all players twice
	-- so make a non functioned playercount
	local playercount = 0
	for player in players.iterate() do
	
		playercount = $ + 1	
		-- INCREMENT OVER --
		ResetPlayerVars(player)	
	end
	PTD.dynamic_maxlaps = playercount*2
	
	PTD.maxrankpoints = PTD.GetRingCount()*1500
end

PTD.ReturnPizzaTimeMusic = function()

	local song = mapmusname
	local songdata = {}

	songdata["It's Pizza Time!"] = 'PIZTIM'
	songdata["The Death That I Deservioli"] = 'DEAOLI'
	songdata["Pillar John's Revenge"] = 'PIJORE'
	songdata["Gluten Getaway"] = 'GLUWAY'
	songdata["Pasta La Vista"] = 'PASTVI'

	if PTD.pizzatime then
		if consoleplayer.lapsdid == 2 then
			song = "The Death That I Deservioli"
		elseif consoleplayer.lapsdid == 3 then
			song = "Pillar John's Revenge"
		elseif consoleplayer.lapsdid == 4 then
			song = "Gluten Getaway"
		elseif consoleplayer.lapsdid >= 5 then
			song = "Pasta La Vista"
		else
			if consoleplayer.lapsdid <= 1 then
				song = "It's Pizza Time!"
			end
		end
	end

	// modding check here

	return songdata[song]
end

-- doesnt actually trigger or increment lap, just tps you
PTD.LapTP = function(player, invincibility)
	if not player and not player.mo and not player.mo.valid then return end -- safety
	player.exiting = 0
	P_SetOrigin(player.mo, PTD.end_location.x*FRACUNIT,PTD.end_location.y*FRACUNIT, PTD.end_location.z*FRACUNIT)
	player.mo.angle = PTD.end_location.angle - ANGLE_90
	
	if invincibility then
		player.powers[pw_invulnerability] = max($,CV_PTD.tpinv.value*TICRATE) -- converts to seconds
	end
end
--does the parameters shit for you.


PTD.StartNewLap = function(mobj)
	local player = mobj.player
	
	if not player.pizzaface then
		PTD.LapTP(player, true)
		//player.lapsdid = $+1

		S_StartSound(nil, sfx_lap2, player)
		
		
		player.laptime = 0
		
		
		player.lapsdid = $ + 1
		if player.lapsdid > PTD.laps
			PTD.laps = player.lapsdid
		end

		
		-- Elfilin support
		
		if player.elfilin and player.mo.elfilin_portal then
			player.mo.elfilin_portal.fuse = 1
		end
		S_ChangeMusic(PTD.ReturnPizzaTimeMusic(mobj.player), true)
	else -- FAKE LAP -- 
		mobj.player.stuntime = TICRATE*CV_PTD.fakelapstun.value
		P_SetOrigin(mobj, PTD.end_location.x*FRACUNIT,PTD.end_location.y*FRACUNIT, PTD.end_location.z*FRACUNIT)
		mobj.angle = PTD.end_location.angle - ANGLE_90
	end
	
end 


PTD.PizzaTimeTrigger = function(mobj)
	if not (PTD.pizzatime and PTD.spawn_location_atdefault) then
		if DiscordBot then
			DiscordBot.Data.msgsrb2 = $ .. ":pizza: Pizza Time has started! Pizzas:\n"
		end
		PTD.pizzatime = true
		PTAnimFunctions.NewAnimation('pizzaface', 'PIZZAFACE_SLEEPING', 2, 11, true)
		PTAnimFunctions.NewAnimation('john', 'JOHN', 2, 22, true)

		local thesign = P_SpawnMobj(0,0,0, MT_SIGN)
		P_SetOrigin(thesign, PTD.spawn_location.x*FRACUNIT, PTD.spawn_location.y*FRACUNIT, PTD.spawn_location.z*FRACUNIT)
		thesign.angle = PTD.spawn_location.angle
		
		if thesign.subsector then
			PTD.endsector = thesign.subsector.sector
		end
		
		PTD.timeleft = CV_PTD.timelimit.value*TICRATE*60
		PTD.laps = 1
		
		--hit the player that touched the location with these variables
		local _, playerCount = PTD_COUNT()
		if playerCount > 1 then
			if CV_PTD.pizzachoosetype.value == 1 then
				mobj.player.pizzaface = true
				mobj.player.stuntime = TICRATE*CV_PTD.pizzatimestun.value+20
				chatprint("\x85*"..mobj.player.name.." has become a pizza!") 
				if DiscordBot then
					DiscordBot.Data.msgsrb2 = $ .. "- [" .. #mobj.player .. "] **" .. mobj.player.name .. "**\n"
				end
			else
				local active_playernums = {}
				local playerschoosing = CV_PTD.pizzacount.value
				
				if playerCount < playerschoosing then
					playerschoosing = 1
				end
				if playerschoosing then
					-- store every playernum
					for player in players.iterate() do
						if CV_PTD.pizzachoosetype.value == 3 and player == mobj.player then
							continue
						end
						if player.quittime then
							player.spectator = true
							continue
						end
						table.insert(active_playernums, #player)
						
					end
					-- loop for every pizza needed
					for i=1,playerschoosing do
						local chosen_playernum = P_RandomRange(1,#active_playernums) -- random entry in table
						local chosen_player = active_playernums[chosen_playernum] -- get the chosen value in table
						players[chosen_player].pizzaface = true
						players[chosen_player].stuntime = TICRATE*CV_PTD.pizzatimestun.value+20
						chatprint("\x85*"..players[chosen_player].name.." has become a pizza!") 
						if DiscordBot then
							DiscordBot.Data.msgsrb2 = $ .. "- [" .. chosen_player .. "] **" .. players[chosen_player].name .. "**\n"
						end
						table.remove(active_playernums, chosen_playernum) -- so we dont repeat the pizza given
					end
				end
			end
		end
		for player in players.iterate() do
			local pmo = player.mo
			if not (pmo and pmo.valid) then continue end
			player.lapsdid = 1
			P_SetOrigin(pmo, PTD.end_location.x*FRACUNIT,PTD.end_location.y*FRACUNIT, PTD.end_location.z*FRACUNIT)
			pmo.angle = PTD.end_location.angle - ANGLE_90
			if not player.pizzaface then
				player.powers[pw_invulnerability] = CV_PTD.tpinv.value*TICRATE+20
				player.powers[pw_nocontrol] = 20
				player.mo.momx = 0
				player.mo.momy = 0
				player.mo.momz = 0
			end
		end   
		
		if PTD.john then
			local john = PTD.john
			john.state = S_PILLARJOHN_PAIN
			john.flags = $ | MF_NOCLIP | MF_NOCLIPHEIGHT
			john.momx = -cos(john.angle)*8
			john.momy = -sin(john.angle)*8
			john.momz = P_MobjFlip(john)*8*FU
		end

		S_ChangeMusic(PTD.ReturnPizzaTimeMusic(mobj.player), true)
	end
end

PTD.GetRingCount = function()
	local count = 0
	for mobj in mobjs.iterate() do
		if mobj.type == MT_RING then
			count = $ + 1
		end
		if mobj.type == MT_COIN then
			count = $ + 1
		end
		if perPlayerRings and mobj.type == MT_MULTIRING then
			count = $ + 1
		end
	end
	
	return count
end



addHook("MapChange", InitMap)
addHook("MapLoad", InitMap)
addHook("MapLoad", InitMap2)




rawset(_G, "GT_PIZZATIMEJISK", GT_PIZZATIMEDELUXE)
rawset(_G, "PTJE", PTD)
rawset(_G, "JISK_COUNT", PTD_COUNT)