return {
	WarnMethod = "Default", -- Warn method (all methods are presented in sv_warn.lua)
	SteamAPIKey = nil, -- If presented, replace nil to "STEAMAPIKEY". It'll be better if you will use it btw.
	DisableSteamCheck = false, -- Disabling checking steam profile.
	DisableLimitedAccountCheck = false, -- Disable checking limited accounts.
	DisableFamilySharingCheck = false, -- Disable family sharing check (it is used to bypass bans).
	DisableAliumBanList = false, -- Alium banlist
	DisableUrbanichkaBanList = false, -- People from urbanichka's server.
	DisableHexSkidCheckBanList = true, -- (It is recomended to be disabled). Ban list from Hex's Skid Check 2.0
	GMRPBanList = false, -- GMRP BanList check
	FastRPBanList = false, -- FastRP BanList check
	UnionRPBanList = false, -- UnionRP BanList check
}