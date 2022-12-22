local module = NMS.Module()

--[[
	opcodes:
		1) Sucessful data
			(net.ReadString - name of bignet)
			(net.ReadString - hash)
			called when data is sucessfuly gotten
		2) Retrieve data(
			net.ReadString - name of bignet
			net.ReadString - hash
			called when server doesn't have this data.
		)
		3) Canceling data send(
			net.ReadString - name of bignet
		)
]]

return module