local opt_v = {}

local function once(k, setter)
	local function inner(acc, tok)
		if acc[k] ~= nil then
			return true
		end
		local v = setter(tok)
		acc[k] = v
		return v == nil
	end
	return inner
end

function opt_v.once(setter)
	return function(k) return once(k, setter) end
end

local function flag(k, set)
	local f = function() return set end
	return opt_v.once(k, f)
end

function opt_v.flag(set)
	return function(k) return flag(k, set) end
end

function opt_v.str(k)
	local function inner(tok, input)
		tok = tok or collections.pop(input)
		if tok == nil then
			return nil
		end
		return tostring(tok)
	end
	return opt_v.once(k, inner)
end

function opt_v.int(k)
	local f = function(tok) return tonumber(tok) end
	return opt_v.once(k, f)
end

function opt_v.count(k)
	local function inner(acc, tok)
		if tok ~= nil then
			return nil
		end

		acc[k] = (acc[k] or 0) + 1

		return true
	end
	return inner
end

function opt_v.add(k)
	local function inner(acc, tok, input)
		tok = tonumber(tok or collections.pop(input))
		if tok then
			acc[k] = (acc[k] or 0) + tok
			return true
		end

		return nil
	end
	return inner
end

function opt_v.lst(k)
	local function inner(acc, tok, input)
		local lst = acc[k] or {}
		tok = tok or collections.pop(input)
		if tok == nil then
			return nil
		end
		lst[#lst] = tok
		return true
	end
end

return opt_v
