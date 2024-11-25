local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local Rorooms = script.Parent.Parent.Parent.Parent
local Future = require(Rorooms.Parent.Future)
local WorldRegistryService = require(Rorooms.SourceCode.Server.Worlds.WorldRegistryService)
local Knit = require(Rorooms.Parent.Knit)
local t = require(Rorooms.Parent.t)
local GetEntriesFromArray = require(Rorooms.SourceCode.Shared.ExtPackages.GetEntriesFromArray)

type TopWorld = {
	PlaceId: number,
	Teleports: number,
}
type Page = {
	[number]: TopWorld,
}

local DATASTORE_NAME = "RR_WorldTeleports"
local PAGE_ADVANCE_DELAY = 60
local REINITIALIZATION_DELAY = 30 * 60
local ROW_SIZE = 3
local WORLD_PERSISTENCE_TIME = (((60 * 60) * 24) * 7)

local TopWorldsService = {
	Name = script.Name,
	Client = {
		TopWorldsInitialized = Knit.CreateSignal(),
	},

	TopWorlds = {},
	TeleportsStore = DataStoreService:GetOrderedDataStore(
		DATASTORE_NAME,
		tostring(math.floor(os.time() / WORLD_PERSISTENCE_TIME))
	),
	LastWeekTeleportsStore = DataStoreService:GetOrderedDataStore(
		DATASTORE_NAME,
		tostring(math.floor(os.time() / WORLD_PERSISTENCE_TIME) - 1)
	),
}

function TopWorldsService.Client:GetTopWorlds(Player: Player, StartIndex: number, EndIndex: number)
	assert(t.tuple(t.instanceOf("Player")(Player), t.number(StartIndex), t.number(EndIndex)))

	return TopWorldsService:GetTopWorlds(StartIndex, EndIndex)
end

function TopWorldsService:GetTopWorlds(StartIndex: number, EndIndex: number)
	return GetEntriesFromArray(TopWorldsService.TopWorlds, StartIndex, EndIndex)
end

function TopWorldsService:_SpawnInitializationLoop()
	return task.spawn(function()
		while true do
			local Success, Result = Future.Try(function()
				self:_ClearTopWorlds()
				self:_SpawnUpdateLoop()
				self:_SpawnLastWeekUpdateLoop()
			end)
			if not Success then
				warn(Result)
			end

			task.wait(REINITIALIZATION_DELAY)
		end
	end)
end

function TopWorldsService:_SpawnUpdateLoop()
	if self.UpdateLoop then
		task.cancel(self.UpdateLoop)
		self.UpdateLoop = nil
	end

	self.UpdateLoop = task.spawn(function()
		local Pages = self.TeleportsStore:GetSortedAsync(false, 100)
		local AdvancedLastCheck = true

		self:_LoadPage(Pages:GetCurrentPage())
		AdvancedLastCheck = self:_AdvanceToNextPage(Pages)

		self.Client.TopWorldsInitialized:FireAll(self:GetTopWorlds(0, 10 * ROW_SIZE))

		while task.wait(PAGE_ADVANCE_DELAY) do
			if AdvancedLastCheck then
				self:_LoadPage(Pages:GetCurrentPage())
			end
			AdvancedLastCheck = self:_AdvanceToNextPage(Pages)
		end
	end)
end

function TopWorldsService:_SpawnLastWeekUpdateLoop()
	if self.LastWeekUpdateLoop then
		task.cancel(self.LastWeekUpdateLoop)
		self.LastWeekUpdateLoop = nil
	end

	self.LastWeekUpdateLoop = task.spawn(function()
		local LastWeekPages = self.LastWeekTeleportsStore:GetSortedAsync(false, 100)
		local AdvancedLastCheck = true

		self:_LoadPage(LastWeekPages:GetCurrentPage())
		AdvancedLastCheck = self:_AdvanceToNextPage(LastWeekPages)

		while task.wait(PAGE_ADVANCE_DELAY) do
			if AdvancedLastCheck then
				self:_LoadPage(LastWeekPages:GetCurrentPage())
			end
			AdvancedLastCheck = self:_AdvanceToNextPage(LastWeekPages)
		end
	end)
end

function TopWorldsService:_FindEntryFromPlaceId(PlaceId: number)
	for _, TopWorld: TopWorld in ipairs(self.TopWorlds) do
		if TopWorld.PlaceId == PlaceId then
			return TopWorld
		end
	end

	return nil
end

function TopWorldsService:_LoadPage(Page: Page)
	for _, Entry in ipairs(Page) do
		local PlaceId = tonumber(Entry.key)
		local Teleports = tonumber(Entry.value)

		local ExistingEntry = self:_FindEntryFromPlaceId(PlaceId)
		if ExistingEntry then
			ExistingEntry.Teleports += Teleports
		else
			local World = WorldRegistryService:GetWorldDetails(PlaceId)
			if (World ~= nil) and not (World.delisted or World.forceDelisted) then
				table.insert(self.TopWorlds, {
					PlaceId = PlaceId,
					Teleports = Teleports,
				})
			end
		end
	end
end

function TopWorldsService:_AdvanceToNextPage(Pages: DataStorePages)
	if Pages.IsFinished then
		return false
	else
		local Success, Result = Future.Try(function()
			return Pages:AdvanceToNextPageAsync()
		end):Await()
		if not Success then
			warn(Result)
		end

		return Success, Result
	end
end

function TopWorldsService:_ClearTopWorlds()
	self.TopWorlds = {}
end

function TopWorldsService:_LogIncomingTeleport(PlaceId: number)
	if WorldRegistryService:IsWorldRegistered(PlaceId) then
		local Success, Result = Future.Try(function()
			return self.TeleportsStore:IncrementAsync(tostring(PlaceId), 1)
		end):Await()
		if not Success then
			warn(Result)
		end

		return Success, Result
	else
		return false
	end
end

function TopWorldsService:KnitStart()
	Players.PlayerAdded:Connect(function(Player)
		local JoinData = Player:GetJoinData()
		if JoinData and JoinData.SourcePlaceId then
			self:_LogIncomingTeleport(JoinData.SourcePlaceId)
		end
	end)
end

WorldRegistryService.RegistryUpdated:Once(function()
	TopWorldsService._InitializationLoop = TopWorldsService:_SpawnInitializationLoop()
end)

return TopWorldsService
