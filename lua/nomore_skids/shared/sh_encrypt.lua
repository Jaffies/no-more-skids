local module = NMS.Module()

--[[
	VERY simple encryption
	String - Caesar cipher (Aka rotN where N is number)
	Number - Inverting bits

	TODO:
		String - change to Xor'ing (lazy)
		Number - change to Xor'ing (lazy)

--]] 

function module:Encrypt(str, elevation)
	local result = str:gsub(".", function(char) return string.char((char:byte()+(elevation or module:GetConfig("Elevation")) )%255 ) end)

	return result
end

function module:Decrypt(str, elevation)
	local result = str:gsub(".", function(char) return string.char((char:byte()-(elevation or module:GetConfig("Elevation")) )%255 ) end)

	return result
end

local bytesLookup = {}
for i=0, 32 do
	bytesLookup[i] = 2^i
end

function module:Number(num, bytes)
	return bytesLookup[bytes]-num
end

function NMS.Encrypt(str, elevation)
	module:Encrypt(str, elevation)
end

function NMS.Decrypt(str, elevation)
	module:Decrypt(str, elevation)
end

return module