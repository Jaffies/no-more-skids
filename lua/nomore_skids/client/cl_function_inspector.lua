local module = NMS.Module()

local functions = module:Require("cl_functions")

local PANEL = {}

function PANEL:Init()
	self:DockPadding(8,8,8,8)

	self.properties = self:Add("DPropertySheet")
	self.properties:Dock(FILL)

	self.properties.traceback = self:Add("NMS.TableInspector")
	self.properties.traceback:Dock(FILL)

	self.properties.calls = self:Add("NMS.TableInspector")
	self.properties.calls:Dock(FILL)

	self.properties.upvalues = self:Add("NMS.TableInspector")
	self.properties.upvalues:Dock(FILL)

	self.properties.locals = self:Add("NMS.TableInspector")
	self.properties.locals:Dock(FILL)

	self.properties.fenv = self:Add("NMS.TableInspector")
	self.properties.fenv:Dock(FILL)

	self.properties.metatable = self:Add("NMS.TableInspector")
	self.properties.metatable:Dock(FILL)

	self.properties.getinfo = self:Add("NMS.TableInspector")
	self.properties.getinfo:Dock(FILL)

	self.properties.lines = self:Add("NMS.TableInspector")
	self.properties.lines:Dock(FILL) 

	self.properties.funcinfo = self:Add("NMS.TableInspector")
	self.properties.funcinfo:Dock(FILL) 

	self.properties.bytecodes = self:Add("NMS.TableInspector")
	self.properties.bytecodes:Dock(FILL) 

	self.properties.consts = self:Add("NMS.TableInspector")
	self.properties.consts:Dock(FILL) 

	self.properties.uvNames = self:Add("NMS.TableInspector")
	self.properties.uvNames:Dock(FILL) 

	self.properties:AddSheet("Traceback", self.properties.traceback, "icon16/information.png")
 	self.properties:AddSheet("Calls", self.properties.calls, "icon16/find.png")
	self.properties:AddSheet("Upvalues", self.properties.upvalues, "icon16/monitor.png")
	self.properties:AddSheet("Local variables", self.properties.locals, "icon16/mouse.png")
	self.properties:AddSheet("Environment", self.properties.fenv, "icon16/layout.png")
	self.properties:AddSheet("MetaTable", self.properties.metatable, "icon16/computer.png")
	self.properties:AddSheet("Lines", self.properties.lines, "icon16/comment.png")
	self.properties:AddSheet("Information", self.properties.getinfo, "icon16/comment.png")
	self.properties:AddSheet("JIT Information", self.properties.funcinfo, "icon16/script.png")
	self.properties:AddSheet("Byte Codes", self.properties.bytecodes, "icon16/text_align_center.png")
	self.properties:AddSheet("Constants", self.properties.consts, "icon16/font.png")
	self.properties:AddSheet("JIT Upvalues", self.properties.uvNames, "icon16/link.png")
end

function PANEL:SetFunction(func)
	local emptyTable = {}

	self.properties.traceback:SetTable(functions:GetOriginalTracebacks(func) or emptyTable)
 	self.properties.calls:SetTable(functions:GetOriginalCalls(func) or emptyTable)
	self.properties.getinfo:SetTable(functions:GetOriginalGetInfo(func) or emptyTable)
	self.properties.upvalues:SetTable(functions:GetOriginalUpvalues(func) or emptyTable)
	self.properties.locals:SetTable(functions:GetOriginalLocalVars(func) or emptyTable)
	self.properties.metatable:SetTable(functions:GetOriginalMetaTable(func) or emptyTable)
	self.properties.fenv:SetTable(functions:GetOriginalFENV(func) or emptyTable)
	self.properties.lines:SetTable(functions:GetOriginalLines(func) or emptyTable)
	self.properties.funcinfo:SetTable(functions:GetOriginalJITGetInfo(func) or emptyTable)
	self.properties.bytecodes:SetTable(functions:GetOriginalJITByteCodes(func) or emptyTable)
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