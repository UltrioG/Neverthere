local XML = {}

---@class DOM A table representing an XML element.
---@field tag string The tag of the XML element.
---@field attributes {[string]: string} A dictionary of the attributes of the XML element.
---@field innerXML [string | DOM] The stuff inside the XML element.
---@field parent DOM?
local DOM = {}

---Creates a new DOM object.
---@param tag string
---@return DOM
local function newDom(tag, attributes)
	local newDom = setmetatable({
		tag = tag,
		attributes = attributes,
		innerXML = {}
	}, {
		__index = DOM,
		__tostring = function (T)
			local T = T --[[@as DOM]]

			local s = ("<%s"):format(tag)
			for k, v in pairs(T.attributes) do
			  s = s .. (("\n\t%s = %s"):format(k, v))
			end
			s = s .. (next(T.attributes) and "\n" or "") .. ">"
			for _, v in ipairs(T.innerXML) do
			  s = s .. (("\n\t%s"):format(tostring(v):gsub("\n", "\n\t")))
			end
			s = s .. (#T.innerXML == 0 and "" or "\n") .. (("</%s>"):format(T.tag))

			return s
		end
	})
	return newDom
end

---Turns an XML string into a DOM object.
---@param xml string
---@return DOM
function XML.parse(xml)
	---@type DOM
	local root

	---@type [DOM]
	local stack = {}
	local line = 1
	local marcher = 1

	local function xmlErr(msg)
		error(("At line %i: %s"):format(line, msg))
	end

	--#region preprocessing
	--#region removeComments
	xml = xml:gsub("<!%-%-.-%-%->", "")
	--#endregion removeComments

	--#region removeProlog
	xml = xml:gsub("<%?%s*xml.-%?>", "")
	--#endregion removeProlog
	--#endregion preprocessing

	--#region parseXML
	local iterations = 0

	while true do
		local top = stack[#stack]
		local matched = xml:match("^%s*%b<>", marcher)
		local cleanMatched = matched and matched:gsub("^%s*", ""):gsub("%s*$", "") or nil
		local foundTag = not not cleanMatched
		if foundTag then
			local cleanMatched = cleanMatched --[[@as string]]
			local isAutoclosing = not not cleanMatched:match("/%s*>$")
			local isClosing = not not cleanMatched:match("^<%s*/")
			local tag = cleanMatched:match("^<%s*/?([_%a][%w-_.]*)")
			if tag:sub(1, 3):lower() == "xml" then
				xmlErr("Tag name cannot start with xml.")
			end
			if not isClosing then
				local attributes = {}
				for attr, val in cleanMatched:gmatch("(%w+)%s*=%s*([^%s>]+)") do
					attributes[attr] = val:gsub('^"([^"]*)"$', "%1"):gsub("^'([^']*)'$", "%1")
				end
				local newdom = newDom(tag, attributes)
				if top then
					newdom.parent = top
					table.insert(newdom.parent.innerXML, newdom)
				end
				if not isAutoclosing then table.insert(stack, newdom) end
				if not root then root = newdom end
			else
				if tag ~= top.tag then xmlErr(("Out of order tag '%s', expected '%s'."):format(tag, top.tag)) end
				table.remove(stack)
			end
			marcher = marcher + #matched
		elseif not matched then
			local innerXML = xml:match("[^<]+", marcher)
			if #stack == 0 and not root then xmlErr("XML cannot start with string.") end
			if #stack == 0 then break end
			table.insert(top.innerXML, innerXML)
			marcher = marcher + #innerXML
		end
		iterations = iterations + 1
	end

	--#endregion parseXML

	return root
end

---Encodes a DOM object, along with all its children, into a string.
---Basically `tostring(dom)` with a few extra elements.
---@param dom DOM
---@return string
function XML.encode(dom)
	return '<?xml version="1.0" encoding="UTF-8"?>\n'..tostring(dom)
end

return XML
