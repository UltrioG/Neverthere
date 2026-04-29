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
local GUI2D = require("Library.Prototypes.Gui.GUI2D")
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

	---@type [GUI2D]
	local renderQueue = {GuiRoot}
	repeat
		---@type GUI2D
		local current = table.remove(renderQueue, 1)
		local children = current:GetChildren()
		for _, v in ipairs(children) do table.insert(renderQueue,v) end
		current:Render(pass)
		log(current:GetAbsolutePosition())
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

--#region parseStringToData
---@alias returnable
---| number
---| color
---| [color, number]
---| string
---| UDim2
---| Vec2
---| Vec3
---| Vec4

---@alias customType
---| "color"
---| "udim2"
---| "vec2"
---| "vec3"
---| "vec4"

---@alias totalType type|customType

local INTEGER_PATTERN = "^[+-]?%d*$"
local NUMBER_PATTERN = "^[+-]?%d*%.%d+$"

---Converts a tuple string to a data type.
---@param s string
---@return [totalType]
---@return [returnable]
function parseTupleToDatas(s)
	local substring = s:sub(2,-2)
	local tupled = {}
	local data = {}
	local types = {}
	for tupler in substring:gmatch("[^,]+,?") do
		table.insert(tupled, tupler)
		local t, d = parseStringToData(tupler)
		table.insert(data, d)
		table.insert(types, t)
	end
	return types, data
end

---@type {
--- [totalType]: {argumentTypes: [totalType], transformationFunction: fun(data:[returnable]): returnable}}
local extypeData = {
	udim2 = {
		argumentTypes = {"number", "number", "number", "number"},
		transformationFunction = function (data)
			---@cast data [number]
			return {
				xScale = data[1],
				xOffset = data[2],
				yScale = data[3],
				yOffset = data[4]
			}
		end
	},
	vec2 = {
		argumentTypes = {"number", "number"},
		transformationFunction = function (data)
			---@cast data [number]
			return vec2(table.unpack(data))
		end
	},
	vec3 = {
		argumentTypes = {"number", "number", "number"},
		transformationFunction = function (data)
			---@cast data [number]
			return vec3(table.unpack(data))
		end
	},
	vec4 = {
		argumentTypes = {"number", "number", "number", "number"},
		transformationFunction = function (data)
			---@cast data [number]
			return vec4(table.unpack(data))
		end
	},
	
}

--- Converts a string to a data type.<br>
--- Currently, the following datatypes are supported:<br>
--- - Number
---  - Base 10 numbers are input as normal, and is the only type that may be nonintegral
---  - Base 16 *must* have 0x prefix, and must be a natural number
---  - Base 2 *must* have 0b prefix, and must be a natural number
--- - Color (#abcdef)
--- - Explicit type (type(blah, blah, blah)) including:
---  - UDim2 (udim2(number, number, number, number))
---  - Vector2 (vec2(number, number))
---  - Vector3 (vec3(number, number, number))
---  - Vector4 (vec4(number, number, number, number))
--- - string
---@param s string
---@return totalType
---@return returnable
function parseStringToData(s)
	local isHex = not not s:match("^#%x%x%x%x%x%x$")
	if isHex then	-- Hex color
		return "color", tonumber(s, 16)
	end

	local isNum = not not (s:match(NUMBER_PATTERN) or s:match(INTEGER_PATTERN) or s:match("^0x%x+$") or s:match("^0b[01]+$"))
	if isNum then
		return "number", tonumber(s, s:sub(2,2) == "b" and 2 or s:sub(2,2) == "x" and 16 or 10)
	end

	local isExplicitType = not not s:match("^.-%b()$")
	if isExplicitType then
		local extype, bracketed = s:match("^(.-)(%b())$")
		local unbracketed = bracketed:sub(2,-2)
		local types, data = parseTupleToDatas(unbracketed)
		for i, v in ipairs(extypeData[extype]) do
			if types[i] ~= v then
				error(("Expected %s as argument no. %i, got %s instead"):format(v, i, types[i]))
			end
		end
		local parsed = extypeData[extype].transformationFunction(data)
		return extype, parsed
	end
	return "string", s
end
--#endregion parseStringToData

---Creates an entire GUI tree out of a DOM object.
---@param DOM DOM
---@return GUI2D root
function GuiManager.DOMToTree(DOM)
	---@type [DOM]
	local doms = {DOM}
	local i = 1
	---@type {[DOM]: GUI2D}
	local domToGuis = {}
	repeat
		local current = doms[i]
		for _, child in ipairs(current.innerXML) do
			if type("child") ~= "string" then table.insert(doms, child) end
		end
		local obj = GuiManager.AddGuiObject(current.tag)
		for attribute, value in pairs(current.attributes) do obj[attribute] = parseStringToData(value) end
		domToGuis[current] = obj
	until i == #doms
	for _, dom in ipairs(doms) do
		domToGuis[dom].Parent = domToGuis[dom.parent]
	end
	return domToGuis[DOM]
end

return GuiManager