local RoRooms = require(game:GetService("ReplicatedStorage").RoRooms)

local Shared = RoRooms.Shared
local Client = RoRooms.Client
local Packages = RoRooms.Packages

local Knit = require(Packages.Knit)

local ProfileMenu = require(Client.UI.ScreenGuis.ProfileMenu)

local UIController = require(Client.Controllers.UIController)

local UserProfileController = {
  Name = "UserProfileController"
}

function UserProfileController:KnitStart()
  UIController = Knit.GetController("UIController")

  UIController:MountUI(ProfileMenu {})
end

function UserProfileController:KnitInit()
  
end

return UserProfileController