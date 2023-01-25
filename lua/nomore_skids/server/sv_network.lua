local module = NMS.Module()

local sh_networking = module:Require("sh_network", "Shared") -- used for getting configs
local warn = module:Require("sv_warn")

local requestFuncs = setmetatable({}, {__mode = "k"}) -- for hook.GetTable()

module:Hook("PlayerSpawn", function(ply)
	if not ply.Exposion then
		ply.Exposion = CurTime() + sh_networking:GetConfig("WaitTime")

		net.Start("NMS.ExposeHooks")
		net.Send(ply)

		net.Start("NMS.ExposeCommands")
		net.Send(ply)
	elseif isnumber(ply.Exposion) then
		if ply.ExposedHooks and ply.ExposedCMDs then
			ply.Exposion = true

			return
		end

		if ply.Exposion < CurTime() then
			warn:Warn(ply, "Hook/Command exposion fail", sh_networking:GetConfig("FailExposeMethdod"))
		end
	end
end)

module:Net("NMS.RequestFunc", function(len, ply)
	local name = net.ReadString()
	if module:HasFuncCallback(ply, name) then -- делаем проверку потмоу что читать функцию жеска
		module:CallFuncCallback(ply, name, sh_networking:ReadFunction())
	end
end)

function module:RequestHook(ply, hook,name, callback)
	local noHook = true

	timer.Simple(sh_networking:GetConfig("WaitTime"), function()
		if IsValid(ply) and noHook then
			warn:Warn(ply, "Request hook fail", sh_networking:GetConfig("FailRequestMethdod"))
		end
	end)

	self:AddFuncCallback(ply, hook .. "->" .. name, function(data)
		noHook = nil
		callback(data)
	end)

	net.Start("NMS.RequestHook")
	net.WriteString(hook .. "->" .. name)
	net.Send(ply)
end

function module:RequestCMD(ply, name, callback)
	local noCMD = true

	timer.Simple(sh_networking:GetConfig("WaitTime"), function()
		if IsValid(ply) and noCMD then
			warn:Warn(ply, "Request CMD fail", sh_networking:GetConfig("FailRequestMethdod"))
		end
	end)

	self:AddFuncCallback(ply, name, function(data)
		noCMD = nil
		callback(data)
	end)

	net.Start("NMS.RequestCMD")
	net.WriteString(name)
	net.Send(ply)
end

function module:HasFuncCallback(ply, name)
	local t = requestFuncs[ply]
	if t then
		local func = t[name]
		if func then
			return true
		end
	end

	return false
end

function module:CallFuncCallback(ply, name, data)
	if not self:HasFuncCallback(ply, hook, name) then return end

	local func = requestFuncs[ply][name]
	
	func(data)
end

function module:AddFuncCallback(ply, hook, name, func)
	requestHooks[ply] = requestHooks[ply] or {}
	requestHooks[ply][name] = func
end

return module