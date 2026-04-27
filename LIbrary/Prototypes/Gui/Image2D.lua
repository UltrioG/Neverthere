local Rectangle = require("Library.Prototypes.Gui.Rectangle")

---@class Image2D: Rectangle
---@field FileName string
---@field Prototype Image2D | Rectangle
---@field ImageAlpha percentage
local Image2D = Rectangle:Inherit()
Image2D.Type = "Image"
Image2D.isPrototype = true

---Render this Image.
---@param pass Pass
function Image2D:Render(pass)
	self:GetPrototype():GetPrototype().Render(self, pass)
	local texture = lovr.graphics.newTexture(self.FileName, {})
	local sizeX, sizeY = self:GetAbsoluteSize()
	local x, y = self:GetAbsolutePosition()
	pass:setColor(0xFFFFFF, self.ImageAlpha)
	local m4 = lovr.math.mat4(vec3(x, y, 0), vec3(-sizeX, sizeY, 0), quat(self.Rotation, 0,0,-1))
	pass:draw(texture, m4)
end

return Image2D