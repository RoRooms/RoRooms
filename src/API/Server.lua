local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local ROROOMS_SOURCE = script.Parent.SourceCode
local DEFAULT_SERVICES = {"PlayerDataService", "CharDefaultsService"}

local RoRoomsServer = {}

function RoRoomsServer:Start()
  assert(not self.Started, "RoRooms already started.")
  self.Started = true

  local Packages = script.Parent.Parent
  local Config = require(script.Parent.Config)

  local Shared = ROROOMS_SOURCE.Shared
  local Storage = ROROOMS_SOURCE.Storage
  local Server = ROROOMS_SOURCE.Server
  local Client = ROROOMS_SOURCE.Client

  local Knit = require(Packages.Knit)
  local Loader = require(Packages.Loader)
  local FindFeatureFromModule = require(Shared.SharedData.FindFeatureFromModule)

  self.Knit = Knit

  Loader.LoadDescendants(Server.Services, function(Descendant)
    if Descendant:IsA("ModuleScript") and Descendant.Name:match("Service$") ~= nil then
      local Feature = FindFeatureFromModule(Descendant)
      if table.find(DEFAULT_SERVICES, Descendant.Name) or (Feature and Config[Feature].Enabled == true) then
        return Knit.CreateService(require(Descendant))
      end
    end
  end)
  
  Knit.Start():andThen(function()
    print('RoRooms server start!')

    Loader.LoadDescendants(Server.Components, function(Descendant)
      return Descendant:IsA("ModuleScript")
    end)
  end)
end

return RoRoomsServer