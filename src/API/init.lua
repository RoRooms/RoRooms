local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local Config = require(script.Config)
local Packages = script.Parent

local RoRooms = {
  Config = Config,
  Packages = Packages,
}

local function InstallRealmAPI(Realm: table)
  for Key, Value in pairs(Realm) do
    RoRooms[Key] = Value
  end
end

if RoRoomsSource then
  RoRooms.Shared = script.Shared
  RoRooms.Storage = script.Storage
  RoRooms.Server = script.Server
  RoRooms.Client = script.Client
end

if RunService:IsServer() then
  InstallRealmAPI(require(script.Server))
else
  InstallRealmAPI(require(script.Client))
end

return RoRooms