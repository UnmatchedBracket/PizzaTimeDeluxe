-- simple midgame joining blocker & more
addHook("PlayerSpawn", function(player)
	player.lapsdid = $ or 0
	player.laptime = $ or 0 
	if player.realmo and player.realmo.valid then
		if player.pizzaface then
			return
		end
		if PTBE.pizzatime and leveltime then
			player.spectator = true
		end
	end
end)

addHook("PlayerSpawn", function(player)
	player["PT@hudstuff"] = PTBE.hudstuff
end)

addHook("PlayerThink", function(player)
	local hudst = player["PT@hudstuff"]
	
	if hudst then
		if not hudst.wait_tics then
			if hudst.anim_active then
				if not hudst.rev then -- normal
					hudst.anim = $ + 1
				else -- reverse
					hudst.anim = $ - 1
				end
				
				if hudst.anim > 45 then
					hudst.anim = $ - 1
					hudst.rev = true
					hudst.wait_tics = 4*TICRATE
				elseif not hudst.anim and hudst.stop then
					hudst.anim_active = false
					hudst.rev = false
					hudst.wait_tics = 0 -- just in case
				end
			end
		else
			hudst.wait_tics = $ - 1
			if hudst.wait_tics == 1 then
				hudst.stop = true
			end
		end
	end
end)

addHook("ThinkFrame", do
	local exitingCount, playerCount = BRAC_COUNT()
	if PTBE.pizzatime then
		PTBE.pizzatime_tics = $ + 1
		if PTBE.timeleft and (exitingCount ~= playerCount) and CV_PTBE.timelimit.value then
			PTBE.timeleft = $ - 1
			if not PTBE.timeleft then
				PTBE.timeover = true
				for player in players.iterate() do
					if player.mo and player.mo.valid and not player.pizzaface and not player.exiting then
						P_KillMobj(player.mo)
					end
				end
				local timeover_text = "\x8F*Time over!"
				chatprint(timeover_text)
				if DiscordBot then
					DiscordBot.Data.msgsrb2 = $ .. ":alarm_clock: Time over!\n"
				end
			end
		end
	end 
end)

addHook("PlayerThink", function(player)
	local pmo = player.mo
	local hudst = player["PT@hudstuff"]
	if player.mo and player.mo.valid then
		if player.exiting and (player.cmd.buttons & BT_ATTACK) and not PTBE.quitting 
		and not ((CV_PTBE.lappingtype.value == 2) and (player.lapsdid >= CV_PTBE.maxlaps_perplayer.value)) then 
			PTBE.StartNewLap(player.mo)
			--PTBE.LapTP(player, true)
			hudst.anim_active = true
			hudst.anim = 1
		end
		
		if player.laptime ~= nil and PTBE.pizzatime and not player.exiting then
			player.laptime = $ + 1
		end
		
		-- elfilin support: KILL THE DAMN PLAYER WHEN TRYING TO RIDE A PIZZAFACE
		-- ridingplayer isnt a player_t this is so clickbait!!!
		if player.elfilin and player.elfilin.ridingplayer 
		and player.mo and player.mo.valid and
		player.elfilin.ridingplayer.valid and
		player.elfilin.ridingplayer.player.pizzaface and player.playerstate == PST_LIVE then
			--P_KillMobj(player.mo,player.elfilin.ridingplayer)
			player.elfilin.ridingplayer = 0
		end
		--endsupport
		local range = 250*FRACUNIT -- higher blockmap range so it doesnt look choppy
		local real_range = 75*FRACUNIT
		searchBlockmap("objects", function(refmobj, foundmobj)
			if R_PointToDist2(foundmobj.x, foundmobj.y, pmo.x, pmo.y) < real_range 
			and L_ZCollide(foundmobj,pmo) then
				if foundmobj.type == MT_RING or foundmobj.type == MT_COIN and not foundmobj.tayken then
					foundmobj["very secure x"] = foundmobj.x
					foundmobj["very secure y"] = foundmobj.y
					foundmobj["very secure z"] = foundmobj.z
					local vs_x = foundmobj["very secure x"]
					local vs_y = foundmobj["very secure y"]
					local vs_z = foundmobj["very secure z"]
					
					P_SetOrigin(foundmobj, pmo.x,pmo.y,pmo.z)
					P_SetOrigin(foundmobj, vs_x,vs_y,vs_z)
					foundmobj.tayken = true
				else
					return false
				end
			end
		end, 
		player.mo,
		player.mo.x-range, player.mo.x+range,
		player.mo.y-range, player.mo.y+range)		
	end
end)

-- rank thinker
addHook("PlayerThink", function(player)
	-- a 6th of the max rank points, multiply later
	-- idk what pec is supposed to mean but i guess it means a fraction of the maxrank points
	local pec = (PTBE.maxrankpoints)/6
	
	--player.ptje_rank = "P"
	-- boy what the hellllll o ma god way ayyaay
	if player.score < pec then
		-- this is real p rank
		-- cry like a wittle babyy!
		player.ptje_rank = "D"
	elseif player.score <= pec*2
		player.ptje_rank = "C"
		
	elseif player.score <= pec*3
		player.ptje_rank = "B"
	elseif player.score <= pec*5
		player.ptje_rank = "A"
	elseif player.score <= pec*6
		player.ptje_rank = "S"
	elseif player.score <= pec*7
		if player.timeshit then
			player.ptje_rank = "S"
		else
			player.ptje_rank = "P"
		end
	end
	
end)