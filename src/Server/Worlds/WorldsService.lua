local TeleportService = game:GetService("TeleportService")

local RoRooms = require(script.Parent.Parent.Parent.Parent)
local WorldRegistryService = require(script.Parent.WorldRegistryService)
local ShuffleArray = require(RoRooms.Shared.ExtPackages.ShuffleArray)
local Knit = require(RoRooms.Packages.Knit)
local t = require(RoRooms.Packages.t)
local GetPagesFromArray = require(RoRooms.Shared.ExtPackages.GetPagesFromArray)

local WorldsService = {
	Name = "WorldsService",
	Client = {
		RandomWorldsInitialized = Knit.CreateSignal(),
	},

	RandomWorlds = {},
}

function WorldsService.Client:GetRandomWorlds(Player: Player, StartingPage: number, PageCount: number, PageSize: number)
	assert(t.tuple(t.instanceOf("Player")(Player), t.number(StartingPage), t.number(PageCount), t.number(PageSize)))

	return GetPagesFromArray(self.Server.RandomWorlds, StartingPage, PageCount, PageSize)
end

function WorldsService.Client:TeleportToWorld(Player: Player, PlaceId: number)
	assert(t.tuple(t.instanceOf("Player")(Player), t.number(PlaceId)))

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

function WorldsService:KnitStart()
	WorldRegistryService.RegistryUpdated:Connect(function(WorldRegistry: { [string]: {} })
		self:_UpdateRandomWorlds(WorldRegistry)
	end)
end

function WorldsService:KnitInit() end

return WorldsService
