local RoRooms = require(game:GetService("ReplicatedStorage").RoRooms)

local Shared = RoRooms.Shared
local Client = RoRooms.Client

local Knit = require(Shared.Packages.Knit)

local SettingsMenu = require(Client.UI.ScreenGuis.SettingsMenu)

local UIController

local SettingsController = Knit.CreateController {
  Name = "SettingsController"
}

function SettingsController:KnitStart()
  UIController = Knit.GetController("UIController")

  UIController:MountUI(SettingsMenu {})
end

function SettingsController:KnitInit()
  
end

return SettingsController