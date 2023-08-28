-- mirror of chaos and stuff

PTBE.currentEvent = nil

local frozen = true

addHook("MapLoad", function ()
	if gametype ~= GT_PIZZATIMEDELUXE then return end

	if PTBE.currentEvent then
		if PTBE.currentEvent.name == "mirror" then
			if PTBE.currentEvent.activated then
				CV_Set(CV_FindVar("forceskin"), -1)
				PTBE.currentEvent = nil
			else
				if DiscordBot then
					DiscordBot.Data.msgsrb2 = $ .. ":mirror: The Chaos Mirror activates!\nChosen skin: " .. skins[PTBE.currentEvent.skin].realname.."!\n"
				end
				PTBE.currentEvent.activated = true
				for player in players.iterate do
					player.preMirrorSkin = player.skin
					R_SetPlayerSkin(player, PTBE.currentEvent.skin)
				end
				CV_Set(CV_FindVar("forceskin"), PTBE.currentEvent.skin)
			end
		end
	else
		if P_RandomChance(FRACUNIT/10) then
			PTBE.currentEvent = {name = "mirrorPrelude"}
			if DiscordBot then
				DiscordBot.Data.msgsrb2 = $ .. ":mirror: The Chaos Mirror glows...\nThe highest scoring player this round will force their character upon all next round!\n"
			end
		end
	end
	if PTBE.currentEvent then
		print(PTBE.currentEvent.name .. " event")
	else
		print("no event")
	end
end)

addHook("IntermissionThinker", function ()
	if PTBE.currentEvent then
		local event = PTBE.currentEvent
		if event.name == "mirrorPrelude" then
			local maxplayer = nil
			local maxscore = -4
			for player in players.iterate do
				if player and player.pstate ~= PST_DEAD then
					if player.score > maxscore then
						maxplayer = player
						maxscore = player.score
					end
				end
			end
			if maxplayer then
				PTBE.currentEvent = {name = "mirror", skin = maxplayer.skin, activated = false}
			else
				PTBE.currentEvent = {name = "mirrorBroken"}
			end
		elseif event.name == "mirror" and event.activated then
			CV_Set(CV_FindVar("forceskin"), -1)
			for player in players.iterate do
				R_SetPlayerSkin(player, player.preMirrorSkin)
			end
		end
	end
end)

addHook("ThinkFrame", function ()
	
end)