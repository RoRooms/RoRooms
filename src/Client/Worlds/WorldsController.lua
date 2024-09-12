local RoRooms = script.Parent.Parent.Parent.Parent
local Knit = require(RoRooms.Parent.Knit)
local Topbar = require(RoRooms.SourceCode.Client.UI.States.Topbar)
local UIController = require(RoRooms.SourceCode.Client.UI.UIController)

local WorldsMenu = require(RoRooms.SourceCode.Client.UI.ScreenGuis.WorldsMenu)
local WorldPageMenu = require(RoRooms.SourceCode.Client.UI.ScreenGuis.WorldPageMenu)

local WorldsController = {
	Name = "WorldsController",
}

function WorldsController:KnitStart()
	UIController = Knit.GetController("UIController")

	UIController:MountUI(WorldsMenu {})
	UIController:MountUI(WorldPageMenu {})

	Topbar:AddTopbarButton("Worlds", Topbar.NativeButtons.Worlds)
end

function WorldsController:KnitInit() end

return WorldsController
