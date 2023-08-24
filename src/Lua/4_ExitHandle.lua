
-- Nothing really needed to be touched here (Maybe)

addHook("ThinkFrame", function()
	if gametype ~= GT_PIZZATIMEBRAC then return end
	
	local exitingCount, playerCount, pizzaCount = BRAC_COUNT()
	
	-- better than the old code since it started a new iteration on every IF block.
	
	for player in players.iterate() do
		if leveltime then -- just a safety check
			if (CV_PTBE.lappingtype.value == 2) and (player.lapsdid > CV_PTBE.maxlaps_perplayer.value) then
				P_DoPlayerExit(player)
			elseif ((playerCount > 1) and not (pizzaCount) and PTBE.pizzatime) or (exitingCount == playerCount) then
				if player.valid and not (player.exiting)
					P_DoPlayerExit(player)
				end
				--print(2)
			elseif (CV_PTBE.maxlaps.value and PTBE.laps > CV_PTBE.maxlaps.value and not CV_PTBE.dynamiclaps.value) or PTBE.quitting 
			or (PTBE.dynamic_maxlaps and PTBE.laps > PTBE.dynamic_maxlaps and CV_PTBE.dynamiclaps.value) 
			and not ((CV_PTBE.lappingtype.value == 2) and (player.lapsdid > CV_PTBE.maxlaps_perplayer.value)) then
				if player.valid and not (player.exiting)
					P_DoPlayerExit(player)
					PTBE.quitting = true
				end
				--print(3)
			else
				if player.valid and (player.pizzaface or player.spectator) and not ( (CV_PTBE.lappingtype.value == 2) and (player.lapsdid > CV_PTBE.maxlaps_perplayer.value) ) then
					player.exiting = 0
				end
				--print(4)
			end
		end
	end
end)
