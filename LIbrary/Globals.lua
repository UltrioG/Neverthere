---@meta

---@alias numeric number|Vec2|Vec3|Vec4|Mat4

---Rounds a number.
---@param x number
---@return integer
math.round = function (x)
	return math.floor(x) + math.floor(2*(x%1))
end

---Linear Interpolation
---@generic T: numeric
---@param a T
---@param b T
---@param t number
---@return T
math.lerp = function (a, b, t)
	return (b-a)*t+a
end