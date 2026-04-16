local Rectangle = require("Library.Rectangle")

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
	pass:draw(texture, x, y, 0, sizeX, self.Rotation, 0, 0, -1)
end

return Image2D