freeslot("MT_TOPPIN", "S_TOPPIN_CAGE", "S_TOPPIN_SONK_FREE", "S_TOPPIN_SONK_STND", "S_TOPPIN_SONK_RUN", "SPR_TPNC", "SPR_SONK")
freeslot("sfx_tppngt")

mobjinfo[MT_TOPPIN] = {
	doomednum = 1612,
	spawnstate = S_TOPPIN_CAGE,
	spawnhealth = 1000,
	deathstate = S_NULL,
	radius = 16*FU,
	height = 48*FU,
	flags = MF_NOCLIP|MF_SPECIAL
}

states[S_TOPPIN_CAGE] = {
    sprite = SPR_TPNC,
    frame = A,
    tics = -1,
    nextstate = S_TOPPIN_CAGE
}

states[S_TOPPIN_SONK_FREE] = {
    sprite = SPR_SONK,
    frame = A,
    tics = 15,
    nextstate = S_TOPPIN_SONK_STND
}

states[S_TOPPIN_SONK_STND] = {
    sprite = SPR_SONK,
    frame = B,
    tics = -1,
    nextstate = S_TOPPIN_SONK_STND
}

states[S_TOPPIN_SONK_RUN] = {
    sprite = SPR_SONK,
    frame = C,
    tics = -1,
    nextstate = S_TOPPIN_SONK_STND
}

rawset(_G, "toppinTypes", {
    {
        free = S_TOPPIN_SONK_FREE,
        stand = S_TOPPIN_SONK_STND,
        run = S_TOPPIN_SONK_RUN
    }
})

local trailDelay = TICRATE/3

addHook("PlayerThink", function (p)
    local origin = p.mo
    local trailCount = 0
    while origin.toppintrail do
        origin = origin.toppintrail
        trailCount = $ + trailDelay
    end
    print("trail " .. trailCount)
    if not p.mo.movetrail then
        p.mo.movetrail = {}
    end
    table.insert(p.mo.movetrail, {p.mo.x, p.mo.y, p.mo.z}, 1)
    while #p.mo.movetrail > trailCount do
        table.remove(p.mo.movetrail)
    end
end)

addHook("TouchSpecial", function (special, toucher)
    if special.state == S_TOPPIN_CAGE then
        local toppinNum = P_RandomRange(1, #toppinTypes)
        special.toppinType = toppinNum
        local trailNum = 1
        if toucher.toppintrail then
            local origin = toucher.toppintrail
            while origin.toppintrail do
                origin = origin.toppintrail
                trailNum = $ + 1
            end
            special.target = origin
            origin.toppintrail = special
        else
            special.target = toucher
            toucher.toppintrail = special
        end
        special.trueorigin = toucher
        special.numInTrail = trailNum
        special.state = toppinTypes[toppinNum].free
        S_StartSound(special, sfx_tppngt)
    end
    return true
end, MT_TOPPIN)

local keepAway = 64*FU

addHook("MobjThinker", function (mo)
    if not mo.toppinType then return end -- prob not released
    local toppinInfo = toppinTypes[mo.toppinType]
    if mo.state == toppinInfo.free then return end --finish the anim first
    -- follow
    -- later maybe keep track of the player's past positions?
    /*
    local dist = P_AproxDistance(mo.x - mo.target.x, mo.y - mo.target.y)
    if dist > keepAway+FU*4 then
        local moveBy = (dist - keepAway) / 8
        local moveAngle = R_PointToAngle2(mo.x, mo.y, mo.target.x, mo.target.y)
        mo.momx = FixedMul(cos(moveAngle), moveBy)
        mo.momy = FixedMul(sin(moveAngle), moveBy)

        if mo.state ~= toppinInfo.run then
            mo.state = toppinInfo.run
        end
    else
        if mo.state ~= toppinInfo.stand then
            mo.state = toppinInfo.stand
        end
    end*/
    local trailList = mo.trueorigin.movetrail
    print(trailDelay*mo.numInTrail, #trailList)
    local pos = trailList[min(trailDelay*mo.numInTrail, #trailList)]
    P_MoveOrigin(mo, unpack(pos))
end, MT_TOPPIN)