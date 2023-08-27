freeslot("MT_PIZZAMASK", "S_PIZZAFACE", "S_CONEBALL", "S_PF_EGGMAN", "SPR_PZAT", "SPR_CONB")

mobjinfo[MT_PIZZAMASK] = {
	doomednum = -1,
	spawnstate = S_PIZZAFACE,
	spawnhealth = 1000,
	deathstate = S_NULL,
	radius = 16*FU,
	height = 48*FU,
	flags = MF_NOCLIP|MF_NOGRAVITY
}

states[S_PIZZAFACE] = {
    sprite = SPR_PZAT,
    frame = FF_ANIMATE|FF_FULLBRIGHT|A,
    tics = -1,
    var1 = P,
    var2 = 2,
    nextstate = S_PIZZAFACE
}

states[S_CONEBALL] = {
    sprite = SPR_CONB,
    frame = FF_ANIMATE|FF_FULLBRIGHT|A,
    tics = -1,
    var1 = H,
    var2 = 2,
    nextstate = S_CONEBALL
}

states[S_PF_EGGMAN] = {
    sprite = SPR_EGGM,
    frame = FF_FULLBRIGHT|A,
    tics = -1,
    nextstate = S_PF_EGGMAN
}

rawset(_G, "pfmaskData", {
	{
		name = "Pizzaface",
		state = S_PIZZAFACE,
		scale = FU/2,
		trails = {SKINCOLOR_RED, SKINCOLOR_GREEN},
		sound = sfx_pizzah,
		emoji = ":pizza:"
	},
	{
		name = "Coneball",
	    state = S_CONEBALL,
		scale = 3*FU/4,
		trails = {SKINCOLOR_SKY, SKINCOLOR_NEON},
		sound = sfx_coneba,
		emoji = ":candy:"
	},
	{
		name = "Eggman",
	    state = S_PF_EGGMAN,
		scale = FU,
		trails = {SKINCOLOR_GOLD, SKINCOLOR_FLAME},
		sound = sfx_bewar3,
		emoji = ":egg:"
	}
})

addHook("PlayerCmd", function (player, cmd)
	if player.pizzaface and player.stuntime then
		cmd.buttons = 0
		cmd.forwardmove = 0
		-- dont do sidemove cuz face swapping
	end
end)


--Pizza Face Thinker
addHook("PlayerThink", function(player)
	player.PTBE_pizzastyle = $ or 1
	player.stuntime = $ or 0 
	if gametype ~= GT_PIZZATIMEBRAC then return end
	if player.realmo and player.realmo.valid and player.pizzaface and leveltime then
		if player.redgreen == nil then
			player.redgreen = $ or false
		end
		player.pizzacharge = $ or 0
		player.pizzachargecooldown = $ or 0
		
		
		P_SetScale(player.realmo, 2*FU)
		
		player.spectator = false -- dont give up! dont spectate as pizzaface! (theres another check when spawning so idk 
		
		if player.stuntime then -- player freeze decrement (mainly for pizza faces)
			player.stuntime = $ - 1
			player.mo.momx = 0
			player.mo.momy = 0
			player.mo.momz = 0
			--player.pflags = $|PF_FULLSTASIS
			if not player.stuntime and CV_PTBE.pizzalaugh.value and not player.pizzachargecooldown then -- once it hits zero, LAUGH AHHHHAHHAAHAHAHHAHAH
				S_StartSound(player.mo, pfmaskData[player.PTBE_pizzastyle].sound)
			elseif PTBE.pizzatime_tics < TICRATE*CV_PTBE.pizzatimestun.value+20 then
				player.mo.momz = P_MobjFlip(player.mo)*-FU
				if player.facechangecooldown then
					player.facechangecooldown = $ - 1
				else
					local change = 0
					if player.cmd.sidemove > 5 then
						change = $ + 1
					elseif player.cmd.sidemove < -5 then
						change = $ - 1
					end
					if change ~= 0 then
						S_StartSound(nil, sfx_menu1, player)
						player.facechangecooldown = TICRATE/3
						local changeTo = (player.PTBE_pizzastyle + change + #pfmaskData - 1) % #pfmaskData + 1
						player.PTBE_pizzastyle = changeTo
						if consoleplayer == player then
							CV_StealthSet(CV_PTBE.pizzastyle, changeTo)
						end
					end
				end
			end
		end
		
		

		if (not player.pizzamask or not player.pizzamask.valid) and CV_PTBE.pizzamask.value then
			player.pizzamask = P_SpawnMobj(player.realmo.x,player.realmo.y,player.realmo.z,MT_PIZZAMASK)
			player.pizzamask.targetplayer = player --dream reference
			player.pizzamask.scale = pfmaskData[1].scale
		end
		
		if player.pizzamask then
			player.realmo.flags2 = $|MF2_DONTDRAW -- invisible so that the pizza mask can draw over.
		else
			player.mo.color = SKINCOLOR_ORANGE
			player.mo.colorized = true
		end
		
		
		
		if not (leveltime % 3) and player.pizzamask and player.pizzamask.valid and player.speed > FRACUNIT then

			local ghost = P_SpawnGhostMobj(player.pizzamask)
			P_SetOrigin(ghost, player.pizzamask.x, player.pizzamask.y, player.pizzamask.z)
			ghost.fuse = 11
			ghost.colorized = true
			local colors = pfmaskData[player.PTBE_pizzastyle].trails
			if player.redgreen then
				ghost.color = colors[1]
			else
				ghost.color = colors[2]
			end
			ghost.frame = $|FF_TRANS10|FF_FULLBRIGHT
			player.redgreen = not player.redgreen
		end
		if player.exiting or PTBE.quitting then
			player.pizzacharge = 0
		end
		if not player.exiting and (player.cmd.buttons & BT_ATTACK) 
		and not PTBE.quitting and not player.stuntime and not player.pizzachargecooldown then -- basically check if you're active in general
			if player.pizzacharge < TICRATE then
				player.pizzacharge = $ + 1
			else
				local peppinos = {} -- temp list of chosen players, or "peppinos" in this case.

				-- we will have "peppino" as the alias because conflicts
				for peppino in players.iterate() do
					if not peppino.pizzaface and (peppino.mo and peppino.mo.valid) and 
					not peppino.spectator and not peppino.exiting and (peppino.playerstate == PST_LIVE)
					and not peppino.quittime then 
						table.insert(peppinos, #peppino)
					end
				end
				local chosen_peppinonum = P_RandomRange(1,#peppinos) -- random entry in table
				local chosen_peppino = peppinos[chosen_peppinonum] -- get the chosen value in table
				if peppinos ~= {} then
					player.pizzacharge = 0
					player.pizzachargecooldown = CV_PTBE.pizzatpcooldown.value*TICRATE
					player.stuntime = CV_PTBE.pizzatpstuntime.value*TICRATE
				
					P_SetOrigin(player.mo, players[chosen_peppino].mo.x,players[chosen_peppino].mo.y,players[chosen_peppino].mo.z)
					S_StartSound(player.mo, pfmaskData[player.PTBE_pizzastyle].sound)
				end

			end
		elseif player.pizzacharge > 0 then
			player.pizzacharge = $ - 1
		end
		
		if player.pizzachargecooldown then
			player.pizzachargecooldown = $ - 1
		end
		--print(player.pizzacharge)
		/*
		if not p.mo.colorized or p.mo.color != SKINCOLOR_ORANGE
			p.mo.color = SKINCOLOR_ORANGE
			p.mo.colorized = true		
		end
		*/
	end
end)

-- Pizza Mask Thinker
addHook("MobjThinker", function(mobj)
	if gametype ~= GT_PIZZATIMEBRAC then return end
	if mobj.targetplayer and mobj.targetplayer.valid and mobj.targetplayer.mo and mobj.targetplayer.mo.valid then
		local targetplayer = mobj.targetplayer
		P_MoveOrigin(mobj, targetplayer.mo.x, targetplayer.mo.y, targetplayer.mo.z)
		mobj.angle = targetplayer.drawangle
		local thisMask = pfmaskData[targetplayer.PTBE_pizzastyle]
		if mobj.state ~= thisMask.state then
			mobj.state = thisMask.state
			mobj.scale = thisMask.scale
		end
		mobj.flags2 = ($ & ~MF2_OBJECTFLIP) | (targetplayer.mo.flags2 & MF2_OBJECTFLIP)
		mobj.eflags = ($ & ~MFE_VERTICALFLIP) | (targetplayer.mo.eflags & MFE_VERTICALFLIP)
		mobj.color = targetplayer.skincolor
	end
end, MT_PIZZAMASK)

--THE BADNIKS ARENT PIZZAHEAD'S ENEMY
addHook("ShouldDamage", function(target, inflictor)
	if target.valid and target.player and target.player.pizzaface then 
	--and inflictor and inflictor.valid and (inflictor.flags & MF_ENEMY)  
	--this code is gone because we want pizzaface to not die
		return false
	end
end)
 -- taken from the original since barely anything needs to be changed
addHook("MobjCollide", function(mo1, mo2)
	if not PTBE.pizzatime then return end
	if not (mo1.player and mo1.valid and mo1.player.valid) then return end
	if not (mo2.player and mo2.valid and mo2.player.valid) or (mo2.player and not mo2.player.pizzaface) then return end -- only continue if mo2 is pizzaface
	if mo2.player.stuntime then return end
	if mo1.player.exiting then return end
	if mo1.player.powers[pw_invulnerability] then return end
	if mo1.player.powers[pw_flashing] then return end
	if mo1.player.pizzaface then return end -- lets not tag our buddies!!
	if not L_ZCollide(mo1,mo2) then return end
	
	P_KillMobj(mo1,mo2)
end, MT_PLAYER)


