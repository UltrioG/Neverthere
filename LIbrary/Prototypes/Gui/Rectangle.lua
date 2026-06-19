local GUI2D = require("Library.Prototypes.Gui.GUI2D")

---A visible rectangle on the screen.
---@class Rectangle: GUI2D
---@field Prototype Rectangle | GUI2D
---@field BackgroundColor color?		The color of the rectangle.
---@field BorderColor color?			The color of the border of the rectangle.
---@field BackgroundAlpha percentage	How visible the rectangle is.
---@field BorderAlpha percentage		How visible the border of the rectangle is.
local Rectangle = GUI2D:Inherit()
Rectangle.Type = "Rectangle"
Rectangle.BackgroundColor = 0xFFFFFF
Rectangle.isPrototype = true
Rectangle.BackgroundAlpha = 1
Rectangle.BorderAlpha = 0

---Render this rectangle.
---@param pass Pass
function Rectangle:Render(pass)
	local x, y = self:GetAbsolutePosition()
	local w, h = self:GetAbsoluteSize()
	if self.BackgroundColor then
		pass:setColor(self.BackgroundColor, self.BackgroundAlpha)
		pass:plane(x, y, 0, w, h, self.Rotation, 0, 0, -1, "fill")
	end
	if self.BorderColor then
		pass:setColor(self.BorderColor, self.BorderAlpha)
		pass:plane(x, y, 0, w, h, self.Rotation, 0, 0, -1, "line")
	end
end

return Rectangle