local module = NMS.Module()

local icons = module:Require("cl_icons")

local function GetValueInfo(val)
	local text = module:GetConfig("Text")

	return text:format(string.format("%p", val), type(val), type(val) == "table" and table.ToString(val, "", true) or tostring(val))
end

local PANEL = {}

function PANEL:Init()

	self.DTree = self:Add("DTree")

	self.Information = self:Add("RichText")
	self.Information:InsertColorChange(0, 0, 0, 255)

	self.HorizontalDivider = self:Add("DHorizontalDivider")
	self.HorizontalDivider:SetLeft(self.DTree)
	self.HorizontalDivider:SetRight(self.Information)
	self.HorizontalDivider:SetDividerWidth(5)
	self.HorizontalDivider:SetLeftMin(80)
	self.HorizontalDivider:SetRightMin(40)
	self.HorizontalDivider:Dock(FILL)
end

local function DoClickFunc(pnl)
	local info = pnl.Information

	info:SetText("")
	info:InsertColorChange(255,255,255,255)
	info:AppendText(GetValueInfo(pnl.Value))
end


local function IterateTable(info, node, tab)
	path = path or ""

	local i = 0
	for k, v in pairs(tab) do
		i = i+1
		
		if i > module:GetConfig("MaxLines") then
			break
		end

		local valType = type(v)
		local sameTable = v == tab

		local node2 = node:AddNode(tostring(k), icons:GetIcon(valType))

		node2.Value = v
		node2.Information = info
		node2.DoClick = DoClickFunc

		node2:SetTooltip(tostring(v))
		if valType == "table" and not sameTable then
			IterateTable(info, node2, v)
		end
	end
end

function PANEL:SetTable(tab)
	IterateTable(self.Information, self.DTree, tab)
end

vgui.Register("NMS.TableInspector", PANEL)

return module