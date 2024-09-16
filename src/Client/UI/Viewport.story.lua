local RoRooms = script.Parent.Parent.Parent.Parent
local Topbar = require(RoRooms.SourceCode.Client.UI.States.Topbar)
local Theme = require(script.Parent.OnyxUITheme)
local OnyxUI = require(RoRooms.Parent.OnyxUI)
local Config = require(RoRooms.Config).Config
local Fusion = require(RoRooms.Parent.Fusion)

local Themer = OnyxUI.Themer

local ROROOMS_CONFIG = {
	ItemsSystem = {
		Categories = {
			General = {
				LayoutOrder = 1,
				Icon = "rbxassetid://12988755627",
			},
			Unlockable = {
				LayoutOrder = 2,
				Icon = "rbxassetid://5743022869",
			},
			Robux = {
				LayoutOrder = 3,
				Icon = "rbxassetid://7058763764",
			},
		},
		Items = {
			Item1 = {
				Name = "Bloxy Cola",
				Tool = Instance.new("Tool"),
			},
			Item2 = {
				Name = "Camera",
				Tool = Instance.new("Tool"),
			},
			Item3 = {
				Name = "Flash Light",
				Tool = Instance.new("Tool"),
			},
			Item4 = {
				Name = "Frog",
				Tool = Instance.new("Tool"),
			},
			Item5 = {
				Name = "Sharky",
				Tool = Instance.new("Tool"),
			},
			Item6 = {
				Name = "Sword",
				Tool = Instance.new("Tool"),
			},
			Item7 = {
				Name = "Test",
				Tool = Instance.new("Tool"),
				Category = "Unlockable",
				LevelRequirement = 55,
			},
			Item8 = {
				Name = "Blabla",
				Tool = Instance.new("Tool"),
				Category = "Unlockable",
				LevelRequirement = 100,
			},
		},
	},
	EmotesSystem = {
		Categories = {
			General = {
				LayoutOrder = 1,
				Icon = "rbxassetid://12988755627",
			},
			Unlockable = {
				LayoutOrder = 2,
				Icon = "rbxassetid://5743022869",
			},
			Robux = {
				LayoutOrder = 3,
				Icon = "rbxassetid://7058763764",
			},
		},
		Emotes = {
			Emote1 = {
				Name = "Emote",
				Emoji = "😼",
				Animation = Instance.new("Animation"),
			},
			Emote2 = {
				Name = "Emote",
				Emoji = "🤞",
				Animation = Instance.new("Animation"),
			},
			Emote3 = {
				Name = "Emote",
				Emoji = "💖",
				Animation = Instance.new("Animation"),
			},
			Emote4 = {
				Name = "Emote Gaga",
				Emoji = "⭐",
				Animation = Instance.new("Animation"),
			},
			Emote5 = {
				Name = "Emote",
				Emoji = "🛍️",
				Animation = Instance.new("Animation"),
			},
			Emote6 = {
				Name = "Emote",
				Emoji = "💖",
				Animation = Instance.new("Animation"),
				Category = "Unlockable",
			},
			Emote7 = {
				Name = "Emote",
				Emoji = "⭐",
				Animation = Instance.new("Animation"),
				Category = "Unlockable",
			},
			Emote8 = {
				Name = "Emote",
				Emoji = "🛍️",
				Animation = Instance.new("Animation"),
				Category = "Unlockable",
			},
		},
	},
	WorldsSystem = {
		FeaturedWorlds = {
			8310127828,
			4960160668,
			9298624201,
		},
	},
}

local Viewport = function(Scope: Fusion.Scope<any>, Props)
	local ReturnedGuis = {}

	for _, GuiModule in ipairs(script.Parent.ScreenGuis:GetChildren()) do
		local GuiNameSplit = string.split(GuiModule.Name, ".")
		local FileSuffix = GuiNameSplit[2]

		if GuiModule:IsA("ModuleScript") and not FileSuffix then
			local Gui = require(GuiModule)
			table.insert(
				ReturnedGuis,
				Gui(Scope, {
					Name = GuiModule.Name,
					Parent = Props.Target,
				})
			)
		end
	end

	return ReturnedGuis
end

return function(Target)
	local Scope = Fusion.scoped(Fusion, {
		Viewport = Viewport,
	})

	Themer.Theme:is(Theme):during(function()
		Scope:Viewport {
			Target = Target,
		}
	end)

	Config:Update(ROROOMS_CONFIG)

	Topbar:AddDefaultButtons()

	return function()
		Scope:doCleanup()
	end
end
