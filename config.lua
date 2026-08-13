local PRETTY = require "Pretty"
local BINSER = require "binser"

local CONFILE = assert(io.open("./data/config.bsr", "rb"))
---@class CONFIG
---@field PROGMODE programMode
CONFIG = BINSER.deserialize(CONFILE:read("*a"))
CONFIG.PROGMODE = CONFIG.PROGMODE or "GAME"

CONFILE:close()

function quitBinds.closeConfig()
	local serialKiller = BINSER.serialize(CONFIG)
	local CONFILE = assert(io.open("./data/config.bsr", "wb"))
	assert(CONFILE:write(serialKiller))
	CONFILE:flush()
	CONFILE:close()
	print("Updated config file.")
end