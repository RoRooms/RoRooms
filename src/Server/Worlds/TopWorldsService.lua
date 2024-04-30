local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent.Parent)
local WorldRegistryService = require(RoRooms.Server.Worlds.WorldRegistryService)
local Knit = require(RoRooms.Packages.Knit)
local GetPagesFromArray = require(RoRooms.Shared.ExtPackages.GetPagesFromArray)
local t = require(RoRooms.Packages.t)

local PAGE_ADVANCE_DELAY = math.ceil((60 / 5) * 2)

local TopWorldsService = {
	Name = script.Name,
	Client = {
		TopWorldsInitialized = Knit.CreateSignal(),
	},

	TopWorlds = {},

	_TopWorldsAdvancedLastCheck = true,
	_TopWorldsPages = nil,
}

function TopWorldsService.Client:GetTopWorlds(Player: Player, StartingPage: number, PageCount: number, PageSize: number)
	assert(t.tuple(t.instanceOf("Player")(Player), t.number(StartingPage), t.number(PageCount), t.number(PageSize)))

	return GetPagesFromArray(TopWorldsService.TopWorlds, StartingPage, PageCount, PageSize)
end

function TopWorldsService:_SpawnTopWorldsLoadLoop()
	return task.spawn(function()
		self._TopWorldsPages = self.WorldTeleportsStore:GetSortedAsync(false, 100)

		self:_LoadCurrentTopWorldsPage()
		self:_AdvanceToNextTopWorldsPage()
		self.Client.TopWorldsInitialized:FireAll()

		while task.wait(PAGE_ADVANCE_DELAY) do
			self:_LoadCurrentTopWorldsPage()
			self:_AdvanceToNextTopWorldsPage()
		end
	end)
end

function TopWorldsService:_LoadCurrentTopWorldsPage()
	local CurrentPage = self._TopWorldsPages:GetCurrentPage()

	if self._TopWorldsAdvancedLastCheck then
		for _, Entry in ipairs(CurrentPage) do
			table.insert(self.TopWorlds, { PlaceId = tonumber(Entry.key), Teleports = Entry.value })
		end
	end
end

function TopWorldsService:_AdvanceToNextTopWorldsPage()
	if self._TopWorldsPages.IsFinished then
		self._TopWorldsAdvancedLastCheck = false
	else
		self._TopWorldsPages:AdvanceToNextPageAsync()

		self._TopWorldsAdvancedLastCheck = true
	end
end

function TopWorldsService:_LogWorldTeleport(PlaceId: number)
	if WorldRegistryService:IsWorldRegistered(PlaceId) then
		self.WorldTeleportsStore:IncrementAsync(tostring(PlaceId), 1)
	end
end

function TopWorldsService:KnitStart()
	self:_SpawnTopWorldsLoadLoop()

	Players.PlayerAdded:Connect(function(Player)
		local JoinData = Player:GetJoinData()
		if JoinData and JoinData.SourcePlaceId then
			self:_LogWorldTeleport(JoinData.SourcePlaceId)
		end
	end)
end

function TopWorldsService:KnitInit()
	self.WorldTeleportsStore =
		DataStoreService:GetOrderedDataStore("RR_WorldTeleports", tostring(math.floor(os.time() / 86400)))
	self.PreviousWorldTeleportsStore =
		DataStoreService:GetOrderedDataStore("RR_WorldTeleports", tostring(math.floor(os.time() / 86400) - 1))
end

return TopWorldsService
