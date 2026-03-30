---Custom Prototype-based object.
---
---Getters can be defined by writing a function named `get_PROPERTYNAMEHERE`.<br>
---Setters can be defined by writing a function named `set_PROPERTYNAMEHERE`.
---
---
---@class Poject
---@field Prototype Poject
local Poject = {}

---Returns a new object identical to the first.
---@return Poject Clone
function Poject:Clone()
	---@type Poject
	local new = {Prototype = self}
	setmetatable(new, {
		__index = function (T, k)
			if rawget(T, k) ~= nil then return rawget(T, k) end

			local prototype = rawget(T, "Prototype")
			if prototype == nil then return end
			return prototype[k]
		end
	})
	return new
end

return Poject