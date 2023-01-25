local module = NMS.Module()

local sh_networking = module:Require("sh_network", "Shared")

net.WriteVars[TYPE_FUNCTION] = function(t, v)
	net.WriteUInt( t, 8 )
	sh_networking:WriteFunction( v, true )
end

net.ReadVars[TYPE_FUNCTION] = function(t, v)
	return sh_networking:ReadFunction()
end

function net.WriteTable(tab)
	for k, v in pairs(tab) do
		if v ~= tab then
			net.WriteType(k)
			net.WriteType(v)
		end
	end

	-- End of table
	net.WriteType(nil)
end


return module