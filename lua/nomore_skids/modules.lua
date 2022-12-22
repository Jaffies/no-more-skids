local MODULE = {}
MODULE.__index = MODULE

function MODULE:GetConfig(name)
	if not self.Config then
		self.Config = {}
	end
	return self.Config[name]
end

local function GetModuleState(module)
	return module.State or SERVER and "Server" or CLIENT and "Client" or "Shared"
end

local promiseTable = {
	__mode = "v", -- __module будет как weak reference как мало ли шо.
	__index = function(obj, key)
		assert(obj.__module, "No original module found")
		assert(obj.__state, "No given state")
		assert(obj.__name, "No given module name to lookup")

		local module = obj.__module:Get(obj.__name, obj.__state)
		
		return module[key]
	end,

	__newindex = function(obj, key, value)
		assert(obj.__module, "No original module found")
		assert(obj.__state, "No given state")
		assert(obj.__name, "No given module name to lookup")

		local module = obj.__module:Get(obj.__name, obj.__state)

		assert(module, "No required module " .. obj.__name .. " from " .. (obj.__module.Name or "Unknown") .. " found to index! ")

		
		module[key] = value
	end,
}

function MODULE:Require(name, state)
	state = state or GetModuleState(self)

	if not self.Requirements then
		self.Requirements = {}
	end

	self.Requirements[state] = self.Requirements[state] or {}
	self.Requirements[state][name] = true

	return setmetatable({__state = state, __name = name, __module = self}, promiseTable)
end

function MODULE:Get(name, state)
	state = state or GetModuleState(self)

	assert(isstring(name), "Name is not string!")
	assert(NMS[state .. "Modules"], "Invalid State")
	assert(self.Modules and self.Modules[state] and self.Modules[state][name], "No required " .. state:lower() .. " module " .. name .. " from " .. (self.Name or "Unknown") .. " is found!")

	return self.Modules[state][name]
end

function MODULE:SetConfig(name, val)
	if not self.Config then
		self.Config = {}
	end

	self.Config[name] = val
end

function MODULE:Hook(name, func)
	if not self.Hooks then
		self.Hooks = {}
	end
	self.Hooks[name] = func
end

function MODULE:Net(name, func)
	if not self.Nets then
		self.Nets = {}
	end
	self.Nets[name] = func or true
end

function MODULE:GetName()
	return self.Name and self.Name:lower()
end

function MODULE:Init(config)
	for k, v in pairs(self.Hooks or {}) do
		hook.Add(k, "NMS.Module." ..self:GetName(), v)
	end

	for k, v in pairs(self.Nets or {}) do
		if SERVER then
			util.AddNetworkString(k)
		end
		
		if isfunction(v) then
			net.Receive(k, v)
		end
	end

	local cfg = config or {}

	hook.Run("NMS.Module.CFG", cfg)

	self.Config = cfg
end

local states = {"Shared", "Client", "Server"}

function MODULE:RequireModules()
	local t = {}
	self.Modules = t
	for i=1, 3 do
		local state = states[i]
		local stateTable = {}

		t[state] = stateTable
		
		for k, v in pairs(self.Requirements and self.Requirements[state] or {}) do
			local module = NMS[state .. "Modules"][k]
			
			assert(istable(module), "No given " .. state .. " module found! (" .. k .. ") from " .. (self.Name or "Unknown") )
			
			stateTable[k] = module
		end
	end

	self.Requirements = nil
end

function NMS.Module()
	return setmetatable({}, MODULE)
end