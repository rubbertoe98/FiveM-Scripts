-- CREATE TALBE cmg_warnings (
	-- warning_id INT,
	-- user_id INT,
	-- warning_type VARCHAR(25),
	-- duration INT,
	-- admin VARCHAR(100),
	-- warning_date DATE,
	-- reason VARCHAT(2000),
	-- PRIMARY KEY (warning_id)
-- )

--TODO
--Fix date DONE
--/warn DONE
--make primary key auto_increment DONE
--getCurrentDate function DONE
--bans auto go on log menu DONE
--kicks auto go on log menu DONE
--Whitelist to staff DONE
--Change crossarms key bind DONE
--change requests DONE
--ban duration column needs to show (hrs) DONE
--ban duration not working DONE
--bar colour DONE
--verify kicks work DONE

AddEventHandler('chatMessage', function(player, color, message)
	user_id = vRP.getUserId(player)
    if message:sub(1, 13) == '/showwarnings' then
		local permID =  tonumber(message:sub(14, 20))
		if permID ~= nil then
			--check if staff
			if vRP.hasPermission(user_id,"player.kick") then
				--print("Getting warnings of ID: " .. tostring(permID))
				cmgwarningstables = getCMGWarnings(permID,player)
				--print("sending to source: " .. tostring(source))
				TriggerClientEvent("CMG:showWarningsOfUser",player,cmgwarningstables)
			end
		else
			--print("Error couldn't get ID: " .. tostring(message:sub(14, 20)))
		end
    end
	CancelEvent()
end)

--print("start:"..dump(testdate).."end")
-- testTime = 1561845600000
-- testTime = testTime / 1000
-- print(os.date('%Y-%m-%d', testTime))
	
function getCMGWarnings(user_id,source) 
	cmgwarningstables = exports['GHMattiMySQL']:QueryResult("SELECT * FROM cmg_warnings WHERE user_id = @uid", {uid = user_id})
	print("Triggering CMG:showWarningsOfUser")
	print(dump(cmgwarningstables))
	for warningID,warningTable in pairs(cmgwarningstables) do
		--print(warningTable["warning_date"])
		date = warningTable["warning_date"]
		--print("date1:" .. tostring(date))
		newdate = tonumber(date) / 1000
		--print("date3:" .. tostring(newdate))
		newdate = os.date('%Y-%m-%d', newdate)
		--print("date4:" .. tostring(newdate))
		warningTable["warning_date"] = newdate
	end
	return cmgwarningstables
end

RegisterServerEvent("CMG:refreshWarningSystem")
AddEventHandler("CMG:refreshWarningSystem",function()
	local source = source
	local user_id = vRP.getUserId(source)
	--local user_id = 1
	
	cmgwarningstables = getCMGWarnings(user_id,source)
	TriggerClientEvent("CMG:recievedRefreshedWarningData",source,cmgwarningstables)
end)

RegisterServerEvent("CMG:warnPlayer")
AddEventHandler("CMG:warnPlayer",function(target_id,adminName,warningReason)
	local source = source
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"player.kick") then
		warning = "Warning"
		warningDate = getCurrentDate()
		exports['GHMattiMySQL']:QueryAsync("INSERT INTO cmg_warnings (`warning_id`, `user_id`, `warning_type`, `duration`, `admin`, `warning_date`, `reason`) VALUES (NULL, @user_id, @warning_type, 0, @admin, @warning_date,@reason);", {user_id = target_id,warning_type = warning, admin = adminName, warning_date = warningDate, reason = warningReason}, function() end)
	else
		vRPclient.notify(player,{"~r~no perms to warn player"})
	end
end)

function saveKickLog(target_id,adminName,warningReason)
	warning = "Kick"
	warningDate = getCurrentDate()
	exports['GHMattiMySQL']:QueryAsync("INSERT INTO cmg_warnings (`warning_id`, `user_id`, `warning_type`, `duration`, `admin`, `warning_date`, `reason`) VALUES (NULL, @user_id, @warning_type, 0, @admin, @warning_date,@reason);", {user_id = target_id,warning_type = warning, admin = adminName, warning_date = warningDate, reason = warningReason}, function() end)

end

function saveBanLog(target_id,adminName,warningReason,warning_duration)
	warning = "Ban"
	warningDate = getCurrentDate()
	exports['GHMattiMySQL']:QueryAsync("INSERT INTO cmg_warnings (`warning_id`, `user_id`, `warning_type`, `duration`, `admin`, `warning_date`, `reason`) VALUES (NULL, @user_id, @warning_type, @duration, @admin, @warning_date,@reason);", {user_id = target_id,warning_type = warning, admin = adminName, duration = warning_duration, warning_date = warningDate, reason = warningReason}, function() end)
end


function getCurrentDate()
	date = os.date("%Y/%m/%d")

	return date
end

-- CMGWarnings = {
	-- [0] = {"Ban","48","Rolex","10-10-19","You VDM'd x2"},
	-- [1] = {"Warning","24","Rob","1-10-19","You VDM'd x4"},
-- }