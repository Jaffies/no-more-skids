local PROMISE = NMS.Module()

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

function NMS.Promise(func)
	local promise = setmetatable({}, PROMISE)

	if func then
		timer.Simple(0, function()
			func(promise)
		end)
	end

	return promise
end

return NMS.Module()