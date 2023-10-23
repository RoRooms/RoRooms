local RoRooms = require(game:GetService("ReplicatedStorage").RoRooms)

local Shared = RoRooms.Shared
local Client = RoRooms.Client

local Knit = require(Shared.Packages.Knit)

local WorldsMenu = require(Client.UI.ScreenGuis.WorldsMenu)

local UIController = require(Client.Controllers.UIController)

local WorldsController = {
  Name = "WorldsController"
}

function WorldsController:KnitStart()
  UIController = Knit.GetController("UIController")

  UIController:MountUI(WorldsMenu {})
end

function WorldsController:KnitInit()
  
end

return WorldsController