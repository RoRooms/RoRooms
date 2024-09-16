export type CategoryName = string
export type Category = {
	DisplayName: string?,
	Icon: string,
	LayoutOrder: number?,
	Color: Color3?,
}
export type Categories = {
	[CategoryName]: Category,
}
export type Item = {
	Enabled: boolean?,
	Tool: Tool,
	DisplayName: string?,
	Category: string?,
	Color: Color3?,
	LayoutOrder: number?,
	LabelIcon: string?,
	LevelRequirement: number?,
	CallbackRequirement: () -> ()?,
}
export type Emote = {
	Enabled: boolean?,
	Animation: Animation,
	DisplayName: string?,
	Category: string?,
	Emoji: string?,
	Color: Color3?,
	LayoutOrder: number?,
	LabelIcon: string?,
	LevelRequirement: number?,
	CallbackRequirement: () -> ()?,
}
export type PlaceId = number
export type Config = {
	Systems: {
		Profiles: {
			Enabled: boolean?,
			NicknameCharacterLimit: number?,
			BioCharacterLimit: number?,
			AvatarEditorCallback: () -> ()?,
		}?,
		Items: {
			Enabled: boolean?,
			MaxItemsEquippable: number?,
			Categories: Categories?,
			Items: {
				[string]: Item?,
			}?,
		}?,
		Emotes: {
			Enabled: boolean?,
			Categories: Categories?,
			Emotes: {
				[string]: Emote,
			}?,
		}?,
		Music: {
			Enabled: boolean?,
			SoundGroup: SoundGroup?,
		}?,
		Worlds: {
			Enabled: boolean?,
			DiscoveryEnabled: boolean?,
			FeaturedWorlds: { [number]: PlaceId }?,
		}?,
		Friends: {
			Enabled: boolean?,
		}?,
		Settings: {
			Enabled: boolean?,
		}?,
		VR: {
			Enabled: boolean?,
		}?,
		UI: {
			OnyxUITheme: { [string]: any }?,
		}?,
		Leveling: {
			Enabled: boolean?,
			XPPerMinute: number?,
			BaseLevelUpXP: number?,
		}?,
	}?,
}

local CONFIG_TEMPLATE: Config = {
	Systems = {
		Profiles = {
			Enabled = true,
			NicknameCharacterLimit = 20,
			BioCharacterLimit = 30,
		},
		Items = {
			Enabled = true,
			MaxItemsEquippable = 5,
			Categories = {},
			Items = {},
		},
		Emotes = {
			Enabled = true,
			Categories = {},
			Emotes = {},
		},
		Music = {
			Enabled = true,
			SoundGroup = Instance.new("SoundGroup"),
		},
		Worlds = {
			Enabled = true,
			DiscoveryEnabled = true,
			FeaturedWorlds = {},
		},
		Friends = {
			Enabled = true,
		},
		Settings = {
			Enabled = true,
		},
		VR = {
			Enabled = true,
		},
		Leveling = {
			Enabled = true,
			XPPerMinute = 30,
			BaseLevelUpXP = 35,
		},
		UI = {},
	},
}

local function DeepCopyTable(Table)
	local Copy = {}
	for Key, Value in pairs(Table) do
		if type(Value) == "table" then
			Copy[Key] = DeepCopyTable(Value)
		else
			Copy[Key] = Value
		end
	end
	return Copy
end

local function ReconcileTable(Target, Template)
	for Key, Value in pairs(Template) do
		if type(Target[Key]) == "table" and type(Value) == "table" then
			ReconcileTable(Target[Key], Value)
		else
			if type(Value) == "table" then
				Target[Key] = DeepCopyTable(Value)
			else
				Target[Key] = Value
			end
		end
	end
end

local Config = {
	Config = table.clone(CONFIG_TEMPLATE),
}

function Config:Update(ConfigModifier: Config)
	ReconcileTable(Config, ConfigModifier)
end

return Config
