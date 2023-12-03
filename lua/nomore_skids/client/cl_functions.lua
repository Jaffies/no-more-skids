local module = NMS.Module()

-- Get functions

function module:GetOriginalLocalVars(func)
	local locals = {}

	local name, val
	local k = 1
	while true do
		name, val = debug.getlocal(func, k)
		k = k + 1
		if not name then break end

		local valName = locals[name] and name.." (" .. tostring(k) .. ")" or name

		locals[valName] = val or "nil"
	end

	return locals
end

function module:GetOriginalGetInfo(func)
	return debug.getinfo(func)
end

function module:GetOriginalJITGetInfo(func)
	return jit.util.funcinfo(func)
end

function module:GetOriginalJITUVNames(func)
	local orig = self:GetFunction(func)

	local upvalueNames = {}
	if debug.getinfo(orig).what == "C" then return upvalueNames end

	local i = 0
	while true do
		local uvName = jit.util.funcuvname(orig, i)
		if uvName == nil then break end
		i = i+1
		upvalueNames[i] = uvName
	end

	return upvalueNames
end

return module