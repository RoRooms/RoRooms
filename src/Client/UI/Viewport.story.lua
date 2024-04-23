local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent.Parent)

local Client = RoRooms.Client
local Shared = RoRooms.Shared
local Config = RoRooms.Config

local Topbar = require(Client.UI.States.Topbar)
local OnyxUI = require(Shared.ExtPackages.OnyxUI)
local Themer = require(OnyxUI.Utils.Themer)
local Theme = require(script.Parent.OnyxUITheme)

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
			ExampleItem = {
				Name = "Item",
				Tool = Instance.new("Tool"),
				LayoutOrder = 1,
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
			ExampleEmote = {
				Name = "Emote",
				Emoji = "😼",
				Animation = Instance.new("Animation"),
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

local Viewport = function(Props)
	local ReturnedGuis = {}

	for _, GuiModule in ipairs(script.Parent.ScreenGuis:GetChildren()) do
		local GuiNameSplit = string.split(GuiModule.Name, ".")
		local FileSuffix = GuiNameSplit[2]

		if GuiModule:IsA("ModuleScript") and not FileSuffix then
			local Gui = require(GuiModule)
			table.insert(
				ReturnedGuis,
				Gui {
					Name = GuiModule.Name,
					Parent = Props.Target,
				}
			)
		end
	end

	return ReturnedGuis
end

return function(Target)
	local ViewportGuis = Viewport {
		Target = Target,
	}

	Config:Update(ROROOMS_CONFIG)

	Themer:Set(Theme)

	Topbar:AddDefaultButtons()

	return function()
		for _, Gui in ipairs(ViewportGuis) do
			Gui:Destroy()
		end
	end
end
