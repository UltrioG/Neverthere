local THINGY = require "Thingy"

---@class Datathingy: Thingy	Thingies which represent data.
---@field frozen boolean
local Datathingy = THINGY:clone()
Datathingy.frozen = false
Datathingy.__type = "Datathingy"
Datathingy.__name = "ProtoDatathingy"

---Makes certain properties of this Datathingy no longer editable.
function Datathingy:freeze()
	rawset(self, "frozen", true)
end

return Datathingy