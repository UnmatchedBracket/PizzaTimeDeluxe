local pizzatimemusic = [[{
    "songs": {
        "It's Pizza Time!": "PIZTIM",
        "The Death That I Deservioli": "DEAOLI",
        "Pillar John's Revenge": "PIJORE",
        "Extreme (OLD)": "GLUWAY",
        "Extreme (NEW)": "PALAVI"
    },
    "musicmods": [
		"musicmodpt.wad"
	]
}]]

dofile "Libraries/json.lua"

dofile "HUD Animation/0_Init.lua"
dofile "HUD Animation/1_UpdatePerFrame.lua"

dofile "Bar Animation Class/1_Init.lua"

dofile "0_customhudlib.lua"

dofile "1_Main.lua"

dofile "2_Console.lua"

dofile "Hooks/1_PlayerThinks.lua"
dofile "Hooks/2_PlayerDeath.lua"
dofile "Hooks/3_PlayerTweaks.lua"
dofile "Hooks/4_LineTriggerSystem.lua"

dofile "3_Libs.lua"
dofile "4_ExitHandle.lua"
dofile "5_MusicHandle.lua"
dofile "6_Pizzaface.lua"
dofile "7_HUDHandle.lua"
dofile "8_RandomEvents.lua"
dofile "9_CustomDiscordLeaderboard.lua"

//hi, nick here with some code for clientside music changing, enjoy gaming with custom music to your hearts content

local file = io.openlocal('client/PizzaTimeDeluxe_Music.txt', 'r+')
if not file
	print('making file')
	local writeitup = io.openlocal('client/PizzaTimeDeluxe_Music.txt', 'w+')
	writeitup:write(pizzatimemusic)
	file = writeitup

	local shit = json.parse(pizzatimemusic)
	for _,i in pairs(shit.musicmods)
		COM_BufInsertText(consoleplayer, 'addfile '..i)
	end
else
	local shit = json.parse(file:read('*a'))
	for _,i in pairs(shit.musicmods)
		COM_BufInsertText(consoleplayer, 'addfile '..i)
	end
end