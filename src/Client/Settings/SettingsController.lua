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

	Topbar:AddTopbarButton(Topbar.NativeButtons.Settings)
end

function SettingsController:KnitInit() end

return SettingsController
