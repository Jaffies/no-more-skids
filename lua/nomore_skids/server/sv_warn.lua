local module = NMS.Module()

function module:Warn(ply, reason, method)

	assert(IsValid(ply) and ply:IsPlayer(), "ply argument is not player!")
	assert(isstring(reason), "reason is not string!")
	assert(isstring(method), "method is not string!")
	
	local func = module.WarnFunctions[method]
	assert(func, "No warn function for method (" .. method .. ")")

	if hook.Run("NMS.Warn", ply,reason, method) then return end

	func(ply, reason)
end

NMS.Warn = function(ply, reason, method) module:Warn(ply, reason, method) end

module.WarnFunctions = {}

local function AddWarnMethod(name, func)
	module.WarnFunctions[name] = func
end

AddWarnMethod("Discord", function(ply, reason)
	local webHook = module:GetConfig("WebHook")
	assert(isstring(webHook), "Web Hook is not a string!")
	assert(CHTTP, "No CHTTP module found!")

	local bodyStr = string.format([[{
		"username":%q,
		"avatar_url":%q,
		"content":%q,
		"embeds":[{
			"title":%q,
			"description":%q,
			"color":%s
		}]
}]],
		module:GetConfig("WebHookName"),
		module:GetConfig("WebHookAvatarURL"),
		module:GetConfig("WebHookContent"),
		module:GetConfig("WebHookTitle"),
		module:GetConfig("WebHookEmbedContent"):format(ply:Nick(), ply:SteamID(), ply:SteamID64(), reason),
		module:GetConfig("WebHookEmbedColor")
	)

	CHTTP({
		method = "POST",
		url = webHook,
		body = bodyStr,
		headers = {
			["User-Agent"] = "Google Chrome",
		},
		type = "application/json",
	})
end)

AddWarnMethod("Ban", function(ply, reason)
	ply:Ban(module:GetConfig("BanLength"))
	ply:Kick(reason)
end)

AddWarnMethod("IPBan", function(ply, reason)
	RunConsoleCommand("addip", module:GetConfig("BanLength"), ply:IPAddress())
	ply:Kick(reason)
end)

AddWarnMethod("Kick", function(ply, reason)
	ply:Kick(reason)
end)

AddWarnMethod("SAM", function(ply, reason)
	local admins = {}

	local i = 0
	for k, v in ipairs(player.GetHumans()) do
		if v:HasPermission("see_admin_chat")  and v ~= ply  then
			i = i+1
			admins[i] = v
		end
	end

	sam.send_message(admins, module:GetConfig("SAMWarnMessage"), {Name = ply:Nick(), Reason=reason, ID=ply:SteamID()})
end)

AddWarnMethod("Default", function(ply, reason)
	local i = 0
	for k, v in ipairs(player.GetHumans()) do
		if v:IsAdmin()  and v~= ply  then
			v:ChatPrint(module:GetConfig("WarnMessage"):format(ply:Nick(), ply:SteamID(), reason))
		end
	end
end)

return module