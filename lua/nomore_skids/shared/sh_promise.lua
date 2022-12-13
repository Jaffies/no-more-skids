local module = NMS.Module()

local PROMISE = {}

PROMISE.__index = PROMISE

function PROMISE:Then(onSuccess, onFail)
	self.Success = onSuccess
	self.Fail = onFail
end

function PROMISE:Resolve(...)
	if self.Success then
		self.Success(...)
	end
end

function PROMISE:Reject(...)
	if self.Fail then
		self.Fail(...)
	end
end

function module:Promise(func)
	local promise = setmetatable({}, PROMISE)

	if func then
		timer.Simple(0, function()
			func(promise)
		end)
	end

	return promise
end

NMS.Promise = function(func) return module:Promise(func) end

return module