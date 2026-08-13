local PRETTY = require "Pretty"
local JSON = require "dkjson"

local CONFILE = assert(io.open("./data/config.json", "r"))
---@class CONFIG
---@field PROGMODE programMode
CONFIG = JSON.decode(CONFILE:read("*a")) or {}
CONFIG.PROGMODE = CONFIG.PROGMODE or "GAME"
CONFILE:close()

function quitBinds.closeConfig()
	local serialKiller = JSON.encode(CONFIG)--[[@as string]]
	local CONFILE = assert(io.open("./data/config.json", "w"))
	assert(CONFILE:write(serialKiller))
	CONFILE:close()
	print("Updated config file.")
end