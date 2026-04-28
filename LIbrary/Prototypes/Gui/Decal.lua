local Rectangle = require("Library.Prototypes.Gui.Rectangle")

---@class Decal: Rectangle
---@field FileName string
---@field Prototype Decal | Rectangle
---@field DecalAlpha percentage
local Decal = Rectangle:Inherit()
Decal.Type = "Decal"
Decal.isPrototype = true

---Render this Decal.
---@param pass Pass
function Decal:Render(pass)
	self:GetPrototype():GetPrototype().Render(self, pass)
	local texture = lovr.graphics.newTexture(self.FileName, {})
	local sizeX, sizeY = self:GetAbsoluteSize()
	local x, y = self:GetAbsolutePosition()
	pass:setColor(0xFFFFFF, self.DecalAlpha)
	local m4 = lovr.math.mat4(vec3(x, y, 0), vec3(-sizeX, sizeY, 0), quat(self.Rotation+math.pi, 0,0,-1))
	pass:draw(texture, m4)
end

return Decal