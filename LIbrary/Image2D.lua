local Rectangle = require("Library.Rectangle")

---@class Image2D: GUI2D
---@field FileName string
---@field Prototype Image2D | Rectangle
local Image2D = Rectangle:Clone() --[[@as Image2D]]
Image2D.Type = "Image"

---Render this Image.
---@param pass Pass
function Image2D:Render(pass)
	io.write(self.Type)
	self.Prototype.Render(self, pass)
	local texture = lovr.graphics.newTexture(self.FileName, {})
	local sizeX, sizeY = self:GetAbsoluteSize()
	local x, y = self:GetAbsolutePosition()
	pass:draw(texture, x, y, 0, sizeX, self.Rotation, 0, 0, -1)
end

return Image2D