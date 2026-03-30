local DEBUG = {}

---Draws a plane with the XYZ unit vectors and the origin marked.
---@param pass Pass
function DEBUG.plane(pass)
	pass:setColor(0xFFFFFF, 0.5)
	pass:plane(
		lovr.math.vec3(0,-0.001,0),
		lovr.math.vec2(64,64),
		lovr.math.quat(math.pi/2,1,0,0)
	, "line", 64, 64)
	pass:setColor(0xFFFFFF, 1)
	pass:plane(
		lovr.math.vec3(0,-0.001,0),
		lovr.math.vec2(64,64),
		lovr.math.quat(math.pi/2,1,0,0)
	, "line", 16, 16)
	pass:sphere(0,0,0, 0.05)
	pass:setColor(0xFF0000)
	pass:line(0,0,0,1,0,0)
	pass:setColor(0x00FF00)
	pass:line(0,0,0,0,1,0)
	pass:setColor(0x0000FF)
	pass:line(0,0,0,0,0,1)
end

return DEBUG