local ROROOMS_SOURCE = script.Parent.SourceCode
local DEFAULT_CONTROLLERS = {"UIController", "BloxstrapController"}

local RoRoomsClient = {}

function RoRoomsClient:Start()
  assert(not self.Started, "RoRooms already started.")
  self.Started = true

  local Config = require(script.Parent.Config)
  local Packages = script.Parent.Parent

  local Shared = ROROOMS_SOURCE.Shared
  local Client = ROROOMS_SOURCE.Client

  local Knit = require(Packages.Knit)
  local Loader = require(Packages.Loader)
  local FindFeatureFromModule = require(Shared.SharedData.FindFeatureFromModule)
  
  self.Knit = Knit

  Loader.LoadDescendants(Client.Controllers, function(Descendant)
    if Descendant:IsA("ModuleScript") and Descendant.Name:match("Controller$") ~= nil then
      local Feature = FindFeatureFromModule(Descendant)
      if table.find(DEFAULT_CONTROLLERS, Descendant.Name) or (Feature and Config[Feature].Enabled == true) then
        return Knit.CreateController(require(Descendant))
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