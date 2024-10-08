local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")

local RoRooms = script.Parent.Parent.Parent.Parent
local Future = require(RoRooms.Parent.Future)
local Signal = require(RoRooms.Parent.Signal)
local t = require(RoRooms.Parent.t)

local REGISTRY_UPDATE_DELAY = 10 * 60
local REGISTRY_ASSET_ID = 16007140043

local WorldRegistryService = {
	Name = "WorldRegistryService",
	Client = {},

	WorldRegistry = {},
	WorldRegistryLastUpdated = 0,

	RegistryUpdated = Signal.new(),
}

function WorldRegistryService.Client:IsWorldRegistered(Player: Player, PlaceId: number)
	assert(t.tuple(t.instanceOf("Player")(Player), t.number(PlaceId)))

	return self.Server:IsWorldRegistered(PlaceId)
end

function WorldRegistryService:IsWorldRegistered(PlaceId: number)
	return self.WorldRegistry[PlaceId] ~= nil
end

function WorldRegistryService:UpdateRegistry()
	Future.Try(function()
		return MarketplaceService:GetProductInfo(REGISTRY_ASSET_ID).Updated
	end):After(function(Success, UpdateStamp)
		if Success then
			if UpdateStamp ~= self.WorldRegistryLastUpdated then
				self:_FetchLatestRegistry():After(function(Success2, Result2)
					if Success2 then
						self.WorldRegistry = Result2
						self.WorldRegistryLastUpdated = UpdateStamp

						self.RegistryUpdated:Fire(Result2)
					else
						warn(Result2)
					end
				end)
			end
		end
	end)
end

function WorldRegistryService:_FetchLatestRegistry()
	return Future.Try(function()
		local WorldsJson =
			HttpService:GetAsync("https://github.com/RoRooms/Worlds/releases/latest/download/worlds.json")

		if typeof(WorldsJson) == "string" then
			local Worlds = HttpService:JSONDecode(WorldsJson)

			if typeof(Worlds) == "table" then
				return Worlds
			else
				warn("Latest world registry version does not decode to JSON. Report this ASAP.")
			end
		else
			warn("Latest world registry version is not a string. Report this ASAP.")

			return {}
		end
	end)
end

function WorldRegistryService:_SpawnRegistryUpdateLoop()
	return task.spawn(function()
		while true do
			self:UpdateRegistry()

			task.wait(REGISTRY_UPDATE_DELAY)
		end
	end)
end

function WorldRegistryService:KnitStart()
	self:_SpawnRegistryUpdateLoop()
end

return WorldRegistryService
