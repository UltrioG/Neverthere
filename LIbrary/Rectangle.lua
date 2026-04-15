local GUI2D = require("Library.GUI2D")

---@class Rectangle: GUI2D
---@field Prototype Rectangle | GUI2D
---@field BackgroundColor color?
---@field BorderColor color?
local Rectangle = GUI2D:Clone()
Rectangle.Type = "Rectangle"
Rectangle.BackgroundColor = 0xFFFFFF

---Render this rectangle.
---@param pass Pass
function Rectangle:Render(pass)
	local x, y = self:GetAbsolutePosition()
	local w, h = self:GetAbsoluteSize()
	if self.BackgroundColor then
		pass:setColor(self.BackgroundColor)
		pass:plane(x, y, 0, w, h, self.Rotation, 0, 0, -1, "fill")
	end
	if self.BorderColor then
		pass:setColor(self.BorderColor)
		pass:plane(x, y, 0, w, h, self.Rotation, 0, 0, -1, "line")
	end
end

return Rectangle