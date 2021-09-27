# vrp_punishmentslog created by Robbster

## Installation:

###### 1) Dependancies: GHMattiMySQL

Ensure you have GHMattiMySQL installed and correctly configured to your database
```https://github.com/GHMatti/FiveM-MySQL```

###### 2) Create your new database table by executing the following SQL in your database

```SQL
CREATE TABLE cmg_warnings (
	warning_id INT,
	user_id INT,
	warning_type VARCHAR(25),
	duration INT,
	admin VARCHAR(100),
	warning_date DATE,
	reason VARCHAR(2000),
	PRIMARY KEY (warning_id)
)
```

###### 3) Go to vrp/modules/admin.lua 
and find the ch_kick function (CTRL-F "ch_kick")
Place this line just before the line starting with "vRP.kick".
```lua
saveKickLog(id,GetPlayerName(player),reason)
```


###### 4) Replace the ch_ban function with the following code

```lua
local function ch_ban(player,choice)
  local user_id = vRP.getUserId(player)
  if user_id ~= nil and vRP.hasPermission(user_id,"player.ban") then
    vRP.prompt(player,"User id to ban: ","",function(player,id)
      id = parseInt(id)
      vRP.prompt(player,"Reason: ","",function(player,reason)
        local source = vRP.getUserSource(id)
	  vRP.prompt(player,"Hours: ","",function(player,duration)
	    if tonumber(duration) then
	      vRPclient.notify(player,{"banned user "..id})
	      saveBanLog(id,GetPlayerName(player),reason,duration)
	      vRP.ban(source,reason)
    	    else
		vRPclient.notify(player,{"~r~Invalid ban time!"})
            end
	end)
      end)
    end)
  end
end
```

###### 5) Place sv_warningsystem.lua in vrp/modules/ and cl_warningsystem.lua in vrp/client/

###### 6) Update your vrp/__resource.lua by putting adding the file names cl_warningsystem.lua & sv_warningsystem.lua in the appropriate section

## How to use:

* F10 to open up the warning sytem
* /showwarnings [user_id] to show someone's punishment log (i.e /showwarnings 1)
* /warn to give a warning
* Kicks & Bans are automatically added to someones punishment log when you ban/kick them through your phone

Feel free to make improvements with PRs


