local RoRooms = require(script.Parent.Parent.Parent.Parent)
local Knit = require(RoRooms.Packages.Knit)
local Topbar = require(RoRooms.Client.UI.States.Topbar)
local UIController = require(RoRooms.Client.UI.UIController)

local SettingsMenu = require(RoRooms.Client.UI.ScreenGuis.SettingsMenu)

local SettingsController = {
	Name = "SettingsController",
}

function SettingsController:KnitStart()
	UIController = Knit.GetController("UIController")

	UIController:MountUI(SettingsMenu {})

	Topbar:AddTopbarButton("Settings", Topbar.NativeButtons.Settings)
end

function SettingsController:KnitInit() end

return SettingsController
