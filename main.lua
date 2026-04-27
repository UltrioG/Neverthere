require "Library.Globals"

local GuiManager = require "GuiManager"
local BASIC = require "basic"


function lovr.load()
	
end



function lovr.draw(pass)
	BASIC.plane(pass)

	GuiManager.Render2D(pass)

	return false
end

function lovr.log(message, level, tag)
	io.write(
		("[%s] [%s] %s%s\n")
		:format(getNowPrettier(), level:upper(), tag and ("[TAG %s] "):format(tag) or "", message)
	)
	io.flush()
end

local function logExit()
	log("Exiting.")



	log("Log finalized.")
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

function lovr.threaderror(thread, message)
	local function formatTraceback(s)
		return s:gsub('\n[^\n]+$', ''):gsub('\t', ''):gsub('stack traceback:', '\nStack:\n')
	end
	err(message..formatTraceback(debug.traceback("",4)))
	logExit()
	lovr.event.push("errhand", message)
end