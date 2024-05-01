local RoRooms = require(script.Parent.Parent.Parent.Parent)
local WorldRegistryService = require(script.Parent.WorldRegistryService)
local ShuffleArray = require(RoRooms.Shared.ExtPackages.ShuffleArray)
local Knit = require(RoRooms.Packages.Knit)
local t = require(RoRooms.Packages.t)
local GetPagesFromArray = require(RoRooms.Shared.ExtPackages.GetPagesFromArray)

type World = {
	PlaceId: number,
}

local PAGE_SIZE = 3

local RandomWorldsService = {
	Name = script.Name,
	Client = {
		RandomWorldsInitialized = Knit.CreateSignal(),
	},

	RandomWorlds = {},
}

function RandomWorldsService.Client:GetRandomWorlds(
	Player: Player,
	StartingPage: number,
	PageCount: number,
	PageSize: number
)
	assert(t.tuple(t.instanceOf("Player")(Player), t.number(StartingPage), t.number(PageCount), t.number(PageSize)))

	return self.Server:GetRandomWorlds(StartingPage, PageCount, PageSize)
end

function RandomWorldsService:GetRandomWorlds(StartingPage: number, PageCount: number, PageSize: number)
	return GetPagesFromArray(self.RandomWorlds, StartingPage, PageCount, PageSize)
end

function RandomWorldsService:_UpdateRandomWorlds(WorldRegistry: { [number]: World })
	local RandomWorlds = {}

	for PlaceId, _ in pairs(WorldRegistry) do
		table.insert(RandomWorlds, {
			PlaceId = PlaceId,
		})
	end

	self.RandomWorlds = ShuffleArray(RandomWorlds)

	self.Client.RandomWorldsInitialized:FireAll(self:GetRandomWorlds(0, 10, PAGE_SIZE))
end

function RandomWorldsService:KnitStart()
	WorldRegistryService.RegistryUpdated:Connect(function(WorldRegistry: { [number]: World })
		self:_UpdateRandomWorlds(WorldRegistry)
	end)
end

function RandomWorldsService:KnitInit() end

return RandomWorldsService