---Custom Prototype-based object.
---@class Poject
---@field __Prototype Poject The Prototype from which methods inherit from.
---@field Type string The "type" of this object.
---@field isPrototype boolean Whether this object is a prototype.
local Poject = {
	Type = "Poject",
	isPrototype = true
}

---@generic T: Poject
---Returns a new object identical to the first.
---@param self T | Poject
---@return T Clone
function Poject.Clone(self)
	---@type Poject
	local new = {
		__Prototype = self,
		Type = self.Type,
		isPrototype = false
	}
	setmetatable(new, {
		__index = function (T, k)
			if rawget(T, k) ~= nil then return rawget(T, k) end
			-- if type(k) == "string" then
			-- 	-- Getters
			-- 	if type(rawget(T, "get_"..k)) == "function" then return rawget(T, "get_"..k) end
			-- end
			local prototype = rawget(T, "__Prototype")
			if not prototype then return nil end
			return prototype[k]
		end
	})
	return new
end

---@generic T: Poject
---Returns a new Prototype identical to the first.
---@param self T | Poject
---@return Poject
function Poject.Inherit(self)
	local new = self:Clone()
	new.isPrototype = true
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
	until currentPoj.__Prototype == nil
	return false
end

---Returns the prototype of this Poject.
---Returned Poject is guaranteed to have isPrototype == true.
---@generic T: Poject
---@param self T
---@return T
function Poject:GetPrototype()
	---@type Poject
	local herence = self
	repeat
		log(herence.Type, herence.isPrototype)
		herence = herence.__Prototype
		if herence == herence.__Prototype then	-- Top of the chain
			if herence.isPrototype then return herence end
			error("Error during prototype chasing: Top of the chain is not Prototype")
		end
	until herence.isPrototype
	return herence
end

return Poject