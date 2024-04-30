local RoRooms = require(script.Parent.Parent.Parent.Parent)
local Knit = require(RoRooms.Packages.Knit)
local Topbar = require(RoRooms.Client.UI.States.Topbar)
local UIController = require(RoRooms.Client.UI.UIController)

local ProfileMenu = require(RoRooms.Client.UI.ScreenGuis.ProfileMenu)

local UserProfileController = {
	Name = "UserProfileController",
}

function UserProfileController:KnitStart()
	UIController = Knit.GetController("UIController")

	UIController:MountUI(ProfileMenu {})

	Topbar:AddTopbarButton("Profile", Topbar.NativeButtons.Profile)
end

function UserProfileController:KnitInit() end

return UserProfileController
