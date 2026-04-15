local GUI2D = require("Library.GUI2D")

---@class TextLabel: GUI2D
---@field Prototype TextLabel | GUI2D
---@field Text string|colortext The content to be displayed
---@field MaxCharacterPerLine integer? Maximum number of characters per line before wrapping. Nil to disable wrapping.
---@field HorizontalAlign "center"|"left"|"right"|nil
---@field VerticalAlign "bottom"|"middle"|"top"|nil
---@field TextScale number How big the text is. Requires testing.
local TextLabel = GUI2D:Clone()
TextLabel.Type = "TextLabel"
TextLabel.Text = "Don't you think you should've moved on by now?"
TextLabel.TextScale = 1

function TextLabel:Render(pass)
	local x,y = self:GetAbsolutePosition()
	pass:text(
	self.Text,
	x,y,0,
	self.TextScale or 1,
	self.Rotation,0,0,-1,
	self.MaxCharacterPerLine or 0,
	self.HorizontalAlign or "center",
	self.VerticalAlign or "middle")
end

return TextLabel