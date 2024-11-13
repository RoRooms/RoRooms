local Rorooms = script.Parent.Parent.Parent.Parent
local Knit = require(Rorooms.Parent.Knit)
local Topbar = require(Rorooms.SourceCode.Client.UI.States.Topbar)
local UIController = require(Rorooms.SourceCode.Client.UI.UIController)

local SettingsMenu = require(Rorooms.SourceCode.Client.UI.ScreenGuis.SettingsMenu)

local SettingsController = {
	Name = "SettingsController",
}

function SettingsController:KnitStart()
	UIController = Knit.GetController("UIController")

	UIController:MountUI(SettingsMenu)

	Topbar:AddTopbarButton("Settings", Topbar.NativeButtons.Settings)
end

return SettingsController
