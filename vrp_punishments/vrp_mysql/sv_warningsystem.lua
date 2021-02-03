
MySQL.createCommand("vRP/getWarnings","SELECT * FROM cmg_warnings WHERE user_id = @uid")
MySQL.createCommand("vRP/warnPlayer","INSERT INTO cmg_warnings(warning_id, user_id, warning_type, duration, admin, warning_date, reason) VALUES(NULL, @user_id, @warning_type, 0, @admin, @warning_date,@reason)")
MySQL.createCommand("vRP/saveKick","INSERT INTO cmg_warnings(warning_id, user_id, warning_type, duration, admin, warning_date, reason) VALUES(NULL, @user_id, @warning_type, 0, @admin, @warning_date,@reason)")
MySQL.createCommand("vRP/saveBan","INSERT INTO cmg_warnings(warning_id, user_id, warning_type, duration, admin, warning_date, reason) VALUES(NULL, @user_id, @warning_type, @duration, @admin, @warning_date,@reason)")

RegisterCommand("showwarnings",function(source, args)
	user_id = vRP.getUserId(player)
	local permID =  args[1]
	if tonumber(args[1]) then
		if vRP.hasPermission(user_id,"player.kick") then
			cmgwarningstables = getCMGWarnings(permID,player)
			TriggerClientEvent("CMG:showWarningsOfUser",player,cmgwarningstables)
		end
	else
	end
end)
	
function getCMGWarnings(user_id,source) 
	MySQL.query("vRP/getWarnings", {uid = user_id}, function(cmgwarningstables)
		for i,v in pairs(cmgwarningstables) do
			date = v["warning_date"]
			newdate = tonumber(date) / 1000
			newdate = os.date('%Y-%m-%d', newdate)
			v["warning_date"] = newdate
		end
		return cmgwarningstables
	end)
end

RegisterServerEvent("CMG:refreshWarningSystem")
AddEventHandler("CMG:refreshWarningSystem",function()
	local source = source
	local user_id = vRP.getUserId(source)
	cmgwarningstables = getCMGWarnings(user_id,source)
	TriggerClientEvent("CMG:recievedRefreshedWarningData",source,cmgwarningstables)
end)

RegisterServerEvent("CMG:warnPlayer")
AddEventHandler("CMG:warnPlayer",function(target_id,adminName,warningReason)
	local source = source
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"player.kick") then
		warning = "Warning"
		warningDate = os.date("%Y/%m/%d")
		MySQL.execute("vRP/warnPlayer", {user_id = target_id,warning_type = warning, admin = adminName, warning_date = warningDate, reason = warningReason})
	else
		vRPclient.notify(player,{"~r~no perms to warn player"})
	end
end)

function saveKickLog(target_id,adminName,warningReason)
	MySQL.execute("vRP/saveKick", {user_id = target_id,warning_type = "Kick", admin = adminName, warning_date = os.date("%Y/%m/%d"), reason = warningReason})
end

function saveBanLog(target_id,adminName,warningReason,warning_duration)
	MySQL.execute("vRP/saveBan", {user_id = target_id,warning_type = "Ban", admin = adminName, duration = warning_duration, warning_date = os.date("%Y/%m/%d"), reason = warningReason})
end