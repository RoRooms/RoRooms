local Rorooms = script.Parent.Parent.Parent.Parent
local WorldRegistryService = require(script.Parent.WorldRegistryService)
local ShuffleArray = require(Rorooms.SourceCode.Shared.ExtPackages.ShuffleArray)
local Knit = require(Rorooms.Parent.Knit)
local t = require(Rorooms.Parent.t)
local GetEntriesFromArray = require(Rorooms.SourceCode.Shared.ExtPackages.GetEntriesFromArray)

type World = {
	PlaceId: number,
}

local ROW_SIZE = 3

local RandomWorldsService = {
	Name = script.Name,
	Client = {
		RandomWorldsInitialized = Knit.CreateSignal(),
	},

	RandomWorlds = {},
}

function RandomWorldsService.Client:GetRandomWorlds(Player: Player, StartIndex: number, EndIndex: number)
	assert(t.tuple(t.instanceOf("Player")(Player), t.number(StartIndex), t.number(EndIndex)))

	return RandomWorldsService:GetRandomWorlds(StartIndex, EndIndex)
end

function RandomWorldsService:GetRandomWorlds(StartIndex: number, EndIndex: number)
	return GetEntriesFromArray(self.RandomWorlds, StartIndex, EndIndex)
end

function RandomWorldsService:_UpdateRandomWorlds(WorldRegistry: { [number]: World })
	local RandomWorlds = {}

	for PlaceId, _ in pairs(WorldRegistry) do
		table.insert(RandomWorlds, {
			PlaceId = tonumber(PlaceId),
		})
	end

	self.RandomWorlds = ShuffleArray(RandomWorlds)

	self.Client.RandomWorldsInitialized:FireAll(self:GetRandomWorlds(0, 10 * ROW_SIZE))
end

function RandomWorldsService:KnitStart() end

WorldRegistryService.RegistryUpdated:Connect(function(WorldRegistry: { [number]: World })
	RandomWorldsService:_UpdateRandomWorlds(WorldRegistry)
end)

return RandomWorldsService
