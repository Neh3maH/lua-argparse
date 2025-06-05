local collections = require 'utils/collections'
local parser = require 'argparse/cmd_parser'

local module = { subcmds = {}, _parser = nil}

function module:new(subcmds, parser)
	local new = { subcmds = subcmds or {}, _parser = parser }
	setmetatable(new, self)
	self.__index = self
	return new
end

function module:add(path, parser)
	local cur = self

	while path and path ~= nil and cur do
		local sep = string.find(path, '.')
		local name = string.sub(1, sep or #path)
		path = sep and string.sub(sep + 1, #path)

		if cur.subcmds[name] then
			cur = cur.subcmds[name]
		else
			local new = self:new()
			cur.subcmds[name] = new
			cur = new
		end
	end
	cur._parser = parser
	return self
end

function module:parse(input)
	input = collections.rev(input)
	local path = nil
	local cur = self

	while #input ~= 0 and string.sub(input[#input], 1, 1) ~= '-'
		and cur.subcmds ~= nil and #cur.subcmds ~= 0 do
		cur = cur.subcmds[input[#input]]
		if cur then
			path = (path or "") .. "." .. cur
		end
	end

	if cur == nil or cur._parser == nil then
		input = collections.rev(input)
		return nil
	end

	local ret = cur._parser:parse(input)
	if ret then
		ret.cmd = path
	end

	return ret
end

return module
