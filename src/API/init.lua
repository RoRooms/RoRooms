local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local RoRoomsSource = script.Parent

local Config = require(script.Config)
local ServerAPI = require(script.Server)
local ClientAPI = require(script.Client)
local Packages = script.Parent.Parent

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
  RoRooms.Shared = RoRoomsSource.Shared
  RoRooms.Storage = RoRoomsSource.Storage
  RoRooms.Server = RoRoomsSource.Server
  RoRooms.Client = RoRoomsSource.Client
end

if RunService:IsServer() then
  InstallRealmAPI(ServerAPI)
else
  InstallRealmAPI(ClientAPI)
end

return RoRooms