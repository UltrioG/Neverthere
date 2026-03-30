---Custom Prototype-based object.
---
---Getters can be defined by writing a function named `get_PROPERTYNAMEHERE`.<br>
---Setters can be defined by writing a function named `set_PROPERTYNAMEHERE`.
---
---
---@class Poject
---@field Prototype Poject
---@field Type string
local Poject = {
	Type = "Poject"
}

---Returns a new object identical to the first.
---@return Poject Clone
function Poject:Clone()
	---@type Poject
	local new = {
		Prototype = self,
		Type = self.Type
	}
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

---Check if this Poject inherits from a type
---@param potype string
---@return boolean
---@overload fun(potype: Poject): boolean
function Poject:IsA(potype)
	---@type string?
	local typeToCheck =
		type(potype) == "table"
		and (type(potype.Type) == "string" and potype.Type or nil)
		or (type(potype) == "string" and potype or nil)
	if not typeToCheck then return false end
	local currentPoj = self
	repeat
		if currentPoj.Type == potype then return true end
	until currentPoj.Prototype == nil
	return false
end

return Poject