local RoRooms = script.Parent.Parent.Parent.Parent
local Knit = require(RoRooms.Parent.Knit)
local Topbar = require(RoRooms.SourceCode.Client.UI.States.Topbar)
local UIController = require(RoRooms.SourceCode.Client.UI.UIController)

local WorldsController = {
	Name = "WorldsController",
}

function WorldsController:KnitStart()
	UIController = Knit.GetController("UIController")

	UIController:MountUI(require(RoRooms.SourceCode.Client.UI.ScreenGuis.WorldsMenu))
	UIController:MountUI(require(RoRooms.SourceCode.Client.UI.ScreenGuis.WorldPageMenu))

	Topbar:AddTopbarButton("Worlds", Topbar.NativeButtons.Worlds)
end

return WorldsController
