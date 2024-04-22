local RoRooms = require(script.Parent.Parent.Parent.Parent)

local Client = RoRooms.Client
local Packages = RoRooms.Packages

local Knit = require(Packages.Knit)
local Topbar = require(Client.UI.States.Topbar)

local SettingsMenu = require(Client.UI.ScreenGuis.SettingsMenu)

local UIController = require(Client.UI.UIController)

local SettingsController = {
	Name = "SettingsController",
}

function SettingsController:KnitStart()
	UIController = Knit.GetController("UIController")

	UIController:MountUI(SettingsMenu {})

	Topbar:AddTopbarButton("Settings", {
		MenuName = "SettingsMenu",
		IconImage = "rbxassetid://15091717549",
		LayoutOrder = 5,
	})
end

function SettingsController:KnitInit() end

return SettingsController
