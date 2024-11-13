local Rorooms = script.Parent.Parent.Parent.Parent
local WorldRegistryService = require(script.Parent.WorldRegistryService)
local ShuffleArray = require(Rorooms.SourceCode.Shared.ExtPackages.ShuffleArray)
local Knit = require(Rorooms.Parent.Knit)
local t = require(Rorooms.Parent.t)
local GetPagesFromArray = require(Rorooms.SourceCode.Shared.ExtPackages.GetPagesFromArray)

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
	StartingPage: number?,
	PageCount: number,
	PageSize: number
)
	assert(
		t.tuple(
			t.instanceOf("Player")(Player),
			t.number(StartingPage) or t.none(StartingPage),
			t.number(PageCount),
			t.number(PageSize)
		)
	)

	if StartingPage == nil then
		local MaxPages = math.ceil(#self.Server.RandomWorlds / PageSize)
		local NewStartingPage = math.random(0, MaxPages)

		if NewStartingPage == MaxPages then
			NewStartingPage -= 1
		end

		StartingPage = NewStartingPage
	end

	return self.Server:GetRandomWorlds(StartingPage, PageCount, PageSize)
end

function RandomWorldsService:GetRandomWorlds(StartingPage: number, PageCount: number, PageSize: number)
	return GetPagesFromArray(self.RandomWorlds, StartingPage, PageCount, PageSize)
end

function RandomWorldsService:_UpdateRandomWorlds(WorldRegistry: { [number]: World })
	local RandomWorlds = {}

	for PlaceId, _ in pairs(WorldRegistry) do
		table.insert(RandomWorlds, {
			PlaceId = tonumber(PlaceId),
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

return RandomWorldsService
