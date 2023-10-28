-- Doesn't limit to grabbing rings. you get extra score on killing other stuff too
addHook("MobjDeath", function(target, inflictor, source)
	if CV_PTSR.scoreonkill.value and gametype == GT_PTSPICER and source and source.valid and source.player and source.player.valid then
		local player = source.player
		if (target.flags & MF_ENEMY) then 
			P_AddPlayerScore(player, ((player.speed>>16)/2) * 170)
		elseif (target.type == MT_RING or target.type == MT_COIN)
			P_AddPlayerScore(player, ((player.speed>>16)/2) * 65)
		end
	end
end)

-- Destroy everything while running
-- only in pizza time tho.
addHook("PlayerCanDamage", function(player, mobj)
	if PTSR.pizzatime and CV_PTSR.killwhilerunning.value and player.speed >= skins[player.mo.skin].runspeed and not mobj.player then
		return true
	end
end)