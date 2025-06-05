local types = require 'utils/types'
local collections = require 'utils/collections'
local opt_v = {}

local function _once(setter)
	local function inner(k)
		return function(acc, tok, input)
			local v = setter(tok)
			if (not types.is.ref(v) and acc[k] == v) or acc[k] ~= nil or v == nil then
				return nil
			end
			acc[k] = v
			return true
		end
	end
	return inner
end

function opt_v.once(setter)
	return _once(k, setter)
end

local function flag(set)
	local f = function() return set end
	return _once(f)
end

function opt_v.flag(set)
	if nil == set then
		set = true
	end
	return flag(set)
end

function opt_v.str(k)
	local function inner(tok, input)
		tok = tok or collections.pop(input)
		if tok == nil then
			return nil
		end
		return tostring(tok)
	end
	return _once(inner)
end

function opt_v.int(k)
	local f = function(tok)
		tok = tok or collections.pop(input) or nil
		return tok or tonumber(tok)
	end
	return _once(f)
end

function opt_v.fold(merge, conv, zero)
	local function inner(k)
		return function(acc, tok, input)
			tok = conv(tok, input)
			if tok == nil then
				return nil
			end

			local l = acc[k]
			if l == nil then
				l = zero()
			end

			acc[k] = merge(l, tok)
			return acc[k] ~= nil or nil
		end
	end
	return inner
end

function opt_v.count(k)
	return opt_v.fold(
		function(l, r) return l + r end,
		function(tok)
			if tok ~= nil then
				return nil
			end
			return 1
		end,
		function() return 0 end
	)
end

function opt_v.add(k)
	return opt_v.fold(
		function(l, r) return l + r end,
		function(tok, input)
			return tonumber(tok or collections.pop(input))
		end,
		function() return 0 end
	)
end

function opt_v.lst(k)
	return opt_v.fold(
		function(l, r)
			l[#l + 1] = r
			return l
		end,
		function(tok, input) return tok or collections.pop(input) end,
		function() return {} end
	)
end

return opt_v
