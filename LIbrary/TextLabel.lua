local GUI2D = require("Library.GUI2D")

---@class TextLabel: GUI2D
---@field Text string|colortext
local TextLabel = GUI2D:Clone()
TextLabel.Type = "TextLabel"

function TextLabel:Render(pass)
	local x,y = self:GetAbsolutePosition()
	pass:text(self.Text, x,y, 0, 1,0,0,0,0,0, "center", "middle")
end

return TextLabel