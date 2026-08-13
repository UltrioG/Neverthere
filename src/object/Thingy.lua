local UUID = require("uuid")

local BYPASS_GETTERS = table.toSet({
	
})
local BYPASS_SETTERS = table.toSet({
	"__name",
	"__type"
})

---Prototype inheritance object
---@class Thingy
---@field __proto Thingy Prototype of this Thingy
---@field private __props table The actual fields and methods of this Thingy
---@field __uuid uuid A unique uuid for the Thingy
---@field __type string? An optional string field for typechecking and tostrings
---@field __name string? An optional string field for description and tostrings
---@field constructor nil | fun(self: Thingy, new: Thingy): nil A function called on the new object when `clone` is called
---@field __getters dictionary<fun(self: Thingy): any> A dictionary of getters
---@field __setters dictionary<fun(self: Thingy, value: any): nil> A dictionary of setters
---@field __protoChain Thingy[] A prototype chain from this Thingy to the root Thingy
---@field __allGettableProperties table
---@field __allSettableProperties table
---@field __allInherentProperties table
---@field __allUniqueProperties table
local Thingy = {
	__proto = nil,
	__props = {
		constructor = void
	},
	__uuid = UUID.v4(),
	__getters = {},
	__setters = {}
}
local THINGY_META = {}
Thingy.__name = "ProtoThingy"
Thingy.__type = "Thingy"
THINGY_META.__type = "Thingy"

---REMINDER TO SELF: ONLY ACTIVATES WHEN THE THINGY HAS IT AS NIL THANKS
---@param self Thingy
---@param k any
---@return any
function THINGY_META.__index(self, k)
	local getters = rawget(self, "__getters")
	if getters and type(getters[k]) == "function" and not BYPASS_GETTERS[k] then return getters[k](self) end
	local props = rawget(self, "__props")
	assert(props, "Critical Error: Thingy has no prop")
	return props[k]
end

---@param self Thingy
---@param k any
---@param v any
function THINGY_META.__newindex(self, k, v)
	if type(self.__setters[k]) == "function" and not BYPASS_SETTERS[k] then self.__setters[k](self, v) return end
	self.__props[k] = v
end

-- Calculational metamethod passing

local function setThingyMetamethodToPass(name)
	THINGY_META["__"..name] = function (self, ...)
		if type(self["__"..name]) == "function" then return self["__"..name](...) end
		error(("No metamethod __%s defined for %s!"):format(name, tostring(self)))
	end
end

local nonspecialMetamethods = {
	"add",
	"sub",
	"mul",
	"div",
	"mod",
	"pow",
	"unm",
	"idiv",
	"band",
	"bor",
	"bxor",
	"bnot",
	"shl",
	"shr",
	"concat",
	"len",
	"eq",
	"lt",
	"le"
}

for _, v in ipairs(nonspecialMetamethods) do setThingyMetamethodToPass(v) end

function THINGY_META.__tostring(self, ...)
	if type(self.__tostring) == "function" then return self.__tostring(self, ...) end
	return ("%s%s <@%s>"):format(
		self.__type or "Thingy",
		self.__name and ' "'..self.__name..'"' or '',
		self.__uuid
	)
end

---Loops over all properties, including of prototype Thingies
---@param self table
function THINGY_META.__pairs(self)
	if type(self.__pairs) == "function" then return self.__pairs(self) end
	return pairs(self.__allGettableProperties)
end

setmetatable(Thingy, THINGY_META)

---Creates a clone of this Thingy.
---@generic T:Thingy
---@param self T
---@return T new The new Thingy whose prototype will be the old Thingy
function Thingy:clone()
	local self = self --[[@as Thingy]]
	local new = {
		__proto = self,
		__props = setmetatable({}, {__index = self.__props}),
		__uuid = UUID.v4(),
		__type = self.__type,
		__getters = setmetatable({}, {__index = self.__getters}),
		__setters = setmetatable({}, {__index = self.__setters})
	}
	setmetatable(new, table.clone(getmetatable(self)))
	if type(new.constructor) == "function" then new:constructor(new) end
	return new
end

---Checks whether this Thiny inherits from that Thingy
---@param otherThingy Thingy
---@return boolean
function Thingy:isInstanceOf(otherThingy)
	local protoChain = table.reverse(self.__protoChain)
	for _, v in ipairs(protoChain) do if rawequal(otherThingy, v) then return true end end
	return false
end

---Gets the chain of prototypes from this Thingy to the root Thingy.
---Errors if there is a thingy loop.
---@param self Thingy
---@return Thingy[] thingyChain
function Thingy.__getters.__protoChain(self)
	---@type Set<Thingy>
	local seenThingies = {
		[self] = true
	}
	---@type Thingy[]
	local thingyChain = {self}
	while true do
		local proto = table.last(thingyChain).__proto
		if seenThingies[proto] then error("Critical Error: Circular Thingy Loop") end
		if proto == nil then break end
		table.insert(thingyChain, proto)
		seenThingies[proto] = true
	end
	return thingyChain
end

---Gets all properties of this thingy which are actually in its __props table and not inherited or gotten with getters.
---@param self Thingy
---@return table
function Thingy.__getters.__allUniqueProperties(self)
	return table.clone(self.__props)
end

---Gets all properties of this thingy, including inherited ones, but excluding getters and setters
---@param self Thingy
---@return table
function Thingy.__getters.__allInherentProperties(self)
	local protoChain = self.__protoChain
	local props = {}
	for _, thingy in ipairs(table.reverse(protoChain)) do
		for k, v in pairs(thingy.__props) do
			props[k] = v
		end
	end
	return props
end

---Get all properties which can be gotten, including from getters and inheritance.
---@param self Thingy
---@return table
function Thingy.__getters.__allGettableProperties(self)
	local protoChain = self.__protoChain
	local props = {}
	for _, thingy in ipairs(table.reverse(protoChain)) do
		---@type Thingy
		local thingy = thingy
		for k, v in pairs(thingy.__props) do
			props[k] = v
		end
		for k, v in pairs(thingy.__getters) do
			props[k] = "getter"
		end
	end
	return props
end

---Get all properties which can be set, including from getters and inheritance.
---@param self Thingy
---@return table
function Thingy.__getters.__allSettableProperties(self)
	local protoChain = self.__protoChain
	local props = {}
	for _, thingy in ipairs(table.reverse(protoChain)) do
		---@type Thingy
		local thingy = thingy
		for k, v in pairs(thingy.__props) do
			props[k] = v
		end
		for k, v in pairs(thingy.__setters) do
			props[k] = "setter"
		end
	end
	return props
end

---Type setter
---@param self Thingy
function Thingy.__setters.__type(self, ty)
	getmetatable(self).__type = ty
	rawset(self, "__type", ty)
end

return Thingy