---@class Box: Gui
---@field Color color In Hex, the color of the box
---@field Transparency percentage The transparency of the box
local Box = require("Gui"):clone()
Box.__type = "Box"
Box.Name = "ProtoBox"
Box.Color = 0xf0f0f0
Box.Transparency = 0
Box.Visible = true

function Box:DrawSelf(pass)
	if not self.Visible then return end
	local x,y,w,h = self:GetAbsoluteDimensionTuple()
	local px, py = self:GetPivotedPosition()
	pass:setColor(self.Color, 1-self.Transparency)
	pass:box(px, py, 0, w, h, 0, 0, 0, 0, 0, "fill")
end

return Box