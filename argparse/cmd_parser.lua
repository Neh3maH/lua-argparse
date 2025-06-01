local utils = require 'lua.utils.misc'
local collections = require 'lua.utils.collections'

local CmdParser = { options = {}, default_acc = {}, validators = {} }

function CmdParser:new(optl, acc, val)
	local new = { options = optl, default_acc = acc, validators = val or {} }
	setmetatable(new, self)
	self.__index = self
	return new
end

function CmdParser:add(opt)
	local k = #(self.options) + 1
	self.options[k] = opt
	return self, k
end

function CmdParser:add_validator(v)
	self.validators[#self.validators + 1] = v
end

function CmdParser:get(k)
	return self.options[k]
end

function CmdParser:remove(k)
	local opt = self.options[k]
	self.options[k] = nil
	return self, opt
end

local function parse_opts(options, input, acc)
	if #options == 0 then
		if input[1] == '--' then
			collections.pop(input)
		end
		input = collections.rev(input)
		return input
	end

	while #input ~= 0 and string.sub(input[#input], 1, 1) == '-' do
		if input[#input] == '--' then
			input[#input] = nil
			return collections.rev(input)
		end

		for _, opt in pairs(options) do
			local match = opt:match(input, acc)

			if true == match then
				return collections.rev(input)
			elseif nil == match then
				return nil
			end
		end
	end
	return collections.rev(input)
end

local function init_acc(default, options)
	local acc = utils.cpy(default)

	for _, opt in pairs(options) do
		opt:init(acc)
	end

	return acc
end

function CmdParser:parse(input)
	local acc = init_acc(self.default_acc, self.options)
	local params = parse_opts(self.options, input, acc)

	local f = function(v) return v.param(params) end
	if nil == params
		or collections.ifind(self.validators, f) then
		print("AAAAAAAAAAAAAA")
		return nil
	end

	for _, opt in pairs(self.options) do
		if opt:validate(acc) then
			print("BBBBBBBBBB")
			return nil
		end
	end

	return { options = acc, params = params }
end

return CmdParser
