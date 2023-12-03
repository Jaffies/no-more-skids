local module = NMS.Module()

local functions = module:Require("cl_functions")

local PANEL = {}

function PANEL:Init()
	self:DockPadding(8,8,8,8)

	self.properties = self:Add("DPropertySheet")
	self.properties:Dock(FILL)

	self.properties.getinfo = self:Add("NMS.TableInspector")
	self.properties.getinfo:Dock(FILL)

	self.properties.funcinfo = self:Add("NMS.TableInspector")
	self.properties.funcinfo:Dock(FILL) 

	self.properties.uvNames = self:Add("NMS.TableInspector")
	self.properties.uvNames:Dock(FILL) 

	self.properties:AddSheet("Local variables", self.properties.locals, "icon16/mouse.png")
	self.properties:AddSheet("Information", self.properties.getinfo, "icon16/comment.png")
	self.properties:AddSheet("JIT Information", self.properties.funcinfo, "icon16/script.png")
	self.properties:AddSheet("JIT Upvalues", self.properties.uvNames, "icon16/link.png")
end

local emptyTable = {}

function PANEL:SetFunction(func)

	self.properties.getinfo:SetTable(functions:GetOriginalGetInfo(func) or emptyTable)
	self.properties.funcinfo:SetTable(functions:GetOriginalJITGetInfo(func) or emptyTable)
	self.properties.consts:SetTable(functions:GetOriginalJITConsts(func) or emptyTable)
	self.properties.uvNames:SetTable(functions:GetOriginalJITUVNames(func) or emptyTable)
end

function module:InspectFunction(func)
	local d = vgui.Create("DFrame")

	local inspector = d:Add("NMS.FunctionInspector")
	inspector:Dock(FILL)

	inspector:SetFunction(func)

	d:SetSize(ScrW()*0.5, ScrH()*0.5)
	d:Center()
	d:SetSizable(true)
	d:MakePopup()
end

vgui.Register("NMS.FunctionInspector", PANEL)

return module