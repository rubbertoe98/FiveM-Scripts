local cfg = module("cfg/cfg_warningsystem")


RegisterCommand("showwarnings", function(source, args) 
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id, "player.kick") then
		local target_id = tonumber(args[1])
		local warnings = getCMGWarnings(target_id,source)
		TriggerClientEvent("CMG:showWarningsOfUser",source,warnings)
	end
end)

--sql

function querySync(query, params) 
	if cfg.database_driver == "ghmattimysql-js" then 
		return exports["ghmattimysql"]:executeSync(query, params)
	elseif cfg.database_driver == "fivem-mysql" then
		return exports['GHMattiMySQL']:QueryResult(query, params)
	elseif cfg.database_driver == "mysql-async" then
		return MySQL.Sync.execute(query, params)
	end
end

function query(query, params, callback) 
	if cfg.database_driver == "ghmattimysql-js" then 
		exports["ghmattimysql"]:execute(query, params, callback)
	elseif cfg.database_driver == "fivem-mysql" then
		exports['GHMattiMySQL']:QueryAsync(query, params, callback)
	elseif cfg.database_driver == "mysql-async" then
		MySQL.Async.execute(query, params, callback)
	end
end

function getCMGWarnings(user_id,source) 
	local warnings = querySync("SELECT * FROM cmg_warnings WHERE user_id = @uid", {uid = user_id})
	for warningID,warningTable in pairs(warnings) do
		local date = warningTable["warning_date"]
		local newdate = tonumber(date) / 1000
		newdate = os.date('%Y-%m-%d', newdate)
		warningTable["warning_date"] = newdate
	end
	return warnings
end

RegisterServerEvent("CMG:refreshWarningSystem")
AddEventHandler("CMG:refreshWarningSystem",function()
	local source = source
	local user_id = vRP.getUserId(source)
	local warnings = getCMGWarnings(user_id,source)
	TriggerClientEvent("CMG:recievedRefreshedWarningData",source,warnings)
end)

RegisterServerEvent("CMG:warnPlayer")
AddEventHandler("CMG:warnPlayer",function(target_id,adminName,warningReason)
	local source = source
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"player.kick") then
		local warning = "Warning"
		local warningDate = getCurrentDate()
		query("INSERT INTO cmg_warnings (`warning_id`, `user_id`, `warning_type`, `duration`, `admin`, `warning_date`, `reason`) VALUES (NULL, @user_id, @warning_type, 0, @admin, @warning_date,@reason);", {user_id = target_id,warning_type = warning, admin = adminName, warning_date = warningDate, reason = warningReason}, function() end)
	else
		vRPclient.notify(player,{"~r~no perms to warn player"})
	end
end)

function saveKickLog(target_id,adminName,warningReason)
	local warning = "Kick"
	local warningDate = getCurrentDate()
	local query("INSERT INTO cmg_warnings (`warning_id`, `user_id`, `warning_type`, `duration`, `admin`, `warning_date`, `reason`) VALUES (NULL, @user_id, @warning_type, 0, @admin, @warning_date,@reason);", {user_id = target_id,warning_type = warning, admin = adminName, warning_date = warningDate, reason = warningReason}, function() end)
end

function saveBanLog(target_id,adminName,warningReason,warning_duration)
	local warning = "Ban"
	local warningDate = getCurrentDate()
	query("INSERT INTO cmg_warnings (`warning_id`, `user_id`, `warning_type`, `duration`, `admin`, `warning_date`, `reason`) VALUES (NULL, @user_id, @warning_type, @duration, @admin, @warning_date,@reason);", {user_id = target_id,warning_type = warning, admin = adminName, duration = warning_duration, warning_date = warningDate, reason = warningReason}, function() end)
end

function getCurrentDate()
	return os.date("%Y/%m/%d")
end
