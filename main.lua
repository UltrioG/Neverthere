require "Library.Globals"

local GuiManager = require "Library.GuiManager"
local BASIC = require "basic"
local PRETTY = require "Library.Pretty"

function lovr.load()
	local O = JSON.parsePath("test.json")
	PRETTY.print(O)
end

function lovr.draw(pass)
	BASIC.plane(pass)

	GuiManager.Render2D(pass)

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

local originalErrhand = lovr.errhand
function lovr.errhand(message)
	if LOG then errLog(message) end
	return originalErrhand(message)
end