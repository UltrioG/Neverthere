require "Library.Globals"
local BASIC = require "basic"
local EVERYTHING = require "Library.Everything"
local IMAGE2D = EVERYTHING.Image2D
local EVERYWHERE = {}

function lovr.load()
	EVERYWHERE.img = IMAGE2D:Clone() --[[@as Image2D]]
	EVERYWHERE.img.FileName = "/assets/textures/FortunaTalkLog6.png"
	EVERYWHERE.img.Size = {xOffset = 640, yOffset = 640}
	EVERYWHERE.img.Position = {xScale = 0.5, yScale = .7}
	EVERYWHERE.img.Rotation = math.pi
	EVERYWHERE.img.BackgroundAlpha = 0
end

local t = 0
function lovr.update(dt)
	t = t + dt
end

---@param pass Pass
local function render2D(pass)
	local font = lovr.graphics.getDefaultFont()
	font:setPixelDensity(1)

	local width, height = lovr.system.getWindowDimensions()
	local projection = Mat4():orthographic(0, width, 0, height, -10, 10)
	pass:setViewPose(1, mat4():identity(), false)
	pass:setProjection(1, projection)
	pass:setDepthTest()

	pass:setColor(0xFF8000)
	EVERYWHERE.img:Render(pass)
end

function lovr.draw(pass)
	BASIC.plane(pass)

	render2D(pass)

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