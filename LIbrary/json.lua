local JSON = {}

---@class JSON_NULL
JSON.JSON_NULL = {}

---Parses a JSON string.
---@param s string
---@return any value The parsed value
---@return number length The length of the value string, incl. whitespace
---@return jsonType jsonType The type of the value returned
function JSON.parse(s)
	-- Simple values
	if s:match("^%s*true") then return true, 4 + #s:match("^%s*"), "true" end
	if s:match("^%s*false") then return false, 5 + #s:match("^%s*"), "false" end
	if s:match("^%s*null") then return JSON.JSON_NULL, 4 + #s:match("^%s*"), "null" end

	-- Numbers
	if s:match("^%s*%-?%d") then
		---@type string, string, string, string
		local WHITESPACE, SIGN, INT, FRAC, EXP = s:match("^(%s*)(%-?)(%d+)(%.?%d*)([eE]?[+-]?%d*)")
		SIGN = SIGN or ""
		INT = INT or ""
		FRAC = FRAC or ""
		EXP = EXP or ""
		if #INT > 1 and INT:first() == '0' then
			error("JSON Error: Numbers cannot start with 0 but be nonzero")
		end
		if FRAC:lower() == "." then FRAC = "" end -- Prevents numbers such as 0.
		if EXP:lower() == "e" then EXP = "" end -- Prevents numbers such as 123E
		local n = tonumber(SIGN .. INT .. FRAC .. EXP)
		return n, #SIGN + #INT + #FRAC + #EXP + #WHITESPACE, "number"
	end

	-- Strings
	if s:match('^%s*"') then
		local foundString = ""
		local index = s:find('"') + 1
		local isControlCharMode = false
		while true do
			local currentChar = s:sub(index, index)
			if isControlCharMode then goto controlChar end
			if currentChar == '\\' then
				isControlCharMode = true
				goto continue
			end
			if currentChar == '"' then break end
			foundString = foundString .. currentChar
			goto continue

			::controlChar::
			if currentChar == '"' then
				foundString = foundString .. '"'
			elseif currentChar == '\\' then
				foundString = foundString .. '\\'
			elseif currentChar == '/' then
				foundString = foundString .. '/'
			elseif currentChar == 'b' then
				foundString = foundString:sub(1, -2)
			elseif currentChar == 'f' then
				foundString = foundString .. '\f'
			elseif currentChar == 'n' then
				foundString = foundString .. '\n'
			elseif currentChar == 'r' then
				foundString = foundString .. '\r'
			elseif currentChar == 't' then
				foundString = foundString .. '\t'
			elseif currentChar == 'u' then
				goto unicode
			else
				warn((
					"JSON Warning: No escape sequence '\\%s' is recognized. Inserting just %s instead."
				):format(currentChar, currentChar))
			end
			goto continue

			::unicode::
			do
				local code = s:sub(index + 1, index + 4)
				if code:match("%X") then
					error((
						"JSON Error: Nonhexadecimal digit while decoding \\u.\nContext: '%s'"
					):format(s:sub(math.max(1, index - 16), math.min(#s, index + 16))))
				end
				--shut the fuck up please thank you
				---@diagnostic disable-next-line: undefined-field
				foundString = foundString .. utf8.char(tonumber(code, 16))
				index = index + 4
			end
			goto continue

			::continue::
			index = index + 1
		end
		return foundString, index, "string"
	end

	-- Arrays
	if s:match("^%s*%[") then
		local list = {}
		local index = s:find('%[') + 1
		while true do
			if s:match("%s*%]", index) then
				index = index + #s:match("%s*%]", index)
				break
			end
			if s:match("%s*,", index) then
				index = index + #s:match("%s*,", index)
				goto continue
			end
			local parsed, length = JSON.parse(s:sub(index))
			table.insert(list, parsed)
			index = index + length

			::continue::
		end
		return list, index, "array"
	end

	-- Objects
	if s:match("^%s*{") then
		local dict = {}
		local index = s:find('{') + 1
		local expectingString = true
		local strindex = ""
		local isFirstElement = true
		while true do
			if expectingString then
				if s:sub(index):match("^%s*}") then
					index = index + #s:sub(index):match("^%s*}")
					break
				end
				if not isFirstElement and not s:sub(index):match("^%s*,") then
					error((
						"JSON Error: Missing separator comma.\nContext '%s'."
					):format(s:sub(math.max(1, index - 16), math.min(#s, index + 16))))
				end
				local str, len, ty = JSON.parse(s:sub(index))
				if ty ~= "string" then
					error((
						"JSON Error: Didn't get string for the first half of an object.\nContext '%s'."
					):format(s:sub(math.max(1, index - 16), math.min(#s, index + 16))))
				end
				strindex = str
				index = index + len
				if not s:sub(index):match("^%s*:") then
					error((
						"JSON Error: No colon found for object.\nContext '%s'"
					):format(s:sub(math.max(1, index - 16), math.min(#s, index + 16))))
				end
				index = index + #s:sub(index):match("^%s*:")
				expectingString = false
			else
				local val, len = JSON.parse(s:sub(index))
				index = index + len
				dict[strindex] = val
				isFirstElement = false
				expectingString = true
			end
		end
		return dict, index, "object"
	end

	error((
		"JSON Error: Unrecognized symbols.\nContext '%s'"
	):format(s:sub(1, math.min(#s, 17))))
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
