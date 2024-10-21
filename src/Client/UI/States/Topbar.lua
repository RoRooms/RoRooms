local Players = game:GetService("Players")
local Players = game:GetService("Players")

local RoRooms = script.Parent.Parent.Parent.Parent.Parent
local States = require(script.Parent)
local OnyxUI = require(RoRooms.Parent.OnyxUI)
local Fusion = require(RoRooms.Parent.Fusion)
local Assets = require(RoRooms.SourceCode.Shared.Assets)

local Peek = Fusion.peek
local Themer = OnyxUI.Themer

local Theme = Themer.Theme:now()

local Topbar = {
	Scope = Fusion.scoped(Fusion),
}

Topbar.NativeButtons = {
	Settings = {
		MenuName = "SettingsMenu",
		Icon = Assets.Icons.Topbar.Settings.Outlined,
		IconFilled = Assets.Icons.Topbar.Settings.Filled,
		LayoutOrder = 5,
		IndicatorColor = Theme.Colors.Warning.Main,
		IndicatorEnabled = Topbar.Scope:Computed(function(Use)
			return Use(States.RoRooms.UpToDate) == false
		end),
	},
	Emotes = {
		MenuName = "EmotesMenu",
		Icon = Assets.Icons.Topbar.Emotes.Outlined,
		IconFilled = Assets.Icons.Topbar.Emotes.Filled,
		LayoutOrder = 3,
	},
	Friends = {
		MenuName = "FriendsMenu",
		Icon = Assets.Icons.Topbar.Friends.Outlined,
		IconFilled = Assets.Icons.Topbar.Friends.Filled,
		LayoutOrder = 2,
	},
	Profile = {
		MenuName = "ProfileMenu",
		Icon = Assets.Icons.Topbar.Profile.Outlined,
		IconFilled = Assets.Icons.Topbar.Profile.Filled,
		LayoutOrder = 1,
		Callback = function()
			States.Menus.ProfileMenu.UserId:set(Players.LocalPlayer.UserId)
		end,
	},
	Worlds = {
		MenuName = "WorldsMenu",
		Icon = Assets.Icons.Topbar.Worlds.Outlined,
		IconFilled = Assets.Icons.Topbar.Worlds.Filled,
		LayoutOrder = 4,
	},
}

function Topbar:AddDefaultButtons()
	for Name, Button in pairs(self.NativeButtons) do
		self:AddTopbarButton(Name, Button)
	end
end

function Topbar:AddTopbarButton(
	Name: string,
	Button: {
		[string]: {
			MenuName: string,
			Icon: string,
			SizeMultiplier: number,
			LayoutOrder: number,
		},
	}
)
	local TopbarButtons = Peek(States.Topbar.Buttons)

	TopbarButtons[Name] = Button

	States.Topbar.Buttons:set(TopbarButtons)
end

function Topbar:RemoveTopbarButton(Name: string)
	local TopbarButtons = Peek(States.Topbar.Buttons)

	TopbarButtons[Name] = nil

	States.Topbar.Buttons:set(TopbarButtons)
end

return Topbar
