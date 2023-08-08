local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local StarterPlayerScripts = game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")

local ROROOMS_SOURCE = ServerStorage:FindFirstChild("RoRoomsSource")
local DIRECTORY_LOAD_ORDER = {"Shared", "Storage", "Server", "Client"}
local TARGET_DIRECTORY_MAP = {
  Shared = ReplicatedStorage,
  Storage = ServerStorage,
  Server = ServerScriptService,
  Client = StarterPlayerScripts,
}
local DEFAULT_SERVICES = {"PlayerDataService", "CharDefaultsService"}

local RoRoomsServer = {}

function RoRoomsServer:Start()
  assert(not self.Started, "RoRooms already started.")
  self.Started = true
  
  self:_InstallDirectories()

  local Shared = ReplicatedStorage.RoRoomsCode
  local Storage = ServerStorage.RoRoomsCode
  local Server = ServerScriptService.RoRoomsCode
  local Client = StarterPlayerScripts.RoRoomsCode
  local Config = require(script.Parent.Config)

  self.Shared = Shared
  self.Storage = Storage
  self.Server = Server
  self.Client = Client

  local Knit = require(Shared.Packages.Knit)
  local Loader = require(Shared.Packages.Loader)
  local FindFeatureFromModule = require(Shared.SharedData.FindFeatureFromModule)

  self.Knit = Knit

  Loader.LoadDescendants(Server.Services, function(Descendant)
    if Descendant.Name:match("Service$") ~= nil then
      local Feature = FindFeatureFromModule(Descendant)
      if table.find(DEFAULT_SERVICES, Descendant.Name) or (Feature and Config[Feature].Enabled == true) then
        return Descendant
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

function RoRoomsServer:_InstallDirectories()
  for _, DirectoryName in ipairs(DIRECTORY_LOAD_ORDER) do
    local Directory = ROROOMS_SOURCE:FindFirstChild(DirectoryName)
    local TargetDirectory = TARGET_DIRECTORY_MAP[DirectoryName]
    
    assert(Directory, " directory "..DirectoryName.." not found")
    assert(TargetDirectory, "Invalid target directory for "..DirectoryName)

    Directory.Name = "RoRoomsCode"
    Directory.Parent = TargetDirectory
  end
  ROROOMS_SOURCE:Destroy()
end

function RoRoomsServer:_EnableScripts(Directories)
  for _, Directory in ipairs(Directories) do
    for _, Child in ipairs(Directory:GetDescendants()) do
        if Child:IsA("Script") or Child:IsA("LocalScript") then
            Child.Disabled = false
        end
    end
  end
end

return RoRoomsServer