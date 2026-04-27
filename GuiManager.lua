local GuiManager = {}
---@enum (key) GuiNames
local GUI_NAMES = {
	GUI2D = 1,
	Rectangle = 2,
	TextLabel = 3,
	Decal = 4
}
---@type {[GuiNames]: GUI2D}
local GUI_OBJECTS = {}
for filename in pairs(GUI_NAMES) do GUI_OBJECTS[filename] = require("Library.Prototypes.Gui."..filename) end

local GuiRoot = require("Library.Prototypes.Gui.GUI2D"):Clone()

---@param pass Pass
function GuiManager.Render2D(pass)
	--#region Basic Setup
	local font = lovr.graphics.getDefaultFont()
	font:setPixelDensity(1)

	local width, height = lovr.system.getWindowDimensions()
	local projection = Mat4():orthographic(0, width, 0, height, -10, 10)
	pass:setViewPose(1, mat4():identity(), false)
	pass:setProjection(1, projection)
	pass:setDepthTest()
	--#endregion Basic Setup

	
end

---Creates a new GUI2D or its inheritants.
---@param guiObjectType GuiNames
---@param parent GUI2D
---@return GUI2D
function GuiManager.AddGuiObject(guiObjectType, parent)
	local parent = parent or GuiRoot
	local new = GUI_OBJECTS[guiObjectType]:Clone()
	new.Parent = parent
	return new
end

return GuiManager