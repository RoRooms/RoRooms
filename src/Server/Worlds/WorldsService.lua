local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

local RoRooms = require(script.Parent.Parent.Parent.Parent)
local WorldRegistryService = require(script.Parent.WorldRegistryService)
local ShuffleArray = require(RoRooms.Shared.ExtPackages.ShuffleArray)

local WorldsService = {
	Name = "WorldsService",
	Client = {},

	TopWorlds = {},
	RandomWorlds = {},
}

function WorldsService.Client:GetTopWorlds(StartingPage: number, PageCount: number, PageSize: number)
	local Pages = {}

	for CurrentPage = StartingPage, (StartingPage + PageCount) do
		local Page = {}

		for Index = (CurrentPage * PageSize), ((CurrentPage * PageSize) + (PageCount * PageSize)) do
			local PlaceId = self.TopWorlds[Index]
			if PlaceId then
				table.insert(Page, PlaceId)
			end
		end

		table.insert(Pages, Page)
	end

	return Pages
end

function WorldsService.Client:GetRandomWorlds(StartingPage: number, PageCount: number, PageSize: number)
	local Pages = {}

	for CurrentPage = StartingPage, (StartingPage + PageCount) do
		local Page = {}

		for Index = (CurrentPage * PageSize), (CurrentPage * PageSize) + (PageCount * PageSize) do
			local PlaceId = self.RandomWorlds[Index]
			if PlaceId then
				table.insert(Page, PlaceId)
			end
		end

		table.insert(Pages, Page)
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
end

function WorldsService:_LogWorldTeleport(PlaceId: number)
	if WorldRegistryService:IsWorldRegistered(PlaceId) then
		self.WorldTeleportsStore:IncrementAsync(tostring(PlaceId), 1)
	end
end

function WorldsService:_SpawnTopWorldsUpdateLoop()
	return task.spawn(function()
		local Pages = self.PreviousWorldTeleportsStore:GetSortedAsync(false, 100)
		local AdvancedLastCheck = true

		self.TopWorlds = {}

		while true do
			local CurrentPage = Pages:GetCurrentPage()

			if AdvancedLastCheck then
				for _, Entry in ipairs(CurrentPage) do
					print(Entry.value)

					table.insert(self.TopWorlds, Entry.value)
				end
			end

			if Pages.IsFinished then
				AdvancedLastCheck = false
			else
				Pages:AdvanceToNextPageAsync()

				AdvancedLastCheck = true
			end

			task.wait(5)
		end
	end)
end

function WorldsService:KnitStart()
	self:_SpawnTopWorldsUpdateLoop()

	WorldRegistryService.RegistryUpdated:Connect(function(WorldRegistry: { [string]: {} })
		self:_UpdateRandomWorlds(WorldRegistry)
	end)

	Players.PlayerAdded:Connect(function(Player)
		self:_LogWorldTeleport(Player:GetJoinData().SourcePlaceId)
	end)
end

function WorldsService:KnitInit()
	self.WorldTeleportsStore =
		DataStoreService:GetOrderedDataStore("WorldTeleports", tostring(math.floor(os.time() / 86400)))
	self.PreviousWorldTeleportsStore =
		DataStoreService:GetOrderedDataStore("WorldTeleports", tostring(math.floor(os.time() / 86400) - 1))
end

return WorldsService
