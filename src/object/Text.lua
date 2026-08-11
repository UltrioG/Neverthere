---@class Text: Gui
---@field Color color In Hex, the color of the box
---@field Transparency percentage The transparency of the Text
---@field Content string The actual words of the Text
---@field MetersBeforeWrapping number? Whether the text should be wrapped if it exceeds its borders
---@field HorizontalAlignment "left"|"center"|"right"
---@field VerticalAlignment "top"|"middle"|"bottom"
---@field Scale number How big the text should be scaled
local Text = require("Gui"):clone()
Text.__type = "Text"
Text.Name = "ProtoText"
Text.Color = 0xf0f0f0
Text.Transparency = 0
Text.Content = "Isn't it about time you moved on?"
Text.HorizontalAlignment = "center"
Text.VerticalAlignment = "middle"
Text.Scale = 1

function Text:DrawSelf(pass)
	if not self.Visible then return end
	local x,y,w,h = self:GetAbsoluteDimensionTuple()
	local px, py = self:GetPivotedPosition()
	pass:setColor(self.Color, 1-self.Transparency)
	pass:text(
		self.Content,
		px, py, 0, self.Scale, 0, 0, 0, 0,
		self.MetersBeforeWrapping or 0,
		self.HorizontalAlignment, self.VerticalAlignment
)
end

return Text