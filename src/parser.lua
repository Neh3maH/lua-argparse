local parser = require 'cmd_parser'

local module = { subcmds = {}, _parser = nil}

function module:new(subcmds)
	local new = { subcmds = subcmds or {} }
	setmetatable(new, self)
	self.__index = self
end

function module:add(path, parser)
	local cur = self.subcmds

	while path do
		local sep = string.find(path, '.')
		local name = string.sub(1, sep or #path)
		path = sep and string.sub(sep + 1, #path)

		if cur[name] then
			cur = cur[name]
		else
			local new = self:new()
			cur[name] = new
			cur = new
		end
	end
	cur._parser = parser
end

function module:parse(input)
	input = collections.rev(input)
	local path = nil
	local cur = self

	while #input ~= 0 and not string.starts(input[#input], '-')
		and cur ~= nil and #cur.subcmds ~= 0 do
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
