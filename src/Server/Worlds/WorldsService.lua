local TeleportService = game:GetService("TeleportService")

local RoRooms = script.Parent.Parent.Parent.Parent
local WorldRegistryService = require(script.Parent.WorldRegistryService)
local t = require(RoRooms.Parent.t)

local WorldsService = {
	Name = script.Name,
	Client = {},
}

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

function WorldsService:KnitStart() end

return WorldsService
