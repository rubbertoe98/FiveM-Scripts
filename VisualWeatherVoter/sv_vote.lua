voteCooldown = 1800
currentWeather = "CLEAR"

weatherVoterCooldown = voteCooldown

RegisterServerEvent("CMG:vote") 
AddEventHandler("CMG:vote", function(weatherType)
    TriggerClientEvent("CMG:voteStateChange",-1,weatherType)
end)

RegisterServerEvent("CMG:tryStartWeatherVote") 
AddEventHandler("CMG:tryStartWeatherVote", function()
	local source = source
    if weatherVoterCooldown >= voteCooldown then
        TriggerClientEvent("CMG:startWeatherVote", -1)
        weatherVoterCooldown = 0
    else
		TriggerClientEvent("chatMessage",source,"Another vote can be started in " .. tostring(voteCooldown-weatherVoterCooldown) .. " seconds!",{255, 0, 0})
    end
end)

RegisterServerEvent("CMG:getCurrentWeather") 
AddEventHandler("CMG:getCurrentWeather", function()
    local source = source
    TriggerClientEvent("CMG:voteFinished",source,currentWeather)
end)

RegisterServerEvent("CMG:setCurrentWeather")
AddEventHandler("CMG:setCurrentWeather", function(newWeather)
	currentWeather = newWeather
end)

Citizen.CreateThread(function()
	while true do
		weatherVoterCooldown = weatherVoterCooldown + 1
		Citizen.Wait(1000)
	end
end)

