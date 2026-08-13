--[[
This Hierarch.lua is for accessing every other thingies.
It's NOT the definition file for the Hierarch Thingy. See src/object/Hierarch.lua for that.
]]

local HIERARCH = {}
---@enum (key) hierarchType
HIERARCH_TYPE = {
	Hierarch = 1,
	Gui = 2,
	Box = 3,
	Text = 4
}
---@type dictionary<Hierarch>
local HIERARCHLIST = {}
for k in pairs(HIERARCH_TYPE) do HIERARCHLIST[k] = require(k) end

---Creates a new Hierarch.
---@generic T: Hierarch
---@param hierarchType hierarchType	The type of the Hierarch you wish to create
---@return T Hierarch				The Hierarch
function HIERARCH.new(hierarchType)
	return assert(HIERARCHLIST[hierarchType], ("No Hierarch of type \"%s\" found!"):format(hierarchType)):clone()
end

return HIERARCH