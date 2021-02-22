--Original Author: rubbertoe98
--Edited & Patched By: Vyast

local takingHostage, takenHostage = {}, {}

local function log(info)
	print(info)
end

local function getCoords(player)
	local coords = nil
	if player ~= nil then
		local ped = GetPlayerPed(player)
		if ped ~= nil then
			coords = GetEntityCoords(ped)
		end
	end
	return coords
end

local function getName(player)
	local name = nil
	if player ~= nil then
		name = GetPlayerName(player)
	end
	return name
end

RegisterServerEvent("TakeHostage:sync")
AddEventHandler("TakeHostage:sync", function(target)
	local src = source
	if src ~= nil and target ~= nil and target ~= -1 then
		local srcName = getName(src)
		if srcName ~= nil then
			local srcCoords, tgtCoords = getCoords(src), getCoords(target)
			if srcCoords ~= nil and tgtCoords ~= nil then
				local dist = #(srcCoords - tgtCoords)
				if dist <= 5.0 then
					TriggerClientEvent("TakeHostage:syncTarget", target, src)
					takingHostage[src] = target
					takenHostage[target] = src
				else
					log('^2TakeHostage: ^1'..srcName..'['..tonumber(src)..']^0 is attempting to exploit the event "sync"! Their distance from the target player is ^1'..dist..'^0.')
				end
			end
		end
	end
end)

RegisterServerEvent("TakeHostage:releaseHostage")
AddEventHandler("TakeHostage:releaseHostage", function(target)
	local src = source
	if src ~= nil and target ~= nil and target ~= -1 then
		local srcName = getName(src)
		if srcName ~= nil then
			local srcCoords, tgtCoords = getCoords(src), getCoords(target)
			if srcCoords ~= nil and tgtCoords ~= nil then
				local dist = #(srcCoords - tgtCoords)
				if dist <= 5.0 then
					TriggerClientEvent("TakeHostage:releaseHostage", target, src)
					takingHostage[src] = nil
					takenHostage[target] = nil
				else
					log('^2TakeHostage: ^1'..srcName..'['..tonumber(src)..']^0 is attempting to exploit the event "releaseHostage"! Their distance from the target player is ^1'..dist..'^0.')
				end
			end
		end
	end
end)

RegisterServerEvent("TakeHostage:killHostage")
AddEventHandler("TakeHostage:killHostage", function(target)
	local src = source
	if src ~= nil and target ~= nil and target ~= -1 then
		local srcName = getName(src)
		if srcName ~= nil then
			local srcCoords, tgtCoords = getCoords(src), getCoords(target)
			if srcCoords ~= nil and tgtCoords ~= nil then
				local dist = #(srcCoords - tgtCoords)
				if dist <= 5.0 then
					TriggerClientEvent("TakeHostage:killHostage", target, src)
					takingHostage[src] = nil
					takenHostage[target] = nil
				else
					log('^2TakeHostage: ^1'..srcName..'['..tonumber(src)..']^0 is attempting to exploit the event "killHostage"! Their distance from the target player is ^1'..dist..'^0.')
				end
			end
		end
	end
end)

RegisterServerEvent("TakeHostage:stop")
AddEventHandler("TakeHostage:stop", function(target)
	local src = source
	if src ~= nil and target ~= nil and target ~= -1 then
		if takingHostage[src] then
			TriggerClientEvent("TakeHostage:cl_stop", target)
			takingHostage[src] = nil
			takenHostage[target] = nil
		elseif takenHostage[src] then
			TriggerClientEvent("TakeHostage:cl_stop", target)
			takenHostage[src] = nil
			takingHostage[target] = nil
		end
	end
end)

AddEventHandler('playerDropped', function(reason)
	local src = source
	if src ~= nil then
		if takingHostage[src] then
			TriggerClientEvent("TakeHostage:cl_stop", takingHostage[src])
			takenHostage[takingHostage[src]] = nil
			takingHostage[src] = nil
		end

		if takenHostage[src] then
			TriggerClientEvent("TakeHostage:cl_stop", takenHostage[src])
			takingHostage[takenHostage[src]] = nil
			takenHostage[src] = nil
		end
	end
end)