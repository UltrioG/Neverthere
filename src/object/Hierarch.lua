local THINGY = require("Thingy")

---A Thingy with a lineage.
---@class Hierarch: Thingy
---@field private __class string The "class" of this Hierarch
---@field Name string A name to identify this Hierarch.
---@field Parent Hierarch The parent of this Hierarch
---@field Children Hierarch[] The children of this Hierarch.
---@field Descendants Hierarch[] The descendants of this Hierarch.
---@field private __children Hierarch[]
---@field private __parent Hierarch
local Hierarch = THINGY:clone()
Hierarch.__children = {}
Hierarch.__type = "Hierarch"

function Hierarch:constructor(new)
	self.__proto:constructor(new)
	---@diagnostic disable-next-line
	new.Children = self.__proto.Children or {}
end

---Gets (a copy of) the Hierarch's children list
---@return [Hierarch] children
function Hierarch.__getters:Children()
	local list = {}
	for child in pairs(self.__children) do table.insert(list, child) end
	return list
end

---Gets a list of the Hierarch's descendants.
---Traversal is in level order.
---@param self Hierarch
---@return [Hierarch] descendants
function Hierarch.__getters:Descendants()
	local desc = self.Children
	local i = 1
	repeat
		local child = desc[i]
		if child == nil then break end
		for _, grandchild in ipairs(child.Children) do table.insert(desc, grandchild) end
		i = i + 1
	until desc[i] == nil
	return desc
end

function Hierarch.__getters:getParent()
	return self.__parent
end

---Sets the Parent of this Hierarch.
---@param self Hierarch
---@param p Hierarch
function Hierarch.__setters:setParent(p)
	---@diagnostic disable
	if self.Parent then self.Parent[self] = nil end
	self.__parent = p
	table.insert(p.__children, self)
	---@diagnostic enable
end

---Creates a new Hierarch with the same properties as this one.
---@generic T: Hierarch
---@param self T
---@return T
function Hierarch:Clone()
	---@type Hierarch
	local self = self
	local new = self:clone()
	new.__proto = self.__proto
	new.__children = {}
	for _, child in ipairs(self.Children) do
		local childClone = child:Clone()
		childClone.Parent = new
	end
	return new
end

function Hierarch.__getters:Name()
	return self.__name
end

function Hierarch.__setters:Name(v)
	self.__name = v
end

return Hierarch