local a = 7
local b = {}
local c = true
local d = {}
Citizen.CreateThread(
    function()
        Wait(500)
        while true do
            if not globalHideUi then
                if c then
                    local e = CMG.getPlayerPed()
                    for f, g in ipairs(GetActivePlayers()) do
                        local h = GetPlayerPed(g)
                        if h ~= e then
                            if b[g] then
                                if b[g] < a then
                                    local i = d[g]
                                    if NetworkIsPlayerTalking(g) then
                                        SetMpGamerTagAlpha(i, 4, 255)
                                        SetMpGamerTagColour(i, 0, 9)
                                        SetMpGamerTagColour(i, 4, 0)
                                        SetMpGamerTagVisibility(i, 4, true)
                                    else
                                        SetMpGamerTagColour(i, 0, 0)
                                        SetMpGamerTagColour(i, 4, 0)
                                        SetMpGamerTagVisibility(i, 4, false)
                                    end
                                end
                            end
                        end
                    end
                end
            end
            Citizen.Wait(0)
        end
    end
)
Citizen.CreateThread(
    function()
        while true do
            b = {}
            local e = CMG.getPlayerPed()
            local j = CMG.getPlayerCoords()
            for f, g in ipairs(GetActivePlayers()) do
                local k = GetPlayerPed(g)
                local l = GetPlayerServerId(g)
                if k ~= e and (IsEntityVisible(k) or not CMG.clientGetPlayerIsStaff(l)) then
                    local m = GetEntityCoords(k)
                    b[g] = #(j - m)
                end
            end
            if not CMG.isStaffedOn() then
                a = 7
            end
            Citizen.Wait(1000)
        end
    end
)
Citizen.CreateThread(
    function()
        while true do
            for f, g in ipairs(GetActivePlayers()) do
                local n = b[g]
                if n and n < a and c then
                    d[g] = CreateFakeMpGamerTag(GetPlayerPed(g), GetPlayerServerId(g), false, false, "", 0)
                    SetMpGamerTagVisibility(d[g], 3, true)
                elseif d[g] then
                    RemoveMpGamerTag(d[g])
                    d[g] = nil
                end
                Wait(0)
            end
            Wait(0)
        end
    end
)
SetMpGamerTagsUseVehicleBehavior(false)
RegisterCommand(
    "farids",
    function(o, p, q)
        if CMG.getStaffLevel() > 2 and CMG.isStaffedOn() then
            local r = p[1]
            if r ~= nil and tonumber(r) then
                a = tonumber(r) + 000.1
                SetMpGamerTagsVisibleDistance(a)
            else
                tvRP.notify("~r~Please enter a valid range! (/farids [range])")
            end
        end
    end
)
RegisterCommand(
    "faridsreset",
    function(o, p, q)
        if CMG.getStaffLevel() > 2 then
            a = 7
            SetMpGamerTagsVisibleDistance(100.0)
        end
    end
)
RegisterCommand(
    "hideids",
    function()
        c = false
    end
)
RegisterCommand(
    "showids",
    function()
        c = true
    end
)
