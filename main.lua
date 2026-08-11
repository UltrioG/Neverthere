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
local GUI = require("Gui")

function lovr.load()
	
end

local function set2D(pass)
	local font = lovr.graphics.getDefaultFont()
	font:setPixelDensity(1)

	local width, height = lovr.system.getWindowDimensions()
	local projection = Mat4():orthographic(0, width, 0, height, -10, 10)
	pass:setViewPose(1, mat4():identity(), false)
	pass:setProjection(1, projection)
	pass:setDepthTest()
end

function lovr.draw(pass)
	BASIC.plane(pass)
	
	set2D(pass)
	
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

--TODO: Figure out why ts ain't workin
local originalErrhand = lovr.errhand
function lovr.errhand(message)
	if LOG then errLog(message) end
	local success, result = pcall(function ()
		return originalErrhand(message)
	end)
	if success then return result end
	return -1
end

function lovr.quit()
	return logExit()
end