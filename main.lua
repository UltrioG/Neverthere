local BASIC = require "basic"

function lovr.update(dt)

end

---@param pass Pass
local function render2D(pass)
	local width, height = lovr.system.getWindowDimensions()
	local projection = Mat4():orthographic(0, width, 0, height, -10, 10)
	pass:setViewPose(1, mat4():identity(), false)
	pass:setProjection(1, projection)
	pass:setDepthTest()

	
end

function lovr.draw(pass)
	BASIC.plane(pass)

	render2D(pass)

	return false
end