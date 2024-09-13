local RoRooms = script.Parent.Parent.Parent.Parent
local Knit = require(RoRooms.Parent.Knit)
local Topbar = require(RoRooms.SourceCode.Client.UI.States.Topbar)
local UIController = require(RoRooms.SourceCode.Client.UI.UIController)

local ProfileMenu = require(RoRooms.SourceCode.Client.UI.ScreenGuis.ProfileMenu)

local UserProfileController = {
	Name = "UserProfileController",
}

function UserProfileController:KnitStart()
	UIController = Knit.GetController("UIController")

	UIController:MountUI(ProfileMenu)

	Topbar:AddTopbarButton("Profile", Topbar.NativeButtons.Profile)
end

function UserProfileController:KnitInit() end

return UserProfileController
