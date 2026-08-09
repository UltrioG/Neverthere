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
for filename in pairs(GUI_NAMES) do GUI_OBJECTS[filename] = require("Prototypes.Gui."..filename) end
local GUI2D = require("Prototypes.Gui.GUI2D")
local GuiRoot = GUI2D:Clone()

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

	---@type queue<GUI2D>
	local renderQueue = {GuiRoot}
	repeat
		---@type GUI2D
		local current = table.remove(renderQueue, 1)
		local children = current:GetChildren()
		for _, v in ipairs(children) do table.insert(renderQueue,v) end
		current:Render(pass)
	until #renderQueue == 0
end

---Creates a new GUI2D or its inheritants.
---@generic T: GUI2D
---@param guiObjectType GuiNames
---@param parent GUI2D?
---@return T
function GuiManager.AddGuiObject(guiObjectType, parent)
	local parent = parent or GuiRoot
	assert(GUI_OBJECTS[guiObjectType], ("No such GUI Object '%s'!"):format(guiObjectType))
	local new = GUI_OBJECTS[guiObjectType]:Clone()
	new.Parent = parent
	return new
end

---Removes a Gui2D and its descendants from the tree.
---@param gui2d GUI2D
function GuiManager.RemoveGuiObject(gui2d)
	---@type [GUI2D]
	local removalQueue = {gui2d}
	repeat
		---@type GUI2D
		local current = table.remove(removalQueue, 1)
		local children = current:GetChildren()
		for _, v in ipairs(children) do table.insert(removalQueue,v) end
		current.Parent = nil
		current:ClearAllChildren()
	until #removalQueue == 0
end

---Directly adds a GUI2D into the hierachy.
---@param O GUI2D
function GuiManager.AddGuiObjectDirect(O)
	if not O.Parent then O.Parent = GuiRoot end
end

return GuiManager