local lua_utils = require 'utils'
local utils = lua_utils.misc 
local types = lua_utils.types
local collections = lua_utils.collections 

local opt_k = {}

-- TODO: handle -vvvvvv
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
	assert(types.is.str(k))
	local raw = '--' .. k
	local pattern = string.format('^--(%s)=(.+)$', k)

	local function inner(tok)
		local ok, ov, lol = string.match(tok, pattern)
		if ok == nil and tok == raw then
			ok = k
		end
		if ov == "" then
			ov = nil
		end
		return ok ~= nil, ov
	end

	return inner
end

return opt_k
