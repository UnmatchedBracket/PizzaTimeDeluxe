rawset(_G, "CV_PTBE", {}) -- for console vars

COM_AddCommand("ptd_makepizza", function(player, arg)
	if gametype ~= GT_PIZZATIMEDELUXE then
		CONS_Printf(player, "Command must be ran in the Pizza Time Deluxe mode.")
		return
	end
	if tonumber(arg) == nil then
		CONS_Printf(player, "arg1 must be a number.")
		return
	end
	if not arg then
		CONS_Printf(player, "makepizza <playernum>")
		return
	end
	
	if players[tonumber(arg)] then
		local targetplayer = players[tonumber(arg)]
		if targetplayer and targetplayer.valid and not targetplayer.pizzaface then
			targetplayer.pizzaface = true
			chatprint("\x85*"..targetplayer.name.." has become a pizza!")
			if DiscordBot then
				DiscordBot.Data.msgsrb2 = $ .. "[" .. chosen_player .. "] **" .. players[chosen_player].name .. "** has magically become a pizza!\n"
			end
			PTBE_add_announcement(5*TICRATE,"\x85*"..targetplayer.name.." has become a pizza!")
		end
	else
		CONS_Printf(player, "Player does not exist")
	end
end,1)


COM_AddCommand("ptd_pizzatimenow", function(player)
	if gametype ~= GT_PIZZATIMEDELUXE then
		CONS_Printf(player, "Command must be ran in the Pizza Time Deluxe mode.")
		return
	end
	PTBE.PizzaTimeTrigger(player.mo)
end,1)

// ADDED FOR TESTING PURPOSES

CV_PTBE.x_positioning = CV_RegisterVar({
	name = "ptd_x_positioning",
	defaultvalue = "0",
	flags = CV_NETVAR,
	PossibleValue = CV_Unsigned
})

CV_PTBE.y_positioning = CV_RegisterVar({
	name = "ptd_y_positioning",
	defaultvalue = "0",
	flags = CV_NETVAR,
	PossibleValue = CV_Unsigned
})

CV_PTBE.forcelap = CV_RegisterVar({
	name = "ptd_forcelap",
	defaultvalue = "Off",
	flags = CV_NETVAR,
	PossibleValue = CV_OnOff, 
})

CV_PTBE.maxlaps = CV_RegisterVar({
	name = "ptd_maxlaps",
	defaultvalue = "16",
	flags = CV_NETVAR,
	PossibleValue = CV_Unsigned, 
})

CV_PTBE.maxlaps_perplayer = CV_RegisterVar({
	name = "ptd_maxlaps_perplayer",
	defaultvalue = "5",
	flags = CV_NETVAR,
	PossibleValue = CV_Unsigned, 
})

CV_PTBE.lappingtype = CV_RegisterVar({
	name = "ptd_lappingtype",
	defaultvalue = "2",
	flags = CV_NETVAR,
	PossibleValue = {shared = 1, perplayer = 2}, 
})

CV_PTBE.pizzatimestun = CV_RegisterVar({
	name = "ptd_pizzatimestun",
	defaultvalue = "10",
	flags = CV_NETVAR,
	PossibleValue = CV_Unsigned, 
})

CV_PTBE.fakelapstun = CV_RegisterVar({
	name = "ptd_fakelapstun",
	defaultvalue = "3",
	flags = CV_NETVAR,
	PossibleValue = CV_Unsigned, 
})

CV_PTBE.tpinv = CV_RegisterVar({
	name = "ptd_tpinv",
	defaultvalue = "3", -- IN SECONDS
	flags = CV_NETVAR,
	PossibleValue = CV_Unsigned, 
})

CV_PTBE.dynamiclaps = CV_RegisterVar({
	name = "ptd_dynamiclaps",
	defaultvalue = "Off",
	flags = CV_NETVAR,
	PossibleValue = CV_OnOff, 
})

CV_PTBE.showdeaths = CV_RegisterVar({
	name = "ptd_showdeaths",
	defaultvalue = "On",
	flags = CV_NETVAR,
	PossibleValue = CV_OnOff, 
})

CV_PTBE.pizzalaugh = CV_RegisterVar({ -- Whenever the pizzaface laugh plays when pizzatime starts.
	name = "ptd_pizzalaugh",
	defaultvalue = "On",
	flags = CV_NETVAR,
	PossibleValue = CV_OnOff, 
})

CV_PTBE.homework = CV_RegisterVar({
	name = "ptd_homework",
	defaultvalue = "Off",
	flags = CV_NETVAR,
	PossibleValue = CV_OnOff, 
})

CV_PTBE.collisionsystem = CV_RegisterVar({
	name = "ptd_collisionsystem",
	defaultvalue = "1",
	flags = CV_NETVAR,
	PossibleValue = {line = 1},  -- , locationcheck = 2
})

CV_PTBE.timelimit = CV_RegisterVar({
	name = "ptd_timelimit",
	defaultvalue = "4", -- in minutes
	flags = CV_NETVAR,
	PossibleValue = CV_Unsigned, 
})

CV_PTBE.pizzachoosetype = CV_RegisterVar({
	name = "ptd_pizzachoosetype",
	defaultvalue = "3",
	flags = CV_NETVAR,
	PossibleValue = {firsttrigger = 1, random = 2, allbutfirst = 3}, 
})

CV_PTBE.pizzacount = CV_RegisterVar({
	name = "ptd_pizzacount",
	defaultvalue = "1",
	flags = CV_NETVAR,
	PossibleValue = CV_Natural, 
})

CV_PTBE.pizzatpcooldown = CV_RegisterVar({
	name = "ptd_pizzatpcooldown",
	defaultvalue = "5",
	flags = CV_NETVAR,
	PossibleValue = CV_Unsigned, 
})

CV_PTBE.pizzatpstuntime = CV_RegisterVar({
	name = "ptd_pizzatpstuntime",
	defaultvalue = "2",
	flags = CV_NETVAR,
	PossibleValue = CV_Unsigned, 
})

CV_PTBE.nomusic = CV_RegisterVar({
	name = "ptd_nomusic",
	defaultvalue = "off",
	PossibleValue = CV_OnOff, 
})

CV_PTBE.scoreonkill = CV_RegisterVar({
	name = "ptd_scoreonkill",
	defaultvalue = "on",
	flags = CV_NETVAR,
	PossibleValue = CV_OnOff, 
})

CV_PTBE.killwhilerunning = CV_RegisterVar({
	name = "ptd_killwhilerunning",
	defaultvalue = "on",
	flags = CV_NETVAR,
	PossibleValue = CV_OnOff, 
})

CV_PTBE.screams = CV_RegisterVar({
	name = "ptd_screams",
	defaultvalue = "off",
	flags = CV_SAVE,
	PossibleValue = CV_OnOff, 
})


CV_PTBE.pizzamask = CV_RegisterVar({
	name = "ptd_pizzamask",
	defaultvalue = "on",
	flags = CV_NETVAR,
	PossibleValue = CV_OnOff, 
})


CV_PTBE.pizzastyle = CV_RegisterVar({
	name = "ptd_pizzastyle",
	defaultvalue = "pizzaface",
	flags = CV_SAVE|CV_CALL,
	PossibleValue = {pizzaface = 1, coneball = 2, eggman = 3}, 
	func = function (cv)
		local name = ({
			[1] = "Pizzaface",
			[2] = "Coneball",
			[3] = "Eggman"
		})[cv.value]
		if consoleplayer then
			CONS_Printf(consoleplayer, "You will now appear as " .. name .. " when you're the villian of Pizza Time.")
		else
			print("You will now appear as " .. name .. " when you're the villian of Pizza Time.")
		end
	end 
})

local luaOnly = "iamlua" .. P_RandomFixed()

COM_AddCommand("_ptd_pizzastyle_sync", function(player, blah, set)
	if blah ~= luaOnly then
		CONS_Printf(player, "Don't run this manually! Instead, set `ptd_pizzastyle`")
		return
	end
	
	player.PTBE_pizzastyle = tonumber(set)
end)

addHook("ThinkFrame", function ()
	if not consoleplayer then return end
	
	if consoleplayer.PTBE_pizzastyle ~= CV_PTBE.pizzastyle.value then
		COM_BufInsertText(consoleplayer, "_ptd_pizzastyle_sync " .. luaOnly .. " " .. CV_PTBE.pizzastyle.value)
	end
end)


CV_PTBE.oldmusic = CV_RegisterVar({
	name = "ptd_oldmusic",
	defaultvalue = "off",
	flags = CV_SAVE|CV_CALL,
	PossibleValue = CV_OnOff, 
	func = function (cv)
		if not consoleplayer then return end
		if cv.value then
			CONS_Printf(consoleplayer, "Lap 4 will now play Glucose Getaway by RodMod.")
		else
			CONS_Printf(consoleplayer, "Lap 4 will now play Pasta La Vista by Oofator.")
		end
	end
})

rawset(_G, "CV_PTJE", CV_PTBE)