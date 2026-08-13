local DATATHINGY = require("Datathingy")

---@class UDim2: Datathingy
---@field xScale number
---@field yScale number
---@field xOffset integer
---@field yOffset integer
---@field private frozen boolean Whether the UDim2 is mutable
local UDim2 = DATATHINGY:clone()
UDim2.xScale = 0
UDim2.xOffset = 0
UDim2.yScale = 0
UDim2.yOffset = 0
UDim2.__name = "ProtoUDim2"
UDim2.__type = "UDim2"

---Human-readable version of UDim2
---@param self UDim2
---@return string
function UDim2:__tostring()
	return ("{%0.4f%%%i, %0.4f%%%i}"):format(self.xScale or 0, self.xOffset or 0, self.yScale or 0, self.yOffset or 0)
end


function UDim2.__setters:xScale(v)
	if UDim2.frozen then error("UDim2 is immutable!") end
	self.__props.xScale = v			---@diagnostic disable-line
end
function UDim2.__setters:xOffset(v)
	if UDim2.frozen then error("UDim2 is immutable!") end
	self.__props.xOffset = v		---@diagnostic disable-line
end
function UDim2.__setters:yScale(v)
	if UDim2.frozen then error("UDim2 is immutable!") end
	self.__props.yScale = v			---@diagnostic disable-line
end
function UDim2.__setters:yOffset(v)
	if UDim2.frozen then error("UDim2 is immutable!") end
	self.__props.yOffset = v		---@diagnostic disable-line
end
function UDim2.__setters:frozen()
	error("Please use UDim2:freeze() to freeze the UDim2.")
end


return UDim2