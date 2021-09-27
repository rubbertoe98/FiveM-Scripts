--Original Author: rubbertoe98
--Edited & Patched By: Vyast

local takingHostage, takenHostage = {}, {}
-- Credits to discord docs for the api ref
function SendToDiscord(name, msg, col)
	local embed = {
		{
			["color"] = 9109247, -- If you have an issue with the string like this change it to "9109247"
			["title"] = "**"..name.."**",
			["description"] = msg,
			["footer"] = {
				["text"] = "discord.gg/Example"
			},
		}
	}
	PerformHttpRequest(Config.WebhookURL, function(err, text, headers) end, 'POST', json.encode({username = "Exploit Log", embeds = embed, avatar_url = "https://cdn.discordapp.com/attachments/891828087912796190/892186680839254086/fcdev.png"}), {['Content-Type'] = 'application/json'})
end
-- (Example of discord log)	SendToDiscord("Cheater Kicked", "**"..GetPlayerName(source).."** (ID: "..source..") has been Kicked for exploiting.\n**EventName:** 'eventhere'\n**Resource:** "..GetCurrentResourceName())


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
                    SendToDiscord("Cheater Kicked", "**"..GetPlayerName(source).."** (ID: "..source..") has been Kicked for exploiting.\n**EventName:** 'sync'\n**Resource:** "..GetCurrentResourceName())

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
                    SendToDiscord("Cheater Kicked", "**"..GetPlayerName(source).."** (ID: "..source..") has been Kicked for exploiting.\n**EventName:** 'releaseHostage'\n**Resource:** "..GetCurrentResourceName())
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
                    SendToDiscord("Cheater Kicked", "**"..GetPlayerName(source).."** (ID: "..source..") has been Kicked for exploiting.\n**EventName:** 'killHostage'\n**Resource:** "..GetCurrentResourceName())
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
