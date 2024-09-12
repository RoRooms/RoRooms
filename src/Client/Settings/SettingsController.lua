local RoRooms = script.Parent.Parent.Parent.Parent
local Knit = require(RoRooms.Parent.Knit)
local Topbar = require(RoRooms.SourceCode.Client.UI.States.Topbar)
local UIController = require(RoRooms.SourceCode.Client.UI.UIController)

local SettingsMenu = require(RoRooms.SourceCode.Client.UI.ScreenGuis.SettingsMenu)

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
