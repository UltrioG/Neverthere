local POJ = require("Library.Prototypes.Hierach")

---A prototype for any object which is to be rendered as a UI element.
---@class GUI2D: Hierach
---@field Prototype Hierach | GUI2D
---@field Position UDim2				Where to render the element. Anchored at the center.
---@field Size UDim2					How big the element should be.
---@field Rotation number				The radians counterclockwise the GUI2D spins.
local GUI2D = POJ:Inherit()
GUI2D.Type = "GUI2D"
GUI2D.Position = {xOffset = 0, yOffset = 0, xScale = 0, yScale = 0}
GUI2D.Size = {xScale = 1, yScale = 1}
GUI2D.Rotation = 0

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