---Custom Prototype-based object.<br>
---Getters can be implemented by writing a function named `get_PROPERTYHERE`.<br>
---Setters can be implemented by writing a function named `set_PROPERTYHERE`.<br>
---Constructor can be implemented by writing a function named `constructor`.<br>
---@class Poject
---@field __Prototype Poject The Prototype from which methods inherit from.
---@field Type string The "type" of this object.
---@field isPrototype boolean Whether this object is a prototype.
---@field constructor (fun(Poject): nil)? An optional function which modifies the Poject on cloning.
local Poject = {
	Type = "Poject",
	isPrototype = true
}

local function isFunction(x)
	return type(x) == "function"
end

local function isString(x)
	return type(x) == "string"
end

---@generic T: Poject
---Returns a new object identical to the first.
---@param self T | Poject
---@return T Clone
function Poject.Clone(self)
	---@type Poject
	local new = {
		__Prototype = self,
		Type = self.Type,
		isPrototype = false,
	}

	setmetatable(new, {
		__index = function (T, k)
			local getter = rawget(T, "get_"..k)
			if isString(k) and isFunction(getter) then return getter(T) end
			
			local prototype = rawget(T, "__Prototype")
			if not prototype then return nil end
			local protoProp = prototype[k]
			if protoProp then return protoProp end
			local protoGet = prototype["get_"..k]
			if isString(k) and isFunction(protoGet) then return protoGet(T) end
		end,
		__newindex = function(T,k,v)
			local setter = T["set_"..k]
			if isFunction(setter) then setter(T, v) end
			rawset(T, k, v)
		end
	})

	local constr = self.constructor --[[@as function]]
	if isFunction(constr) then constr(new) end
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
		currentPoj = currentPoj:GetPrototype()
	until currentPoj.__Prototype == currentPoj
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
		herence = herence.__Prototype
		if herence == herence.__Prototype then	-- Top of the chain
			if herence.isPrototype then return herence end
			error("Error during prototype chasing: Top of the chain is not Prototype")
		end
	until herence.isPrototype
	return herence
end

return Poject