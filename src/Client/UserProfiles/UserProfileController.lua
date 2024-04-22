local RoRooms = require(script.Parent.Parent.Parent.Parent)

local Client = RoRooms.Client
local Packages = RoRooms.Packages

local Knit = require(Packages.Knit)
local Topbar = require(Client.UI.States.Topbar)

local ProfileMenu = require(Client.UI.ScreenGuis.ProfileMenu)

local UIController = require(Client.UI.UIController)

local UserProfileController = {
	Name = "UserProfileController",
}

function UserProfileController:KnitStart()
	UIController = Knit.GetController("UIController")

	UIController:MountUI(ProfileMenu {})

	Topbar:AddTopbarButton("Profile", {
		MenuName = "ProfileMenu",
		IconImage = "rbxassetid://15091717235",
		LayoutOrder = 1,
	})
end

function UserProfileController:KnitInit() end

return UserProfileController
