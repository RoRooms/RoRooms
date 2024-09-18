local RoRooms = script.Parent.Parent.Parent.Parent
local Topbar = require(RoRooms.SourceCode.Client.UI.States.Topbar)
local UIController = require(RoRooms.SourceCode.Client.UI.UIController)

local ProfilesController = {
	Name = "ProfilesController",
}

function ProfilesController:KnitStart()
	UIController:MountUI(require(RoRooms.SourceCode.Client.UI.ScreenGuis.ProfileMenu))

	Topbar:AddTopbarButton("Profile", Topbar.NativeButtons.Profile)
end

return ProfilesController
