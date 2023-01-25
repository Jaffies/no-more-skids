local module = NMS.Module()

module.DetouredFunctions = setmetatable({}, {__mode = "k"})
module.DetouredFunctionsToOriginal = setmetatable({}, {__mode = "kv"})

local debug_traceback = debug.traceback
local debug_getinfo = debug.getinfo
local debug_sethook = debug.sethook

function module:Detour(func)
	local t = {}
	self.DetouredFunctions[func] = t

	local detourFunc = function(...)
		local traceback = debug_traceback(2)
		t.tracebacks = (t.tracebacks or -1) + 1

		t.traceback = t.traceback or {}
		t.traceback[t.tracebacks%self:GetConfig("TracebackNum")+1] = traceback:Trim("\n")

		local info = debug_getinfo(2)

		t.calls = (t.calls or -1) + 1
		t.call = t.call or {}
		t.call[t.calls%self:GetConfig("CallNum")+1] = info and (info.short_src or info.source) or "Engine"

		local lines = {}
		local i = 0

		debug_sethook(function(str, line)
			lines[line] = debug_getinfo(2)
		end, "l")
		local a, b, c, d, d, e = func(...)

		debug_sethook()
		t.lines = lines

		return a, b, c, d, e
	end

	self.DetouredFunctionsToOriginal[detourFunc] = func

	return detourFunc
end

function module:DetourTableFunction(tab, key)
	local func = tab[key]

	tab[key] = self:Detour(func)
end

-- Get functions

function module:GetFunction(func)
	return self.DetouredFunctionsToOriginal[func] or func
end

function module:GetFunctionTable(func)
	return self.DetouredFunctions[self:GetFunction(func)]
end

function module:GetOriginalCalls(func)
	local t = self:GetFunctionTable(func)

	return t and t.call
end

function module:GetOriginalTracebacks(func)
	local t = self:GetFunctionTable(func)

	return t and t.traceback
end

function module:GetOriginalLines(func)
	local t = self:GetFunctionTable(func)

	return t and t.lines
end

function module:GetOriginalMetaTable(func)
	local orig = self:GetFunction(func)

	return debug.getmetatable(orig or func)
end

function module:GetOriginalFENV(func)
	local orig = self:GetFunction(func)

	return debug.getfenv(orig or func)
end

function module:GetOriginalUpvalues(func)
	local orig = self:GetFunction(func)

	local info = debug.getinfo(orig)
	local upvalues = {}

	for i=1, (info.nups or 1) do
		local key, value = debug.getupvalue(func, i)

		if not key then break end
		upvalues[key] = value
	end

	return upvalues
end

function module:GetOriginalLocalVars(func)
	local orig = self:GetFunction(func)

	local locals = {}

	local name, val
	local k = 1
	while true do
		name, val = debug.getlocal(orig, k)
		k = k + 1
		if not name then break end

		local valName = locals[name] and name.." (" .. tostring(k) .. ")" or name

		locals[valName] = val or "nil"
	end

	return locals
end

function module:GetOriginalGetInfo(func)
	return debug.getinfo(self:GetFunction(func))
end

function module:GetOriginalJITGetInfo(func)
	return jit.util.funcinfo(self:GetFunction(func))
end

function module:GetOriginalJITByteCodes(func)
	local orig = self:GetFunction(func)
	
	local bytecodes = {}
	if debug.getinfo(orig).what == "C" then return bytecodes end

	local i = 0
	while true do
		local instruction, opcode = jit.util.funcbc(orig, i)
		if not instruction then break end
		i = i+1
		bytecodes[i] = {instruction, opcode}
	end

	return bytecodes
end

function module:GetOriginalJITConsts(func)
	local orig = self:GetFunction(func)
	
	local consts = {}
	if debug.getinfo(orig).what == "C" then return consts end

	local i = -1
	while true do
		local const = jit.util.funck(orig, i)
		if const == nil then break end
		consts[-i] = const
		i = i-1
	end

	return consts
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