local CONFIG_TEMPLATE = {
	ProfilesSystem = {
		Enabled = true,
		AvatarEditorCallback = nil,
	},
	ItemsSystem = {
		Enabled = true,
		MaxItemsEquippable = 5,
		Categories = {
			-- "General",
		},
		Items = {
			-- ExampleItem = {
			-- 	Name = "Example Item",
			-- 	Categories = {"All"},
			-- 	Tool = Instance.new("Tool"),
			-- 	LevelRequirement = 100,
			-- 	PriceInCoins = 10,
			-- 	LabelIcon = "rbxassetid://5743022869",
			-- 	TintColor = Color3.fromRGB(255, 255, 255),
			-- 	LayoutOrder = 1,
			-- 	RequirementCallback = function(Player, ItemId)

			-- 	end,
			-- }
		},
	},
	EmotesSystem = {
		Enabled = true,
		EmotesDirectory = nil,
		Categories = {
			-- "General",
		},
		Emotes = {
			-- ExampleEmote = {
			-- 	Name = "Example Emote",
			-- 	Emoji = "😼",
			-- 	Animation = Instance.new("Animation"),
			-- 	LevelRequirement = 100,
			-- 	PriceInCoins = 10,
			-- 	LabelIcon = "rbxassetid://5743022869",
			-- 	TintColor = Color3.fromRGB(255, 255, 255),
			-- 	LayoutOrder = 1,
			-- 	RequirementCallback = function(Player, WorldId)

			-- 	end,
			-- }
		},
	},
	MusicSystem = {
		Enabled = true,
		SoundGroup = nil,
	},
	WorldsSystem = {
		Enabled = true,
		VCServersEnabled = true,
	},
	FriendsSystem = {
		Enabled = true,
	},
	ProgressionSystem = {
		FriendsXPMultiplier = {
			Enabled = true,
			MultiplierAddon = 0.5,
		},
	},
	SettingsSystem = {
		Enabled = true,
	},
	Interface = {},
	VRSystem = {
		Enabled = true,
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
		if type(Key) == "string" then
			if Target[Key] == nil then
				if type(Value) == "table" then
					Target[Key] = DeepCopyTable(Value)
				else
					Target[Key] = Value
				end
			elseif type(Target[Key]) == "table" and type(Value) == "table" then
				ReconcileTable(Target[Key], Value)
			end
		end
	end
end

local Config = table.clone(CONFIG_TEMPLATE)

function Config:Update(ConfigModifier)
	ReconcileTable(Config, ConfigModifier)
end

return Config
