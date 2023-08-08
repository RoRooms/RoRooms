local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayerScripts = game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")

local DEFAULT_CONTROLLERS = {"UIController"}

local RoRoomsClient = {}

function RoRoomsClient:Start()
  assert(not self.Started, "RoRooms already started.")
  self.Started = true

  local Shared = ReplicatedStorage:WaitForChild("RoRoomsCode", 10)
  local Client = StarterPlayerScripts:WaitForChild("RoRoomsCode", 10)
  local Config = require(script.Parent.Config)

  self.Shared = Shared
  self.Client = Client

  local Knit = require(Shared.Packages.Knit)
  local Loader = require(Shared.Packages.Loader)
  local FindFeatureFromModule = require(Shared.SharedData.FindFeatureFromModule)
  
  self.Knit = Knit

  Loader.LoadDescendants(Client.Controllers, function(Descendant)
    if Descendant.Name:match("Controller$") ~= nil then
      local Feature = FindFeatureFromModule(Descendant)
      if table.find(DEFAULT_CONTROLLERS, Descendant.Name) or (Feature and Config[Feature].Enabled == true) then
        return Descendant
      end
    end
  end)
  
  Knit.Start():andThen(function()
    print('RoRooms client start!')

    Loader.LoadDescendants(Client.Components, function(Descendant)
      return Descendant:IsA("ModuleScript")
    end)
  end)
end

return RoRoomsClient