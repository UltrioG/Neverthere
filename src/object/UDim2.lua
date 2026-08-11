local THINGY = require("Thingy")

---@class UDim2: Thingy
---@field xScale number
---@field yScale number
---@field xOffset integer
---@field yOffset integer
---@field private frozen boolean Whether the UDim2 is mutable
local UDim2 = THINGY:clone()
UDim2.xScale = 0
UDim2.xOffset = 0
UDim2.yScale = 0
UDim2.yOffset = 0
UDim2.__name = "ProtoUDim2"
UDim2.__type = "UDim2"
UDim2.frozen = false

---Human-readable version of UDim2
---@param self UDim2
---@return string
function UDim2:__tostring()
	return ("{%0.4f%%%i, %0.4f%%%i}"):format(self.xScale or 0, self.xOffset or 0, self.yScale or 0, self.yOffset or 0)
end


function UDim2.__setters:xScale(v)
	if UDim2.frozen then error("UDim2 is immutable!") end
	rawset(self, "xScale", v)
end
function UDim2.__setters:xOffset(v)
	if UDim2.frozen then error("UDim2 is immutable!") end
	rawset(self, "xOffset", v)
end
function UDim2.__setters:yScale(v)
	if UDim2.frozen then error("UDim2 is immutable!") end
	rawset(self, "yScale", v)
end
function UDim2.__setters:yOffset(v)
	if UDim2.frozen then error("UDim2 is immutable!") end
	rawset(self, "yOffset", v)
end
function UDim2.__setters:frozen()
	error("Please use UDim2:freeze() to freeze the UDim2.")
end
function UDim2:freeze()
	rawset(self, "frozen", true)
end

return UDim2