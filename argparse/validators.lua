local Validator = {}
Validator.prototype = { opt = nil, param = nil }
Validator.instances = {}
local validators = Validator.instances

function Validator:new(opt, param)
	local new = { opt = opt, param = param }
	setmetatable(new, self)
	self.__index = self
	return new
end

function Validator:get(name)
	return self.instances[name]
end

function validators.req()
	local of = function(acc, k) return acc[k] == nil end
	local pf = function(params) return #params == 0 end
	return Validator:new(of, pf)
end

function validators.min(x)
	local of = function(acc, k) return acc[k] < x end
	local pf = function(params) return #params < x end
	return Validator:new(of, pf)
end

function validators.max(x)
	local of = function(acc, k) return acc[k] > x end
	local pf = function(params) return #params > x end
	return Validator:new(of, pf)
end

function validators.allowed(list)
	local of = function(acc, k) return nil == collections.findk(list, acc[k]) end
	local function pf(params)
		for _, p in ipairs(params) do
			if nil == collections.findk(list, p) then
				return true
			end
		end
		return false
	end

	return Validator:new(of, pf)
end

function validators.forbidden(list)
	local of = function(acc, k) return nil ~= collections.findk(list, acc[k]) end
	local function pf(params)
		for _, p in ipairs(params) do
			if nil ~= collections.findk(list, p) then
				return true
			end
		end
	end

	return Validator:new(of, pf)
end

return validators
