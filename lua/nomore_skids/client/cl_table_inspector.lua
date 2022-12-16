local module = NMS.Module()

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

local icons = {
	["string"] = "icon16/page_white_text.png",
	["number"] = "icon16/coins.png",
	["table"] = "icon16/layout.png",
	["function"] = "icon16/joystick.png",
	["thread"] = "icon16/door_in.png",
	["Vector"] = "icon16/arrow_switch.png",
	["Player"] = "icon16/user.png",
	["Entity"] = "icon16/page.png",
	["Angle"] = "icon16/time.png",
	["userdata"] = "icon16/table.png",
}


local function IterateTable(info, node, tab, path)
	path = path or ""

	local i = 0
	for k, v in pairs(tab) do
		i = i+1
		if i > module:GetConfig("MaxLines") then
			break
		end

		local valType = type(v)
		local sameTable = v == tab

		local node2 = node:AddNode(tostring(k), icons[valType])

		function node2:DoClick()
			info:SetText("")
			info:InsertColorChange(255,255,255,255)
			info:AppendText(GetValueInfo(v))
		end

		node2:SetTooltip(tostring(v))
		
		if valType == "table" and not sameTable then
			IterateTable(info, node2, v, path .. tostring(k) .. "->")
		end
	end
end

function PANEL:SetTable(tab)
	IterateTable(self.Information, self.DTree, tab)
end

vgui.Register("NMS.TableInspector", PANEL)

return module