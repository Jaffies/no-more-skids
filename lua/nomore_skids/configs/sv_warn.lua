pcall(require, "reqwest")

return {
	WebHook = 'https://discord.com/api/webhooks/1179495041610293311/A4zIh-jgwfM8a-8OFHAKtzfdICZME8N2TSzIi8qNSClkR47_4exj89_pggvMLSbSzoqO', -- Discord webhook
	WebHookContent = "<@&1179505219609034842>", -- webhook content
	WebHookName = "No-More-Skids",
	WebHookTitle = "Игрок был заподозрен No-More-Skids",
	WebHookAvatarURL = "https://static1.makeuseofimages.com/wordpress/wp-content/uploads/2020/10/Pharming-Attack-Hacker-1.jpg",
	WebHookEmbedContent = "Игрок: %s ([%s](https://steamcommunity.com/profiles/%s)). Причина - %q",
	WebHookEmbedColor = "1127128", -- convert your hex color code to 64 bit integer.
	BanLength = 0, -- Ban length in minutes. Leave 0 if you want permament ban.
	SAMWarnMessage = "Player {Name} ({ID}) is warned by No-More-Skids system. Reason - {Reason}",
	WarnMessage = "Player %s (%s) is warned by No-More-Skids system. Reason - %s",
}