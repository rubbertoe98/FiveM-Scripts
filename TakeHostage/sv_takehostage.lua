
RegisterServerEvent('cmg3_animations:sync')
AddEventHandler('cmg3_animations:sync', function(target, animations, attach)
	print("got to srv cmg3_animations:sync")
	print("got that fucking attach flag as: " .. tostring(attach))
	TriggerClientEvent('cmg3_animations:syncTarget', target, source, animations.target, attach)
	print("triggering to target: " .. tostring(target))
	TriggerClientEvent('cmg3_animations:syncMe', source, animations.source)
end)

RegisterServerEvent('cmg3_animations:stop')
AddEventHandler('cmg3_animations:stop', function(targetSrc)
	TriggerClientEvent('cmg3_animations:cl_stop', targetSrc)
end)
