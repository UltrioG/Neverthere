local SMPL = {}

local function valueEncode(thing, encodeQueue, seenThings)
	if rawtype(thing) == "table" then
		if thing.__proto then
			if not seenThings[thing.__uuid] then table.insert(encodeQueue, thing) end
			return ("<%s>"):format(thing.__uuid)
		else
			local toReturn = "{"
			for k, v in pairs(thing) do
				toReturn = toReturn .. '\n' .. ("[%s] = %s"):format(
					(type(k) == "string" and '"%s"' or "%s"):format(tostring(k)),
					valueEncode(v, encodeQueue, seenThings)
				) .. ','
			end
			if toReturn:sub(-1, -1) ~= '{' then
				toReturn = toReturn:sub(1,-2):gsub("\n", "\n\t")
				toReturn = toReturn .. "\n}"
			else
				toReturn = toReturn .. '}'
			end
			return toReturn
		end
	end
	if type(thing) == "string" then
		return ('"%s"'):format(thing:sanitize())
	end
	return tostring(thing)
end

---Converts an entire Hierarch tree into a somewhat human-readable format
---@param hierarch Hierarch
---@return string
function SMPL.encode(hierarch)
	local output = ""
	---@type queue<Hierarch>
	local encodeQueue = {hierarch}
	local encodeIndex = 1
	---@type {[uuid]: any}
	local seenThings = {}
	repeat
		local current = encodeQueue[encodeIndex]
		seenThings[current.__uuid] = true
		-- print(("Encoding %s"):format(tostring(current)))
		output = output .. ("<%s> %s\n"):format(current.__uuid, current.__type)
		for k, v in pairs(current.__allUniqueProperties) do
			if k == "__uuid" then goto continue end
			local encoded = valueEncode(v, encodeQueue, seenThings):gsub('\n', "\n\t")
			output = output .. ("\t%s = %s\n"):format(k, encoded)
			::continue::
		end
		output = output .. '<eob>\n\n'
		encodeIndex = encodeIndex + 1
	until encodeQueue[encodeIndex] == nil
	return output
end

---Creates a thingy from a string
---@param thingy string
---@return Thingy
---@return boolean needFreeze Whether `thingy:freeze()` ought be called when all modifications are complete
local function createThing(thingy)
	if thingy == "UDim2" then
		local udim2 = UDim2.new()
		---@diagnostic disable-next-line
		udim2.__props.frozen = false	-- Shh... don't tell anyone I'm doing this :)
		return udim2, true
	else
		return Hierarch.new(thingy), false
	end
end

---Converts smpl to a list of Hierarch objects with the correct lineage.
---@param s string
---@return Hierarch root The Hierarch which is the ancestor of all other Hierarchs found
---@return Hierarch[]
function SMPL.decode(s)
	---@type {[uuid]: Thingy}
	local objects = {}
	---@type {[uuid]: {key: string?, value: string?}[]}
	local properties = {}
	for section in s:gmatch("<.-<eob>") do
		local uuid = section:match("<([%x-]+)>")
		local ty = section:match("<.-> (%w+)")
		---@type {key: string?, value: string?}[]
		local kvLines = {}
		local tableDepth = 0
		for line in section:gmatch("%s*.-\n") do
			if line:match("^<") then goto continue end
			local key, value =
				line:match((tableDepth > 0) and "^%s*(%[.-%])%s*=%s*(.-),?\n$" or "^%s*([%w_]+)%s*=%s*(.-)\n$")
			if value == '{' then tableDepth = tableDepth + 1 end
			if line:match('}') and not line:match('=') then
				tableDepth = tableDepth - 1
				table.insert(kvLines, {key=nil, value='}'})
			else
				table.insert(kvLines, {key=key, value=value})
			end
			::continue::
		end
		-- for _, v in pairs(kvLines) do print(v.key, v.value) end

		local object = createThing(ty)
		object.__uuid = uuid
		objects[uuid] = object
		properties[uuid] = kvLines
	end
	for uuid, O in pairs(objects) do
		local props = properties[uuid]

		---@type queue<table>
		local tableQueue = {O}
		---@type queue<string?>
		local keyQueue = {}
		for _, propKV in ipairs(props) do
			local k = propKV.key
			local v = propKV.value
			if v == '}' then
				local finishedTable = table.remove(tableQueue)
				table.last(tableQueue)[table.remove(keyQueue)] = finishedTable
			elseif v == '{' then
				table.insert(tableQueue, {})
				table.insert(keyQueue, k)
			else
				---@type any
				local k = k
				if k:match("%b[]") then
					k = k:sub(2,-2)
					print(k)
					if k:match("^<[%w-]+>$") then	-- Is UUID
						k = objects[k:match("^<([%w-]+)>$")]
					elseif k == "true" then			-- Is true
						k = true
					elseif k == "false" then		-- Is false
						k = false
					elseif tonumber(k) then			-- Is number
						k = tonumber(k)
					elseif k:match('%b""') then		-- Is string
						k = k:match('(%b"")'):sub(2, -2):unsanitize()
					else
						error("Unrecognized type")
					end
				end

				local v = v --[[@as string]]
				if v:match("^<[%w-]+>$") then	-- Is UUID
					table.last(tableQueue)[k] = objects[v:match("^<([%w-]+)>$")]
				elseif v == "true" then			-- Is true
					table.last(tableQueue)[k] = true
				elseif v == "false" then		-- Is false
					table.last(tableQueue)[k] = false
				elseif tonumber(v) then			-- Is number
					table.last(tableQueue)[k] = tonumber(v)
				elseif v:match('%b""') then		-- Is string
					print(v:sub(2,-2))
					table.last(tableQueue)[k] = v:sub(2,-2):unsanitize()
				elseif v == "{}" then			-- Is empty table
					table.last(tableQueue)[k] = {}
				else
					error("Unrecognized type")
				end
			end
		end
	end
	---@type Hierarch[]
	local toReturn = {}
	local hier = require "Hierarch"
	for _, v in pairs(objects) do
		-- for k, v in pairs(v.__protoChain) do print(v) end
		-- print(v, hier, v:isInstanceOf(hier))
		if not v:isInstanceOf(hier) then goto continue end
		table.insert(toReturn, v)
		::continue::
	end
	local top = toReturn[1]
	while top.Parent do top = top.Parent end
	return top, toReturn
end

return SMPL