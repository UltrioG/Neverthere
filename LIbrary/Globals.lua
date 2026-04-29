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

---Checks whether two lists are equal.<br>
---It is a shallow check meaning internal tables are equal iff they are the same table in memory.
---@generic T
---@param T1 [T]
---@param T2 [T]
---@return boolean
function listEqual(T1, T2)
	if #T1 ~= #T2 then return false end
	for i, v in ipairs(T1) do if v ~= T2[i] then return false end end
	return true
end

---Custom implementation which works with logging.<br>
---Graciously stolen and adapted from https://stackoverflow.com/a/7153689
---@param ... any
function log(...)
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

	io.write(
		("[%s] [%s] [TAG %s] %s\n")
		:format(getNowPrettier(), "INFO", "user", S)
	)
	io.flush()
end

---Custom implementation which works with logging.<br>
---Graciously stolen and adapted from https://stackoverflow.com/a/7153689
---@param ... any
function err(...)
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

	io.write(
		("[%s] [%s] [TAG %s] %s\n")
		:format(getNowPrettier(), "ERROR", "user", S)
	)
	io.flush()
end

LOG, errmsg = io.open("./logs/latest.log", "w")
if not LOG then error("Cannot create log file with error "..tostring(errmsg)) end
io.output(LOG)
log("Log initialized.")
io.flush()