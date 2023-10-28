
-- Nothing really needed to be touched here (Maybe)

addHook("ThinkFrame", function()
	if gametype ~= GT_PIZZATIMEDELUXE then return end
	
	local exitingCount, playerCount, pizzaCount = PTD_COUNT()
	
	-- better than the old code since it started a new iteration on every IF block.
	
	for player in players.iterate() do
		if leveltime then -- just a safety check
			if (CV_PTD.lappingtype.value == 2) and (player.lapsdid > CV_PTD.maxlaps_perplayer.value) then
				P_DoPlayerExit(player)
			elseif ((playerCount > 1) and not (pizzaCount) and PTD.pizzatime) or (exitingCount == playerCount) then
				if player.valid and not (player.exiting)
					P_DoPlayerExit(player)
				end
				--print(2)
			elseif (CV_PTD.maxlaps.value and PTD.laps > CV_PTD.maxlaps.value and not CV_PTD.dynamiclaps.value) or PTD.quitting 
			or (PTD.dynamic_maxlaps and PTD.laps > PTD.dynamic_maxlaps and CV_PTD.dynamiclaps.value) 
			and not ((CV_PTD.lappingtype.value == 2) and (player.lapsdid > CV_PTD.maxlaps_perplayer.value)) then
				if player.valid and not (player.exiting)
					P_DoPlayerExit(player)
					PTD.quitting = true
				end
				--print(3)
			else
				if player.valid and (player.pizzaface or player.spectator) and not ( (CV_PTD.lappingtype.value == 2) and (player.lapsdid > CV_PTD.maxlaps_perplayer.value) ) then
					player.exiting = 0
				end
				--print(4)
			end
		end
	end
end)
