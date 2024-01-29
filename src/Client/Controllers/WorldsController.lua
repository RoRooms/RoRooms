local RoRooms = require(script.Parent.Parent.Parent.Parent)

local Client = RoRooms.Client
local Packages = RoRooms.Packages

local Knit = require(Packages.Knit)

local WorldsMenu = require(Client.UI.ScreenGuis.WorldsMenu)
local WorldPageMenu = require(Client.UI.ScreenGuis.WorldPageMenu)

local UIController = require(Client.Controllers.UIController)

local WorldsController = {
	Name = "WorldsController",
}

function WorldsController:KnitStart()
	UIController = Knit.GetController("UIController")

	UIController:MountUI(WorldsMenu {})
	UIController:MountUI(WorldPageMenu {})
end

function WorldsController:KnitInit() end

return WorldsController
