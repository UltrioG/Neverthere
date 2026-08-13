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

local parseSingular = function (x)
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

---Prettifies a value.
---@vararg any
---@return string ...
function PRETTY.parse(...)
	return unpack(table.map({...}, function(k,v) return k, parseSingular(v) end))
end

---Pretty prints a value.
---@vararg any
function PRETTY.print(...)
	return print(PRETTY.parse(...))
end

return PRETTY