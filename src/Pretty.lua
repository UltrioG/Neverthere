---[[
---
---Pretty
---
---Pretty prints tables.
---
---Written by Ultrio.
---
---]]

local PRETTY = {}

---Prettifies a value.
---@param x any
---@return string
function PRETTY.parse(x)
	local s = tostring(x)
	if type(x) == "string" then return '"'..s:gsub("\n", "\\n")..'"' end
	if type(x) == "nil" then return "nil" end
	if type(x) ~= "table" then return s end
	if not s:match("table: 0x%x+") then return s end
	
	local s = ("(@%s) {"):format(tostring(x):match("0x%x+"))
	for k, v in pairs(x) do
		s = s .. '\n' .. ("[%s] = %s"):format(
			(type(k) == "string" and '"%s"' or "%s"):format(tostring(k)),
			PRETTY.parse(v)
		) .. ','
	end
	if s:sub(-1, -1) ~= '{' then
		s = s:sub(1,-2):gsub("\n", "\n\t")
		s = s .. "\n}"
	else
		s = s .. '}'
	end
	return s
end

---Pretty prints a value.
---@param x any
function PRETTY.print(x)
	return print(PRETTY.parse(x))
end

return PRETTY