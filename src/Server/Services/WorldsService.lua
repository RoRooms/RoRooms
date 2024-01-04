local RoRooms = require(script.Parent.Parent.Parent.Parent)

local Config = RoRooms.Config
local Packages = RoRooms.Packages

local TeleportService = game:GetService("TeleportService")

local WorldsService = {
  Name = "WorldsService",
  Client = {}
}

function WorldsService.Client:TeleportToSubWorld(Player: Player, SubWorldId: string)
  if typeof(SubWorldId) ~= "string" then return end
  self.Server:TeleportPlayerToSubWorld(Player, SubWorldId)
end

function WorldsService.Client:TeleportToWorld(Player: Player, WorldId: string)
  if typeof(WorldId) ~= "string" then return end
  self.Server:TeleportPlayerToWorld(Player, WorldId)
end

function WorldsService:TeleportPlayerToSubWorld(Player: Player, SubWorldId: string)
  local SubWorld = Config.WorldsSystem.SubWorlds[SubWorldId]
  if SubWorld then
    local AbleToJoin = false
    if SubWorld.RequirementCallback then
      AbleToJoin = SubWorld.RequirementCallback(Player, SubWorldId)
    else
      AbleToJoin = true
    end
    if AbleToJoin then
      if Player then
        TeleportService:Teleport(SubWorld.PlaceId, Player)
      end
    end
  end
end

function WorldsService:TeleportPlayerToWorld(Player: Player, WorldId: string)
  local World = Config.WorldsSystem.Worlds[WorldId]
  if World then
    local AbleToJoin = false
    if World.RequirementCallback then
      AbleToJoin = World.RequirementCallback(Player, WorldId)
    else
      AbleToJoin = true
    end
    if AbleToJoin then
      if Player then
        TeleportService:Teleport(World.PlaceId, Player)
      end
    end
  end
end

function WorldsService:KnitStart()
  
end

function WorldsService:KnitInit()
  
end

return WorldsService