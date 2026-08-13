LOVR_BINDS = {
	quit = {},
	draw = {},
	conf = {},
	keypressed = {},
	textinput = {},
	mousereleased = {},
	keyreleased = {}
}
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

LOVR_BINDS.quit[1] = function()
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

for bindName, bindList in pairs(LOVR_BINDS) do
	lovr[bindName] = function (...)
		for _, v in ipairs(bindList) do v(...) end
	end
end

-- Parsing arguments
require "config"

---@type {[programMode]: function}
local PROGRAM_MODE_MAP = {
	GAME = function ()	end,
	GUIEDIT = function () require "GuiEditor" end
}
print("Running in mode "..CONFIG.PROGMODE)
PROGRAM_MODE_MAP[CONFIG.PROGMODE]()