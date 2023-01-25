local module = NMS.Module()

--[[ 
	When ply loads, ply needs to expose his hooks and cmd's after 40 seconds after sending his first net message.
--]]

local encrypt = module:Require("sh_encrypt", "Shared")
local sv_network = SERVER and module:Require("sv_network", "Server")
local functions = CLIENT and module:Require("cl_functions", "Client")

module:Net("NMS.ExposeHooks", function(len, ply)
	local time = CurTime()

	if CLIENT then
		local t = {}
		local i = 0

		for name, tab in pairs(hook.GetTable()) do
			for k, v in pairs(tab) do
				if isstring(k) then
					i = i + 1
					t[i] = name .. "->" .. k
				end
			end
		end

 		net.Start("NMS.ExposeHooks")
		net.WriteUInt(encrypt:Number(i, 16), 16)

		for i = 1, i do
			net.WriteString(encrypt:Encrypt(t[i]) )
		end

		net.SendToServer()
	else
		if ply.ExposeHookTime and ply.ExposeHookTime > time or not isnumber(ply.Exposion) then return end

		ply.ExposeHookTime = time + module:GetConfig("Cooldown")
		local count = encrypt:Number(net.ReadUInt(16), 16) -- How many hooks are there;
		local t = {}

		for i = 1, count do
			t[i] = encrypt:Decrypt(net.ReadString()) -- string: %hook_name%.%func_name%
		end

		ply.ExposedHooks = t
	end
end)

module:Net("NMS.ExposeCommands", function(len, ply)
	local time = CurTime()
	if CLIENT then
		local t = {}
		local i = 0

		for k, v in pairs(concommand.GetTable()) do
			i = i + 1
			t[i] = k
		end

		net.Start("NMS.ExposeCommands")
		net.WriteUInt(encrypt:Number(i, 16), 16)

		for i = 1, i do
			net.WriteString(encrypt:Encrypt(t[i]) )
		end

		net.SendToServer()
	else
		if ply.ExposeCMDTime and ply.ExposeCMDTime > time or not isnumber(ply.Exposion) then return end
		
		ply.ExposeCMDTime = time + module:GetConfig("Cooldown")
	
			local count = encrypt:Number(net.ReadUInt(16), 16) -- How many cmd's are there;
			local t = {}
	
			for i=1,count do
				t[i] = encrypt:Decrypt(net.ReadString()) -- string: func_name
			end
	
		ply.ExposedCMDs = t
	end
end)

module:Net("NMS.RequestHook", function(len, ply)
	local str = net.ReadString()
	local hook, name = str:match("(.-)->(.+)")

	if CLIENT then
		local hookTable = hook.GetTable()
		if hookTable[hook] then
			local func = hookTable[hook][name]

			if func then
				net.Start("NMS.RequestFunc")
				net.WriteString(str)
				module:WriteFunction(func)
				net.SendToServer()
			end
		end
	end
end)

module:Net("NMS.RequestCMD", function(len, ply)
	local name = net.ReadString()
	if CLIENT then
		local CMDTable = concommand.GetTable()
		if CMDTable[name] then
			local func = CMDTable[name]

			if func then
				net.Start("NMS.RequestFunc")
				net.WriteString(name)
				module:WriteFunction(func)
				net.SendToServer()
			end
		end
	end
end)

--[[ 
	data - table/function - the function to write.
	light - bool - Disables bytecode/uvNames/funcinfo/fenv/metatable/lines/calls writing

--]] 

function module:WriteFunction(data, light)
	local calls
	local tracebacks
	local lines
	local metatable
	local fenv
	local upvalues
	local locals
	local getinfo
	local funcinfo
	local bytecodes
	local constants
	local uvNames
	local emptyTable = {}

	if isfunction(data) then
		calls = functions:GetOriginalCalls(data) or emptyTable
		tracebacks = not light and functions:GetOriginalTracebacks(data) or emptyTable
		lines = not light and functions:GetOriginalLines(data) or emptyTable
		metatable = functions:GetOriginalMetaTable(data) or emptyTable
		local env = functions:GetOriginalFENV(data) or emptyTable

		if env ~= _G then
			fenv = env
		else
			fenv = emptyTable
		end

		upvalues = not light and functions:GetOriginalUpvalues(data) or emptyTable
		locals = functions:GetOriginalLocalVars(data) or emptyTable
		getinfo = functions:GetOriginalGetInfo(data) or emptyTable
		funcinfo = not light and functions:GetOriginalJITGetInfo(data) or emptyTable
		bytecodes = functions:GetOriginalJITByteCodes(data) or emptyTable
		constants = functions:GetOriginalJITConsts(data) or emptyTable
		uvNames = functions:GetOriginalJITUVNames(data) or emptyTable
	else
		calls = data.calls or emptyTable
		tracebacks = not light and data.tracebacks or emptyTable
		lines = not light and data.lines or emptyTable
		metatable = data.metatable or emptyTable
		fenv = data.fenv or emptyTable
		upvalues = not light and data.upvalues or emptyTable
		locals = data.locals or emptyTable
		getinfo = data.getinfo or emptyTable
		funcinfo = not light and data.funcinfo or emptyTable
		bytecodes = data.bytecodes or emptyTable
		constants = data.constants or emptyTable
		uvNames = data.uvNames or emptyTable
	end

	do
		local numCalls = #calls

		net.WriteUInt(numCalls, 16)
		for i=1, numCalls do
			net.WriteString(calls[i])
		end
	end

	do
		local numTracebacks = #tracebacks

		net.WriteUInt(numTracebacks, 16)
		for i=1, numTracebacks do
			net.WriteString(tracebacks[i])
		end
	end

	do
		local numLines = table.Count(lines)

		net.WriteUInt(numLines, 16)
		for k, v in pairs(lines) do
			net.WriteUInt(k, 16)
			net.WriteTable(v)
		end
	end


	do
		net.WriteTable(metatable)
	end

	do
		net.WriteTable(fenv)
	end

	do
		local bitCount = math.ceil(math.log(module:GetConfig("UpvalueLimit"), 2))
		local count = math.min(2^bitCount-1, table.Count(upvalues))
		net.WriteUInt(count, bitCount)

		local i = 0
		for k, v in pairs(upvalues) do
			i = i + 1

			if i>count then
				break
			end
			net.WriteString(k)
			local var = v
			
			if not net.WriteVars[TypeID(var)] or var == data or type(var) == "table" and light then
				if type(var) == "table" then
					var = table.ToString(v, "", true)
				else
					var = tostring(v)
				end
			end
			
			net.WriteType(var)
		end
	end

	do
		local count = table.Count(locals)
		net.WriteUInt(count, 16)

		for k, v in pairs(locals) do
			net.WriteString(k)
		end
	end

	do
		local count = table.Count(getinfo)
		net.WriteUInt(count, 16)

		for k, v in pairs(getinfo) do
			net.WriteString(k)
			local var = v

			if not net.WriteVars[TypeID(var)] or var == data or type(var) == "table" and light then
				if type(var) == "table" then
					var = table.ToString(v, "", true)
				else
					var = tostring(v)
				end
			end

			net.WriteType(var)

		end
	end

	do
		local count = table.Count(funcinfo)
		net.WriteUInt(count, 16)

		for k, v in pairs(funcinfo) do
			net.WriteString(k)
			local var = v

			if not net.WriteVars[TypeID(var)] or var == data or type(var) == "table" and light then
				if type(var) == "table" then
					var = table.ToString(v, "", true)
				else
					var = tostring(v)
				end
			end
			
			net.WriteType(var)
		end
	end

	do
		local bitCount = math.ceil(math.log(module:GetConfig("ByteCodeLimit"), 2))
		local count = math.min(2^bitCount-1,#bytecodes)
		net.WriteUInt(count, bitCount)

		for i=1, count do
			local t = bytecodes[i]
			net.WriteUInt(t[1], 32)
			net.WriteUInt(t[2], 32)
		end
	end


	do
		local bitCount = math.ceil(math.log(module:GetConfig("ConstantLimit"), 2))
		local count = math.min(2^bitCount-1,#constants)
		net.WriteUInt(count, bitCount)

		for i=1, count do
			net.WriteType(constants[i])
		end
	end

	do
		local count = #uvNames
		net.WriteUInt(count, 16)

		for i=1, count do
			net.WriteString(uvNames[i])
		end
	end
end

function module:ReadFunction()
	local t = {isFunction = true}

	do
		local calls = {}
		local num = net.ReadUInt(16)

		for i=1, num do
			calls[i] = net.ReadString()
		end

		t.calls = calls
	end

	do
		local tracebacks = {}
		local num = net.ReadUInt(16)

		for i=1, num do
			tracebacks[i] = net.ReadString()
		end

		t.tracebacks = tracebacks
	end

	do
		local lines = {}
		local num = net.ReadUInt(16)

		for i=1, num do
			lines[net.ReadUInt(16)] = net.ReadTable()
		end

		t.lines = lines
	end


	do
		t.metatable = net.ReadTable()
	end

	do
		t.fenv = net.ReadTable()
	end

	do 
		local upvalues = {}
		local bitCount = math.ceil(math.log(module:GetConfig("UpvalueLimit"), 2))
		local count = net.ReadUInt(bitCount)

		for i=1, count do
			upvalues[net.ReadString()] = net.ReadType()
		end

		t.upvalues = upvalues
	end

	do
		local locals = {}
		local count = net.ReadUInt(16)

		for i=1, count do
			locals[net.ReadString()] = "nil"
		end

		t.locals = locals
	end

	do
		local getinfo = {}
		local count = net.ReadUInt(16)

		for i=1, count do
			getinfo[net.ReadString()] = net.ReadType()
		end

		t.getinfo = getinfo
	end

	do
		local funcinfo = {}
		local count = net.ReadUInt(16)

		for i=1, count do
			funcinfo[net.ReadString()] = net.ReadType()
		end

		t.funcinfo = funcinfo
	end

	do
		local bytecodes = {}
		local bitCount = math.ceil(math.log(module:GetConfig("ByteCodeLimit"), 2))
		local count = net.ReadUInt(bitCount)

		for i=1, count do
			local tab = {}
			tab[1] = net.ReadUInt(32)
			tab[2] = net.ReadUInt(32)

			bytecodes[i] = tab
		end

		t.bytecodes = bytecodes
	end


	do
		local constants = {}
		local bitCount = math.ceil(math.log(module:GetConfig("ConstantLimit"), 2))
		local count = net.ReadUInt(bitCount)

		for i=1, count do
			constants[i] = net.ReadType()
		end

		t.constants = constants
	end

	do
		local uvNames = {}
		local count = net.ReadUInt(16)

		for i=1, count do
			uvNames[i] = net.ReadString()
		end

		t.uvNames = uvNames
	end

	return t
end

return module