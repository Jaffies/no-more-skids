pcall(require, "chttp")

return {
	WebHook = nil, -- Discord webhook
	WebHookContent = "@everyone", -- webhook content
	WebHookName = "No-More-Skids",
	WebHookTitle = "Player has been warned by No-More-Skids",
	WebHookAvatarURL = "https://static1.makeuseofimages.com/wordpress/wp-content/uploads/2020/10/Pharming-Attack-Hacker-1.jpg",
	WebHookEmbedContent = "Player is: %s ([%s](https://steamcommunity.com/profiles/%s)). Reason - %q",
	WebHookEmbedColor = "1127128", -- convert your hex color code to 64 bit integer.
	BanLength = 0, -- Ban length in minutes. Leave 0 if you want permament ban.
	SAMWarnMessage = "Player {Name} ({ID}) is warned by No-More-Skids system. Reason - {Reason}",
	WarnMessage = "Player %s (%s) is warned by No-More-Skids system. Reason - %s",
}