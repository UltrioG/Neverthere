local POJ = require("Library.Hierach")

---@class GUI2D: Hierach
---@field Prototype Hierach | GUI2D
---@field Position UDim2
---@field Size UDim2
---@field Rotation number 	The radians counterclockwise the GUI2D spins
local GUI2D = POJ:Inherit()
GUI2D.Type = "GUI2D"
GUI2D.Position = {xScale = 0.5, yScale = 0.5}
GUI2D.Rotation = 0
GUI2D.Size = {xOffset = 10, yOffset = 10}

---Gets the pixel size of the GUI2D.
---@return integer
---@return integer
function GUI2D:GetAbsoluteSize()
	local xParent, yParent
	local p = self.Parent --[[@as GUI2D]]
	if p and p:IsA("GUI2D") then
		xParent, yParent = p:GetAbsoluteSize()
	else
		xParent, yParent = lovr.system.getWindowDimensions()
	end
	return
		math.round(xParent * (self.Size.xScale or 0) + (self.Size.xOffset or 0)),
		math.round(yParent * (self.Size.yScale or 0) + (self.Size.yOffset or 0))
end

---Gets the pixel position of the GUI2D.
---@return integer
---@return integer
function GUI2D:GetAbsolutePosition()
	local p = self.Parent--[[@as GUI2D]]
	local wParent, hParent
	local xParent, yParent
	if p and p:IsA("GUI2D") then
		wParent, hParent = p:GetAbsoluteSize()
		xParent, yParent = p:GetAbsolutePosition()
	else
		wParent, hParent = lovr.system.getWindowDimensions()
		xParent, yParent = 0, 0
	end
	return
		math.round(wParent * (self.Position.xScale or 0) + (self.Position.xOffset or 0) + xParent),
		math.round(hParent * (self.Position.yScale or 0) + (self.Position.yOffset or 0) + yParent)
end

---Renders this GUI2D.
---@param pass Pass
function GUI2D:Render(pass)
	
end

return GUI2D