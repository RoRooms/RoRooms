local RoRooms = require(script.Parent.Parent.Parent.Parent)
local DataStoreService = game:GetService("DataStoreService")
local InsertService = game:GetService("InsertService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

local Config = RoRooms.Config
local Shared = RoRooms.Shared

local SharedData = require(Shared.SharedData)

local WORLD_REGISTRY_UPDATE_DELAY = 60 * 60

local WorldsService = {
	Name = "WorldsService",
	Client = {},
}

function WorldsService.Client:TeleportToSubWorld(Player: Player, SubWorldId: string)
	if typeof(SubWorldId) ~= "string" then
		return
	end
	self.Server:TeleportPlayerToSubWorld(Player, SubWorldId)
end

function WorldsService.Client:TeleportToWorld(Player: Player, WorldId: string)
	if typeof(WorldId) ~= "string" then
		return
	end
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

function WorldsService:UpdateWorldRegistry()
	local Success, Result = pcall(function()
		return require(InsertService:LoadAsset(SharedData.WorldRegistryAssetId):GetChildren()[1])
	end)
	if Success then
		self.WorldRegistry = Result
	else
		warn(Result)
	end
end

function WorldsService:StartWorldRegistryUpdateLoop()
	task.spawn(function()
		while true do
			self:UpdateWorldRegistry()
			task.wait(WORLD_REGISTRY_UPDATE_DELAY)
		end
	end)
end

function WorldsService:KnitStart()
	self:StartWorldRegistryUpdateLoop()

	Players.PlayerAdded:Connect(function(Player)
		local JoinData = Player:GetJoinData()
		if self.WorldRegistry[JoinData.SourcePlaceId] then
			self.WorldTeleportsStore:IncrementAsync(tostring(JoinData.SourcePlaceId), 1)
		end
	end)
end

function WorldsService:KnitInit()
	self.WorldRegistry = {}

	self.WorldTeleportsStore =
		DataStoreService:GetOrderedDataStore("WorldTeleports", tostring(math.floor(os.time() / 86400)))
	self.PreviousWorldTeleportsStore =
		DataStoreService:GetOrderedDataStore("WorldTeleports", tostring(math.floor(os.time() / 86400) - 1))
end

return WorldsService
