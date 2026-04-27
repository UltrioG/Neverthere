local POJ = require("Library.Prototypes.Poject")

---@class Hierach: Poject
---@field Prototype Poject | Hierach
---@field Parent Hierach?		The "parent" of this Hierach.
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
	child.Parent = self
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



return Hierach