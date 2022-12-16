NMS = {
	ClientModules = CLIENT and {},
	ServerModules = SERVER and {},
	SharedModules = {},
	Path = "nomore_skids/",
	ConfigPath = "nomore_skids/configs/"
}

AddCSLuaFile("modules.lua")
include("modules.lua")

local includes = {
	Client = function(path)
		if SERVER then
			AddCSLuaFile(path)
		else
			return include(path)
		end
	end,
	Server = function(path)
		if SERVER then
			return include(path)
		end
	end,
	Shared = function(path)
		AddCSLuaFile(path)
		return include(path)
	end,
}

local includes2 = {
	Client = function() return CLIENT end,
	Server = function() return SERVER end,
	Shared = function() return true end,
}

local function GetModuleNameFromPath(path)
	return path:match("/(.+)%.lua")
end

local function GetCFGFromPath(path)
	return NMS.ConfigPath .. path:match("/(.+%.lua)")
end

local function CreateModule(path, state)
	local func = includes[state]
	if not func then return end

	local module = func(path)

	local cfgPath = GetCFGFromPath(path)
	local cfgExists = file.Exists(cfgPath, "LUA")

	local cfg = cfgExists and includes[state](cfgPath) or nil

	if not includes2[state]() then
		return
	end
	
	assert(istable(module), "Module '" .. GetModuleNameFromPath(path) .. "' doesn't return table!")

	if not module.Name then
		module.Name = GetModuleNameFromPath(path)
	end

	module.State = state

	NMS[state .. "Modules"][module:GetName()] = module

	module:Init(cfg)
end

local function IterateFolder(path, state)
	local fl = file.Find(NMS.Path .. path .. "/*.lua", "LUA")

	for k, v in ipairs(fl) do
		CreateModule(path .. "/" .. v, state)
	end
end

IterateFolder("server", "Server")
IterateFolder("client", "Client")
IterateFolder("shared", "Shared")

hook.Run("NMS.Module.Loaded")

for i, state in ipairs({"Server", "Client", "Shared"}) do
	for k, v in pairs(NMS[state .. "Modules"] or {}) do
		v:RequireModules()
	end
end

hook.Run("NMS.Module.LoadedRequirements")