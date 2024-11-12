local ConfigUtils = require(script.Parent.ConfigUtils)

local Config = {
	Systems = {
		Profiles = {
			Roles = ConfigUtils:CompileRoles(script.Roles),
			DefaultRoleId = script.Roles:GetAttribute("DefaultRoleId"),
			AvatarEditorCallback = ConfigUtils:GetAvatarEditorCallback(script),
		},
		Music = {
			SoundGroup = script.Music,
		},
		Emotes = {
			Emotes = ConfigUtils:CompileEmotes(script.Emotes),
			Categories = {
				General = {
					LayoutOrder = 1,
				},
				Unlockable = {
					LayoutOrder = 2,
				},
				Robux = {
					LayoutOrder = 3,
				},
			},
		},
		Items = {
			Items = ConfigUtils:CompileItems(script.Items),
			Categories = {
				General = {
					LayoutOrder = 1,
				},
				Unlockable = {
					LayoutOrder = 2,
				},
				Robux = {
					LayoutOrder = 3,
				},
			},
		},
		Worlds = {
			FeaturedWorlds = {},
		},
	},
}

return Config
