defaultWeather = "CLEAR"
currentWeather = defaultWeather
showWeatherVoteGUI = false
voteInProgress = false
voted = false
timer = 60

votesTable = {
	["CLEAR"] = 0,
	["EXTRASUNNY"] = 0,
	["CLOUDS"] = 0,
	["OVERCAST"] = 0,
	["RAIN"] = 0,
	["THUNDER"] = 0,
	["CLEARING"] = 0,
	["SMOG"] = 0,
	["FOGGY"] = 0,
	["XMAS"] = 0,
	["SNOWLIGHT"] = 0,
	["BLIZZARD"] = 0
}

function sorted_iter(t)
  local i = {}
  for k in next, t do
    table.insert(i, k)
  end
  table.sort(i)
  return function()
    local k = table.remove(i)
    if k ~= nil then
      return k, t[k]
    end
  end
end

	
function DrawAdvancedText(x,y ,w,h,sc, text, r,g,b,a,font,jus)
    SetTextFont(font)
    SetTextScale(sc, sc)
	N_0x4e096588b13ffeca(jus)
    SetTextColour(r, g, b, a)
    SetTextEntry("STRING")
    AddTextComponentString(text)
	DrawText(x - 0.1+w, y - 0.02+h)
end

function voteWeather(weatherType) 
	print("voteInProgress: " .. tostring(voteInProgress))
	if voteInProgress then
		if not voted then
			TriggerServerEvent("CMG:vote", weatherType)
			voted = true
			TriggerEvent("chatMessage","Vote sent!",{0, 255, 0})
		else
			TriggerEvent("chatMessage","You have already voted!",{255, 0, 0})
		end
	else
		TriggerEvent("chatMessage","Vote not in progress!",{255, 0, 0})
	end
end


function changeWeather()
	highestWeather = defaultWeather
	highestCounter = 0
	for k,v in sorted_iter(votesTable) do
		if v > highestCounter then
			highestWeather = k
			highestCounter = v
		end
	end
	currentWeather = highestWeather
	TriggerServerEvent("CMG:setCurrentWeather",highestWeather)
end

RegisterNetEvent("CMG:voteFinished")
AddEventHandler("CMG:voteFinished", function(newWeather)
	currentWeather = newWeather
end)

RegisterNetEvent("CMG:startWeatherVote")
AddEventHandler("CMG:startWeatherVote", function()
	voteInProgress = true
	TriggerEvent("chatMessage","Weather vote has started! Type /[weather] e.g /snow or /rain to vote.",{0, 250, 50})
	TriggerEvent("chatMessage","Weather types are in bottom left & /voteweather to start a vote",{0, 250, 50})
end)

RegisterNetEvent("CMG:voteStateChange")
AddEventHandler("CMG:voteStateChange",function(type)
	votesTable[type] = votesTable[type] + 1
end)

RegisterCommand("voteweather", function()
	TriggerServerEvent("CMG:tryStartWeatherVote")
end, false)

RegisterCommand("clear", function()
	voteWeather("CLEAR")
end, false)

RegisterCommand("extrasunny", function()
	voteWeather("EXTRASUNNY")
end, false)

RegisterCommand("cloudy", function()
	voteWeather("CLOUDS")
end, false)

RegisterCommand("overcast", function()
	voteWeather("OVERCAST")
end, false)

RegisterCommand("rain", function()
	voteWeather("RAIN")
end, false)

RegisterCommand("thunder", function()
	voteWeather("THUNDER")
end, false)

RegisterCommand("clearing", function()
	voteWeather("CLEARING")
end, false)

RegisterCommand("smog", function()
	voteWeather("SMOG")
end, false)

RegisterCommand("foggy", function()
	voteWeather("FOGGY")
end, false)

RegisterCommand("snow", function()
	voteWeather("XMAS")
end, false)

RegisterCommand("snowlight", function()
	voteWeather("SNOWLIGHT")
end, false)

RegisterCommand("blizzard", function()
	voteWeather("BLIZZARD")
end, false)

Citizen.CreateThread(function()
    while true do
		SetWeatherTypePersist(currentWeather)
        SetWeatherTypeNowPersist(currentWeather)
        SetWeatherTypeNow(currentWeather)
        SetOverrideWeather(currentWeather)
		Wait(1000)
	end
end)

Citizen.CreateThread(function()
	while true do
		if voteInProgress then 
			DrawAdvancedText(0.27, 0.96, 0.005, 0.0028, 0.318, "Time Left:", 0, 208, 104, 255, 4, 0)
			DrawAdvancedText(0.29, 0.96, 0.005, 0.0028, 0.29, tostring(timer), 255, 74, 53, 255, 0, 0)
			DrawAdvancedText(0.297, 0.827, 0.005, 0.0028, 0.38, "Weather Voter", 0, 208, 104, 255, 4, 0)
			
			DrawAdvancedText(0.2645, 0.848, 0.005, 0.0028, 0.318, "Clear", 255, 255, 255, 255, 4, 0)
			DrawAdvancedText(0.2728, 0.866, 0.005, 0.0028, 0.318, "ExtraSunny", 255, 255, 255, 255, 4, 0)
			DrawAdvancedText(0.266, 0.884, 0.005, 0.0028, 0.318, "Cloudy", 255, 255, 255, 255, 4, 0)
			DrawAdvancedText(0.269, 0.902, 0.005, 0.0028, 0.318, "Overcast", 255, 255, 255, 255, 4, 0)
			DrawAdvancedText(0.263, 0.920, 0.005, 0.0028, 0.318, "Rain", 255, 255, 255, 255, 4, 0)
			DrawAdvancedText(0.268, 0.938, 0.005, 0.0028, 0.318, "Thunder", 255, 255, 255, 255, 4, 0)
			
			DrawAdvancedText(0.293, 0.848, 0.005, 0.0028, 0.25, tostring(votesTable["CLEAR"]), 255, 74, 53, 255, 0, 0)
			DrawAdvancedText(0.293, 0.866, 0.005, 0.0028, 0.25, tostring(votesTable["EXTRASUNNY"]), 255, 74, 53, 255, 0, 0)
			DrawAdvancedText(0.293, 0.884, 0.005, 0.0028, 0.25, tostring(votesTable["CLOUDS"]), 255, 74, 53, 255, 0, 0)
			DrawAdvancedText(0.293, 0.902, 0.005, 0.0028, 0.25, tostring(votesTable["OVERCAST"]), 255, 74, 53, 255, 0, 0)
			DrawAdvancedText(0.293, 0.920, 0.005, 0.0028, 0.25, tostring(votesTable["RAIN"]), 255, 74, 53, 255, 0, 0)
			DrawAdvancedText(0.293, 0.938, 0.005, 0.0028, 0.25, tostring(votesTable["THUNDER"]), 255, 74, 53, 255, 0, 0)
			
			DrawAdvancedText(0.315, 0.848, 0.005, 0.0028, 0.318, "Clearing", 255, 255, 255, 255, 4, 0)
			DrawAdvancedText(0.315, 0.866, 0.005, 0.0028, 0.318, "Smog", 255, 255, 255, 255, 4, 0)
			DrawAdvancedText(0.314, 0.884, 0.005, 0.0028, 0.318, "Snow", 255, 255, 255, 255, 4, 0)
			DrawAdvancedText(0.315, 0.902, 0.005, 0.0028, 0.318, "Blizzard", 255, 255, 255, 255, 4, 0)
			DrawAdvancedText(0.315, 0.920, 0.005, 0.0028, 0.318, "Snowlight", 255, 255, 255, 255, 4, 0)
			DrawAdvancedText(0.315, 0.938, 0.005, 0.0028, 0.318, "Foggy", 255, 255, 255, 255, 4, 0)

			DrawAdvancedText(0.333, 0.848, 0.005, 0.0028, 0.25, tostring(votesTable["CLEARING"]), 255, 74, 53, 255, 0, 0)
			DrawAdvancedText(0.333, 0.866, 0.005, 0.0028, 0.25, tostring(votesTable["SMOG"]), 255, 74, 53, 255, 0, 0)
			DrawAdvancedText(0.333, 0.884, 0.005, 0.0028, 0.25, tostring(votesTable["XMAS"]), 255, 74, 53, 255, 0, 0)
			DrawAdvancedText(0.333, 0.902, 0.005, 0.0028, 0.25, tostring(votesTable["BLIZZARD"]), 255, 74, 53, 255, 0, 0)
			DrawAdvancedText(0.333, 0.920, 0.005, 0.0028, 0.25, tostring(votesTable["SNOWLIGHT"]), 255, 74, 53, 255, 0, 0)
			DrawAdvancedText(0.333, 0.938, 0.005, 0.0028, 0.25, tostring(votesTable["FOGGY"]), 255, 74, 53, 255, 0, 0)
		end
		Wait(0)
	end
end)


Citizen.CreateThread(function()
	while true do
		if voteInProgress then 
			timer = timer - 1
			if timer == 0 then
				voteInProgress = false
				timer = 60
				voted = false
				changeWeather()
				resetVotes()
			end
		end
		Wait(1000)
	end
end)

AddEventHandler('playerSpawned', function(spawn)
    TriggerServerEvent("CMG:getCurrentWeather")

end)

function resetVotes()
	votesTable = {
		["CLEAR"] = 0,
		["EXTRASUNNY"] = 0,
		["CLOUDS"] = 0,
		["OVERCAST"] = 0,
		["RAIN"] = 0,
		["THUNDER"] = 0,
		["CLEARING"] = 0,
		["SMOG"] = 0,
		["FOGGY"] = 0,
		["XMAS"] = 0,
		["SNOWLIGHT"] = 0,
		["BLIZZARD"] = 0
	}
end
