local MODULE = {}
MODULE.__index = MODULE

function MODULE:GetConfig(name)
	if not self.Config then
		self.Config = {}
	end
	return self.Config[name]
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
	self.Nets[name] = func
end

function MODULE:GetName()
	return self.Name and self.Name:lower()
end

function MODULE:Init(config)
	for k, v in pairs(self.Hooks or {}) do
		hook.Add(k, "NMS.Module." ..self:GetName(), v)
	end

	for k, v in pairs(self.Nets or {}) do
		net.Receive(k, v)
	end

	if config then
		self.Config = config
	end
end

function NMS.Module()
	return setmetatable({}, MODULE)
end