---An object which is rendered on the screen, but does not have depth.
---@class Gui: Hierarch
---@field Position UDim2
---@field Size UDim2
---@field Visible boolean
---@field x integer The absolute X-Coordinate of the center of the Gui
---@field y integer The absolute Y-Coordinate of the center of the Gui
---@field width integer The absolute width of the Gui
---@field height integer The absolute height of the Gui
---@field dimensions {x: integer, y: integer, w: integer, h: integer} A nicely-packed up version of x, y, width and height.
---@field Pivot pivot
---@field private __position UDim2
---@field private __size UDim2
local Gui = require("Hierarch"):clone()
Gui.Visible = false
Gui.__type = "Gui"
Gui.__position = UDim2.new(.5,0,.5,0)
Gui.__size = UDim2.new(0,100,0,100)
Gui.Pivot = vector(0.5, 0.5)
Gui:constructor(Gui)

---@param new Gui
function Gui:constructor(new)
	self.__proto:constructor(new)
	new.Position = self.Position
	new.Size = self.Size
end

---Get the size, in pixels, of this Gui.
---@param self Gui
---@return integer width
---@return integer height
function Gui:GetAbsoluteSize()
	local parentW, parentH
	local parent = self.Parent
	if parent and parent:isInstanceOf(Gui) then
		local parent = parent	--[[@as Gui]]
		parentW, parentH = parent:GetAbsoluteSize()
	else
		parentW, parentH = lovr.system.getWindowDimensions()
	end
	return
		math.round(parentW * (self.Size.xScale or 0) + (self.Size.xOffset or 0)),
		math.round(parentH * (self.Size.yScale or 0) + (self.Size.yOffset or 0))
end

---Get the position, in pixels, of this Gui.
---@param self Gui
---@return integer x
---@return integer y
function Gui:GetAbsolutePosition()
	local parentW, parentH
	local parent = self.Parent
	if parent and parent:isInstanceOf(Gui) then
		local parent = parent	--[[@as Gui]]
		parentW, parentH = parent:GetAbsoluteSize()
	else
		parentW, parentH = lovr.system.getWindowDimensions()
	end
	local x = parentW * (self.Position.xScale or 0) + (self.Position.xOffset or 0)
	local y = parentH * (self.Position.yScale or 0) + (self.Position.yOffset or 0)
	return math.round(x), math.round(y)
end

---Get the coordinate such that if the middle of the Gui were there, the pivot would be at `Pivot`
---@return integer x
---@return integer y
function Gui:GetPivotedPosition()
	local x, y, w, h = self:GetAbsoluteDimensionTuple()
	return math.round(x - math.lerp(-w/2,w/2,self.Pivot.x)),math.round(y - math.lerp(-h/2,h/2,self.Pivot.y))
end

---@diagnostic disable
function Gui.__getters:dimensions()
	local x, y = self:GetAbsolutePosition()
	local w, h = self:GetAbsoluteSize()
	return {
		x=x,
		y=y,
		w=w,
		h=h
	}
end
function Gui.__getters:x()
	return self.dimensions.x
end
function Gui.__getters:y()
	return self.dimensions.y
end
function Gui.__getters:width()
	return self.dimensions.w
end
function Gui.__getters:height()
	return self.dimensions.h
end
---Get the dimensions of the Gui as a tuple.
---@return integer x
---@return integer y
---@return integer w
---@return integer h
function Gui:GetAbsoluteDimensionTuple()
	local dims = self.dimensions
	return dims.x, dims.y, dims.w, dims.h
end
---@diagnostic enable

---Set the position, in UDim2, of this Gui
---@param self Gui
---@param pos UDim2
function Gui.__setters:Position(pos)
	---@type UDim2
	local newPos = pos
	self.__position = newPos
end

---Get the position, in UDim2, of this Gui
---@param self Gui
---@return UDim2 Position
function Gui.__getters:Position()
	return self.__position
end

---Sets the size, in UDim2, of this Gui
---@param self Gui
---@param size UDim2
function Gui.__setters:Size(size)
	self.__size = size
end

---Gets the size, in UDim2, of this Gui
---@param self Gui
---@return UDim2 Size
function Gui.__getters:Size()
	return self.__size
end

---Draws this Gui, and all its children, to this pass.
---@param pass Pass
function Gui:DrawLineage(pass)
	self:DrawSelf(pass)
	local toDraw = self.Descendants
	for _, v in ipairs(toDraw) do
		local v = v --[[@as Gui]]
		if not v:isInstanceOf(Gui) then goto continue end
		v:DrawSelf(pass)
		::continue::
	end
end

---Draw only this Gui to the pass.
---@param pass Pass
function Gui:DrawSelf(pass)
	if not self.Visible then return end
	local x, y, w, h = self:GetAbsoluteDimensionTuple()
	local px, py = self:GetPivotedPosition()
	pass:setColor(0xff0000, 1)
	pass:box(px, py, 0, w, h, 0, 0, 0, 0, 0, "line")	-- Box
	pass:box(x, y, 0, 8, 8, 0, 0, 0, 0, 0, "fill")	-- Pivot
	local font = lovr.graphics.getDefaultFont()
	local text = tostring(self)
	local width, height = font:getWidth(text), font:getHeight()
	pass:setColor(0, 1)
	pass:box(
		math.round(px - w/2 + width/4),
		math.round(py - h/2 - height/4),
		0,
		math.floor(width/2)+ 8,
		math.floor(height/2),
		0, 0, 0, 0, 0,
		"fill"
	)
	pass:setColor(0xff0000, 1)
	pass:text(text, math.round(px - w/2), math.round(py - h/2), 1, 0.5, 0, 0, 0, 0, 0, "left", "bottom")
end

return Gui