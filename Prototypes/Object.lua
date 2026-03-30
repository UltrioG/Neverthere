---Custom Prototype-based object.
---@class Poject
---@field Prototype Poject
local Poject = {}

---Returns a new object identical to the first.
---@return Poject Clone
function Poject:Clone()
	---@type Poject
	local new = {Prototype = self}
	setmetatable(new, {__index = self})
	return new
end

return Poject