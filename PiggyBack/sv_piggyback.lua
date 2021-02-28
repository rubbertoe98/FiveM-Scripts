local piggybacking = {}
--piggybacking[source] = targetSource, source is piggybacking targetSource
local beingPiggybacked = {}
--beingPiggybacked[targetSource] = source, targetSource is beingPiggybacked by source

RegisterServerEvent("Piggyback:sync")
AddEventHandler("Piggyback:sync", function(targetSrc)
	local source = source
	local sourcePed = GetPlayerPed(source)
    	local sourceCoords = GetEntityCoords(sourcePed)
	local targetPed = GetPlayerPed(targetSrc)
    	local targetCoords = GetEntityCoords(targetPed)
	if #(sourceCoords - targetCoords) <= 3.0 then 
		TriggerClientEvent("Piggyback:syncTarget", targetSrc, source)
		piggybacking[source] = targetSrc
		beingPiggybacked[targetSrc] = source
	end
end)

RegisterServerEvent("Piggyback:stop")
AddEventHandler("Piggyback:stop", function(targetSrc)
	local source = source

	if piggybacking[source] then
		TriggerClientEvent("Piggyback:cl_stop", targetSrc)
		piggybacking[source] = nil
		beingPiggybacked[targetSrc] = nil
	elseif beingPiggybacked[source] then
		TriggerClientEvent("Piggyback:cl_stop", beingPiggybacked[source])
		beingPiggybacked[source] = nil
		piggybacking[beingPiggybacked[source]] = nil
	end
end)

AddEventHandler('playerDropped', function(reason)
	local source = source
	
	if piggybacking[source] then
		TriggerClientEvent("Piggyback:cl_stop", piggybacking[source])
		beingPiggybacked[piggybacking[source]] = nil
		piggybacking[source] = nil
	end

	if beingPiggybacked[source] then
		TriggerClientEvent("Piggyback:cl_stop", beingPiggybacked[source])
		piggybacking[beingPiggybacked[source]] = nil
		beingPiggybacked[source] = nil
	end
end)
