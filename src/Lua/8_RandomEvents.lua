-- mirror of chaos and stuff

PTD.currentEvent = nil

local frozen = true

addHook("MapLoad", function ()
	if gametype ~= GT_PIZZATIMEDELUXE then return end

	if PTD.currentEvent then
		if PTD.currentEvent.name == "mirror" then
			if PTD.currentEvent.activated then
				CV_Set(CV_FindVar("forceskin"), -1)
				PTD.currentEvent = nil
			else
				if DiscordBot then
					DiscordBot.Data.msgsrb2 = $ .. ":mirror: The Chaos Mirror activates!\nChosen skin: " .. skins[PTD.currentEvent.skin].realname.."!\n"
				end
				PTD.currentEvent.activated = true
				for player in players.iterate do
					player.preMirrorSkin = player.skin
					R_SetPlayerSkin(player, PTD.currentEvent.skin)
				end
				CV_Set(CV_FindVar("forceskin"), PTD.currentEvent.skin)
			end
		else
			PTD.currentEvent = nil
		end
	else
		if P_RandomChance(FRACUNIT/16) then
			PTD.currentEvent = {name = ({"super", "mini"})[P_RandomRange(1,2)]}
			if DiscordBot then
				if PTD.currentEvent.name == "mirrorPrelude" then
					DiscordBot.Data.msgsrb2 = $ .. ":mirror: The Chaos Mirror glows...\nThe highest scoring player this round will force their character upon all next round!\n"
				elseif PTD.currentEvent.name == "super" then
					DiscordBot.Data.msgsrb2 = $ .. ":superhero: Everyone is super now!\n"
				elseif PTD.currentEvent.name == "super" then
					DiscordBot.Data.msgsrb2 = $ .. ":small_red_triangle_down: Everyone is mini now!\n"
				end
			end
		end
	end
	if PTD.currentEvent then
		print(PTD.currentEvent.name .. " event")
	else
		print("no event")
	end
end)

addHook("IntermissionThinker", function ()
	if gametype ~= GT_PIZZATIMEDELUXE then return end
	if PTD.currentEvent then
		local event = PTD.currentEvent
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
				PTD.currentEvent = {name = "mirror", skin = maxplayer.skin, activated = false}
			else
				PTD.currentEvent = nil
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
	if p.ptd_wasmini then
		p.mo.scale = FU
		p.ptd_wasmini = false
	end
	if gametype ~= GT_PIZZATIMEDELUXE then return end
	if not PTD.currentEvent then return end
	if p.pstate == PST_DEAD or p.spectator or not p.realmo then return end
	if PTD.currentEvent.name == "super" then
		p.rings = 9999
		if not p.powers[pw_super] and not p.exiting then p.powers[pw_super] = 2 end
		p.charflags = $ | SF_SUPER
	end
	if PTD.currentEvent.name == "mini" then
		p.mo.scale = FU/3
		if p.pizzaface then
			p.mo.scale = $ * 2
		end
		p.ptd_wasmini = true
	end
end)

addHook("ThinkFrame", function ()
	if gametype ~= GT_PIZZATIMEDELUXE then return end
	if PTD.currentEvent and PTD.currentEvent.name == "super" then
		emeralds = 127
	else
		emeralds = 0
	end
end)