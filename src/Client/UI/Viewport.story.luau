local Rorooms = script.Parent.Parent.Parent.Parent
local Topbar = require(Rorooms.SourceCode.Client.UI.States.Topbar)
local Theme = require(script.Parent.OnyxUITheme)
local OnyxUI = require(Rorooms.Parent.OnyxUI)
local Config = require(Rorooms.Config)
local Fusion = require(Rorooms.Parent.Fusion)
local Assets = require(Rorooms.SourceCode.Shared.Assets)

local Themer = OnyxUI.Themer

local ROROOMS_CONFIG = {
	Systems = {
		Items = {
			Categories = {
				General = {
					LayoutOrder = 1,
					Icon = Assets.Icons.Categories.General,
				},
				Unlockable = {
					LayoutOrder = 2,
					Icon = Assets.Icons.Categories.Unlockable,
				},
				Robux = {
					LayoutOrder = 3,
					Icon = Assets.Icons.Categories.Robux,
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
		Emotes = {
			Categories = {
				General = {
					LayoutOrder = 1,
					Icon = Assets.Icons.Categories.General,
				},
				Unlockable = {
					LayoutOrder = 2,
					Icon = Assets.Icons.Categories.Unlockable,
				},
				Robux = {
					LayoutOrder = 3,
					Icon = Assets.Icons.Categories.Robux,
				},
			},
			Emotes = {
				Emote1 = {
					Name = "Emote Test",
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
					LevelRequirement = 100,
				},
				Emote7 = {
					Name = "Emote",
					Emoji = "⭐",
					Animation = Instance.new("Animation"),
					Category = "Unlockable",
					LevelRequirement = 100,
				},
				Emote8 = {
					Name = "Emote",
					Emoji = "🛍️",
					Animation = Instance.new("Animation"),
					Category = "Unlockable",
					LevelRequirement = 100,
				},
			},
		},
		Worlds = {
			FeaturedWorlds = {
				8310127828,
				4960160668,
				9298624201,
			},
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
