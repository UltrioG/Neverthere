local POJ = require("Library.Prototypes.Poject")

---@class Hierach: Poject
---@field Prototype Poject | Hierach
---@field Parent Hierach?		The "parent" of this Hierach.
---@field _Parent Hierach?		The actual parent of this Hierach.
---@field _Children [Hierach]	The children of this Hierach.
local Hierach = POJ:Inherit()
Hierach.Type = "Hierach"

function Hierach.constructor(new)
	new._Children = {}
end

---Adds a child to this Hierach object.
---@generic T: Hierach
---@param self T | Hierach
---@param child Hierach
---@return T parent The parent hierach.
function Hierach:AddChild(child)
	rawset(child, "_Parent", self)
	table.insert(self._Children, child)
	return self
end

---Get all children of the Hierach.
---@return [Hierach]
function Hierach:GetChildren()
	local children = {}
	table.move(self._Children, 1, #self._Children, 1, children)
	return children
end

---Setter for setting Parent
---@param P Hierach
function Hierach:set_Parent(P)
	P:AddChild(self)
end

---Getter for getting Parent
---@generic T: Hierach
---@return T Parent
function Hierach:get_Parent()
	return rawget(self, "_Parent")
end

return Hierach