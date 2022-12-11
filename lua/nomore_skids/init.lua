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
	assert(istable(module), "Module '" .. GetModuleNameFromPath(path) .. "' doesn't return table!")

	if not module.Name then
		module.Name = GetModuleNameFromPath(path)
	end

	NMS[state .. "Modules"][module:GetName()] = module

	local cfgPath = GetCFGFromPath(path)
	local cfgExists = file.Exists(cfgPath, "LUA")

	module:Init(cfgExists and includes[state](cfgPath))
end

local function IterateFolder(path, state)
	local fl = file.Find(NMS.Path .. path .. "/*.lua", "LUA")

	for k, v in ipairs(fl) do
		CreateModule(path .. "/" .. v, state)
	end
end

IterateFolder("server", "Server")
IterateFolder("client", "Client")
IterateFolder("Shared", "Shared")
