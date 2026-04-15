require "Library.Globals"
local BASIC = require "basic"
local EVERYTHING = require "Library.Everything"
local TextLabel = EVERYTHING.TextLabel

function lovr.load()
	
end

local t = 0
function lovr.update(dt)
	t = t + dt
end

local TL = TextLabel:Clone()
-- TL.Text = "hii"
TL.Position = {xScale = 0.5, yScale = 0.5}
TL.Size = {xOffset = 20, yOffset = 20}

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
	TL.Position.xScale = math.lerp(0.25, 0.75, (math.cos(t)+1)/2)
	TL.Position.yScale = math.lerp(0.25, 0.75, (math.sin(t)+1)/2)
	-- TL.TextScale = math.lerp(0.8, 2, (math.cos(t)+1)/2)
	TL.Rotation = math.lerp(0, math.pi/6, math.sin(t^2))
	TL:Render(pass)
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

function lovr.quit()
	log("Exiting.")



	log("Log finalized.")
	LOG:close()
	local timedLog, errmsg2 = io.open("./logs/"..getNow()..".log", "w")
	if not timedLog then return false end
	LOG, errmsg = io.open("./logs/latest.log", "r")
	if not LOG then return false end
	timedLog:write(LOG:read("*a"))
	timedLog:close()
	LOG:close()
	return false
end