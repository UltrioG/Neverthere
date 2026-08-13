quitBinds = {}
local LOVERRHAND = require "errhand"

lovr.filesystem.setRequirePath(
	table.concat(
		{
			"lua_modules/share/lua/5.4/?.lua",
			"lua_modules/share/lua/5.4/?/init.lua",
			"src/?.lua",
			"src/object/?.lua"
		}, ';'
	) .. ';' .. lovr.filesystem.getRequirePath()
)
require "Globals"

--TODO: Figure out why ts ain't workin
local originalErrhand = lovr.errhand
function lovr.errhand(message)
	if LOG then errLog(message) end
	local success, result = pcall(originalErrhand, message)
	if success then return result end
	return function()
		errLog("An unexpected error has occurred during error handling. The program will now quit with code -1.")
		errLog(tostring(result))
		return -1
	end
end

function lovr.quit()
	for k, v in pairs(quitBinds) do
		print(("Running quitbind %s"):format(k))
		v()
	end
	if not LOG then return false end
	print("Exiting.")
	print("Log finalized.")
	LOG:close()
	local timedLog, errmsg2 = io.open("./logs/" .. getNow() .. ".log", "w")
	if not timedLog then return false end
	LOG, errmsg = io.open("./logs/latest.log", "r")
	if not LOG then return false end
	timedLog:write(LOG:read("*a"))
	timedLog:close()
	LOG:close()
	return false
end

-- Parsing arguments
require "config"