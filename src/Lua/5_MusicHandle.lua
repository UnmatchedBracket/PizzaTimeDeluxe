-- nothing needed to be changed here.
addHook("ThinkFrame", function()
	if gametype ~= GT_PIZZATIMEBRAC then return end
	if CV_PTBE.nomusic.value then return end
	
	if not consoleplayer then return end
	
	if PTBE.pizzatime then
		if consoleplayer.spectator then
			local originalname = mapheaderinfo[gamemap].musname
			if mapmusname ~= originalname then
				S_ChangeMusic(originalname, true)
				mapmusname = originalname
			end
			return
		end
		local laps = consoleplayer.lapsdid
		if consoleplayer.exiting and consoleplayer.pstate ~= PST_DEAD then
			laps = $ - 1
		end
		local lap4 = CV_PTBE.oldmusic.value and "GLUWAY" or "PASTVI"
		if laps <= 1 and mapmusname ~= "PIZTIM" then
			S_ChangeMusic("PIZTIM", true)
			mapmusname = "PIZTIM"
		elseif laps == 2 and mapmusname ~= "DEAOLI" then
			S_ChangeMusic("DEAOLI", true)
			mapmusname = "DEAOLI"
		elseif laps == 3 and mapmusname ~= "PIJORE" then
			S_ChangeMusic("PIJORE", true)
			mapmusname = "PIJORE"
		elseif laps == 4 and mapmusname ~= lap4 then
			S_ChangeMusic(lap4, true)
			mapmusname = lap4
		end
	end
end)