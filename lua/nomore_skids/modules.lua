local MODULE = {}

function MODULE:GetConfig(name)
	return self.Config[name]
end

function MODULE:SetConfig(name, val)
	if not self.Config then
		self.Config = {}
	end

	self.Config[name] = val
end

function MODUlE:Hook(name, func)
	self.Hooks[name] = func
end

function MODULE:Net(name, func)
	self.Nets[name] = func
end

function MODULE:Name()
	return self.Name and self.Name:lower()
end

function MODULE:Init(config)
	for k, v in pairs(self.Hooks) do
		hook.Add(k, self:Name(), v)
	end

	for k, v in pairs(self.Nets) do
		net.Receive(k, v)
	end

	if config then
		self.Config = config
	end
end

function NMS.Module()
	return setmetatable({}, MODULE)
end