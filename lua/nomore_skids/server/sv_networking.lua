local module = NMS.Module()

--[[
	opcodes:
		1) Start sending bignet:(
			net.ReadString = name of bignet operation (max is 8 bignets per user)
			net.ReadUInt(8) - max is 255 packets.
			
			after it server generates SHA256 hash and gives it to client
		)
		2) Sending data:(
				net.ReadString = name of bignet
				net.ReadString = sha256 hash
				net.ReadString - data

				after it server generates sha 256 hash out of prev. hash and gives it to client
			)
--]] 


module:Net("NMS.BigNet", function(len, ply)
	local 
end)

return module