local RoRooms = require(script.Parent.Parent.Parent.Parent)
local DataStoreService = game:GetService("DataStoreService")
local InsertService = game:GetService("InsertService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

local Shared = RoRooms.Shared

local SharedData = require(Shared.SharedData)

local WORLD_REGISTRY_UPDATE_DELAY = 60 * 60

local WorldsService = {
	Name = "WorldsService",
	Client = {},
}

function WorldsService.Client:IsWorldRegistered(_Player: Player, PlaceId: number)
	if typeof(PlaceId) ~= "number" then
		return
	end
	return WorldsService:IsWorldRegistered(PlaceId)
end

function WorldsService.Client:TeleportToWorld(Player: Player, PlaceId: number)
	if typeof(PlaceId) ~= "number" then
		return
	end
	self.Server:TeleportPlayerToWorld(Player, PlaceId)
end

function WorldsService:IsWorldRegistered(PlaceId: number)
	return self.WorldRegistry[PlaceId] ~= nil
end

function WorldsService:TeleportPlayerToWorld(Player: Player, PlaceId: number)
	if self.WorldRegistry[PlaceId] ~= nil then
		TeleportService:Teleport(PlaceId, Player)
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
