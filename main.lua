lovr.filesystem.setRequirePath(
	table.concat(
		{
			"lua_modules/share/lua/5.4/?.lua",
			"lua_modules/share/lua/5.4/?/init.lua",
			"src/?.lua",
			"src/object/?.lua"
		}, ';'
	)..';'..lovr.filesystem.getRequirePath()
)
require "Globals"

local BASIC = require "basic"
local PRETTY = require "Pretty"
local THINGY = require("Thingy")

function lovr.load()

	local originalErrhand = lovr.errhand
	function lovr.errhand(message)
		if LOG then errLog(message) end
		return originalErrhand(message)
	end

	local thingy = THINGY:clone()
	thingy.__name = "new"
end

function lovr.draw(pass)
	BASIC.plane(pass)

	return false
end

local function logExit()
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

function lovr.quit()
	return logExit()
end