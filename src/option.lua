local lua_utils = require 'utils'
local utils = lua_utils.misc 
local types = lua_utils.types
local collections = lua_utils.collections 

local Option = { k = nil, opt_k = {}, opt_v = nil, validators = {}, default = nil }

function Option:new(name, k, v, val, default)
	local new = {
		k = name,
		opt_k = k,
		opt_v = v(name),
		validators = val or {},
		default = default
	}
	setmetatable(new, self)
	self.__index = self
	return new
end

function Option:add_validator(v)
	self.validators[#self.validators + 1] = v
	return self
end

function Option:add_key(k)
	self.opt_k[#self.opt_k] = k
end

function Option:match(input, acc)
	local match = false
	local v = nil
	local i = 0

	if types.is.tbl(self.opt_k) then
		local len = #self.opt_k
		while not match and i < len do
			match, v = self.opt_k[i + 1](input[#input])
			i = i + 1
		end
		input[#input] = nil
	else
		match = true
	end

	if not match then
		return false
	end

	if self.opt_v == nil and v ~= nil then
		return nil
	elseif self.opt_v == nil then
		return true
	else
		return self.opt_v(acc, v, input)
	end
end

function Option:validate(acc)
	local f = function(v) local a = v.opt(acc, self.k); return a end
	local x = collections.ifind(self.validators, f)
	return x ~= nil
end

function Option:init(acc)
	acc[self.k] = utils.cpy(self.default)
	return self
end

return Option
