local RoRooms = require(script.Parent.Parent.Parent.Parent)
local DataStoreService = game:GetService("DataStoreService")
local InsertService = game:GetService("InsertService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

local Shared = RoRooms.Shared

local SharedData = require(Shared.SharedData)
local ShuffleArray = require(Shared.ExtPackages.ShuffleArray)

local WORLD_REGISTRY_UPDATE_DELAY = 10 * 60

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

function WorldsService:GetWorlds(CurrentPage: number, PageSize: number)
	local Results = {}

	local TopWorldsPageCount = math.ceil(#self.TopWorlds / PageSize)
	if TopWorldsPageCount == 0 then
		TopWorldsPageCount = 1
	end

	if CurrentPage >= TopWorldsPageCount then
		local PagesPastTopWorlds = CurrentPage - TopWorldsPageCount
		local CurrentRandomWorldsIndex = PagesPastTopWorlds * PageSize

		for Index = CurrentRandomWorldsIndex, CurrentRandomWorldsIndex + PageSize do
			table.insert(Results, self.RandomWorldsIndex[Index])
		end
	else
		local CurrentTopWorldsIndex = CurrentPage * PageSize

		for Index = CurrentTopWorldsIndex, CurrentTopWorldsIndex + PageSize do
			table.insert(Results, self.TopWorlds[Index])
		end
	end

	return Results
end

function WorldsService:GetRandomUnchosenWorld()
	for _, PlaceId in ipairs(self.RandomWorldsIndex) do
		if table.find(self.Worlds, PlaceId) == nil then
			return PlaceId
		end
	end
end

function WorldsService:StartTopWorldsUpdateLoop()
	return task.spawn(function()
		local Pages = self.PreviousWorldTeleportsStore:GetSortedAsync(false, 100)
		local AdvancedLastRun = true

		self.TopWorlds = {}

		while true do
			local CurrentPage = Pages:GetCurrentPage()

			if AdvancedLastRun then
				for _, Entry in ipairs(CurrentPage) do
					table.insert(self.TopWorlds, Entry.value)
				end
			end

			if Pages.IsFinished then
				AdvancedLastRun = false
			else
				Pages:AdvanceToNextPageAsync()
				AdvancedLastRun = true
			end

			task.wait(5)
		end
	end)
end

function WorldsService:IsWorldRegistered(PlaceId: number)
	return self.WorldRegistry[PlaceId] ~= nil
end

function WorldsService:TeleportPlayerToWorld(Player: Player, PlaceId: number)
	if self.WorldRegistry[PlaceId] ~= nil then
		TeleportService:Teleport(PlaceId, Player)
	end
end

function WorldsService:UpdateRandomWorldsIndex()
	local RandomWorlds = {}
	for PlaceId, _ in pairs(self.WorldRegistry) do
		table.insert(RandomWorlds, PlaceId)
	end
	ShuffleArray(RandomWorlds)
	self.RandomWorldsIndex = RandomWorlds
end

function WorldsService:UpdateWorldRegistry()
	local function GetRegistryUpdateStamp()
		local Success, Result = pcall(function()
			return MarketplaceService:GetProductInfo(SharedData.WorldRegistryAssetId).Updated
		end)
		if Success then
			return Result
		else
			warn(Result)
		end
	end

	local function GetRegistryModule()
		local Success, Result = pcall(function()
			return InsertService:LoadAsset(SharedData.WorldRegistryAssetId):GetChildren()[1]
		end)
		if Success then
			return Result
		else
			warn(Result)
		end
	end

	local UpdateStamp = GetRegistryUpdateStamp()
	if UpdateStamp ~= self.LastWorldRegistryUpdateStamp then
		self.WorldRegistry = require(GetRegistryModule())
		self.LastWorldRegistryUpdateStamp = UpdateStamp

		self:UpdateRandomWorldsIndex()
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
	task.delay(3, function()
		print(self:GetWorlds(1, 40))
	end)

	self:StartWorldRegistryUpdateLoop()

	self:StartTopWorldsUpdateLoop()

	Players.PlayerAdded:Connect(function(Player)
		local JoinData = Player:GetJoinData()
		if self.WorldRegistry[JoinData.SourcePlaceId] then
			self.WorldTeleportsStore:IncrementAsync(tostring(JoinData.SourcePlaceId), 1)
		end
	end)
end

function WorldsService:KnitInit()
	self.WorldRegistry = {}
	self.RandomWorldsIndex = {}
	self.LastWorldRegistryUpdateStamp = nil

	self.Worlds = {}
	self.TopWorlds = {}

	self.WorldTeleportsStore =
		DataStoreService:GetOrderedDataStore("WorldTeleports", tostring(math.floor(os.time() / 86400)))
	self.PreviousWorldTeleportsStore =
		DataStoreService:GetOrderedDataStore("WorldTeleports", tostring(math.floor(os.time() / 86400) - 1))

	self.WorldTeleportsPages = nil
	self.WorldTeleportsLastUpdated = nil
end

return WorldsService
