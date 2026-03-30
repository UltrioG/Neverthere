require "Library.Globals"
local BASIC = require "basic"
local TextLabel = require "Library.TextLabel"

function lovr.load()
	camera = {
		transform = Mat4(Vec3(0,1,0))
	}
end

local t = 0
function lovr.update(dt)
	t = t + dt
end

local TL = TextLabel:Clone()
TL.Text = "hii"
TL.Position = {xScale = 0.5, yScale = 0.5}

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
	TL.Position.xScale = (math.cos(t)+1)/2*(0.5)+0.25
	TL.Position.yScale = (math.sin(t)+1)/2*(0.5)+0.25
	TL:Render(pass)
end

function lovr.draw(pass)
	pass:setViewPose(1, camera.transform, false)
	BASIC.plane(pass)

	render2D(pass)

	return false
end