local lua_utils = require 'utils'
local utils = lua_utils.misc
local collections = lua_utils.collections

local CmdParser = { options = {}, pos_params = {}, default_acc = {}, validators = {} }

function CmdParser:new(optl, pos_params, acc, val)
	local new = { options = optl, pos_params = pos_params, default_acc = acc, validators = val or {} }
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

local function match_opts(options, input, acc)
	for _, opt in pairs(options) do
		local match = opt:match(input, acc)

		if true == match then
			return true
		end
	end
	return false
end

local function parse_opts(options, input, acc)
	if #options == 0 then
		if input[#input] == '--' then
			collections.pop(input)
		end
		return true
	end

	while #input ~= 0 and string.sub(input[#input], 1, 1) == '-' do
		if input[#input] == '--' then
			input[#input] = nil
			return true
		end

		if not match_opts(options, input, acc) then
			return false
		end
	end
	return true
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
	
	if not parse_opts(self.options, input, acc) then
		return nil
	end

	if not parse_opts(self.pos_params, input, acc) then
		return nil
	end

	local params = collections.rev(input)
	local f = function(v) return v.param(params) end
	if nil == params
		or collections.ifind(self.validators, f) then
		return nil
	end

	for _, opt in pairs(self.options) do
		if opt:validate(acc) then
			return nil
		end
	end

	return { options = acc, params = params }
end

return CmdParser
