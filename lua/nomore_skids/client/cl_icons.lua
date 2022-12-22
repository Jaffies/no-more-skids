local module = NMS.Module()

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

function module:GetIcon(valType)
	return icons[valType]
end

return module