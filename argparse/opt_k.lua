local types = require 'lua.utils.types'
local collections = require 'lua.utils.collections'

local opt_k = {}

function opt_k.short(k)
	assert(types.is.str(k) and #k == 1)
	local key = '-' .. k

	local function inner(tok)
		local v = string.sub(tok, 3)
		if v == "" then
			v = nil
		end
		return string.sub(tok, 1, 2) == key, v
	end

	return inner
end

function opt_k.long(k)
	assert(types.is_str(k))
	local find = string.format('--(%s)=(.+)', k)

	local function inner(tok)
		local _, _, ok, ov = string.find(find)
		return ok ~= nil, ov
	end

	return inner
end

return opt_k
