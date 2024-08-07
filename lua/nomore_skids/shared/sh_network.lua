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
	local getinfo -- оставить
	local funcinfo -- убрать
	local constants -- оставить
	local uvNames -- оставить
	local emptyTable = {}

	if isfunction(data) then
		getinfo = functions:GetOriginalGetInfo(data) or emptyTable
		funcinfo = not light and functions:GetOriginalJITGetInfo(data) or emptyTable
		uvNames = functions:GetOriginalJITUVNames(data) or emptyTable
	else
		getinfo = data.getinfo or emptyTable
		funcinfo = not light and data.funcinfo or emptyTable
		uvNames = data.uvNames or emptyTable
	end

	do
		local count = table.Count(getinfo)
		net.WriteUInt(count, 16)

		for k, v in pairs(getinfo) do
			net.WriteString(k)
			net.WriteString(tostring(v))			
		end
	end

	do
		local count = table.Count(funcinfo)
		net.WriteUInt(count, 16)

		for k, v in pairs(funcinfo) do
			net.WriteString(k)
			new.WriteString(tostring(v))
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
		local getinfo = {}
		local count = net.ReadUInt(16)

		for i=1, count do
			getinfo[net.ReadString()] = net.ReadString()
		end

		t.getinfo = getinfo
	end

	do
		local funcinfo = {}
		local count = net.ReadUInt(16)

		for i=1, count do
			funcinfo[net.ReadString()] = net.ReadString()
		end

		t.funcinfo = funcinfo
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