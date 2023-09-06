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
		else
			PTBE.currentEvent = nil
		end
	else
		if P_RandomChance(FRACUNIT/16) then
			PTBE.currentEvent = {name = ({"mirrorPrelude", "super", "mini"})[P_RandomRange(1,3)]}
			if DiscordBot then
				if PTBE.currentEvent.name == "mirrorPrelude" then
					DiscordBot.Data.msgsrb2 = $ .. ":mirror: The Chaos Mirror glows...\nThe highest scoring player this round will force their character upon all next round!\n"
				elseif PTBE.currentEvent.name == "super" then
					DiscordBot.Data.msgsrb2 = $ .. ":superhero: Everyone is super now!\n"
				elseif PTBE.currentEvent.name == "super" then
					DiscordBot.Data.msgsrb2 = $ .. ":small_red_triangle_down: Everyone is mini now!\n"
				end
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
	if gametype ~= GT_PIZZATIMEDELUXE then return end
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
				PTBE.currentEvent = nil
			end
		elseif event.name == "mirror" and event.activated then
			CV_Set(CV_FindVar("forceskin"), -1)
			for player in players.iterate do
				R_SetPlayerSkin(player, player.preMirrorSkin)
			end
		end
	end
end)

--[[@param p player_t]]
addHook("PlayerThink", function (p)
	if gametype ~= GT_PIZZATIMEDELUXE then return end
	if not PTBE.currentEvent then return end
	if p.pstate == PST_DEAD or p.spectator or not p.realmo then return end
	if PTBE.currentEvent.name == "super" then
		p.rings = 9999
		if not p.powers[pw_super] and not p.exiting then p.powers[pw_super] = 2 end
		p.charflags = $ | SF_SUPER
	end
	if PTBE.currentEvent.name == "mini" then
		p.mo.scale = FU/3
		if p.pizzaface then
			p.mo.scale = $ * 2
		end
	end
end)

addHook("ThinkFrame", function ()
	if gametype ~= GT_PIZZATIMEDELUXE then return end
	if PTBE.currentEvent and PTBE.currentEvent.name == "super" then
		emeralds = 127
	else
		emeralds = 0
	end
end)