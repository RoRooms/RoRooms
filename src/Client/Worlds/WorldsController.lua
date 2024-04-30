local RoRooms = require(script.Parent.Parent.Parent.Parent)
local Knit = require(RoRooms.Packages.Knit)
local Topbar = require(RoRooms.Client.UI.States.Topbar)
local UIController = require(RoRooms.Client.UI.UIController)

local WorldsMenu = require(RoRooms.Client.UI.ScreenGuis.WorldsMenu)
local WorldPageMenu = require(RoRooms.Client.UI.ScreenGuis.WorldPageMenu)

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
