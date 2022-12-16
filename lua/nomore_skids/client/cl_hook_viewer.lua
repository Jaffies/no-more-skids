local module = NMS.Module()

local PANEL = {}

function PANEL:Init()
	self.DListView = self:Add("DListView")

	self.DListView:AddColumn("Hook Name")
	self.DListView:AddColumn("Hook Func")

end

return module