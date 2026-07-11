local JSON = {}

---@enum (key) jsonEnum
local JSON_ENUM = {
	arrInit = {"arrInit"},
	arrExit = {"arrExit"},
	objInit = {"objInit"},
	objExit = {"objExit"},
	comma = {"comma"},
	colon = {"colon"},
	null = {"null"}
}

local CONSTANTS = {
	["null"] = JSON_ENUM.null,
	["true"] = true,
	["false"] = false
}

---Parses a JSON string.
---@param s string
---@return any value The parsed value
function JSON.parse(s)
	---@type [jsonEnum | string | true | false | number]
	local intermediate = {}
	---@type [ [integer, integer] ]
	local intermediatePositions = {}
	local index = 1
	local line = 1
	local lastRecordedChar = 1
	local function push(x) table.insert(intermediate, x) end
	local function pushIndex()
		table.insert(intermediatePositions, {line, index - lastRecordedChar})
	end
	local function currentChar() return s:sub(index, index) end
	local function fromIndex() return s:sub(index) end
	local function jsonErr(s)
		local s = s:gsub("%%k", fromIndex():sub(1, math.min(#fromIndex(), 24)))
		error("JSONError: "..s)
	end
	local function isNontrivialToken(x)
		if x == JSON_ENUM.comma then return false end
		if x == JSON_ENUM.colon then return false end
		for k, v in pairs(JSON_ENUM) do if x == v then return true end end return false
	end
	-- Generate intermediate form
	repeat
		local foundNumber 		= not not currentChar():match("[-%d]")
		local foundString 		= currentChar() == '"'
		local foundObject 		= currentChar() == '{'
		local foundObjectEnd 	= currentChar() == '}'
		local foundArray 		= currentChar() == '['
		local foundArrayEnd 	= currentChar() == ']'
		local foundComma 		= currentChar() == ','
		local foundColon 		= currentChar() == ':'
		if currentChar():match("%s") then
			if currentChar() == '\n' then
				line = line + 1
				lastRecordedChar = index
			end
			index = index + 1
			goto continue
		end

		for constType, constValue in pairs(CONSTANTS) do if s:match("^"..constType) then
			pushIndex()
			push(constValue)
			index = index + #constType
			goto continue
		end end

		if foundNumber then
			pushIndex()
			local sign = fromIndex():match("^%-?")
			index = index + #sign
			local int = fromIndex():match("^[1-9]%d*") or fromIndex():match("^(0)%D")
			xpcall(
				assert,
				jsonErr,
				int,
				("Line %i Char %i: Malformed Number. Context: %%k"):format(line,index-lastRecordedChar)
			)
			index = index + #int
			local fraction = fromIndex():match("^%.%d+") or ''
			index = index + #fraction
			local exponent = fromIndex():match("^[Ee][+-]?%d+") or ''
			index = index + #exponent
			local number =
				(sign == '-' and -1 or 1)
				* (tonumber(int .. fraction))
				* 10^(tonumber(exponent:sub(2)) or 0)
			push(number)
			goto continue
		end

		if foundString then
			pushIndex()
			local stringToAdd = ""
			repeat
				index = index + 1
				if currentChar() == '\\' then
					index = index + 1
					if currentChar() == '\n' then
						jsonErr("Malformed string. Context: %k")
					end
					if currentChar() == '"' then stringToAdd = stringToAdd .. '"' end
					if currentChar() == '/' then stringToAdd = stringToAdd .. '/' end
					if currentChar() == 'b' then stringToAdd = stringToAdd .. 'b' end
					if currentChar() == 'f' then stringToAdd = stringToAdd .. 'f' end
					if currentChar() == 'n' then stringToAdd = stringToAdd .. 'n' end
					if currentChar() == 'r' then stringToAdd = stringToAdd .. 'r' end
					if currentChar() == 't' then stringToAdd = stringToAdd .. 't' end
					if currentChar() == '\\' then stringToAdd = stringToAdd .. '\\' end
					if currentChar() == 'u' then
						index = index + 1
						local fourHex = fromIndex():match("^%x%x%x%x")
						xpcall(assert, jsonErr, fourHex, "Expected four hex characters, found %k...")
						---@diagnostic disable-next-line
						stringToAdd = stringToAdd .. utf8.char(tonumber(fourHex, 16))
						index = index + 4
						index = index - 1
					end
					index = index + 1
				elseif currentChar() == '"' then break
				else
					stringToAdd = stringToAdd .. currentChar()
				end
			until false
			push(stringToAdd)
			index = index + 1
			goto continue
		end

		if foundObject 		then pushIndex() push(JSON_ENUM.objInit	) index = index + 1 goto continue end
		if foundObjectEnd 	then pushIndex() push(JSON_ENUM.objExit	) index = index + 1 goto continue end
		if foundArray 		then pushIndex() push(JSON_ENUM.arrInit	) index = index + 1 goto continue end
		if foundArrayEnd 	then pushIndex() push(JSON_ENUM.arrExit	) index = index + 1 goto continue end
		if foundComma 		then pushIndex() push(JSON_ENUM.comma	) index = index + 1 goto continue end
		if foundColon 		then pushIndex() push(JSON_ENUM.colon	) index = index + 1 goto continue end

		jsonErr("Unknown symbol. Context: %k")

		::continue::
	until fromIndex() == ""

	local stackTop = 1
	local objectStack = {}
	local tokenIndex = 1
	---@type stack<"array" | "object">
	local modeStack = {}
	local arrayTop = 1
	local function pushToArray()
		local array = objectStack[stackTop-2]
		local toBePushed = objectStack[stackTop - 1]
		array[arrayTop] = toBePushed
		arrayTop = arrayTop + 1
		stackTop = stackTop - 1
	end
	local function pushToObject()
		local Object = objectStack[stackTop-4]
		local key = objectStack[stackTop-3]
		local value = objectStack[stackTop-1]
		Object[key] = value
		stackTop = stackTop - 3
	end
	while true do
		local current = intermediate[tokenIndex]
		local currentPos = intermediatePositions[tokenIndex]
		if current == nil then break end
		if not isNontrivialToken(current) then
			if not next(modeStack) and next(objectStack) then
				jsonErr(("Line %i Char %i: Expected <eof>, got %%k"):format(currentPos[1], currentPos[2]))
			end
			objectStack[stackTop] = current
			stackTop = stackTop + 1
		else
			if current == JSON_ENUM.arrInit then
				objectStack[stackTop] = {}
				stackTop = stackTop + 1
				table.insert(modeStack, "array")
				arrayTop = 1
			elseif current == JSON_ENUM.arrExit then
				pushToArray()
				table.remove(modeStack)
			elseif current == JSON_ENUM.objInit then
				objectStack[stackTop] = {}
				stackTop = stackTop + 1
				table.insert(modeStack, "object")
			elseif current == JSON_ENUM.objExit then
				pushToObject()
				table.remove(modeStack)
			elseif current == JSON_ENUM.null then
				stackTop = stackTop + 1
			end
		end
		if modeStack[#modeStack] == "array" then
			if objectStack[stackTop-1] == JSON_ENUM.comma then
				stackTop = stackTop - 1
				pushToArray()
			end
		elseif modeStack[#modeStack] == "object" then
			if objectStack[stackTop-1] == JSON_ENUM.comma then
				stackTop = stackTop - 1
				pushToObject()
			end
		end
		tokenIndex = tokenIndex + 1
		
		local cutStack = {}
		for i = 1, stackTop-1 do cutStack[i] = objectStack[i] end
	end
	return objectStack[1]
end

---Parses a json file from its path into an object.
---@param filePath string
---@return jsonType
function JSON.parsePath(filePath)
	local F = assert(io.open(filePath, "r"), "File not found!")
	local O = JSON.parse(F:read("*a"))
	F:close()
	return O
end

return JSON
