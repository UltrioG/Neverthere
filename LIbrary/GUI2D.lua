local POJ = require("Library.Poject")

---@class GUI2D: Poject
---@field Position UDim2
---@field Size UDim2
---@field Parent GUI2D?		The "parent" of this GUI2D. Its position and scale will be relative to this object.
---@field Rotation number 	The radians counterclockwise the GUI2D spins
local GUI2D = POJ:Clone()
GUI2D.Type = "GUI2D"
GUI2D.Parent = GUI2D
GUI2D.Position = {xScale = 0.5, yScale = 0.5}
GUI2D.Rotation = 0

---Gets the pixel size of the GUI2D.
---@return integer
---@return integer
function GUI2D:GetAbsoluteSize()
	if not self.Parent then return lovr.system.getWindowDimensions() end
	local xParent, yParent = self.Parent:GetAbsoluteSize()
	return
		math.round(xParent * (self.Size.xScale or 0) + (self.Size.xOffset or 0)),
		math.round(yParent * (self.Size.yScale or 0) + (self.Size.yOffset or 0))
end

---Gets the pixel position of the GUI2D.
---@return integer
---@return integer
function GUI2D:GetAbsolutePosition()
	if not self.Parent then return 0,0 end
	local wParent, hParent = self.Parent:GetAbsoluteSize()
	local xParent, yParent = self.Parent:GetAbsolutePosition()
	return
		math.round(wParent * (self.Position.xScale or 0) + (self.Position.xOffset or 0) + xParent),
		math.round(hParent * (self.Position.yScale or 0) + (self.Position.yOffset or 0) + yParent)
end

---Renders this GUI2D.
---@param pass Pass
function GUI2D:Render(pass)
	
end

return GUI2D