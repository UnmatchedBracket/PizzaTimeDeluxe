/*
	player has died text
	screams
	dynamic lap adjustments
*/

local lastScreamTic = -1

addHook("MobjDeath", function(mobj)
	local player = mobj.player
	if PTD.pizzatime then
		if not player.pizzaface then
			if CV_PTD.showdeaths.value and not PTD.timeover then
				chatprint("\x82*"..player.name.."\x82 has died.")
				if DiscordBot then
					DiscordBot.Data.msgsrb2 = $ .. "[" .. #player .. "]:skull: **" .. player.name .. "** died.\n"
				end
			end
			if P_RandomChance(FRACUNIT/4) and CV_PTD.screams.value and lastScreamTic ~= leveltime then
				lastScreamTic = leveltime
				S_StartSound(nil, sfx_pepdie)
			end
			if (PTD.dynamic_maxlaps - 1) > 0 and (PTD.dynamic_maxlaps - PTD.laps) > 0 then
				PTD.dynamic_maxlaps = $ - 1
				if (PTD.dynamic_maxlaps - 1) > 15 and (PTD.dynamic_maxlaps - PTD.laps) > 0  then
					PTD.dynamic_maxlaps = $ - 1 -- delete one extra maxlap if its more than 15 laps
				end
			end
		end
	end
end, MT_PLAYER)