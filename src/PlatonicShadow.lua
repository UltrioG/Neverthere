local SMPL = require "smpl"

local EXTENSION = ".smpl"
local PATH = "./data/gui/"

local SHADOW = {}

---Export a Gui tree to a smpl file.
---@generic T: Gui
---@param guiRoot T	The root of the Gui tree to export
---@param fileName string	The name of the file to export to.
---@param overwrite boolean?	Whether or not overwrites to files should be allowed. Defaults to false
---@return boolean success		Whether or not the export was successful.
---@return string? error		If applicable, the error which cause the export to fail.
local function exportGui(guiRoot, fileName, overwrite)
	assert(not fileName:match('/'), "Filename cannot contain slashes!")
	assert(not fileName:match('%.'), "Filename cannot contain dots!")
	assert(not fileName:match('%s'), "Filename cannot contain whitespaces!")
	local fileName = fileName:gsub("%..+$", "")
	local path = PATH..fileName .. EXTENSION
	local fileExists = lovr.filesystem.isFile(path)
	if not overwrite and fileExists then
		return false, "Cannot overwrite file without overwrite flag."
	end
	local smpl, errmsg = io.open(path, "wb")
	if not smpl then return false, errmsg end
	smpl:write(SMPL.encode(guiRoot))
	smpl:flush()
	smpl:close()
	return true
end

local function set2D(pass)
	local font = lovr.graphics.getDefaultFont()
	font:setPixelDensity(1)

	local width, height = lovr.system.getWindowDimensions()
	local projection = Mat4():orthographic(0, width, 0, height, -10, 10)
	pass:setViewPose(1, mat4():identity(), false)
	pass:setProjection(1, projection)
	pass:setDepthTest()
end

---Converts a smpl file to a Gui.
---@param filename string	The filename of the path, without extension.
---@return Gui
---@return Hierarch[] others
local function importGui(filename)
	local filename = assert(filename, "No filename provided!"):gsub("%..+$", "")
	local FILE = assert(io.open(PATH..filename..EXTENSION))
	return SMPL.decode(FILE:read("*a"))	---@diagnostic disable-line
end

local focus = nil
local command = ""
local lastEnteredCommandTime = 0

local root = Hierarch.new("Gui")	--[[@as Gui]]
root.Size = UDim2.new(1,0,1,0)
root.Name = "guiroot"
local exportRoot = root:Clone()
exportRoot.Name = "ExportRoot"
local commandLabel = Hierarch.new("Text")	--[[@as Text]]
commandLabel.Pivot = vector(0,1)
commandLabel.Position = UDim2.new(0,8,1,-8)
commandLabel.Size = UDim2.new(1, -16, 0, 50)
commandLabel.Name = "CommandLine"
commandLabel.HorizontalAlignment = "left"
commandLabel.Scale = 0.75
commandLabel.VerticalAlignment = "bottom"
commandLabel.Content = "Please input your command..."
local commandBG = Hierarch.new("Box")	--[[@as Box]]
commandBG.Color = 0x0d0d0d
commandBG.Name = "CommandBG"
commandBG.__size = commandLabel.__size
commandBG.__position = commandLabel.__position
commandBG.Pivot = commandLabel.Pivot

exportRoot.Parent = root
commandBG.Parent = root
commandLabel.Parent = root


---@type Gui
local relevant = exportRoot
---@type Gui
local storage = nil

---@return Gui[]
local function getAllUIs()
	return table.union({root}, root.Descendants)
end

local historyIndex = 1
local history = {}

---Executes command
---@param cmd string
local function dexecution(cmd)
	---@type string[]
	local chunks = {}
	for chunk in cmd:gmatch("[%w.-]+") do table.insert(chunks, chunk) end
	local cmdThing = chunks[1]
	print(chunks)
	if cmdThing == "new" then
		local success, err = pcall(function (...)
			relevant = Hierarch.new(chunks[2])
			relevant.Parent = exportRoot
			relevant.Name = chunks[3]
			relevant.Visible = true
		end)
		if not success then errLog(err) end
	elseif cmdThing == "childls" then
		print(relevant.Children)
	elseif cmdThing == "child" then
		relevant = assert(relevant.Children[tonumber(chunks[2])], "No such child")	--[[@as Gui]]
	elseif cmdThing == "curr" then
		print(relevant)
	elseif cmdThing == "udim2" then
		relevant[chunks[2]] = UDim2.new(tonumber(chunks[3]), tonumber(chunks[4]), tonumber(chunks[5]), tonumber(chunks[6]))
	elseif cmdThing == "vec" then
		relevant[chunks[2]] = vector(tonumber(chunks[3]), tonumber(chunks[4]), tonumber(chunks[5]))
	elseif cmdThing == "store" then
		storage = relevant
	elseif cmdThing == "parent" then
		relevant = relevant.Parent	--[[@as Gui]]
	elseif cmdThing == "plink" then
		relevant.Parent = storage
	elseif cmdThing == "number" then
		relevant[chunks[2]] = tonumber(chunks[3])
	elseif cmdThing == "export" then
		exportGui(exportRoot, chunks[2], true)
	elseif cmdThing == "import" then
		exportRoot = importGui(chunks[2])
		exportRoot.Parent = root
	elseif cmdThing == "include" then
		local imported = importGui(chunks[2])
		imported.Name = chunks[2]
		imported.Parent = exportRoot
	end
end

table.insert(LOVR_BINDS.keypressed, function (key, scancode, isRepeat)
	if key == "backspace" then
		if lovr.system.isKeyDown("lctrl") or lovr.system.isKeyDown("rctrl") then
			local wordy = command:match("%s?%w+$")
			if wordy then command = command:sub(1, -1-#wordy)
			else command = command:sub(1,-2) end
		else
			command = command:sub(1,-2)
		end
	elseif key == "return" then
		table.insert(history, command)
		historyIndex = #history + 1
		dexecution(command)
		command = ""
	elseif key == "up" then
		historyIndex = historyIndex - 1
		if historyIndex < 0 then historyIndex = 0 end
		command = history[historyIndex] or ""
	elseif key == "down" then
		historyIndex = historyIndex + 1
		if historyIndex > #history+1 then historyIndex = #history+1 end
		command = history[historyIndex] or ""
	end
end)

table.insert(LOVR_BINDS.keyreleased, function (key, scancode)
	lovr.system.setKeyRepeat(false)
end)

table.insert(LOVR_BINDS.textinput, function (char, code)
	command = command .. char
end)

---Draw
---@param pass Pass
function SHADOW.draw(pass)
	local nocommand = command == ""
	commandLabel.Content = nocommand and "Please input your command..." or command
	commandLabel.Color = nocommand and 0x808080 or 0xffffff

	set2D(pass)
	root:DrawLineage(pass)
end

return SHADOW