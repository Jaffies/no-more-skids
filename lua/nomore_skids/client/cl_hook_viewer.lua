local module = NMS.Module()

local icons = module:Require("cl_icons")
local function_inspector = module:Require("cl_function_inspector")

local PANEL = {}

local function DoClickFunc(pnl)
	function_inspector:InspectFunction(pnl.Function)
end


local function IterateTable(node, tab)
	path = path or ""

	local i = 0
	for k, v in pairs(tab) do
		i = i+1

		local valType = type(v)
		local sameTable = v == tab

		local node2 = node:AddNode(tostring(k), icons:GetIcon(valType))

		if valType == "function" then
			node2.Function = v
			node2.DoClick = DoClickFunc
		elseif valType == "table" then
			IterateTable(node2, v)
		end
	end
end

function PANEL:Init()
	self.BaseClass.Init(self)

	IterateTable(self, hook.GetTable())
end

vgui.Register("NMS.HookInspector", PANEL, "DTree")

function module:InspectHooks()
	local f = vgui.Create("DFrame")

	f.HookInspector = f:Add("NMS.HookInspector")
	f.HookInspector:Dock(FILL)

	f:SetSizable(true)
	f:SetSize(ScrW()*0.5, ScrH()*0.5)
	f:Center()
	f:MakePopup()
end

return module