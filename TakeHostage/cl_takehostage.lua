-----------------------------------------------------------------
--TakeHostage by Robbster, do not redistrbute without permission--
------------------------------------------------------------------

local hostageAllowedWeapons = {
	`WEAPON_PISTOL`,
	`WEAPON_COMBATPISTOL`,
	--etc add guns you want
}
local animations = {
	take = {
		source = {
			dictionary = "anim@gangops@hostage@",
			animation = "perp_idle",
			flag = 49,
			length = 100000,
		},
		target = {
			dictionary = "anim@gangops@hostage@",
			animation = "victim_idle",
			flag = 49,
			length = 100000,			
		},
	},
	kill = {
		source = {
			dictionary = "anim@gangops@hostage@",
			animation = "perp_fail",
			flag = 168,
			length = 0.2,
		},
		target = {
			dictionary = "anim@gangops@hostage@",
			animation = "victim_fail",
			flag = 0,
			length = 0.2,			
		},
	},
	release = {
		source = {
			dictionary = "reaction@shove",
			animation = "shove_var_a",
			flag = 120,
			length = 100000,
		},
		target = {
			dictionary = "reaction@shove",
			animation = "shoved_back",
			flag = 0,
			length = 100000,			
		},
	},
}
local attachment = {
	offset = vector3(-0.24, 0.11, 0.0),
	rotation = vector3(0.5, 0.5, 0.0),
}

local holdingHostageInProgress = false

function takeHostage(src, args, raw)
	local playerPed = PlayerPedId()
	local canTakeHostage = false
	local weapon = nil

	ClearPedSecondaryTask(playerPed)
	DetachEntity(playerPed, true, false)
          
	for i = 1, #hostageAllowedWeapons do
		if HasPedGotWeapon(playerPed, hostageAllowedWeapons[i], false) then
			if GetAmmoInPedWeapon(playerPed, hostageAllowedWeapons[i]) > 0 then
				canTakeHostage = true 
				weapon = hostageAllowedWeapons[i]
				break
			end 					
		end
	end

	if not canTakeHostage then 
		drawNativeNotification("You need a pistol with ammo to take a hostage at gunpoint!")
	end

	if not holdingHostageInProgress and canTakeHostage then		
		local closestPlayer = GetClosestPlayer(2)
		local targetId = GetPlayerServerId(closestPlayer)

		if closestPlayer ~= nil then
			SetCurrentPedWeapon(playerPed, weapon, true)
			holdingHostageInProgress = true
			holdingHostage = true 
			print("triggering cmg3_animations:sync")
			TriggerServerEvent('cmg3_animations:sync', targetId, animations.take, true)
		else
			--print("[CMG Anim] No player nearby")
			drawNativeNotification("No one nearby to take as hostage!")
		end 
	end
	canTakeHostage = false 
end 

RegisterCommand("takehostage", takeHostage)
RegisterCommand("th", takeHostage)

RegisterNetEvent('cmg3_animations:syncTarget')
AddEventHandler('cmg3_animations:syncTarget', function(target, animation, attach)
	local playerPed = PlayerPedId()
	local targetPed = GetPlayerPed(GetPlayerFromServerId(target))
	if holdingHostageInProgress then 
		holdingHostageInProgress = false 
	else 
		holdingHostageInProgress = true
	end

	beingHeldHostage = true 
	--print("triggered cmg3_animations:syncTarget")
	RequestAnimDict(animation.dictionary)

	while not HasAnimDictLoaded(animation.dictionary) do
		Citizen.Wait(10)
	end

	if attach then 
		--print("attaching entity")
		AttachEntityToEntity(playerPed, targetPed, 0, attachment.offset.x, attachment.offset.y, attachment.offset.z, attachment.rotation.x, attachment.rotation.y, attachment.rotation.z, false, false, false, false, 2, false)
	else 
		--print("not attaching entity")
	end

	if animation.animation == "victim_fail" then 
		SetEntityHealth(playerPed, 0)
		TaskPlayAnim(playerPed, animation.dictionary, animation.animation, 8.0, -8.0, animation.length, animation.flag, 0, false, false, false)
		beingHeldHostage = false 
		holdingHostageInProgress = false 
	elseif animation.animation == "shoved_back" then 
		holdingHostageInProgress = false 
		TaskPlayAnim(playerPed, animation.dictionary, animation.animation, 8.0, -8.0, animation.length, animation.flag, 0, false, false, false)
		beingHeldHostage = false 
	else
		TaskPlayAnim(playerPed, animation.dictionary, animation.animation, 8.0, -8.0, animation.length, animation.flag, 0, false, false, false)
	end
end)

RegisterNetEvent('cmg3_animations:syncMe')
AddEventHandler('cmg3_animations:syncMe', function(animation)
	local playerPed = PlayerPedId()
	--print("triggered cmg3_animations:syncMe")
	ClearPedSecondaryTask(playerPed)
	RequestAnimDict(animation.dictionary)
	while not HasAnimDictLoaded(animation.dictionary) do
		Citizen.Wait(10)
	end
	--Wait(500)

	TaskPlayAnim(playerPed, animation.dictionary, animation.animation, 8.0, -8.0, animation.length, animation.flag, 0, false, false, false)

	if animation == "perp_fail" then 
		SetPedShootsAtCoord(playerPed, 0.0, 0.0, 0.0, 0)
		holdingHostageInProgress = false 
	end
	if animation == "shove_var_a" then 
		Wait(900)
		ClearPedSecondaryTask(playerPed)
		holdingHostageInProgress = false 
	end
end)

RegisterNetEvent('cmg3_animations:cl_stop')
AddEventHandler('cmg3_animations:cl_stop', function()
	local playerPed = PlayerPedId()
	holdingHostageInProgress = false
	beingHeldHostage = false 
	holdingHostage = false 
	ClearPedSecondaryTask(playerPed)
	DetachEntity(playerPed, true, false)
end)

function GetClosestPlayer(radius)
    local players = GetActivePlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed, false)

    for i = 1, #players do
        local targetPed = GetPlayerPed(players[i])
        if playerPed ~= targetPed then
            local targetCoords = GetEntityCoords(targetPed, false)
            local distance = #(playerCoords - targetCoords)

            if closestDistance == -1 or closestDistance > distance then
                closestPlayer = players[i]
                closestDistance = distance
            end
        end
    end

	if closestDistance <= radius then
		return closestPlayer
	else
		return nil
	end
end

Citizen.CreateThread(function()
	while true do 
		if holdingHostage then
			local playerPed = PlayerPedId()
			if IsEntityDead(playerPed) then
				--print("release this mofo")			
				holdingHostage = false
				holdingHostageInProgress = false 
				local closestPlayer = GetClosestPlayer(2)
				local targetId = GetPlayerServerId(closestPlayer)
				TriggerServerEvent("cmg3_animations:stop", targetId)
				Wait(100)
				releaseHostage()
			end 
			DisableControlAction(0,24,true) -- disable attack
			DisableControlAction(0,25,true) -- disable aim
			DisableControlAction(0,47,true) -- disable weapon
			DisableControlAction(0,58,true) -- disable weapon
			DisablePlayerFiring(playerPed, true)
			local playerCoords = GetEntityCoords(playerPed)
			DrawText3D(playerCoords.x,playerCoords.y,playerCoords.z,"Press [G] to release, [H] to kill")
			if IsDisabledControlJustPressed(0,47) then --release
				--print("release this mofo")			
				holdingHostage = false
				holdingHostageInProgress = false 
				local closestPlayer = GetClosestPlayer(2)
				local targetId = GetPlayerServerId(closestPlayer)
				TriggerServerEvent("cmg3_animations:stop", targetId)
				Wait(100)
				releaseHostage()
			elseif IsDisabledControlJustPressed(0,74) then --kill 
				--print("kill this mofo")				
				holdingHostage = false
				holdingHostageInProgress = false 		
				local closestPlayer = GetClosestPlayer(2)
				local targetId = GetPlayerServerId(closestPlayer)
				TriggerServerEvent("cmg3_animations:stop", targetId)				
				killHostage()
			end
		end
		if beingHeldHostage then 
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
		Wait(0)
	end
end)

function DrawText3D(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    
    if onScreen then
        SetTextScale(0.19, 0.19)
        SetTextFont(0)
        SetTextProportional(1)
        -- SetTextScale(0.0, 0.55)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 55)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
    end
end

function releaseHostage()
	local closestPlayer = GetClosestPlayer(2)
	local targetId = GetPlayerServerId(closestPlayer)
	if closestPlayer ~= nil then
		print("triggering cmg3_animations:sync")
		TriggerServerEvent('cmg3_animations:sync', targetId, animations.release, false)
	else
		print("[CMG Anim] No player nearby")
	end
end 

function killHostage()
	local closestPlayer = GetClosestPlayer(2)
	local targetId = GetPlayerServerId(closestPlayer)
	if closestPlayer ~= nil then
		print("triggering cmg3_animations:sync")
		TriggerServerEvent('cmg3_animations:sync', targetId, animations.kill, false)
	else
		print("[CMG Anim] No player nearby")
	end	
end 

function drawNativeNotification(text)
    SetTextComponentFormat('STRING')
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end