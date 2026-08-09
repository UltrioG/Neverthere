---@meta

do	-- Math lib changes
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
end

do	-- String lib changes
	---Gets the first character in a string
	---@param s string
	---@return string
	string.first = function (s)
		return s:sub(1,1)
	end
end

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
	local write = function (s)
		S = S .. s
	end

	local n = select("#",...)
    for i = 1,n do
        local v = tostring(select(i,...))
        write(v)
        if i~=n then write'\t' end
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

LOG, errmsg = io.open("./logs/latest.log", "w")
if not LOG then error("Cannot create log file with error "..tostring(errmsg)) else
	print("Log initialized.")
end