local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent.Parent)
local WorldRegistryService = require(RoRooms.Server.Worlds.WorldRegistryService)
local Knit = require(RoRooms.Packages.Knit)
local GetPagesFromArray = require(RoRooms.Shared.ExtPackages.GetPagesFromArray)
local t = require(RoRooms.Packages.t)

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

local TopWorldsService = {
	Name = script.Name,
	Client = {
		TopWorldsInitialized = Knit.CreateSignal(),
	},

	TopWorlds = {},
}

function TopWorldsService.Client:GetTopWorlds(Player: Player, StartingPage: number, PageCount: number, PageSize: number)
	assert(t.tuple(t.instanceOf("Player")(Player), t.number(StartingPage), t.number(PageCount), t.number(PageSize)))

	return GetPagesFromArray(TopWorldsService.TopWorlds, StartingPage, PageCount, PageSize)
end

function TopWorldsService:_SpawnInitializationLoop()
	return task.spawn(function()
		while true do
			self:_ClearTopWorlds()
			self:_SpawnUpdateLoop()
			self:_SpawnLastWeekUpdateLoop()

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

		self.Client.TopWorldsInitialized:FireAll()

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
		local ExistingEntry = self:_FindEntryFromPlaceId(Entry.PlaceId)
		if ExistingEntry then
			ExistingEntry.Teleports += Entry.value
		else
			table.insert(self.TopWorlds, {
				PlaceId = tonumber(Entry.key),
				Teleports = Entry.value,
			})
		end
	end
end

function TopWorldsService:_AdvanceToNextPage(Pages: DataStorePages)
	if Pages.IsFinished then
		return false
	else
		local Success, Result = pcall(function()
			return Pages:AdvanceToNextPageAsync()
		end)
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
		local Success, Result = pcall(function()
			return self.TeleportsStore:IncrementAsync(tostring(PlaceId), 1)
		end)
		if not Success then
			warn(Result)
		end

		return Success, Result
	else
		return false
	end
end

function TopWorldsService:KnitStart()
	self._InitializationLoop = self:_SpawnInitializationLoop()

	Players.PlayerAdded:Connect(function(Player)
		local JoinData = Player:GetJoinData()
		if JoinData and JoinData.SourcePlaceId then
			self:_LogIncomingTeleport(JoinData.SourcePlaceId)
		end
	end)
end

function TopWorldsService:KnitInit()
	self.TeleportsStore = DataStoreService:GetOrderedDataStore(DATASTORE_NAME, tostring(math.floor(os.time() / 86400)))
	self.LastWeekTeleportsStore =
		DataStoreService:GetOrderedDataStore(DATASTORE_NAME, tostring(math.floor(os.time() / 86400) - 1))
end

return TopWorldsService
