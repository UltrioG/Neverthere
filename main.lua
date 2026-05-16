require "Library.Globals"

local GuiManager = require "GuiManager"
local XML = require "Library.xml"
local BASIC = require "basic"

function lovr.load()
	local guitestfile = io.open("./guitest.xml", "r")
	if not guitestfile then goto skip1 end
	local read = guitestfile:read("*a")
	local parsedXML = XML.parse(read)
	local bigTree = GuiManager.DOMToTree(parsedXML)
	::skip1::
end

function lovr.draw(pass)
	BASIC.plane(pass)

	GuiManager.Render2D(pass)

	return false
end

function lovr.log(message, level, tag)
	io.write(
		("[%s] [%s] %s%s\n")
		:format(getNowPrettier(), level:upper(), tag and ("[TAG %s] "):format(tag) or "", message)
	)
	io.flush()
end

local function logExit()
	log("Exiting.")



	log("Log finalized.")
	LOG:close()
	local timedLog, errmsg2 = io.open("./logs/" .. getNow() .. ".log", "w")
	if not timedLog then return false end
	LOG, errmsg = io.open("./logs/latest.log", "r")
	if not LOG then return false end
	timedLog:write(LOG:read("*a"))
	timedLog:close()
	LOG:close()
	return false
end

function lovr.quit()
	return logExit()
end

function lovr.errhand(message)
	local function formatTraceback(s)
		return s:gsub('\n[^\n]+$', ''):gsub('\t', ''):gsub('stack traceback:', '\nStack:\n')
	end

	message = 'Error:\n\n' .. tostring(message) .. formatTraceback(debug.traceback('', 4))

	err(message)

	if not lovr.graphics or not lovr.graphics.isInitialized() then
		return function() return 1 end
	end

	if lovr.audio then lovr.audio.stop() end

	if not lovr.headset or lovr.headset.getPassthrough() == 'opaque' then
		lovr.graphics.setBackgroundColor(.11, .10, .14)
	else
		lovr.graphics.setBackgroundColor(0, 0, 0, 0)
	end

	local font = lovr.graphics.getDefaultFont()

	return function()
		logExit()
		lovr.system.pollEvents()

		for name, a in lovr.event.poll() do
			if name == 'quit' then
				return a or 1
			elseif name == 'restart' then
				return 'restart', lovr.restart and lovr.restart()
			elseif name == 'keypressed' and a == 'f5' then
				lovr.event.restart()
			elseif name == 'keypressed' and a == 'escape' then
				lovr.event.quit()
			end
		end

		if lovr.headset and lovr.headset.getDriver() ~= 'simulator' then
			lovr.headset.update()
			local pass = lovr.headset.getPass()
			if pass then
				font:setPixelDensity()

				local scale = .35
				local font = lovr.graphics.getDefaultFont()
				local wrap = .7 * font:getPixelDensity()
				local lines = font:getLines(message, wrap)
				local width = math.min(font:getWidth(message), wrap) * scale
				local height = .8 + #lines * font:getHeight() * scale
				local x = -width / 2
				local y = math.min(height / 2, 10)
				local z = -10

				pass:setColor(.95, .95, .95)
				pass:text(message, x, y, z, scale, 0, 0, 0, 0, wrap, 'left', 'top')

				lovr.graphics.submit(pass)
				lovr.headset.submit()
			end
		end

		if lovr.system.isWindowOpen() then
			local pass = lovr.graphics.getWindowPass()
			if pass then
				local w, h = lovr.system.getWindowDimensions()
				pass:setProjection(1, lovr.math.mat4():orthographic(0, w, 0, h, -1, 1))
				font:setPixelDensity(1)

				local scale = .6
				local wrap = w * .8 / scale
				local width = math.min(font:getWidth(message), wrap) * scale
				local x = w / 2 - width / 2

				pass:setColor(.95, .95, .95)
				pass:text(message, x, h / 2, 0, scale, 0, 0, 0, 0, wrap, 'left', 'middle')

				lovr.graphics.submit(pass)
				lovr.graphics.present()
			end
		end

		lovr.math.drain()
	end
end
