local module = NMS.Module()

local warn = module:Require("sv_warn") -- Server автоматом будет стоять 
local promise = module:Require("sh_promise", "Shared") -- оно шередовское

module.Checks = {}

module:Hook("PlayerSpawn", function(ply)
	if --[[ not ply.CheaterListChecked and--]]   not ply:IsBot() then
		ply.CheaterListChecked = true

		promise:Promise(function(self)
			for k, v in ipairs(module.Checks) do
				v(ply, self)
			end
		end):Then(function(reason)
			reason = reason and " " .. reason or ""

			if IsValid(ply) then
				print("|Cheaters List|", ply, reason)
				warn:Warn(ply, "|Cheaters List| " .. reason, module:GetConfig("WarnMethod"))
			end
		end)
	end
end)

do

	local function AddCheck(func)
		module.Checks[#module.Checks+1] = func
	end
	
	
	do -- Checking steam profile through API
		local function SteamBansCheck(num, str, tab)
			if num > 0 then
				tab[#tab+1] = str .. num
			end
		end
		
		
		AddCheck(function(ply, promise)
			if not module:GetConfig("SteamAPIKey") or module:GetConfig("DisableSteamCheck") then return end

		
			local url = string.format("http://api.steampowered.com/ISteamUser/GetPlayerBans/v1/?key=%s&steamids=%s", module:GetConfig("SteamAPIKey"), ply:SteamID64())
		
			http.Fetch(url, function(body)

				local t = util.JSONToTable(body)

				if t and t.players then
					local strTable = {}
					local plyTable = t.players[1]
					local numGameBans = plyTable.NumberOfGameBans
					local numVacBans = plyTable.NumberOfVACBans
					local daysSinceLastBan = plyTable.DaysSinceLastBan
					local communityBanned = plyTable.CommunityBanned
					local tradeBanned = plyTable.EconomyBan ~= "none"
		
					SteamBansCheck(numGameBans, "Game Bans : ", strTable)
					SteamBansCheck(numVacBans, "Vac Bans : ", strTable)
					SteamBansCheck(daysSinceLastBan, "Days since last ban : ", strTable)
		
					if communityBanned then
						strTable[#strTable+1] = "Community ban"
					end

					if tradeBanned then
						strTable[#strTable+1] = "Trade ban"
					end
					
					if #strTable > 0 then
						promise:Resolve(table.concat(strTable, ", "))
					end
				end

			end)
		end)
	end

	-- Checking steam VAC bans without steam API (if no key provided)
	AddCheck(function(ply, promise)
		if module:GetConfig("SteamAPIKey") or module:GetConfig("DisableSteamCheck") then return end

		local url = string.format("https://steamcommunity.com/profiles/%s?xml=1", ply:SteamID64())

		http.Fetch(url, function(body)


			local strTable = {}
			local vacBan = body:match("<vacBanned>(%d)</vacBanned>") == "1"
			local tradeBan = body:match("<tradeBanState>(.+)</tradeBanState>") ~= "None"

			if vacBan then
				strTable[1] = "Vac ban"
			end

			if tradeBan then
				strTable[#strTable+1] = "Trade Ban"
			end

			if #strTable > 0 then
				promise:Resolve(table.concat( strTable, ", "))
			end
		end)
	end)

	-- Limited Account check (account is limited if user didn't spent at least 5$ in that account)
	AddCheck(function(ply, promise)
		if module:GetConfig("DisableLimitedAccountCheck") then return end

		local url = string.format("https://steamcommunity.com/profiles/%s?xml=1", ply:SteamID64())

		http.Fetch(url, function(body)
			if body:match("<isLimitedAccount>(%d)</isLimitedAccount>") == "1" then
				promise:Resolve("Limited account")
			end
		end)
	end)

	-- Family Sharing
	AddCheck(function(ply, promise)
		if module:GetConfig("DisableFamilySharingCheck") then return end
		if ply:OwnerSteamID64() ~= ply:SteamID64() then
			promise:Resolve("Family sharing")
		end
	end)

	AddCheck(function(ply, promise)
		if module:GetConfig("DisableSkidCoders") then return end
		if ply:Nick():lower():EndsWith("code") then
			promise:Resolve("Skid coder")
		end
	end)

	do
		local function AddBanListCheck(name, urls)
			AddCheck(function(ply, promise)
				if module:GetConfig(name .. "BanList") then return end

				local url = string.format(urls, ply:SteamID())
			
				http.Fetch(url, function(body)
					local t = util.JSONToTable(body or "")
					local time = os.time()
					if t and t.data then
						for k, v in ipairs(t.data) do
							if v.unbanTime and (v.unbanTime == "0" or tonumber(v.unbanTime) > time) then
								promise:Resolve(name .. " active ban: " .. (v.reason or "Unknown reason") )
								break
							end
						end
					end
				end)
			end)
		end

		-- Checking some public ban lists from russian servers (GMRP, FastRP, UnionRP)
		-- TODO: Add some english server's banlist (for an example: Fudgy's server)
		AddBanListCheck("GMRP", "https://app.gmrp.ru/bans/ajaxify.php?page=1&steamid=%s")
		AddBanListCheck("FastRP", "https://desk.fastrp.ru/bans/ajaxify.php?page=1&steamid=%s")
		AddBanListCheck("UnionRP", "https://unionrp.info/hl2rp/bans/c2/?page=1&player=%s")
	end



	do
		local function CheckBanList(name, url)
			AddCheck(function(ply, promise)
				if module:GetConfig("Disable".. name .. "BanList") then return end

				local plyID = ply:SteamID():match("STEAM_%d:%d:(%d+)")

				http.Fetch(url, function(body)
					if body:match(plyID) then
						promise:Resolve(name .. " ban list")
					end
				end)
			end)
		end

		-- Checking Alium ban list
		CheckBanList("Alium", "https://raw.githubusercontent.com/Pika-Software/gmod_alium_bans/main/banned_user.cfg")
		-- Checking Urbanichka's discord server users
		CheckBanList("Urbanichka", "https://pastebin.com/raw/RU1KksJw")
	end

	--Checking Hex's SkidCheck2.0 ban list
	AddCheck(function(ply, promise)
		if module:GetConfig("DisableHexSkidCheckBanList") then return end

		local matchStr = "%[\"%d:" .. ply:SteamID():match("STEAM_%d:%d:(%d+)") .. "\"%]%s*\"(.*)\",\n"

		for i=65, 85 do
			local url = string.format("https://raw.githubusercontent.com/ThatLing/hex-memorial/master/Repos/SkidCheck-2.0-master/lua/skidcheck/sv_SkidList_%c.lua", i)

			http.Fetch(url, function(body)

				local reason = body:match(matchStr)
				if reason then
					promise:Resolve("Hex's SkidCheck2.0 ban list :" .. reason
						:Replace("..GG..", "Member of hack/troll group")
						:Replace("..Snix..", "Member of snixzz hacking site")
					)
				end
			end)
		end
	end)


end

return module