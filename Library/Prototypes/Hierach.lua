local POJ = require("Library.Prototypes.Poject")

---@class Hierach: Poject
---@field Prototype Poject | Hierach
---@field Parent Hierach?		The parent of this Hierach.
---@field _Parent Hierach?		The internally used actual parent of this Hierach. Please do not modify directly.
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
	if child.Parent then
		for i, v in ipairs(child.Parent._Children) do
			if v == child then table.remove(child.Parent._Children, i) break end
		end
	end
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

---Clears all children of this Hierach.
---@generic T: Hierach
---@param self T | Hierach
---@return T | Hierach self
function Hierach:ClearAllChildren()
	for _, v in ipairs(self:GetChildren()) do
		v.Parent = nil
	end
	self._Children = {}
	return self
end

return Hierach