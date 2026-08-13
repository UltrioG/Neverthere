local EXTENSION = ".smpl"
local PATH = "./data/gui/"
local SMPL = require "smpl"
local PRETTY = require "Pretty"

local function set2D(pass)
	local font = lovr.graphics.getDefaultFont()
	font:setPixelDensity(1)

	local width, height = lovr.system.getWindowDimensions()
	local projection = Mat4():orthographic(0, width, 0, height, -10, 10)
	pass:setViewPose(1, mat4():identity(), false)
	pass:setProjection(1, projection)
	pass:setDepthTest()
end

---Export 
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
	local bsr, errmsg = io.open(path, "wb")
	if not bsr then return false, errmsg end
	bsr:write(SMPL.encode(guiRoot))
	bsr:flush()
	bsr:close()
	return true
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

function lovr.draw(pass)
	set2D(pass)
end