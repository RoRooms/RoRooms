local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

local RoRooms = require(script.Parent.Parent.Parent.Parent)
local WorldRegistryService = require(script.Parent.WorldRegistryService)
local ShuffleArray = require(RoRooms.Shared.ExtPackages.ShuffleArray)
local Knit = require(RoRooms.Packages.Knit)

local WorldsService = {
	Name = "WorldsService",
	Client = {
		TopWorldsInitialized = Knit.CreateSignal(),
		RandomWorldsInitialized = Knit.CreateSignal(),
	},

	TopWorlds = {},
	RandomWorlds = {},

	_TopWorldsAdvancedLastCheck = true,
	_TopWorldsPages = nil,
}

function WorldsService.Client:GetTopWorlds(_Player: Player, StartingPage: number, PageCount: number, PageSize: number)
	local Pages = {}

	for CurrentPage = StartingPage, (StartingPage + PageCount) do
		local Page = {}

		for Index = (CurrentPage * PageSize), ((CurrentPage * PageSize) + (PageCount * PageSize)) do
			local PlaceId = WorldsService.TopWorlds[Index]
			if PlaceId then
				table.insert(Page, PlaceId)
			end
		end

		if #Page >= 1 then
			table.insert(Pages, Page)
		else
			break
		end
	end

	return Pages
end

function WorldsService.Client:GetRandomWorlds(
	_Player: Player,
	StartingPage: number,
	PageCount: number,
	PageSize: number
)
	local Pages = {}

	for CurrentPage = StartingPage, (StartingPage + PageCount) do
		local Page = {}

		for Index = (CurrentPage * PageSize), (CurrentPage * PageSize) + (PageCount * PageSize) do
			local PlaceId = WorldsService.RandomWorlds[Index]
			if PlaceId then
				table.insert(Page, PlaceId)
			end
		end

		if #Page >= 1 then
			table.insert(Pages, Page)
		else
			break
		end
	end

	return Pages
end

function WorldsService.Client:TeleportToWorld(Player: Player, PlaceId: number)
	if typeof(PlaceId) ~= "number" then
		return
	end

	return self.Server:TeleportPlayerToWorld(Player, PlaceId)
end

function WorldsService:TeleportPlayerToWorld(Player: Player, PlaceId: number)
	if WorldRegistryService:IsWorldRegistered(PlaceId) then
		TeleportService:Teleport(PlaceId, Player)

		return true
	else
		return false, `World {PlaceId} not registered with RoRooms.`
	end
end

function WorldsService:_UpdateRandomWorlds(WorldRegistry: { [string]: { any } })
	local RandomWorlds = {}

	for PlaceId, _ in pairs(WorldRegistry) do
		table.insert(RandomWorlds, PlaceId)
	end

	self.RandomWorlds = ShuffleArray(RandomWorlds)

	self.Client.RandomWorldsInitialized:FireAll()
end

function WorldsService:_LogWorldTeleport(PlaceId: number)
	if WorldRegistryService:IsWorldRegistered(PlaceId) then
		self.WorldTeleportsStore:IncrementAsync(tostring(PlaceId), 1)
	end
end

function WorldsService:_SpawnTopWorldsLoadLoop()
	return task.spawn(function()
		self._TopWorldsPages = self.WorldTeleportsStore:GetSortedAsync(false, 100)

		self:_LoadCurrentTopWorldsPage()
		self:_AdvanceToNextTopWorldsPage()
		self.Client.TopWorldsInitialized:FireAll()

		while task.wait(5) do
			self:_LoadCurrentTopWorldsPage()
			self:_AdvanceToNextTopWorldsPage()
		end
	end)
end

function WorldsService:_LoadCurrentTopWorldsPage()
	local CurrentPage = self._TopWorldsPages:GetCurrentPage()

	if self._TopWorldsAdvancedLastCheck then
		for _, Entry in ipairs(CurrentPage) do
			table.insert(self.TopWorlds, tonumber(Entry.key))
		end
	end
end

function WorldsService:_AdvanceToNextTopWorldsPage()
	if self._TopWorldsPages.IsFinished then
		self._TopWorldsAdvancedLastCheck = false
	else
		self._TopWorldsPages:AdvanceToNextPageAsync()

		self._TopWorldsAdvancedLastCheck = true
	end
end

function WorldsService:KnitStart()
	self:_SpawnTopWorldsLoadLoop()

	WorldRegistryService.RegistryUpdated:Connect(function(WorldRegistry: { [string]: {} })
		self:_UpdateRandomWorlds(WorldRegistry)
	end)

	Players.PlayerAdded:Connect(function(Player)
		local JoinData = Player:GetJoinData()
		if JoinData and JoinData.SourcePlaceId then
			self:_LogWorldTeleport(JoinData.SourcePlaceId)
		end
	end)
end

function WorldsService:KnitInit()
	self.WorldTeleportsStore =
		DataStoreService:GetOrderedDataStore("RR_WorldTeleports", tostring(math.floor(os.time() / 86400)))
	self.PreviousWorldTeleportsStore =
		DataStoreService:GetOrderedDataStore("RR_WorldTeleports", tostring(math.floor(os.time() / 86400) - 1))
end

return WorldsService
