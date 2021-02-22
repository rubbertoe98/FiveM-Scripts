--Original Author: rubbertoe98
--Edited & Patched By: Vyast

local takeHostage = {
	allowedWeapons = {
		`WEAPON_PISTOL`,
		`WEAPON_COMBATPISTOL`,
		`WEAPON_APPISTOL`,
		--etc add guns you want
	},
	InProgress = false,
	type = "",
	targetSrc = -1,
	agressor = {
		animDict = "anim@gangops@hostage@",
		anim = "perp_idle",
		flag = 49,
	},
	hostage = {
		animDict = "anim@gangops@hostage@",
		anim = "victim_idle",
		attachX = -0.24,
		attachY = 0.11,
		attachZ = 0.0,
		flag = 49,
	}
}

local function drawNativeNotification(text)
    SetTextComponentFormat("STRING")
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

local function playerPed()
	return PlayerPedId()
end

local function GetClosestPlayer(radius)
    local closestDistance, closestPlayer = -1, -1
    local playerPed = playerPed()
    local playerCoords = GetEntityCoords(playerPed)

    for k, v in ipairs(GetActivePlayers()) do
        local targetPed = GetPlayerPed(v)
        if targetPed ~= playerPed then
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(targetCoords - playerCoords)
            if closestDistance == -1 or closestDistance > distance then
                closestPlayer = v
                closestDistance = distance
            end
        end
    end

	if closestDistance ~= -1 and closestDistance <= radius then
		return closestPlayer
	else
		return nil
	end
end

local function ensureAnimDict(animDict)
    if not HasAnimDictLoaded(animDict) then
        RequestAnimDict(animDict)
        while not HasAnimDictLoaded(animDict) do
            Wait(0)
        end        
    end
    return animDict
end

local function drawNativeText(str)
	SetTextEntry_2("STRING")
	AddTextComponentString(str)
	EndTextCommandPrint(1000, 1)
end

RegisterCommand("takehostage", function()
	callTakeHostage()
end)

RegisterCommand("th", function()
	callTakeHostage()
end)

function callTakeHostage()
	local ped = playerPed()
	if not IsEntityDead(ped) then
		ClearPedSecondaryTask(ped)
		DetachEntity(ped, true, false)

		local canTakeHostage = false
		for i=1, #takeHostage.allowedWeapons do
			if HasPedGotWeapon(ped, takeHostage.allowedWeapons[i], false) then
				if GetAmmoInPedWeapon(ped, takeHostage.allowedWeapons[i]) > 0 then
					canTakeHostage = true 
					foundWeapon = takeHostage.allowedWeapons[i]
					break
				end 					
			end
		end

		if not canTakeHostage then 
			drawNativeNotification("You need a pistol with ammo to take a hostage at gunpoint!")
		end

		if not takeHostage.InProgress and canTakeHostage then			
			local closestPlayer = GetClosestPlayer(3)
			if closestPlayer then
				local targetSrc = GetPlayerServerId(closestPlayer)
				if targetSrc ~= -1 then
					SetCurrentPedWeapon(ped, foundWeapon, true)
					takeHostage.InProgress = true
					takeHostage.targetSrc = targetSrc
					TriggerServerEvent("TakeHostage:sync", targetSrc)
					ensureAnimDict(takeHostage.agressor.animDict)
					takeHostage.type = "agressor"
				else
					drawNativeNotification("~r~No one nearby to take as hostage!")
				end
			else
				drawNativeNotification("~r~No one nearby to take as hostage!")
			end
		end
	else
		drawNativeNotification("~r~You cannot do that while you are dead!")
	end
end 

RegisterNetEvent("TakeHostage:syncTarget")
AddEventHandler("TakeHostage:syncTarget", function(target)
	local targetPed = GetPlayerPed(GetPlayerFromServerId(target))
	takeHostage.InProgress = true
	ensureAnimDict(takeHostage.hostage.animDict)
	AttachEntityToEntity(playerPed(), targetPed, 0, takeHostage.hostage.attachX, takeHostage.hostage.attachY, takeHostage.hostage.attachZ, 0.5, 0.5, 0.0, false, false, false, false, 2, false)
	takeHostage.type = "hostage" 
end)

RegisterNetEvent("TakeHostage:releaseHostage")
AddEventHandler("TakeHostage:releaseHostage", function()
	local ped = playerPed()
	takeHostage.InProgress = false 
	takeHostage.type = ""
	DetachEntity(ped, true, false)
	ensureAnimDict("reaction@shove")
	TaskPlayAnim(ped, "reaction@shove", "shoved_back", 8.0, -8.0, -1, 0, 0, false, false, false)
	Citizen.Wait(250)
	ClearPedSecondaryTask(ped)
end)

RegisterNetEvent("TakeHostage:killHostage")
AddEventHandler("TakeHostage:killHostage", function()
	local ped = playerPed()
	takeHostage.InProgress = false 
	takeHostage.type = ""
	SetEntityHealth(ped, 0)
	DetachEntity(ped, true, false)
	ensureAnimDict("anim@gangops@hostage@")
	TaskPlayAnim(ped, "anim@gangops@hostage@", "victim_fail", 8.0, -8.0, -1, 168, 0, false, false, false)
end)

RegisterNetEvent("TakeHostage:cl_stop")
AddEventHandler("TakeHostage:cl_stop", function()
	local ped = playerPed()
	takeHostage.InProgress = false
	takeHostage.type = "" 
	ClearPedSecondaryTask(ped)
	DetachEntity(ped, true, false)
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local ped = playerPed()

		if takeHostage.type == "agressor" then
			if not IsEntityPlayingAnim(ped, takeHostage.agressor.animDict, takeHostage.agressor.anim, 3) then
				TaskPlayAnim(ped, takeHostage.agressor.animDict, takeHostage.agressor.anim, 8.0, -8.0, 100000, takeHostage.agressor.flag, 0, false, false, false)
			end
		elseif takeHostage.type == "hostage" then
			if not IsEntityPlayingAnim(ped, takeHostage.hostage.animDict, takeHostage.hostage.anim, 3) then
				TaskPlayAnim(ped, takeHostage.hostage.animDict, takeHostage.hostage.anim, 8.0, -8.0, 100000, takeHostage.hostage.flag, 0, false, false, false)
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do 
		Citizen.Wait(0)
		local ped = playerPed()

		if takeHostage.type == "agressor" then
			DisableControlAction(0, 24, true) -- disable attack
			DisableControlAction(0, 25, true) -- disable aim
			DisableControlAction(0, 47, true) -- disable weapon
			DisableControlAction(0, 58, true) -- disable weapon
			DisableControlAction(0, 21, true) -- disable sprint
			DisablePlayerFiring(ped, true)
			drawNativeText("Press [G] to release, [H] to kill")

			if IsEntityDead(ped) then	
				takeHostage.type = ""
				takeHostage.InProgress = false
				ensureAnimDict("reaction@shove")
				TaskPlayAnim(ped, "reaction@shove", "shove_var_a", 8.0, -8.0, -1, 168, 0, false, false, false)
				TriggerServerEvent("TakeHostage:releaseHostage", takeHostage.targetSrc)
			end 

			if IsDisabledControlJustPressed(0,47) then --release	
				takeHostage.type = ""
				takeHostage.InProgress = false 
				ensureAnimDict("reaction@shove")
				TaskPlayAnim(ped, "reaction@shove", "shove_var_a", 8.0, -8.0, -1, 168, 0, false, false, false)
				TriggerServerEvent("TakeHostage:releaseHostage", takeHostage.targetSrc)
			elseif IsDisabledControlJustPressed(0,74) then --kill 			
				takeHostage.type = ""
				takeHostage.InProgress = false 		
				ensureAnimDict("anim@gangops@hostage@")
				TaskPlayAnim(ped, "anim@gangops@hostage@", "perp_fail", 8.0, -8.0, -1, 168, 0, false, false, false)
				TriggerServerEvent("TakeHostage:killHostage", takeHostage.targetSrc)
				TriggerServerEvent("TakeHostage:stop",takeHostage.targetSrc)
				Wait(100)
				SetPedShootsAtCoord(ped, 0.0, 0.0, 0.0, 0)
			end
		elseif takeHostage.type == "hostage" then 
			DisableControlAction(0,21,true) -- disable sprint
			DisableControlAction(0,24,true) -- disable attack
			DisableControlAction(0,25,true) -- disable aim
			DisableControlAction(0,47,true) -- disable weapon
			DisableControlAction(0,58,true) -- disable weapon
			DisableControlAction(0,263,true) -- disable melee
			DisableControlAction(0,264,true) -- disable melee
			DisableControlAction(0,257,true) -- disable melee
			DisableControlAction(0,140,true) -- disable melee
			DisableControlAction(0,141,true) -- disable melee
			DisableControlAction(0,142,true) -- disable melee
			DisableControlAction(0,143,true) -- disable melee
			DisableControlAction(0,75,true) -- disable exit vehicle
			DisableControlAction(27,75,true) -- disable exit vehicle  
			DisableControlAction(0,22,true) -- disable jump
			DisableControlAction(0,32,true) -- disable move up
			DisableControlAction(0,268,true)
			DisableControlAction(0,33,true) -- disable move down
			DisableControlAction(0,269,true)
			DisableControlAction(0,34,true) -- disable move left
			DisableControlAction(0,270,true)
			DisableControlAction(0,35,true) -- disable move right
			DisableControlAction(0,271,true)
		end
	end
end)