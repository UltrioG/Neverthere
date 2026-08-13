---@meta

local uuid = require("uuid")
uuid.set_rng(
	function (n)
		local toReturn = ""
		for _ = 1, n do
			toReturn = toReturn .. string.char(math.floor(lovr.math.random(0, 255)))
		end
		return toReturn
	end
)

do -- Math lib changes
	---Rounds a number.
	---@param x number
	---@return integer
	math.round = function(x)
		return math.floor(x) + math.floor(2 * (x % 1))
	end

	---Linear Interpolation
	---@generic T: numeric
	---@param a T
	---@param b T
	---@param t number
	---@return T
	math.lerp = function(a, b, t)
		return (b - a) * t + a
	end
end

do -- String lib changes
	---Gets the first character in a string
	---@param s string
	---@return string
	string.first = function(s)
		return s:sub(1, 1)
	end
	string.head = string.first

	---Gets everything except the first character in a string
	---@param s string
	---@return string
	string.rest = function (s)
		return s:sub(2)
	end
	string.tail = string.rest

	---Converts the first character of a string to uppercase.
	---@param s string
	---@return string
	string.upperfirst = function(s)
		return s:first():upper() .. s:rest()
	end

	local TO_SANITIZE = {
		["\a"] = "\\a",
		["\b"] = "\\b",
		["\f"] = "\\f",
		["\n"] = "\\n",
		["\r"] = "\\r",
		["\t"] = "\\t",
		["\v"] = "\\v",
		["\\"] = "\\\\",
		["\'"] = "\\'",
		["\""] = '\\"'
	}
	---Sanitizes a string so that it'd be equivalent to what one would type in source code.
	---@param s string
	---@return string
	string.sanitize = function (s)
		local out = s
		for k, v in pairs(TO_SANITIZE) do
			out = out:gsub(k, v)
		end
		return out
	end
	string.sanitise = string.sanitize


	---Unsanitizes a string.
	---@see string.sanitize
	---@param s string
	---@return string
	string.unsanitize = function (s)
		local out = s
		for k, v in pairs(TO_SANITIZE) do
			out = out:gsub(v, k)
		end
		return out
	end
	string.unsanitise = string.unsanitize
end

do -- Table lib changes
	---Creates a monad from a table.<br>
	---A monad is a monoid in the category of endofunctors.
	---@generic T: table
	---@param T T
	---@return monad<T, tablelib> Monad A monoid in the category of endofunctors
	table.toMonad = function (T)
		return setmetatable({
			__interior = T
		}, {
			__index = function (T, k)
				if T.__interior[k] then return T.__interior[k] end
				if table[k] then
					return function (...)
						local new = table[k](...)
						return table.toMonad(new)
					end
				end
			end,
			__newindex = T
		})
	end

	---Shallow clones a table
	---@generic T: table
	---@param T T
	---@return T
	table.clone = function (T)
		local new = {}
		for k,v in pairs(T) do new[k] = v end
		return new
	end

	---Creates a new table which is the union of all the given tables.
	---Does not preserve order. For that,
	---@see table.join
	---@param ... table
	---@return table
	table.union = function (...)
		local new = {}
		for i = 1, select("#", ...) do
			for k, v in pairs(select(i, ...)) do new[k] = v end
		end
		return new
	end

	---Joins the given lists.
	---For tables which are not lists,
	---@see table.union
	---@param ... any[]
	---@return table
	table.join = function (...)
		local new = {}
		for i = 1, select("#", ...) do
			for _, v in ipairs(select(i, ...)) do table.insert(new, v) end
		end
		return new
	end

	---Reverses a list.
	---@param T any[]
	---@return table
	table.reverse = function (T)
		local new = {}
		for i = #T, 1, -1 do new[#T-i+1] = T[i] end
		return new
	end

	---Converts a list to a Set.
	---@generic T
	---@param T T[]
	---@return Set<T>
	table.toSet = function (T)
		local set = {}
		for _, thing in ipairs(T) do
			set[thing] = true
		end
		return set
	end

	---Returns a new table with keys and values swapped
	---@generic K
	---@generic V
	---@param T {[K]: V}
	---@return {[V]: K}
	table.swapKV = function (T)
		local new = {}
		for k, v in pairs(T) do new[v] = k end
		return new
	end

	---Get the last element of a list.
	---@generic T
	---@param T T[]
	---@return T
	table.last = function (T)
		return T[#T]
	end

	---Runs a function for each element of the table, creating a new one in the process.
	---@generic K, V
	---@param T {[K]: V}
	---@param transformation fun(key: K, value: V): K, V
	table.map = function (T, transformation)
		local new = {}
		for k, v in pairs(T) do
			local mk, mv = transformation(k, v)
			new[mk] = mv
		end
		return new
	end

	---Get the keys of a table as a list
	---@generic K
	---@param T {[K]: any}
	---@return K[]
	table.keys = function (T)
		local new = {}
		for k in pairs(T) do table.insert(new, k) end
		return new
	end

	---Finds an element in a table
	---@param haystack table
	---@param needle any
	---@return any? Index
	table.find = function (haystack, needle)
		for k, v in pairs(haystack) do if v == needle then return k end end
	end
end

do -- Uncategorized Changes
	---Get a string indicating the current time.
	---@return string
	function getNow()
		return os.date("%Y%m%dT%H%M%S") --[[@as string]]
	end

	---Get a string indicating the current time, but prettier.
	---@return string
	function getNowPrettier()
		return os.date("%Y-%m-%d %H:%M:%S") --[[@as string]]
	end

	---Turns a series of arguments into a format for logging.
	---Graciously stolen and adapted from https://stackoverflow.com/a/7153689
	---@param severity severityLevel How severe this log mesage is
	---@param tag "User" | string The origin of the message
	---@param ... any The content of the message
	---@return string
	function formatForLog(severity, tag, ...)
		local S = ""
		local write = function(s)
			S = S .. s
		end

		local n = select("#", ...)
		for i = 1, n do
			local v = tostring(select(i, ...))
			write(v)
			if i ~= n then write '\t' end
		end

		return ("[%s] [%s] [TAG %s] %s\n")
			:format(getNowPrettier(), severity:upper(), tag, S)
	end

	---Writes a message to the log.
	---It is preferred to use `print` as it has been replaced to write to both console and log.
	---@param ... any
	function log(...)
		if not LOG then return end

		local result = formatForLog("info", "User", ...)
		
		LOG:write(result)
		LOG:flush()
	end

	local cprint = print
	---Custom implementation which works with logging.<br>
	---Prints with the usual `print` function and also writes it to the log.
	---@param ... any
	function print(...)
		log(...)
		cprint(...)
	end

	---Writes an error to the log.
	---Does not trigger program shutdown, but is used when program shuts down.
	---@param ... any
	function errLog(...)
		local result = formatForLog("error", "User", ...)

		LOG:write(result)
		LOG:flush()
	end

	---Prints with a warning tag.
	---@param ... any
	function warn(...)
		cprint("WARNING:", ...)
		if not LOG then return end
		local result = formatForLog("warn", "User", ...)

		LOG:write(result)
		LOG:flush()
	end

	---Function which does nothing.
	function void()
		
	end

	-- Fix weird bug with pairs not respecting metamethods
	rawpairs = pairs
	function pairs(T)
		local meta = getmetatable(T)
		if meta and meta.__pairs then
			return meta.__pairs(T)
		end
		return rawpairs(T)
	end

	rawtype = type
	function type(T)
		if rawtype(T) == "table" and T.__type ~= nil then
			return T.__type
		else
			return rawtype(T)
		end
	end
end

do	-- Globalization
	local protoudim2 = require("UDim2")
	UDim2 = {}
	function UDim2.new(xScale, xOffset, yScale, yOffset)
		local new = protoudim2:clone()
		new.xScale = xScale
		new.xOffset = xOffset
		new.yScale = yScale
		new.yOffset = yOffset
		new:freeze()
		return new
	end

	Hierarch = require "HierarchConstructor"
end

LOG, errmsg = io.open("./logs/latest.log", "w")
if not LOG then
	error("Cannot create log file with error " .. tostring(errmsg))
else
	print("Log initialized.")
end
